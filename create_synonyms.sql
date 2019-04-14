rem
rem Creates synonyms for your public API (packages, views, ...) in user which is using your package
rem
rem Usage
rem     SQL > @create_synonyms.sql <schema name>
rem
rem Options
rem
rem     schema name - whre your package is installed with public API
rem
set verify off
define l_schema_name = "&1"

rem Load package
@@package.sql

prompt Creating synonyms in &&g_current_schema schema for API objects &&g_package_name package installed in &&l_schema_name schema
@module/api/create_synonyms.sql

rem undefine locals
undefine l_schema_name

rem undefine package globals
@@undefine_globals.sql
