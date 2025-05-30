-- db/init/01-create-test-db.sql

-- plain SQL: run once on first init
CREATE DATABASE "benradler-test"
  WITH OWNER = postgres
       ENCODING = 'UTF8'
       LC_COLLATE = 'en_US.utf8'
       LC_CTYPE   = 'en_US.utf8'
       TEMPLATE = template0;