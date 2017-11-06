CREATE OR REPLACE Type BODY plparse_AST_BlockDeclPart AS

    ----------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION plparse_AST_BlockDeclPart(declarations plparse_ASTChildren) RETURN SELF AS Result IS
    BEGIN
        self.symbol_type := plparse.ast_BlockDeclPart;
        self.children    := declarations;
        RETURN;
    END;

    ----------------------------------------------------------------------------
    STATIC FUNCTION createNew(declarations plparse_ASTChildren) RETURN plparse_AST_BlockDeclPart IS
        l_Result plparse_AST_BlockDeclPart;
    BEGIN
        l_Result := NEW plparse_AST_BlockDeclPart(declarations);
        plparse_ast_registry.register(l_Result);
        RETURN l_Result;
    END;

END;
/
