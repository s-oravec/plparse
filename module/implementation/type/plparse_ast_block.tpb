CREATE OR REPLACE Type BODY plparse_ast_block AS

    ----------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION plparse_ast_block
    (
        Name          IN VARCHAR2,
        symbol_type   IN VARCHAR2,
        blockDeclPart IN plparse_ast_BlockDeclPart,
        blockCode     IN plparse_ast_BlockCode
    ) RETURN SELF AS Result IS
    BEGIN
        self.name        := Name;
        self.symbol_type := nvl(symbol_type, plparse.ast_Block);
        self.children    := plparse_ASTChildren();
        --
        IF blockDeclPart IS NOT NULL THEN
            self.children.extend;
            self.children(self.children.last) := blockDeclPart.Id_Registry;
        END IF;
        IF blockCode IS NOT NULL THEN
            self.children.extend;
            self.children(self.children.last) := blockCode.Id_Registry;
        END IF;
        --
        RETURN;
    END;

    ----------------------------------------------------------------------------
    STATIC FUNCTION createNew
    (
        Name          IN VARCHAR2,
        symbol_type   IN VARCHAR2,
        blockDeclPart IN plparse_ast_BlockDeclPart,
        blockCode     IN plparse_ast_BlockCode
    ) RETURN plparse_ast_block IS
        l_Result plparse_ast_block;
    BEGIN
        l_Result := NEW plparse_ast_block(Name, symbol_type, blockDeclPart, blockCode);
        plparse_ast_registry.register(l_Result);
        RETURN l_Result;
    END;

    ----------------------------------------------------------------------------
    OVERRIDING MEMBER FUNCTION toString
    (
        lvl       INTEGER DEFAULT 0,
        verbosity INTEGER DEFAULT 0
    ) RETURN VARCHAR2 IS
        l_Result VARCHAR2(32767);
        l_child  plparse_ast;
    
        FUNCTION strMe RETURN VARCHAR2 IS
        BEGIN
            IF verbosity = 0 THEN
                RETURN self.symbol_type;
            ELSE
                RETURN chr(10) || lpad(' ', 2 * lvl, ' ') || self.symbol_type || ':' || nvl(self.name, '__anonymous');
            END IF;
        END;
    
        FUNCTION strAfterChildren RETURN VARCHAR2 IS
        BEGIN
            IF verbosity = 0 THEN
                RETURN NULL;
            ELSE
                RETURN chr(10) || lpad(' ', 2 * lvl, ' ');
            END IF;
        END;
    
    BEGIN
        IF self.children.count > 0 THEN
            FOR idx IN 1 .. self.children.count LOOP
                l_child := plparse_ast_registry.get_by_id(self.children(idx));
                IF idx = 1 THEN
                    l_Result := l_Result || l_child.toString(lvl + 1, verbosity);
                ELSE
                    l_Result := l_Result || ',' || l_child.toString(lvl + 1, verbosity);
                END IF;
            END LOOP;
            RETURN strMe || '(' || l_Result || strAfterChildren || ')';
        END IF;
        RETURN strMe;
    END;

END;
/
