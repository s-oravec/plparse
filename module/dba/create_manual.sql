accept l_schema_name  prompt "Package [&&g_package_name] schema [&&g_schema_name] : " default "&&g_schema_name"
accept l_schema_pwd   prompt "Package [&&g_package_name] schema password : " hide
accept l_schema_tbspc prompt "Package [&&g_package_name] schema tablespace [&&g_schema_tbspc] : " default "&&g_schema_tbspc"
accept l_temp_tbspc   prompt "Package [&&g_package_name] temp tablespace [&&g_temp_tbspc] : " default "&&g_temp_tbspc"

declare
  lc_error_message constant varchar2(255) := 'ERROR: Zero-length password not permitted.';
begin
  if '&&l_schema_pwd' is null then
    dbms_output.put_line(lc_error_message);
    raise_application_error(-20000, lc_error_message);
  end if;
end;
/

@@create_implementation.sql

undefine l_schema_name
undefine l_schema_pwd
undefine l_schema_tbspc
undefine l_temp_tbspc