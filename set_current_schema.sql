rem hide verify - if called before package.sql
set verify off
define l_current_schema = &1

rem show termout - we want to see possible error (like SP2-0640: Not connected)
set termout on
alter session set current_schema = &&l_current_schema;

rem init g_current_schema with _USER substitution variable - if not connected then it will be ""
define g_current_schema = "&&_USER"
rem get current_schema from userenv context
column current_schema new_value g_current_schema
set termout off
select sys_context('userenv','current_schema') as current_schema from dual;
set termout on

rem feedback with current_schema setting
prompt Current schema changed to "&&g_current_schema"

rem undefine locals
undefine l_current_schema