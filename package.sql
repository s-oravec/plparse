rem default SQL*Plus settings
set serveroutput on size unlimited format wrapped
set trimspool on
set verify   off
set define   on
set lines    4000
set feedback off

rem Package name
define g_package_name="PLPARSE"

rem SQL name compatible version string
define g_sql_version = "000100"

rem full semver version string
define g_semver_version = "0.1.0"

rem get current schema
define g_current_schema = "&&_USER"
column current_schema new_value g_current_schema
set termout off
select sys_context('userenv','current_schema') as current_schema from dual;
set termout on

rem schema name
define g_schema_name  = &&g_package_name._&&g_sql_version
define g_schema_pwd   = &&g_schema_name
define g_schema_tbspc = "USERS"
define g_temp_tbspc   = "TEMP"

rem prompt config
prompt
prompt Loaded package
prompt .. package name      = "&&g_package_name"
prompt .. sql version       = "&&g_sql_version"
prompt .. semver version    = "&&g_semver_version"
prompt .. current user      = "&&_USER"
prompt .. current schema    = "&&g_current_schema"
prompt .. default schema    = "&&g_schema_name"
prompt .. schema password   = "********"
prompt .. schema tablespace = "&&g_schema_tbspc"
prompt .. temp tablespace   = "&&g_temp_tbspc"
prompt
