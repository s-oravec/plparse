prompt
prompt SQL*Plus Run Configuration
prompt .. Ensuring that SQL*Plus ErrorLog table exists

set errorlogging off
set feedback off

create table &&_user..sqlplus_log (
    username   varchar(256),
    timestamp  timestamp,
    script     varchar(1024),
    identifier varchar(256),
    message    clob,
    statement  clob
);

grant select on &&_user..sqlplus_log to public;

column g_run_identifier new_value g_run_identifier
set termout off
select rawtohex(sys_guid()) as g_run_identifier from dual;
set termout on

prompt .. Setting SQL*Plus ErrorLog table with identifier = &&g_run_identifier
set errorlogging on table &&_user..sqlplus_log identifier &&g_run_identifier

prompt done
prompt
