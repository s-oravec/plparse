CREATE OR REPLACE Type plparse_AST_Branch UNDER plparse_AST
(
    CONSTRUCTOR FUNCTION plparse_AST_Branch(statements plparse_ASTChildren) RETURN SELF AS Result,

    STATIC FUNCTION createNew(statements plparse_ASTChildren) RETURN plparse_AST_Branch
)
;
/
