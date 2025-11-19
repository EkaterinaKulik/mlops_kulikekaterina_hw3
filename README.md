# Домашнее задание 3

## Описание проекта

Проект реализуе пайплайн загрузки данных из CSV в Kafka, а затем в ClickHouse с выполнением SQL-запроса и оптимизацией хранения данных

## Архитектура решения

```bash
.
├── docker-compose.yml
├── requirements.txt
├── kafka_producer/
│   └── producer.py
├── clickhouse/
│   ├── init/
│   │   └── 01_create_tables_initial.sql
│   └── queries/
│       └── 03_max_category_by_state.sql
├── scripts/
│   └── export_max_category_by_state.sh
└── data/
    └── train.csv 
```

## Быстрый старт

### Требования

- Docker 20.10+
- Docker Compose 1.29+ или Compose V2
- 2 ГБ свободного места
- CPU-инференс, GPU не требуется

### Запуск сервиса

1. Скачайте файл test.csv из соревнования https://www.kaggle.com/competitions/teta-ml-1-2025 и разместите в директории ./data/train.csv.
2. Запустите Docker-окружение
```bash
docker compose up -d
```
3. Запустите продюссер
```bash
docker compose run --rm app python kafka_producer/producer.py
```
4. Проверьте, что данные появились в ClickHouse
```bash
docker compose exec clickhouse clickhouse-client -u click --password click \
  -q "SELECT count() FROM transactions_raw"
```
5. Выполните SQL-запрос
```bash
./scripts/export_max_category_by_state.sh
```
6. После выполнения сервис автоматически:
- читает данные из ClickHouse (transactions_raw);
- рассчитывает категорию с максимальной транзакцией для каждого штата;
- сохраняет результат в CSV.
