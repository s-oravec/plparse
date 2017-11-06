rem
rem grant privileges to either package or deployer schema
rem
rem Usage
rem     SQL > @grant.sql <packageSchema>
rem
rem Options
rem
rem     packageSchema - grant privileges to packageSchema before installing package
rem
rem     environment   - development - more privileges required for development
rem                   - production  - production ready
rem
set verify off
define l_schema_name = "&1"
define l_environment = "&2"

undefine 1
undefine 2

rem init SQL*Plus settings
@sqlplus_init.sql

rem Load package
@@package.sql

prompt Grant grants
@module/dba/grant_schema_&&l_environment..sql &&l_schema_name

rem finalize SQL*Plus
@@sqlplus_finalize.sql

rem undefine locals
undefine l_schema_name
undefine l_environment

rem undefine package globals
@@undefine_globals.sql
