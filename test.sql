set serveroutput on size unlimited

prompt Executing all test in schema
exec pete.run_test_suite(a_suite_name_in => sys_context('userEnv', 'current_schema'));
