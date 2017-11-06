CREATE OR REPLACE Type BODY plparse_ast_decision AS

    ----------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION plparse_ast_decision
    (
        symbol_type IN VARCHAR2,
        branches    IN plparse_ASTChildren
    ) RETURN SELF AS Result IS
    BEGIN
        self.symbol_type := nvl(symbol_type, plparse.ast_Decision);
        self.children    := branches;
        --
        RETURN;
    END;

    ----------------------------------------------------------------------------
    STATIC FUNCTION createNew
    (
        symbol_type IN VARCHAR2,
        branches    IN plparse_ASTChildren
    ) RETURN plparse_ast_decision IS
        l_Result plparse_ast_decision;
    BEGIN
        l_Result := NEW plparse_ast_decision(symbol_type, branches);
        plparse_ast_registry.register(l_Result);
        RETURN l_Result;
    END;

END;
/
