#!/bin/bash

set -e

# Create Moodle database
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE moodle;
    GRANT ALL PRIVILEGES ON DATABASE moodle TO $POSTGRES_USER;
EOSQL
