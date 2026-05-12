# =============================================================================
# Dockerfile — Real-time fraud detection engine (C++ service)
# =============================================================================
# Multi-stage build:
#   1. builder  → installs toolchain + Conan, compiles C++ binary
#   2. runtime  → minimal image with only the binary + shared libs needed
#
# FAANG NOTE: keep the runtime image small (<150MB). A bloated image
# means slower deploys, slower autoscaling, and a wider attack surface.
# =============================================================================

# -----------------------------------------------------------------------------
# Stage 1: builder
# -----------------------------------------------------------------------------
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV CONAN_HOME=/opt/conan

# Toolchain. We need a recent CMake (>=3.20) and gcc-11+ for full C++17.
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        ninja-build \
        git \
        pkg-config \
        python3 \
        python3-pip \
        ca-certificates \
        curl \
    && rm -rf /var/lib/apt/lists/*

# Conan 2.x for dependency management (matches conanfile.txt syntax above).
RUN pip3 install --no-cache-dir "conan>=2.0,<3.0"
RUN conan profile detect --force

WORKDIR /src

# Copy only what's needed to resolve deps first — this layer caches
# until conanfile.txt actually changes, which is rare.
COPY conanfile.txt ./
RUN conan install . \
        --output-folder=build \
        --build=missing \
        -s build_type=Release \
        -s compiler.cppstd=17

# Now copy source. Changes here invalidate only the build, not the deps.
COPY CMakeLists.txt ./
COPY proto/      ./proto/
COPY src/        ./src/
COPY include/    ./include/
COPY tests/      ./tests/

RUN cmake -B build \
        -G Ninja \
        -DCMAKE_TOOLCHAIN_FILE=build/conan_toolchain.cmake \
        -DCMAKE_BUILD_TYPE=Release \
    && cmake --build build --parallel \
    && cmake --install build --prefix /opt/fraud

# -----------------------------------------------------------------------------
# Stage 2: runtime — minimal image. Only ship the binary + needed .so's.
# -----------------------------------------------------------------------------
FROM ubuntu:22.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive

# Runtime libs we statically didn't link (libstdc++, libgcc, ssl/crypto for grpc).
RUN apt-get update && apt-get install -y --no-install-recommends \
        libstdc++6 \
        libssl3 \
        ca-certificates \
        tini \
    && rm -rf /var/lib/apt/lists/*

# Run as non-root.
RUN groupadd --system fraud && useradd --system --gid fraud --no-create-home fraud

COPY --from=builder /opt/fraud/bin/fraud_detection_engine /usr/local/bin/

USER fraud

# Prometheus metrics endpoint.
EXPOSE 9090

# tini reaps zombie processes and forwards signals correctly. Critical for
# our graceful-shutdown semantics: SIGTERM must reach the C++ process
# unmolested or we'll lose in-flight messages on `docker stop`.
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/fraud_detection_engine"]
