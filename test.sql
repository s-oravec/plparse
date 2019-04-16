set trimspool on
set serveroutput on size unlimited
set linesize 4000
set pages 0
set feedback off
set verify off
set echo off

clear screen

prompt .. Creating test fixture procedure FIX_PARSER_CASE
@test/fixture/fix_parser_case.prc

prompt .. Creating test fixture procedure FIX_PARSER_DECL_WITH_INIT
@test/fixture/fix_parser_decl_with_init.prc

prompt .. Creating test fixture procedure FIX_PARSER_DECL_WITHOUT_INIT
@test/fixture/fix_parser_decl_without_init.prc

prompt .. Creating test fixture procedure FIX_PARSER_FNCANDPROC
@test/fixture/fix_parser_fncandproc.sql

prompt .. Creating test fixture procedure FIX_PARSER_IF
@test/fixture/fix_parser_if.prc

prompt .. Creating package UT_PLPARSE_AST
@test/implemtation/type/ut_plparse_ast.pkg

prompt .. Creating package UT_PLPARSE_TOKEN_STREAM
@test/implemtation/package/ut_plparse_token_stream.pkg

prompt .. Creating package UT_PLPARSE_PARSER
@test/implemtation/package/ut_plparse_parser.pkg

prompt .. Creating package UT_PLPARSE_AST_REGISTRY
@test/implemtation/package/ut_plparse_ast_registry.pkg



define utplsql_user=ceos_utplsql
prompt granting execute on test packages to &&utplsql_user user
begin
    for ii in (select *
                 from user_objects
                where object_name like 'TEST%'
                  and object_type = 'PACKAGE') loop
        execute immediate 'grant execute on ' || ii.object_name || ' to &&utplsql_user';
    end loop;
end;
/
prompt done

prompt .. Resetting packages
exec dbms_session.reset_package;

prompt .. Re-enabling DBMS_OUTPUT
exec dbms_output.enable;

set termout on
set serveroutput on size unlimited

--prompt utPLSQL test reported as JUnit
--spool report/test-report-core.xml
--begin
--    ut.run(ut_junit_reporter());
--end;
--/
--spool off

--prompt done

--prompt Code Coverage Report
--spool report/coverage-report-core.html
--begin
--    ut.run(ut_coverage_html_reporter());
--end;
--/
--spool off

select * from table(ut.run());