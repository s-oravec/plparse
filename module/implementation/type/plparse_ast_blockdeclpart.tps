CREATE OR REPLACE Type plparse_AST_BlockDeclPart UNDER plparse_AST
(
    CONSTRUCTOR FUNCTION plparse_AST_BlockDeclPart(declarations plparse_ASTChildren) RETURN SELF AS Result,

    STATIC FUNCTION createNew(declarations plparse_ASTChildren) RETURN plparse_AST_BlockDeclPart

)
;
/
