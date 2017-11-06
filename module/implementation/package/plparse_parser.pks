CREATE OR REPLACE PACKAGE plparse_parser AS

    -- initializes parser with source lines
    PROCEDURE initialize(p_source_lines IN plparse.source_lines_type);

    -- parse source lines and return root AST
    FUNCTION parse RETURN plparse_ast;

END;
/
