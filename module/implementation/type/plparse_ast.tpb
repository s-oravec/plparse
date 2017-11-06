CREATE OR REPLACE Type BODY plparse_ast AS

    ----------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION plparse_ast(token plex_token) RETURN SELF AS Result IS
    BEGIN
        self.token                 := token;
        self.symbol_type           := token.tokenType;
        self.sourceLine_start      := token.sourceLine;
        self.sourceLineIndex_start := token.sourceLineIndex;
        self.sourceLine_end        := token.sourceLine;
        self.sourceLineIndex_end   := token.sourceLineIndex + length(token.text);
        self.children              := plparse_AstChildren();
        --
        RETURN;
    END;

    ----------------------------------------------------------------------------
    STATIC FUNCTION createNew(token plex_token) RETURN plparse_ast IS
        l_Result plparse_ast;
    BEGIN
        l_Result := plparse_ast(token);
        plparse_ast_registry.register(l_Result);
        RETURN l_Result;
    END;

    ----------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION plparse_ast
    (
        symbol_type           IN VARCHAR2,
        sourceLine_start      INTEGER,
        sourceLineIndex_start INTEGER,
        sourceLine_end        INTEGER,
        sourceLineIndex_end   INTEGER
    ) RETURN SELF AS Result IS
    BEGIN
        self.token                 := NULL;
        self.symbol_type           := symbol_type;
        self.sourceLine_start      := sourceLine_start;
        self.sourceLineIndex_start := sourceLineIndex_start;
        self.sourceLine_end        := sourceLine_end;
        self.sourceLineIndex_end   := sourceLineIndex_end;
        self.children              := plparse_AstChildren();
        --
        RETURN;
    END;

    ----------------------------------------------------------------------------    
    STATIC FUNCTION createNew
    (
        symbol_type           IN VARCHAR2,
        sourceLine_start      INTEGER,
        sourceLineIndex_start INTEGER,
        sourceLine_end        INTEGER,
        sourceLineIndex_end   INTEGER
    ) RETURN plparse_ast IS
        l_Result plparse_ast;
    BEGIN
        l_Result := plparse_ast(symbol_type, sourceLine_start, sourceLineIndex_start, sourceLine_end, sourceLineIndex_end);
        plparse_ast_registry.register(l_Result);
        RETURN l_Result;
    END;

    ----------------------------------------------------------------------------
    MEMBER PROCEDURE addChild(child plparse_ast) IS
    BEGIN
        IF child IS NOT NULL THEN
            children.extend;
            children(children.count) := child.id_registry;
        END IF;
    END;

    ----------------------------------------------------------------------------
    MEMBER FUNCTION toString
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
                RETURN chr(10) || lpad(' ', 2 * lvl, ' ') || self.symbol_type;
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

    ----------------------------------------------------------------------------
    MEMBER FUNCTION executeAst RETURN plparse_ast IS
    BEGIN
        RETURN NULL;
    END;

END;
/
