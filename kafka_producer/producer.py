import os
import json
import sys
from typing import List

import pandas as pd
from kafka import KafkaProducer


def get_bootstrap_servers(env_value: str) -> List[str]:
    return [s.strip() for s in env_value.split(",") if s.strip()]


def main() -> None:
    kafka_bootstrap = os.getenv("KAFKA_BOOTSTRAP_SERVERS", "localhost:9092")
    kafka_topic = os.getenv("KAFKA_TOPIC", "transactions_topic")
    csv_path = os.getenv("CSV_PATH", "data/train.csv")

    if not os.path.exists(csv_path):
        print(f"[ERROR] CSV file not found: {csv_path}", file=sys.stderr)
        sys.exit(1)

    bootstrap_servers = get_bootstrap_servers(kafka_bootstrap)

    print(f"[INFO] Using Kafka bootstrap servers: {bootstrap_servers}")
    print(f"[INFO] Using Kafka topic: {kafka_topic}")
    print(f"[INFO] Reading CSV from: {csv_path}")

    producer = KafkaProducer(
        bootstrap_servers=bootstrap_servers,
        value_serializer=lambda v: json.dumps(v).encode("utf-8"),
        acks="all",
        linger_ms=5,
        retries=3,
    )

    rows_sent = 0
    chunk_size = 1000

    try:
        for chunk_idx, chunk in enumerate(
            pd.read_csv(csv_path, chunksize=chunk_size)
        ):
            print(f"[INFO] Processing chunk #{chunk_idx}, rows: {len(chunk)}")

            for _, row in chunk.iterrows():
                message_dict = row.to_dict()
                producer.send(kafka_topic, value=message_dict)
                rows_sent += 1

            producer.flush()
            print(f"[INFO] Sent {rows_sent} messages so far")

        print(f"[INFO] Finished. Total messages sent: {rows_sent}")

    except Exception as e:
        print(f"[ERROR] Error while sending messages to Kafka: {e}", file=sys.stderr)
        sys.exit(1)

    finally:
        producer.close()
        print("[INFO] Kafka producer closed")


if __name__ == "__main__":
    main()
