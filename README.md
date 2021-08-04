# YugabyteDB example PostgreSQL extension

This is a minimal example of a PostgreSQL extension for [YugabyteDB](https://yugabyte.com). YugabyteDB uses standard PostgreSQL extensions so this extension also works with PostgreSQL.

YugabyteDB extensions documentation: [extensions requiring installation](https://docs.yugabyte.com/latest/api/ysql/extensions/#extensions-requiring-installation)

This example extension is mostly useless and is used [to support the infrastructure from this repository](https://github.com/radekg/yugabytedb-postgres-extensions-build-infrastructure).

All this extension does, is to disallow a regular user (no superuser) from:

- creating a table in the _pg\_public_ tablespace
- set _default\_tablespace_ and _temp\_tablespaces_; thus change them

Work originally inspired by the article from _supabase_:

- [Protecting reserved roles with PostgreSQL Hooks](https://supabase.io/blog/2021/07/01/roles-postgres-hooks)

## PostgreSQL 11.2

YugabyteDB uses PostgreSQL 11.2 internally so this extension tooling uses exactly that version.

## Create the build infrastructure Docker image

```sh
make ext-infra
```

## Build the extension

```sh
make ext-build
```

Optionally:

```sh
make ext-clean
```

## Run PostgreSQL with the extension

```sh
make ext-run-postgres
```

## Run tests: installcheck

```sh
make ext-installcheck
```

This target will run the regression tests using PostgreSQL regression testing framework.

## Compile with YugabyteDB

```sh
mkdir -p /tmp/yugabytedb-compile
cd /tmp/yugabytedb-compile
make ybdb-build-infrastructure
mkdir -p .tmp/extensions/example
cd .tmp/extensions/example
git clone https://github.com/radekg/yugabytedb-example-extension.git .
cd -
make ybdb-build-first-pass
make ybdb-distribution
make ybdb-build-docker
```

Run a container from the resulting Docker image, by default, the command will be:

```sh
docker run --rm -ti \
    -p 7000:7000 \
    -p 5433:5433 \
    local/yugabytedb:2.7.2.0 yugabyted start --daemon=false --ui=false
```

In another terminal:

```sh
docker exec -ti $(docker ps | grep 'local/yugabytedb' | awk '{print $1}') /bin/bash
```

Validate:

```
bash-4.2$ ysqlsh
ysqlsh (11.2-YB-2.7.2.0-b0)
Type "help" for help.
yugabyte=# \dx
                                     List of installed extensions
        Name        | Version |   Schema   |                        Description
--------------------+---------+------------+-----------------------------------------------------------
 pg_stat_statements | 1.6     | pg_catalog | track execution statistics of all SQL statements executed
 plpgsql            | 1.0     | pg_catalog | PL/pgSQL procedural language
(2 rows)
yugabyte=# create extension example;
CREATE EXTENSION
yugabyte=# \dx
                                     List of installed extensions
        Name        | Version |   Schema   |                        Description
--------------------+---------+------------+-----------------------------------------------------------
 example            | 0.1.0   | public     | Example library
 pg_stat_statements | 1.6     | pg_catalog | track execution statistics of all SQL statements executed
 plpgsql            | 1.0     | pg_catalog | PL/pgSQL procedural language
(3 rows)
yugabyte=# \q
exit
```
