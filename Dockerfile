FROM postgres:18-bookworm AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        ninja-build \
        git \
        ca-certificates \
        pkg-config \
        libreadline-dev \
        zlib1g-dev \
        libssl-dev \
        libxml2-dev \
        libxslt-dev \
        libcurl4-openssl-dev \
        libc++-dev \
        liblz4-dev \
        postgresql-server-dev-18 \
    && rm -rf /var/lib/apt/lists/*

# pg_duckdb — bundles DuckDB via git submodule; heaviest layer (~10–20 min, several GB peak RAM).
ARG PG_DUCKDB_REF=v1.1.1
RUN git clone --depth 1 --branch "${PG_DUCKDB_REF}" --recurse-submodules \
        https://github.com/duckdb/pg_duckdb.git /tmp/pg_duckdb \
    && cd /tmp/pg_duckdb \
    && make -j"$(nproc)" \
    && make install DESTDIR=/build-output \
    && rm -rf /tmp/pg_duckdb

# pgedge-vectorizer — SQL extension name is discovered at build time by scanning .control files
# and written to /build-output/pgedge_vectorizer_name.txt for downstream consumers.
ARG PGEDGE_VECTORIZER_REF=main
RUN git clone --depth 1 --branch "${PGEDGE_VECTORIZER_REF}" \
        https://github.com/pgEdge/pgedge-vectorizer.git /tmp/pgedge-vectorizer \
    && cd /tmp/pgedge-vectorizer \
    && make \
    && make install DESTDIR=/build-output \
    && find /build-output -name '*.control' -path '*/extension/*' \
        -exec basename {} .control \; \
        | grep -i 'vectoriz' \
        | head -1 > /build-output/pgedge_vectorizer_name.txt \
    && test -s /build-output/pgedge_vectorizer_name.txt \
        || { echo "FATAL: pgedge-vectorizer extension name not detected" >&2; exit 1; } \
    && rm -rf /tmp/pgedge-vectorizer


FROM postgres:18-bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg lsb-release \
    && curl -fsSL https://packagecloud.io/timescale/timescaledb/gpgkey \
        | gpg --dearmor -o /usr/share/keyrings/timescaledb.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/timescaledb.gpg] \
        https://packagecloud.io/timescale/timescaledb/debian/ \
        $(lsb_release -cs) main" \
        > /etc/apt/sources.list.d/timescaledb.list \
    && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc \
        | gpg --dearmor -o /usr/share/keyrings/pgdg.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/pgdg.gpg] \
        https://apt.postgresql.org/pub/repos/apt/ \
        $(lsb_release -cs)-pgdg main" \
        > /etc/apt/sources.list.d/pgdg.list \
    && apt-get update && apt-get install -y --no-install-recommends \
        timescaledb-2-postgresql-18 \
        timescaledb-tools \
        postgresql-18-pgvector \
    && apt-get purge -y curl gnupg lsb-release \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build-output/usr/lib/postgresql/18/lib/ \
                    /usr/lib/postgresql/18/lib/
COPY --from=builder /build-output/usr/share/postgresql/18/extension/ \
                    /usr/share/postgresql/18/extension/
COPY --from=builder /build-output/pgedge_vectorizer_name.txt \
                    /etc/pgedge_vectorizer_name
