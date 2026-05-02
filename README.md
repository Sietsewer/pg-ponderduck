# pg-ponderduck

PostgreSQL 18 base image with TimescaleDB 2, pg_duckdb, and pgedge-vectorizer compiled from source.

Published to `ghcr.io/sietsewer/pg-ponderduck`.

## Contents

| Component | Version | License |
|---|---|---|
| [PostgreSQL](https://www.postgresql.org/) | 18 | [PostgreSQL License](https://www.postgresql.org/about/licence/) |
| [TimescaleDB](https://github.com/timescale/timescaledb) | 2.x | [Timescale License (TSL)](https://github.com/timescale/timescaledb/blob/main/tsl/LICENSE-TIMESCALE) |
| [pg_duckdb](https://github.com/duckdb/pg_duckdb) | 1.1.1 | [MIT](https://github.com/duckdb/pg_duckdb/blob/main/LICENSE) |
| [DuckDB](https://github.com/duckdb/duckdb) (bundled by pg_duckdb) | 1.1.1 | [MIT](https://github.com/duckdb/duckdb/blob/main/LICENSE) |
| [pgvector](https://github.com/pgvector/pgvector) | latest PGDG | [PostgreSQL License](https://github.com/pgvector/pgvector/blob/master/LICENSE) |
| [pgedge-vectorizer](https://github.com/pgEdge/pgedge-vectorizer) | main | [Apache 2.0](https://github.com/pgEdge/pgedge-vectorizer/blob/main/LICENSE) |

**Note on TimescaleDB:** The TSL permits unrestricted use for internal and development purposes. It restricts offering TimescaleDB as a managed database service to third parties. See the [license](https://github.com/timescale/timescaledb/blob/main/tsl/LICENSE-TIMESCALE) for full terms.
