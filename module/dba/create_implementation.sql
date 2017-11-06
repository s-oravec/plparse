prompt .. Creating package &&g_package_name schema &&l_schema_name with default tablespace &&l_schema_tbspc and temp tablespace &&l_temp_tbspc
create user &&l_schema_name
  identified by "&&l_schema_pwd"
  default tablespace &&l_schema_tbspc
  temporary tablespace &&l_temp_tbspc
  quota unlimited on &&l_schema_tbspc
  account unlock
/

prompt Grant schema privileges
@@grant_schema_&&l_environment..sql &&l_schema_name
