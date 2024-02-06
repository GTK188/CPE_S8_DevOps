FROM postgres:14.1-alpine

ENV POSTGRES_DB=db \
   POSTGRES_USER=usr \
   POSTGRES_PASSWORD=pwd

COPY createScheme.sql /docker-entrypoint-initdb.d
COPY insertData.sql /docker-entrypoint-initdb.d
