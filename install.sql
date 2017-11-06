rem
rem install package
rem
rem Usage
rem     SQL > @install.sql <privileges> <environment>
rem
rem Options
rem
rem     privileges - public - installs package and grants API to public
rem                - peer   - installs package and grants API to peers - use whitelist grants
rem
rem     environment   - development - more privileges required for development
rem                   - production  - production ready
rem
set verify off
define l_privileges  = "&1"
define l_environment = "&2"

undefine 1
undefine 2

rem Load package
@package.sql

rem init SQL*Plus settings
@sqlplus_init.sql

prompt Installing API specification
@module/api/package/plparse.pks

prompt Installing package Implementation
@module/implementation/install.sql

prompt Installing package API
@module/api/install.sql

prompt Installing package tests
@test/install_&&l_environment..sql

prompt Granting privileges on package API
@module/api/grant_&&l_privileges..sql

rem finalize SQL*Plus
@@sqlplus_finalize.sql

rem undefine locals
undefine l_privileges

rem undefine package globals
@undefine_globals.sql
