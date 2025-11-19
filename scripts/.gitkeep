#!/usr/bin/env bash
set -e

docker compose exec clickhouse clickhouse-client \
  -u click --password click \
  --query="$(< clickhouse/queries/03_max_category_by_state.sql)" \
  --format=CSVWithNames > data/max_category_by_state.csv
