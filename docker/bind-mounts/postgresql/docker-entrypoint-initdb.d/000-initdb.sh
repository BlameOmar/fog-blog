#!/bin/bash

set -e

database="${FOG_BLOG_POSTGRESQL_DATABASE:-app}"
app_user="${FOG_BLOG_POSTGRESQL_APP_USER:-app}"
liquibase_user="${FOG_BLOG_POSTGRESQL_LIQUIBASE_USER:-liquibase}"

echo Getting app user password
app_user_password=$(cat "$FOG_BLOG_POSTGRESQL_APP_USER_PASSWORD_FILE")
echo Getting liquibase_user password
liquibase_user_password=$(cat "$FOG_BLOG_POSTGRESQL_LIQUIBASE_USER_PASSWORD_FILE")
echo Getting superuser password
superuser_password=$(cat "$FOG_BLOG_POSTGRESQL_SUPERUSER_PASSWORD_FILE")

export PGPASSWORD=$superuser_password

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE ROLE liquibase_usage;
    CREATE ROLE liquibase_read IN ROLE liquibase_usage;
    CREATE ROLE liquibase_write IN ROLE liquibase_usage;
    CREATE ROLE liquibase_admin IN ROLE liquibase_usage;
    CREATE ROLE liquibase_read_write IN ROLE liquibase_read, liquibase_write;

    CREATE ROLE user_usage;
    CREATE ROLE user_read IN ROLE user_usage;
    CREATE ROLE user_write IN ROLE user_usage;
    CREATE ROLE user_admin IN ROLE user_usage;
    CREATE ROLE user_read_write IN ROLE user_read, user_write;

    CREATE ROLE blog_usage;
    CREATE ROLE blog_read IN ROLE blog_usage;
    CREATE ROLE blog_write IN ROLE blog_usage;
    CREATE ROLE blog_admin IN ROLE blog_usage;
    CREATE ROLE blog_read_write IN ROLE blog_read, blog_write;

    CREATE USER $app_user WITH PASSWORD '$app_user_password' IN ROLE user_read_write, blog_read_write;
    CREATE USER $liquibase_user WITH PASSWORD '$liquibase_user_password' IN ROLE liquibase_admin, liquibase_read_write, user_admin, blog_admin;

    \connect template1

    CREATE EXTENSION citext;

    CREATE DATABASE $database;

    \connect $database

    CREATE SCHEMA liquibase;
    CREATE SCHEMA "user";
    CREATE SCHEMA blog;

    GRANT USAGE ON SCHEMA liquibase TO liquibase_usage;
    GRANT CREATE ON SCHEMA liquibase TO liquibase_admin;
    ALTER DEFAULT PRIVILEGES FOR ROLE $liquibase_user IN SCHEMA liquibase GRANT SELECT ON TABLES TO liquibase_read;
    ALTER DEFAULT PRIVILEGES FOR ROLE $liquibase_user IN SCHEMA liquibase GRANT INSERT, UPDATE, DELETE ON TABLES TO liquibase_write;
    ALTER DEFAULT PRIVILEGES FOR ROLE $liquibase_user IN SCHEMA liquibase GRANT TRUNCATE, REFERENCES, TRIGGER ON TABLES TO liquibase_admin;

    GRANT USAGE ON SCHEMA "user" TO user_usage;
    GRANT CREATE ON SCHEMA "user" TO user_admin;
    ALTER DEFAULT PRIVILEGES FOR ROLE $liquibase_user IN SCHEMA "user" GRANT SELECT ON TABLES TO user_read;
    ALTER DEFAULT PRIVILEGES FOR ROLE $liquibase_user IN SCHEMA "user" GRANT INSERT, UPDATE, DELETE ON TABLES TO user_write;
    ALTER DEFAULT PRIVILEGES FOR ROLE $liquibase_user IN SCHEMA "user" GRANT TRUNCATE, REFERENCES, TRIGGER ON TABLES TO user_admin;

    GRANT USAGE ON SCHEMA blog TO blog_usage;
    GRANT CREATE ON SCHEMA blog TO blog_admin;
    ALTER DEFAULT PRIVILEGES FOR ROLE $liquibase_user IN SCHEMA blog GRANT SELECT ON TABLES TO blog_read;
    ALTER DEFAULT PRIVILEGES FOR ROLE $liquibase_user IN SCHEMA blog GRANT INSERT, UPDATE, DELETE ON TABLES TO blog_write;
    ALTER DEFAULT PRIVILEGES FOR ROLE $liquibase_user IN SCHEMA blog GRANT TRUNCATE, REFERENCES, TRIGGER ON TABLES TO blog_admin;
EOSQL
