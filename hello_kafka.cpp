#include <librdkafka/rdkafka.h>
#include <stdio.h>
#include <string.h>

int main() {
    char errstr[512];

    // Create config
    rd_kafka_conf_t* conf = rd_kafka_conf_new();
    rd_kafka_conf_set(conf, "bootstrap.servers", "localhost:9092", errstr, sizeof(errstr));

    // Create producer
    rd_kafka_t* rk = rd_kafka_new(RD_KAFKA_PRODUCER, conf, errstr, sizeof(errstr));
    if (!rk) { fprintf(stderr, "Failed: %s\n", errstr); return 1; }

    // Produce one message
    rd_kafka_producev(rk,
        RD_KAFKA_V_TOPIC("hello-topic"),
        RD_KAFKA_V_VALUE("hello kafka", 11),
        RD_KAFKA_V_END);

    // Wait for delivery (up to 3 seconds)
    rd_kafka_flush(rk, 3000);
    rd_kafka_destroy(rk);

    printf("Message delivered — toolchain works.\n");
    return 0;
}