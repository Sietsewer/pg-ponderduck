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

## Enabling extensions

The image ships the extension files but applies no PostgreSQL configuration. You must wire up `shared_preload_libraries` and run `CREATE EXTENSION` yourself.

**TimescaleDB** and **pg_duckdb** must be added to `shared_preload_libraries` before their extensions can be created — PostgreSQL won't load them on demand:

```
shared_preload_libraries = 'timescaledb,pg_duckdb'
```

**pgvector** and **pgedge-vectorizer** do not require preloading.

After restarting with the updated config:

```sql
CREATE EXTENSION IF NOT EXISTS timescaledb;
CREATE EXTENSION IF NOT EXISTS pg_duckdb;
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS <pgedge_vectorizer_name>;
```

The pgedge-vectorizer SQL name is not fixed upstream. The actual name discovered at build time is written to `/etc/pgedge_vectorizer_name` — read that file rather than hardcoding it.
