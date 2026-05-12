# =============================================================================
# ml_server/Dockerfile — Python ML scoring server
# =============================================================================
# IMPORTANT: this Dockerfile expects the build context to be the project root,
# not ml_server/. See docker-compose.yml — we set context: . and
# dockerfile: ml_server/Dockerfile. That way we can COPY the .proto from
# ../proto/ without playing context-juggling games.
# =============================================================================

FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

# System packages: curl for healthcheck, build-essential for any wheels that
# fall back to compiling from source.
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        build-essential \
    && rm -rf /var/lib/apt/lists/*

# Deps first (cache layer) — invalidates only when requirements.txt changes.
COPY ml_server/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Generate gRPC stubs from the shared schema. The .proto is the single source
# of truth between C++ engine and Python server. Generating at build time
# guarantees the stubs are always in sync with the deployed contract.
COPY proto/fraud.proto /app/proto/fraud.proto
RUN python -m grpc_tools.protoc \
        --proto_path=/app/proto \
        --python_out=/app \
        --grpc_python_out=/app \
        /app/proto/fraud.proto

# App code + saved model artifacts.
COPY ml_server/server.py ./
COPY ml_server/model/    ./model/

# Run as non-root.
RUN groupadd --system ml && useradd --system --gid ml --no-create-home ml \
    && chown -R ml:ml /app
USER ml

EXPOSE 50051 8000

CMD ["python", "server.py"]
