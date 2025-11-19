CREATE DATABASE IF NOT EXISTS default;

CREATE TABLE IF NOT EXISTS kafka_transactions
(
    transaction_time   DateTime,
    merch              String,
    cat_id             UInt32,
    amount             Float64,
    name_1             String,
    name_2             String,
    gender             String,
    street             String,
    one_city           String,
    us_state           String,
    post_code          String,
    lat                Float64,
    lon                Float64,
    population_city    UInt32,
    jobs               String,
    merchant_lat       Float64,
    merchant_lon       Float64,
    target             UInt8
)
ENGINE = Kafka
SETTINGS
    kafka_broker_list   = 'kafka:29092',
    kafka_topic_list    = 'transactions_topic',
    kafka_group_name    = 'clickhouse_consumer_group',
    kafka_format        = 'JSONEachRow',
    kafka_row_delimiter = '\n',
    kafka_num_consumers = 1;

CREATE TABLE IF NOT EXISTS transactions_raw
(
    transaction_time   DateTime,
    merch              LowCardinality(String),
    cat_id             UInt32,
    amount             Float64,
    name_1             LowCardinality(String),
    name_2             LowCardinality(String),
    gender             LowCardinality(String),
    street             String,
    one_city           LowCardinality(String),
    us_state           LowCardinality(String),
    post_code          String,
    lat                Float64,
    lon                Float64,
    population_city    UInt32,
    jobs               LowCardinality(String),
    merchant_lat       Float64,
    merchant_lon       Float64,
    target             UInt8
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(transaction_time)
ORDER BY (us_state, cat_id, transaction_time, merch)
SETTINGS
    index_granularity = 8192;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_kafka_to_transactions_raw
TO transactions_raw
AS
SELECT
    transaction_time,
    merch,
    cat_id,
    amount,
    name_1,
    name_2,
    gender,
    street,
    one_city,
    us_state,
    post_code,
    lat,
    lon,
    population_city,
    jobs,
    merchant_lat,
    merchant_lon,
    target
FROM kafka_transactions;
