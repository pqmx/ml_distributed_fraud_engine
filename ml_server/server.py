"""
ml_server/server.py — Python ML scoring server.

Two surfaces:
  - gRPC on :50051 — the hot path. C++ engine calls Score() per transaction.
  - HTTP on :8000  — health checks, model metadata, debug endpoints.

Why both? gRPC is great for the C++ ↔ Python boundary (typed, fast, binary)
but mediocre for ops poking around. A tiny FastAPI sidecar gives us
`curl /health` for compose healthchecks and `curl /info` for "what model
version is currently deployed?" without bringing in grpcurl.

Design notes:
  - The server is stateless. Features arrive in the request, model is loaded
    once at startup. No per-request DB hits.
  - We do NOT batch on the server side. Per-call inference (~1-3ms with
    XGBoost on a single tree) is fast enough that batching would add
    queueing latency without saving meaningful CPU.
  - Concurrency: gRPC's ThreadPoolExecutor handles request fan-out. Default
    of 10 workers is plenty since each call is short.
"""

from __future__ import annotations

import logging
import os
import threading
import time
from concurrent import futures

import fastapi
import grpc
import joblib
import numpy as np
import uvicorn

# Generated stubs (produced by `python -m grpc_tools.protoc ...` at build time)
import fraud_pb2
import fraud_pb2_grpc

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] ml-server: %(message)s",
)
log = logging.getLogger(__name__)

MODEL_PATH = os.environ.get("MODEL_PATH", "/app/model/xgb_model.joblib")
GRPC_PORT  = int(os.environ.get("GRPC_PORT", "50051"))
HTTP_PORT  = int(os.environ.get("HTTP_PORT", "8000"))
MODEL_VERSION = os.environ.get("MODEL_VERSION", "xgb-v1")


# =============================================================================
# Model loading
# =============================================================================
class ModelHolder:
    """
    Wraps the XGBoost classifier. Loaded once at startup. If the file is
    missing we fall back to a tiny "always-low-risk" stub so the C++ engine
    can still smoke-test the gRPC boundary without a trained model on disk.
    """

    def __init__(self, path: str) -> None:
        self.path = path
        self.model = None
        self._load()

    def _load(self) -> None:
        if not os.path.exists(self.path):
            log.warning(
                "Model file not found at %s — using stub scorer. "
                "Run scripts/train_model.py to produce a real model.",
                self.path,
            )
            self.model = None
            return
        log.info("Loading model from %s", self.path)
        self.model = joblib.load(self.path)
        log.info("Model loaded: %s", type(self.model).__name__)

    def predict_proba(self, features: np.ndarray) -> float:
        if self.model is None:
            # Stub: low-risk by default, with a small bump for very large amounts.
            # Keeps the C++ engine smoke-testable end-to-end without a trained model.
            return 0.05
        proba = self.model.predict_proba(features.reshape(1, -1))[0]
        # Class 1 == fraud; column 1 of predict_proba is P(fraud).
        return float(proba[1])


model_holder = ModelHolder(MODEL_PATH)


# =============================================================================
# Feature engineering — must match the training script's column order EXACTLY.
# Drift here is the most insidious bug class in ML serving. Single source of
# truth lives in scripts/train_model.py — keep them in sync.
# =============================================================================
def build_feature_vector(req: fraud_pb2.ScoreRequest) -> np.ndarray:
    tx = req.transaction
    f  = req.features

    # Order must match training. See scripts/train_model.py.
    return np.array([
        float(tx.amount),
        float(f.tx_count_30d),
        float(f.avg_amount_30d),
        # Number of distinct countries seen in last 30d (proxy for travel risk).
        float(len(f.countries_30d.split(",")) if f.countries_30d else 0),
        float(f.risk_score),
        # Time since last transaction (seconds). Very recent → higher risk.
        max(0.0, (tx.timestamp_ms - f.last_tx_ts_ms) / 1000.0),
        # Cache miss flag: zero-history users get a small uplift in risk
        # (we know nothing about them, model can learn that signal).
        1.0 if f.is_cache_miss else 0.0,
    ], dtype=np.float32)


# =============================================================================
# gRPC service
# =============================================================================
class FraudServicer(fraud_pb2_grpc.FraudServiceServicer):
    def Score(
        self,
        request: fraud_pb2.ScoreRequest,
        context: grpc.ServicerContext,
    ) -> fraud_pb2.ScoreResponse:
        t0 = time.perf_counter_ns()
        try:
            x = build_feature_vector(request)
            p = model_holder.predict_proba(x)
        except Exception as e:
            log.exception("scoring failed: %s", e)
            context.abort(grpc.StatusCode.INTERNAL, f"scoring error: {e}")
            return fraud_pb2.ScoreResponse()  # unreachable, satisfies type checker

        elapsed_us = (time.perf_counter_ns() - t0) // 1000
        return fraud_pb2.ScoreResponse(
            fraud_probability=p,
            model_version=MODEL_VERSION,
            inference_us=elapsed_us,
        )


# =============================================================================
# HTTP health/debug surface
# =============================================================================
http_app = fastapi.FastAPI(title="fraud ml-server")


@http_app.get("/health")
def health() -> dict:
    return {"status": "ok", "model_loaded": model_holder.model is not None}


@http_app.get("/info")
def info() -> dict:
    return {
        "model_version": MODEL_VERSION,
        "model_path":    MODEL_PATH,
        "model_loaded":  model_holder.model is not None,
        "grpc_port":     GRPC_PORT,
    }


# =============================================================================
# Entrypoint — run gRPC + HTTP servers in parallel, block on the gRPC one.
# =============================================================================
def serve_grpc() -> grpc.Server:
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=16))
    fraud_pb2_grpc.add_FraudServiceServicer_to_server(FraudServicer(), server)
    server.add_insecure_port(f"[::]:{GRPC_PORT}")
    server.start()
    log.info("gRPC server listening on :%d", GRPC_PORT)
    return server


def serve_http() -> None:
    uvicorn.run(http_app, host="0.0.0.0", port=HTTP_PORT, log_level="info")


def main() -> None:
    grpc_server = serve_grpc()

    # HTTP server runs on a daemon thread; gRPC server.wait_for_termination
    # blocks the main thread, which is what we want — that's the hot-path
    # surface, and SIGTERM kills the process via tini.
    http_thread = threading.Thread(target=serve_http, daemon=True)
    http_thread.start()

    try:
        grpc_server.wait_for_termination()
    except KeyboardInterrupt:
        log.info("interrupted, stopping gRPC server")
        grpc_server.stop(grace=5)


if __name__ == "__main__":
    main()
