CREATE OR REPLACE Type plparse_AST_Decision UNDER plparse_AST
(
    CONSTRUCTOR FUNCTION plparse_AST_Decision
    (
        symbol_type IN VARCHAR2,
        branches    IN plparse_ASTChildren
    ) RETURN SELF AS Result,

    STATIC FUNCTION createNew
    (
        symbol_type IN VARCHAR2,
        branches    IN plparse_ASTChildren
    ) RETURN plparse_AST_Decision

)
;
/
