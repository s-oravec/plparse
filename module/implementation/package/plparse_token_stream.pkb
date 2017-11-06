CREATE OR REPLACE PACKAGE BODY plparse_token_stream AS

    -- list of tokens returned
    g_tokens plex_tokens;
    -- current index
    g_index PLS_INTEGER;
    --
    g_snapshotIndexes plparse_integer_stack;

    Type typ_Memo IS RECORD(
        ast       plparse_ast,
        nextIndex PLS_INTEGER);
    Type typ_AstMemoIntDictionary IS TABLE OF typ_Memo INDEX BY PLS_INTEGER;

    g_cachedAstMemo typ_AstMemoIntDictionary;

    ----------------------------------------------------------------------------
    PROCEDURE initialize_impl IS
    BEGIN
        plparse_ast_registry.initialize;
        g_cachedAstMemo.delete();
        g_tokens          := plex.tokens;
        g_index           := 1;
        g_snapshotIndexes := plparse_integer_stack();
    END;

    ----------------------------------------------------------------------------
    FUNCTION currentToken RETURN plex_token IS
    BEGIN
        RETURN g_tokens(g_index);
    END;

    ----------------------------------------------------------------------------
    FUNCTION isMatch(TokenType plex.token_type) RETURN BOOLEAN IS
    BEGIN
        IF currentToken().tokenType = TokenType THEN
            RETURN TRUE;
        END IF;
        RETURN FALSE;
    END;

    ----------------------------------------------------------------------------
    PROCEDURE initialize(p_source_lines IN plparse.source_lines_type) IS
        ltab_source_lines plex.source_lines_type := plex.source_lines_type();
    BEGIN
        -- transform source lines
        IF p_source_lines IS NOT NULL AND p_source_lines.count() > 0 THEN
            ltab_source_lines.extend(p_source_lines.count());
            FOR idx IN 1 .. p_source_lines.count() LOOP
                ltab_source_lines(idx) := p_source_lines(idx);
            END LOOP;
        END IF;
        plex.initialize(ltab_source_lines);
        initialize_impl;
    END;

    ----------------------------------------------------------------------------
    FUNCTION getIndex RETURN PLS_INTEGER IS
    BEGIN
        RETURN g_index;
    END;

    ----------------------------------------------------------------------------
    FUNCTION eof(p_lookahead PLS_INTEGER) RETURN BOOLEAN IS
    BEGIN
        IF g_tokens IS NULL OR g_index + p_lookahead > g_tokens.count OR currentToken().tokenType = plex.tk_EOF THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END;

    ----------------------------------------------------------------------------
    FUNCTION eof RETURN BOOLEAN IS
    BEGIN
        RETURN eof(0);
    END;

    ----------------------------------------------------------------------------
    FUNCTION peek(p_lookahead PLS_INTEGER) RETURN plex_token IS
    BEGIN
        IF eof(p_lookahead) THEN
            RETURN NULL;
        ELSE
            RETURN g_tokens(g_index + p_lookahead);
        END IF;
    END;

    ----------------------------------------------------------------------------
    PROCEDURE consume IS
    BEGIN
        g_index := g_index + 1;
    END;

    ----------------------------------------------------------------------------
    PROCEDURE takeSnapshot IS
    BEGIN
        g_snapshotIndexes.push(g_index);
    END;

    ----------------------------------------------------------------------------
    PROCEDURE rollbackSnapshot IS
    BEGIN
        g_index := g_snapshotIndexes.pop();
    END;

    ----------------------------------------------------------------------------
    PROCEDURE commitSnapshot IS
    BEGIN
        g_snapshotIndexes.pop();
    END;

    ----------------------------------------------------------------------------
    FUNCTION getCachedOrExecute(ast plparse_ast) RETURN plparse_ast IS
        l_memo typ_Memo;
    BEGIN
        IF NOT g_cachedAstMemo.exists(g_index) THEN
            RETURN ast.executeAst;
        END IF;
        l_memo  := g_cachedAstMemo(g_index);
        g_index := l_memo.nextIndex;
        RETURN l_memo.ast;
    END;

    ----------------------------------------------------------------------------
    FUNCTION capture(ast plparse_ast) RETURN plparse_ast IS
    BEGIN
        IF alt(ast) THEN
            RETURN getCachedOrExecute(ast);
        END IF;
        RETURN NULL;
    END;

    ----------------------------------------------------------------------------
    FUNCTION take(tokenType plex.token_type) RETURN plex_token IS
        l_current plex_token;
    BEGIN
        IF isMatch(tokenType) THEN
            l_current := currentToken();
            consume;
            RETURN l_current;
        END IF;
        -- TODO: rewrite without exception
        raise_application_error(-20000, 'Invalid syntax. Expecting ' || tokenType || ' but got ' || currentToken().tokenType);
    END;

    ----------------------------------------------------------------------------
    PROCEDURE take(tokenType plex.token_type) IS
        l_token plex_token;
    BEGIN
        l_token := take(tokenType);
    END;

    ----------------------------------------------------------------------------
    FUNCTION take RETURN plex_token IS
        l_Result plex_token;
    BEGIN
        l_Result := currentToken();
        consume;
        RETURN l_Result;
    END;

    ----------------------------------------------------------------------------
    FUNCTION takeReservedWord(Text VARCHAR2) RETURN plex_token IS
        l_current plex_token;
    BEGIN
        IF isMatch(plex.tk_Word) AND currentToken().matchText(Text) THEN
            l_current := currentToken();
            consume;
            RETURN l_current;
        END IF;
        -- TODO: rewrite without exception
        raise_application_error(-20000, 'Invalid syntax. Expecting reserved word ' || Text || ' but got ' || currentToken().text);
    END;

    ----------------------------------------------------------------------------
    PROCEDURE takeReservedWord(Text VARCHAR2) IS
        l_token plex_token;
    BEGIN
        l_token := takeReservedWord(Text);
    END;

    ----------------------------------------------------------------------------
    FUNCTION alt(ast plparse_ast) RETURN BOOLEAN IS
        l_found        BOOLEAN;
        l_currentIndex PLS_INTEGER;
        l_ast          plparse_ast;
        l_newMemo      typ_Memo;
    BEGIN
        takeSnapshot;
        l_found := FALSE;
        BEGIN
            l_currentIndex := g_index;
            l_ast          := ast.executeAst();
            IF l_ast IS NOT NULL THEN
                l_found := TRUE;
                l_newMemo.ast := l_ast;
                l_newMemo.nextIndex := g_index;
                g_cachedAstMemo(l_currentIndex) := l_newMemo;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
        rollbackSnapshot;
        RETURN l_found;
    END;

END;
/
