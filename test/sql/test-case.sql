-- tenant1 is not a superuser:
set role some_user;
\echo

-- creating tables in pg_public is not allowed
create table test (
    rowval varchar(100)
) tablespace pg_default;
\echo

-- set default_tablespace to pg_public disallowed
set default_tablespace = 'pg_public';
\echo

-- set temp_tablespaces to pg_public disallowed
set temp_tablespaces = 'pg_public';
\echo