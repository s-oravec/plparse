define l_schema_name = &1
undefine 1

prompt .. Granting privileges to package &&g_package_name in schema &&l_schema_name

prompt .. Granting CREATE PROCEDURE to &&l_schema_name
grant create procedure to &&l_schema_name;

prompt .. Granting CREATE TYPE to &&l_schema_name
grant create type to &&l_schema_name;

prompt .. Granting CREATE SYNONYM to &&l_schema_name
grant create synonym to &&l_schema_name;

rem .. required by pete package
prompt .. Granting CREATE SEQUENCE to &&l_schema_name
grant create sequence to &&l_schema_name;

rem .. required by pete package
prompt .. Granting CREATE TABLE to &&l_schema_name
grant create table to &&l_schema_name;

rem .. required by pete package
prompt .. Granting CREATE VIEW to &&l_schema_name
grant create view to &&l_schema_name;

rem .. required for debugging
prompt .. Granting CREATE SESSION to &&l_schema_name
grant create session to &&l_schema_name;

rem .. required for debugging
prompt .. Granting DEBUG CONNECT SESSION to &&l_schema_name
grant debug connect session to &&l_schema_name;

undefine l_schema_name
