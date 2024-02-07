FROM postgres:14.1-alpine

COPY createScheme.sql /docker-entrypoint-initdb.d
COPY insertData.sql /docker-entrypoint-initdb.d
