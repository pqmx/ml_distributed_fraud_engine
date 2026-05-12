message(STATUS "Conan: Using CMakeDeps conandeps_legacy.cmake aggregator via include()")
message(STATUS "Conan: It is recommended to use explicit find_package() per dependency instead")

find_package(RdKafka)
find_package(hiredis)
find_package(gRPC)
find_package(protobuf)
find_package(spdlog)
find_package(nlohmann_json)
find_package(prometheus-cpp)
find_package(libpqxx)
find_package(GTest)

set(CONANDEPS_LEGACY  RdKafka::rdkafka++  hiredis::hiredis  grpc::grpc  protobuf::protobuf  spdlog::spdlog  nlohmann_json::nlohmann_json  prometheus-cpp::prometheus-cpp  libpqxx::pqxx  gtest::gtest )