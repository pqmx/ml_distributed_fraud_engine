# =============================================================================
# CMakeLists.txt — Real-time fraud detection engine (C++17)
# =============================================================================
# Build system: CMake + Conan for dependency management.
#
# To build (after `conan install` populates the toolchain):
#   cmake -B build -DCMAKE_TOOLCHAIN_FILE=build/conan_toolchain.cmake -DCMAKE_BUILD_TYPE=Release
#   cmake --build build -j$(nproc)
#
# To build with sanitizers (debug builds only):
#   cmake -B build -DCMAKE_BUILD_TYPE=Debug -DENABLE_SANITIZERS=ON ...
#
# FAANG NOTE: Pinning C++17 (not 20) because librdkafka and hiredis headers
# don't always play nicely with C++20 modules, and we want a build that
# works on every major distro's default toolchain.
# =============================================================================

cmake_minimum_required(VERSION 3.20)
project(fraud_detection_engine
    VERSION 0.1.0
    DESCRIPTION "Low-latency fraud detection pipeline"
    LANGUAGES CXX
)

# ---------------------------------------------------------------------------
# Compiler standard & warning hygiene
# ---------------------------------------------------------------------------
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Export compile_commands.json for clangd / IDEs.
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Default to Release if the user hasn't picked a build type.
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

# ---------------------------------------------------------------------------
# Warnings — be strict. We want -Wall -Wextra -Wpedantic on every TU.
# ---------------------------------------------------------------------------
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(
        -Wall -Wextra -Wpedantic
        -Wshadow -Wnon-virtual-dtor
        -Wold-style-cast -Wcast-align
        -Wunused -Woverloaded-virtual
        -Wconversion -Wsign-conversion
        -Wnull-dereference -Wdouble-promotion
    )
endif()

# ---------------------------------------------------------------------------
# Optional sanitizers for debug builds — catches data races, UB, leaks.
# Toggle with -DENABLE_SANITIZERS=ON at configure time.
# ---------------------------------------------------------------------------
option(ENABLE_SANITIZERS "Enable ASan + UBSan in debug builds" OFF)
if(ENABLE_SANITIZERS AND CMAKE_BUILD_TYPE STREQUAL "Debug")
    message(STATUS "Sanitizers enabled (ASan + UBSan)")
    add_compile_options(-fsanitize=address,undefined -fno-omit-frame-pointer)
    add_link_options(-fsanitize=address,undefined)
endif()

# Release builds: optimize aggressively but keep frame pointers for profiling.
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    add_compile_options(-O3 -fno-omit-frame-pointer)
endif()

# ---------------------------------------------------------------------------
# Dependencies (pulled in via Conan — see conanfile.txt)
# ---------------------------------------------------------------------------
find_package(RdKafka REQUIRED)        # librdkafka — Kafka client
find_package(hiredis REQUIRED)        # hiredis    — Redis client
find_package(gRPC REQUIRED)           # grpc       — RPC to Python ML server
find_package(Protobuf REQUIRED)       # protobuf   — message schema
find_package(spdlog REQUIRED)         # spdlog     — structured logging
find_package(nlohmann_json REQUIRED)  # json       — DLQ payload serialization
find_package(prometheus-cpp REQUIRED) # prometheus — metrics exposition
find_package(libpqxx REQUIRED)        # libpqxx    — Postgres client (DLQ log)
find_package(GTest REQUIRED)          # gtest      — unit tests

# ---------------------------------------------------------------------------
# Generate protobuf + gRPC stubs from proto/fraud.proto
# ---------------------------------------------------------------------------
set(PROTO_SRC_DIR  ${CMAKE_SOURCE_DIR}/proto)
set(PROTO_GEN_DIR  ${CMAKE_BINARY_DIR}/generated)
file(MAKE_DIRECTORY ${PROTO_GEN_DIR})

