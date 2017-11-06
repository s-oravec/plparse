CREATE OR REPLACE Type plparse_AST_BlockCode UNDER plparse_AST
(
    CONSTRUCTOR FUNCTION plparse_AST_BlockCode(statements plparse_ASTChildren) RETURN SELF AS Result,

    STATIC FUNCTION createNew(statements plparse_ASTChildren) RETURN plparse_AST_BlockCode
)
;
/
