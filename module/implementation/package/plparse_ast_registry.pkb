CREATE OR REPLACE PACKAGE BODY plparse_ast_registry AS

    Type typ_ast_table IS TABLE OF plparse_ast;
    g_ast_registry typ_ast_table;

    ----------------------------------------------------------------------------
    PROCEDURE initialize IS
    BEGIN
        g_ast_registry := typ_ast_table();
    END;

    ----------------------------------------------------------------------------  
    PROCEDURE register(ast IN OUT NOCOPY plparse_ast) IS
    BEGIN
        g_ast_registry.extend();
        g_ast_registry(g_ast_registry.last) := ast;
        ast.id_registry := g_ast_registry.last;
    END;

    ----------------------------------------------------------------------------
    PROCEDURE unregister(ast IN OUT NOCOPY plparse_ast) IS
    BEGIN
        g_ast_registry.delete(ast.id_registry);
        ast.id_registry := NULL;
    END;

    ----------------------------------------------------------------------------
    FUNCTION get_by_id(id_registry IN INTEGER) RETURN plparse_ast IS
    BEGIN
        RETURN g_ast_registry(id_registry);
    END;

END;
/
