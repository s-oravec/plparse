CREATE OR REPLACE Type BODY plparse_AST_BlockCode AS

    ----------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION plparse_AST_BlockCode(statements plparse_ASTChildren) RETURN SELF AS Result IS
    BEGIN
        self.symbol_type := plparse.ast_BlockCode;
        self.children    := statements;
        RETURN;
    END;

    ----------------------------------------------------------------------------
    STATIC FUNCTION createNew(statements plparse_ASTChildren) RETURN plparse_AST_BlockCode IS
        l_Result plparse_AST_BlockCode;
    BEGIN
        l_Result := NEW plparse_AST_BlockCode(statements);
        plparse_ast_registry.register(l_Result);
        RETURN l_Result;
    END;

END;
/
