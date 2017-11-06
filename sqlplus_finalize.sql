prompt
prompt SQL*Plus finalize
prompt .. Errors in &&g_current_schema schema

set lines 200
column location format a40
column text     format a60 word_wrapped

set feedback off

select owner || '.' || name as location, line, text as error
  from all_errors
 where owner = upper('&&g_current_schema')
 order by 1, sequence, line, position
;

prompt .. Errors in script with identifier = &&g_run_identifier

column username format a30
column script   format a30
column message  format a80 word_wrapped

select username, script, cast(message as varchar2(4000)) as message
  from &&_user..sqlplus_log
 where identifier = '&&g_run_identifier';

prompt done
prompt