set(FRAUD_PROTO  ${PROTO_SRC_DIR}/fraud.proto)
set(FRAUD_PB_CC  ${PROTO_GEN_DIR}/fraud.pb.cc)
set(FRAUD_PB_H   ${PROTO_GEN_DIR}/fraud.pb.h)
set(FRAUD_GRPC_CC ${PROTO_GEN_DIR}/fraud.grpc.pb.cc)
set(FRAUD_GRPC_H  ${PROTO_GEN_DIR}/fraud.grpc.pb.h)

# Locate the protoc binary and the gRPC C++ plugin (both come from Conan).
get_target_property(PROTOC_EXE protobuf::protoc IMPORTED_LOCATION_RELEASE)
if(NOT PROTOC_EXE)
    get_target_property(PROTOC_EXE protobuf::protoc IMPORTED_LOCATION)
endif()
get_target_property(GRPC_CPP_PLUGIN gRPC::grpc_cpp_plugin IMPORTED_LOCATION_RELEASE)
if(NOT GRPC_CPP_PLUGIN)
    get_target_property(GRPC_CPP_PLUGIN gRPC::grpc_cpp_plugin IMPORTED_LOCATION)
endif()

add_custom_command(
    OUTPUT ${FRAUD_PB_CC} ${FRAUD_PB_H} ${FRAUD_GRPC_CC} ${FRAUD_GRPC_H}
    COMMAND ${PROTOC_EXE}
        --proto_path=${PROTO_SRC_DIR}
        --cpp_out=${PROTO_GEN_DIR}
        --grpc_out=${PROTO_GEN_DIR}
        --plugin=protoc-gen-grpc=${GRPC_CPP_PLUGIN}
        ${FRAUD_PROTO}
    DEPENDS ${FRAUD_PROTO}
    COMMENT "Generating C++ + gRPC stubs from fraud.proto"
    VERBATIM
)

add_library(fraud_proto STATIC
    ${FRAUD_PB_CC}
    ${FRAUD_GRPC_CC}
)
target_include_directories(fraud_proto PUBLIC ${PROTO_GEN_DIR})
target_link_libraries(fraud_proto PUBLIC
    protobuf::libprotobuf
    gRPC::grpc++
)

# ---------------------------------------------------------------------------
# Core library — everything except main(). Lets us link from tests too.
# ---------------------------------------------------------------------------
add_library(fraud_core STATIC
    src/consumer/kafka_consumer.cpp
    src/enrichment/redis_feature_store.cpp
    src/scoring/grpc_ml_client.cpp
    src/scoring/rule_engine.cpp
    src/routing/kafka_producer.cpp
    src/metrics/prometheus_metrics.cpp
    src/utils/thread_pool.cpp
    src/utils/circuit_breaker.cpp
)

target_include_directories(fraud_core PUBLIC
    ${CMAKE_SOURCE_DIR}/src
    ${CMAKE_SOURCE_DIR}/include
)

target_link_libraries(fraud_core PUBLIC
    fraud_proto
    RdKafka::rdkafka
    hiredis::hiredis
    gRPC::grpc++
    protobuf::libprotobuf
    spdlog::spdlog
    nlohmann_json::nlohmann_json
    prometheus-cpp::core
    prometheus-cpp::pull
    libpqxx::pqxx
)

# ---------------------------------------------------------------------------
# Main binary
# ---------------------------------------------------------------------------
add_executable(fraud_detection_engine src/main.cpp)
target_link_libraries(fraud_detection_engine PRIVATE fraud_core)

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------
enable_testing()
add_executable(unit_tests
    tests/test_rule_engine.cpp
    tests/test_circuit_breaker.cpp
    tests/test_thread_pool.cpp
)
target_link_libraries(unit_tests PRIVATE
    fraud_core
    GTest::gtest
    GTest::gtest_main
)
include(GoogleTest)
gtest_discover_tests(unit_tests)

# ---------------------------------------------------------------------------
# Install rules — used by the runtime Docker stage.
# ---------------------------------------------------------------------------
install(TARGETS fraud_detection_engine
    RUNTIME DESTINATION bin
)
