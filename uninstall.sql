rem
rem uninstall package
rem
rem Usage
rem     SQL > @uninstall.sql <privileges> <environment>
rem
rem Options
rem
rem     environment   - development - more privileges required for development
rem                   - production  - production ready
rem
set verify off
define l_environment = "&1"

undefine 1

rem Load package
@@package.sql

rem init SQL*Plus settings
@sqlplus_init.sql

prompt Uninstall package Implementation
@module/implementation/uninstall.sql

prompt Uninstall package API
@module/api/uninstall.sql

prompt Unistalling package tests
@test/uninstall_&&l_environment..sql

rem finalize SQL*Plus
@@sqlplus_finalize.sql

rem undefine package globals
@@undefine_globals.sql
