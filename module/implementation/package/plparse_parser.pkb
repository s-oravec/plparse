CREATE OR REPLACE PACKAGE BODY plparse_parser AS

    FUNCTION blockDeclPart RETURN plparse_AST_BlockDeclPart;
    FUNCTION blockCode RETURN plparse_AST_BlockCode;
    FUNCTION branchList RETURN plparse_AstChildren;
    FUNCTION statementList RETURN plparse_AstChildren;

    ----------------------------------------------------------------------------
    PROCEDURE initialize(p_source_lines IN plparse.source_lines_type) IS
    BEGIN
        plparse_token_stream.initialize(p_source_lines);
    END;

    ----------------------------------------------------------------------------  
    PROCEDURE appendToList
    (
        ast      IN plparse_ast,
        children IN OUT NOCOPY plparse_ASTChildren
    ) IS
    BEGIN
        IF ast IS NOT NULL THEN
            children.extend();
            children(children.last) := ast.id_registry;
        END IF;
    END;

    ----------------------------------------------------------------------------  
    FUNCTION appendToList
    (
        ast      IN plparse_ast,
        children IN OUT NOCOPY plparse_ASTChildren
    ) RETURN BOOLEAN IS
    BEGIN
        IF ast IS NOT NULL THEN
            children.extend();
            children(children.last) := ast.id_registry;
            RETURN TRUE;
        END IF;
        RETURN FALSE;
    END;

    ----------------------------------------------------------------------------
    FUNCTION currentTokenType RETURN plex.token_type IS
    BEGIN
        RETURN plparse_token_stream.currentToken().tokenType;
    END;

    ---------------------------------------------------------------------------- 
    FUNCTION currentTokenTypeIs(tokeType plex.token_type) RETURN BOOLEAN IS
    BEGIN
        RETURN plparse_token_stream.currentToken().tokenType = tokeType;
    END;

    ----------------------------------------------------------------------------  
    FUNCTION currentTokenIsReserwedWord(reservedWord plex.token_type) RETURN BOOLEAN IS
        l_currentToken plex_token;
    BEGIN
        l_currentToken := plparse_token_stream.currentToken();
        RETURN l_currentToken.tokenType = plex.tk_Word AND upper(l_currentToken.text) = upper(reservedWord);
    END;

    ----------------------------------------------------------------------------
    FUNCTION currentTokenText RETURN VARCHAR2 IS
    BEGIN
        RETURN plparse_token_stream.currentToken().text;
    END;

    ----------------------------------------------------------------------------
    PROCEDURE raiseUnexpectedToken(tokenType IN plex.token_type) IS
    BEGIN
        raise_application_error(-20000, 'Unexpected token ' || tokenType || '. Please report this issue here http://bit.ly/2cHuOnx');
    END;

    ----------------------------------------------------------------------------
    PROCEDURE raiseUnexpectedToken IS
    BEGIN
        raise_application_error(-20000, 'Unexpected token ' || currentTokenType || ':' || currentTokenText);
    END;

    ----------------------------------------------------------------------------
    PROCEDURE raiseUnexpectedTokenIfEOF IS
    BEGIN
        IF plparse_token_stream.eof THEN
            raiseUnexpectedToken;
        END IF;
    END;

    ----------------------------------------------------------------------------
    PROCEDURE takeAny
    (
        tokenType1 IN plex.token_type,
        tokenType2 IN plex.token_type
    ) IS
    BEGIN
        IF currentTokenType IN (tokenType1, tokenType2) THEN
            plparse_token_stream.consume;
        ELSE
            raiseUnexpectedToken;
        END IF;
    END;

    ----------------------------------------------------------------------------
    FUNCTION peekTokenType(lookahead IN PLS_INTEGER DEFAULT 0) RETURN plex.token_type IS
    BEGIN
        RETURN plparse_token_stream.peek(lookahead).tokenType;
    END;

    ----------------------------------------------------------------------------
    FUNCTION peekTokenText(lookahead IN PLS_INTEGER DEFAULT 0) RETURN plex.token_type IS
    BEGIN
        RETURN plparse_token_stream.peek(lookahead).text;
    END;

    ----------------------------------------------------------------------------
    FUNCTION simpleName RETURN VARCHAR2 IS
        l_Result VARCHAR2(255);
    BEGIN
        IF currentTokenType = plex.tk_Word THEN
            l_Result := currentTokenText;
            plparse_token_stream.consume;
            RETURN l_Result;
        END IF;
        raiseUnexpectedToken;
    END;

    ----------------------------------------------------------------------------
    FUNCTION qualifiedNameLocal RETURN VARCHAR2 IS
        l_Result VARCHAR2(255);
    BEGIN
        IF currentTokenType = plex.tk_Word THEN
            l_Result := currentTokenText;
            plparse_token_stream.consume;
            --
            IF currentTokenType = plex.tk_Dot THEN
                -- consume rest of qualified name
                l_Result := l_Result || currentTokenText;
                plparse_token_stream.consume;
                l_Result := l_Result || currentTokenText;
                plparse_token_stream.consume;
            END IF;
            RETURN l_Result;
        END IF;
        raiseUnexpectedToken;
    END;

    -- declaration with initialization - constant or variable
    ----------------------------------------------------------------------------
    FUNCTION executableDecl RETURN plparse_AST IS
        l_found                 BOOLEAN := FALSE;
        l_sourceLine_start      PLS_INTEGER;
        l_sourceLineIndex_start PLS_INTEGER;
        l_sourceLine_end        PLS_INTEGER;
        l_sourceLineIndex_end   PLS_INTEGER;
        l_currentToken          plex_token;
    BEGIN
        plparse_token_stream.takeSnapshot;
        --
        l_currentToken          := plparse_token_stream.currentToken;
        l_sourceLine_start      := l_currentToken.sourceLine;
        l_sourceLineIndex_start := l_currentToken.sourceLineIndex;
        LOOP
            l_currentToken        := plparse_token_stream.take;
            l_sourceLine_end      := l_currentToken.sourceLine;
            l_sourceLineIndex_end := l_currentToken.sourceLineIndex + length(l_currentToken.text);
            IF l_currentToken.tokenType = plex.tk_Semicolon AND l_found THEN
                RETURN plparse_ast.createNew(symbol_type           => plparse.ast_ExecutableDecl,
                                             sourceLine_start      => l_sourceLine_start,
                                             sourceLineIndex_start => l_sourceLineIndex_start,
                                             sourceLine_end        => l_sourceLine_end,
                                             sourceLineIndex_end   => l_sourceLineIndex_end);
            ELSIF l_currentToken.tokenType = plex.tk_Semicolon AND NOT l_found THEN
                plparse_token_stream.rollbackSnapshot;
                RETURN NULL;
            ELSIF l_currentToken.tokenType = plex.tk_Assign THEN
                l_found := TRUE;
            ELSIF l_currentToken.tokenType = plex.tk_EOF THEN
                raiseUnexpectedToken;
            END IF;
        END LOOP;
    END;

    ----------------------------------------------------------------------------  
    FUNCTION otherDecl RETURN plparse_ast IS
        l_sourceLine_start      PLS_INTEGER;
        l_sourceLineIndex_start PLS_INTEGER;
        l_sourceLine_end        PLS_INTEGER;
        l_sourceLineIndex_end   PLS_INTEGER;
        l_currentToken          plex_token;
    BEGIN
        l_currentToken          := plparse_token_stream.currentToken;
        l_sourceLine_start      := l_currentToken.sourceLine;
        l_sourceLineIndex_start := l_currentToken.sourceLineIndex;
        LOOP
            l_currentToken        := plparse_token_stream.take;
            l_sourceLine_end      := l_currentToken.sourceLine;
            l_sourceLineIndex_end := l_currentToken.sourceLineIndex + length(l_currentToken.text);
            IF l_currentToken.tokenType = plex.tk_Semicolon THEN
                RETURN plparse_ast.createNew(symbol_type           => plparse.ast_OtherDecl,
                                             sourceLine_start      => l_sourceLine_start,
                                             sourceLineIndex_start => l_sourceLineIndex_start,
                                             sourceLine_end        => l_sourceLine_end,
                                             sourceLineIndex_end   => l_sourceLineIndex_end);
            ELSIF l_currentToken.tokenType = plex.tk_EOF THEN
                raiseUnexpectedToken;
            END IF;
        END LOOP;
    END;

    ----------------------------------------------------------------------------
    PROCEDURE paramListDecl IS
    BEGIN
        IF currentTokenType = plex.tk_LParenth THEN
            LOOP
                plparse_token_stream.consume;
                IF currentTokenType = plex.tk_RParenth OR currentTokenType = plex.tk_EOF THEN
                    plparse_token_stream.consume;
                    RETURN;
                END IF;
            END LOOP;
        END IF;
        raiseUnexpectedToken;
    END;

    ----------------------------------------------------------------------------
    FUNCTION functionDeclaration RETURN plparse_ast IS
        l_Name  VARCHAR2(255);
        l_token plex_token;
    BEGIN
        plparse_token_stream.takeSnapshot;
        BEGIN
            plparse_token_stream.take(plex.tk_FUNCTION);
            l_Name := simpleName();
            IF currentTokenType = plex.tk_LParenth THEN
                paramListDecl;
            END IF;
            plparse_token_stream.takeReservedWord(plex.tk_RETURN);
            -- consume rest until ;
            LOOP
                IF plparse_token_stream.eof THEN
                    raiseUnexpectedToken;
                END IF;
                l_token := plparse_token_stream.take;
                EXIT WHEN l_token.tokenType = plex.tk_Semicolon;
            END LOOP;
            RETURN plparse_ast.createNew(plparse.ast_FunctionDecl, NULL, NULL, NULL, NULL);
        EXCEPTION
            WHEN OTHERS THEN
                plparse_token_stream.rollbackSnapshot;
        END;
        RETURN NULL;
    END;

    ----------------------------------------------------------------------------
    FUNCTION procedureDeclaration RETURN plparse_ast IS
        l_Name VARCHAR2(255);
    BEGIN
        plparse_token_stream.takeSnapshot;
        BEGIN
            plparse_token_stream.take(plex.tk_PROCEDURE);
            l_Name := simpleName();
            IF currentTokenType = plex.tk_LParenth THEN
                paramListDecl;
            END IF;
            plparse_token_stream.take(plex.tk_Semicolon);
            RETURN plparse_ast.createNew(plparse.ast_ProcedureDecl, NULL, NULL, NULL, NULL);
        EXCEPTION
            WHEN OTHERS THEN
                plparse_token_stream.rollbackSnapshot;
        END;
        RETURN NULL;
    END;

    ----------------------------------------------------------------------------
    FUNCTION functionDefinition RETURN plparse_AST_Block IS
        l_Name  VARCHAR2(255);
        l_token plex_token;
    BEGIN
        plparse_token_stream.takeSnapshot;
        BEGIN
            plparse_token_stream.take(plex.tk_FUNCTION);
            l_Name := simpleName();
            IF currentTokenType = plex.tk_LParenth THEN
                paramListDecl;
            END IF;
            plparse_token_stream.takeReservedWord(plex.tk_RETURN);
            -- consume rest until ;
            LOOP
                IF plparse_token_stream.eof THEN
                    raiseUnexpectedToken;
                END IF;
                l_token := plparse_token_stream.take;
                EXIT WHEN l_token.tokenType IN(plex.tk_IS, plex.tk_AS);
            END LOOP;
            RETURN plparse_ast_block.createNew(l_Name, plparse.ast_FunctionDef, blockDeclPart(), blockCode());
        EXCEPTION
            WHEN OTHERS THEN
                plparse_token_stream.rollbackSnapshot;
        END;
        RETURN NULL;
    END;

    ----------------------------------------------------------------------------
    FUNCTION procedureDefinition RETURN plparse_AST_Block IS
        l_Name VARCHAR2(255);
    BEGIN
        plparse_token_stream.takeSnapshot;
        BEGIN
            plparse_token_stream.take(plex.tk_PROCEDURE);
            l_Name := simpleName();
            IF currentTokenType = plex.tk_LParenth THEN
                paramListDecl;
            END IF;
            takeAny(plex.tk_IS, plex.tk_AS);
            RETURN plparse_ast_block.createNew(l_Name, plparse.ast_ProcedureDef, blockDeclPart(), blockCode());
        EXCEPTION
            WHEN OTHERS THEN
                plparse_token_stream.rollbackSnapshot;
        END;
        RETURN NULL;
    END;

    ----------------------------------------------------------------------------
    PROCEDURE takeBlockEnd(endToken IN plex_token DEFAULT NULL) IS
    BEGIN
        -- take block end
        plparse_token_stream.take(plex.tk_END);
        -- ok
        IF endToken IS NOT NULL AND endToken.tokenType != plex.tk_Word THEN
            -- take keword
            plparse_token_stream.take(endToken.tokenType);
        ELSIF endToken IS NOT NULL AND endToken.tokenType = plex.tk_Word THEN
            -- take reserved word
            plparse_token_stream.takeReservedWord(endToken.text);
        END IF;
        -- consume optional name after end - not for IF
        -- other "blocks" may be labeled/named
        -- !!! case can have label !!!
        IF endToken IS NULL OR endToken.tokenType NOT IN (plex.tk_IF) THEN
            IF currentTokenType = plex.tk_Word THEN
                plparse_token_stream.consume;
            END IF;
        END IF;
        -- and semicolon
        plparse_token_stream.take(plex.tk_Semicolon);
    END;

    ----------------------------------------------------------------------------  
    FUNCTION blockDeclPart RETURN plparse_AST_BlockDeclPart IS
        l_declarations plparse_AstChildren;
    BEGIN
        IF currentTokenType NOT IN (plex.tk_END, plex.tk_BEGIN) THEN
            l_declarations := plparse_AstChildren();
            WHILE currentTokenType NOT IN (
                                           -- end of package body/type body declaration - when it doesn't contain initialization block
                                           plex.tk_END,
                                           -- end of function/procedure declaration pat or start of initialization bloc in package body
                                           plex.tk_BEGIN) LOOP
                IF currentTokenType = plex.tk_PROCEDURE THEN
                    -- procedure definition
                    IF NOT appendToList(procedureDefinition, l_declarations) THEN
                        appendToList(procedureDeclaration, l_declarations);
                    END IF;
                ELSIF currentTokenType = plex.tk_FUNCTION THEN
                    -- function definition
                    IF NOT appendToList(functionDefinition, l_declarations) THEN
                        appendToList(functionDeclaration, l_declarations);
                    END IF;
                ELSIF (currentTokenType IN (plex.tk_TYPE, plex.tk_CURSOR)) OR
                      (currentTokenType = plex.tk_Word AND upper(currentTokenText) IN (plex.tk_PRAGMA)) THEN
                    -- other declarations - type, cursor, pragma - consume until ;                
                    appendToList(otherDecl, l_declarations);
                ELSIF plparse_token_stream.peek(1)
                 .tokenType = plex.tk_Word AND plparse_token_stream.peek(1).text = plex.tk_CONSTANT THEN
                    appendToList(executableDecl, l_declarations);
                ELSE
                    IF NOT appendToList(executableDecl(), l_declarations) THEN
                        IF NOT appendToList(otherDecl(), l_declarations) THEN
                            raiseUnexpectedToken;
                        END IF;
                    END IF;
                END IF;
            END LOOP;
            RETURN plparse_AST_BlockDeclPart.createNew(l_declarations);
        END IF;
        RETURN NULL;
    END;

    ----------------------------------------------------------------------------  
    FUNCTION isSimpleStatementBegin RETURN BOOLEAN IS
    BEGIN
        RETURN currentTokenType IN(plex.tk_NULL,
                                   plex.tk_SELECT,
                                   plex.tk_WITH,
                                   plex.tk_INSERT,
                                   plex.tk_GOTO,
                                   plex.tk_UPDATE,
                                   plex.tk_FETCH) OR(currentTokenType = plex.tk_Word AND
                                                           upper(currentTokenText) IN (plex.tk_FORALL,
                                                                                       plex.tk_MERGE,
                                                                                       plex.tk_EXIT,
                                                                                       plex.tk_RETURN,
                                                                                       plex.tk_OPEN,
                                                                                       plex.tk_CONTINUE,
                                                                                       plex.tk_PIPE,
                                                                                       plex.tk_RAISE,
                                                                                       plex.tk_CLOSE,
                                                                                       plex.tk_EXECUTE));
    END;

    ----------------------------------------------------------------------------  
    FUNCTION isStatementListEnd RETURN BOOLEAN IS
    BEGIN
         -- NoFormat Start
         RETURN (currentTokenType IN (plex.tk_END, plex.tk_EXCEPTION, plex.tk_ELSE, plex.tk_WHEN)) 
             OR (currentTokenType = plex.tk_Word AND upper(currentTokenText) IN (plex.tk_ELSIF)) 
             OR (currentTokenType = plex.tk_EOF)
         ;
        -- NoFormat End                                                                                                                                                      
    END;

    ---------------------------------------------------------------------------- 
    FUNCTION simpleStatement RETURN plparse_ast IS
        l_sourceLine_start      PLS_INTEGER;
        l_sourceLineIndex_start PLS_INTEGER;
        l_sourceLine_end        PLS_INTEGER;
        l_sourceLineIndex_end   PLS_INTEGER;
        l_currentToken          plex_token;
    BEGIN
        IF isSimpleStatementBegin THEN
            --
            l_currentToken          := plparse_token_stream.currentToken;
            l_sourceLine_start      := l_currentToken.sourceLine;
            l_sourceLineIndex_start := l_currentToken.sourceLineIndex;
            LOOP
                l_currentToken        := plparse_token_stream.take;
                l_sourceLine_end      := l_currentToken.sourceLine;
                l_sourceLineIndex_end := l_currentToken.sourceLineIndex + length(l_currentToken.text);
                IF l_currentToken.tokenType = plex.tk_Semicolon THEN
                    RETURN plparse_ast.createNew(symbol_type           => plparse.ast_SimpleStatement,
                                                 sourceLine_start      => l_sourceLine_start,
                                                 sourceLineIndex_start => l_sourceLineIndex_start,
                                                 sourceLine_end        => l_sourceLine_end,
                                                 sourceLineIndex_end   => l_sourceLineIndex_end);
                ELSIF l_currentToken.tokenType = plex.tk_EOF THEN
                    raiseUnexpectedToken;
                END IF;
            END LOOP;
        END IF;
        RETURN NULL;
    END;

    ----------------------------------------------------------------------------
    FUNCTION decision(decisionToken IN plex_token) RETURN plparse_AST_Decision IS
        l_branches plparse_AstChildren;
    BEGIN
        IF decisionToken.tokenType = plex.tk_CASE THEN
            -- consume until first when
            WHILE NOT currentTokenTypeIs(plex.tk_WHEN) LOOP
                plparse_token_stream.consume;
            END LOOP;
        END IF;
        l_branches := branchList();
        takeBlockEnd(decisionToken);
        RETURN plparse_AST_Decision.createNew(plparse.ast_Decision, l_branches);
    END;

    ----------------------------------------------------------------------------
    FUNCTION loopBlock(loopToken IN plex_token) RETURN plparse_AST_BlockCode IS
        l_token      plex_token;
        l_statements plparse_ASTChildren;
    BEGIN
        LOOP
            l_token := plparse_token_stream.take;
            EXIT WHEN currentTokenIsReserwedWord(plex.tk_LOOP);
        END LOOP;
        l_statements := statementList();
        takeBlockEnd(loopToken);
        RETURN plparse_AST_BlockCode.createNew(l_statements);
    END;

    ----------------------------------------------------------------------------
    FUNCTION statementList RETURN plparse_AstChildren IS
        l_Result plparse_AstChildren;
    BEGIN
        l_Result := plparse_AstChildren();
        WHILE NOT isStatementListEnd LOOP
            -- parse complex statements
            IF currentTokenType = plex.tk_FOR OR currentTokenIsReserwedWord(plex.tk_LOOP) OR
               currentTokenIsReserwedWord(plex.tk_WHILE) THEN
                appendToList(loopBlock(plparse_token_stream.currentToken), l_Result);
            ELSIF currentTokenType IN (plex.tk_CASE, plex.tk_IF) THEN
                appendToList(decision(plparse_token_stream.currentToken), l_Result);
            ELSIF currentTokenType = plex.tk_Label THEN
                -- label
                appendToList(plparse_AST.createNew(plparse_token_stream.take(plex.tk_Label)), l_Result);
            ELSIF currentTokenType = plex.tk_DECLARE THEN
                -- conusme DECLARE kw
                plparse_token_stream.consume;
                -- append inner anonymous block with declaration
                appendToList(plparse_ast_block.createNew(NULL, plparse.ast_InnerBlock, blockDeclPart(), blockCode()), l_Result);
            ELSIF currentTokenType = plex.tk_BEGIN THEN
                -- append inner anonymous block without declaration
                appendToList(plparse_ast_block.createNew(NULL, plparse.ast_InnerBlock, NULL, blockCode()), l_Result);
            ELSIF isSimpleStatementBegin THEN
                -- simple statements - forall, select, with, insert, update, delete, merge, exit, return, fetch, open, close, execute, null, label - take until ;
                -- goto, raise, pipe, continue
                appendToList(simpleStatement(), l_Result);
            ELSE
                plparse_token_stream.consume;
            END IF;
        END LOOP;
        RETURN l_Result;
    END;

    ----------------------------------------------------------------------------
    FUNCTION branchList RETURN plparse_AstChildren IS
        l_Result       plparse_AstChildren;
        l_currentToken plex_token;
    BEGIN
        l_Result := plparse_AstChildren();
        WHILE NOT currentTokenType IN (plex.tk_END, plex.tk_EOF) LOOP
            -- consume branch kw (IF, ELSIF, WHEN, ELSE ) [ ... kw THEN ]
            LOOP
                l_currentToken := plparse_token_stream.take;
                EXIT WHEN l_currentToken.tokenType IN(plex.tk_THEN, plex.tk_ELSE, plex.tk_EOF);
            END LOOP;
            -- create branch with statementList
            appendToList(plparse_ast_branch.createNew(statementList()), l_Result);
        END LOOP;
        RETURN l_Result;
    END;
    ---------------------------------------------------------------------------- 
    FUNCTION blockException RETURN plparse_AST_Decision IS
    BEGIN
        IF currentTokenType = plex.tk_EXCEPTION THEN
            -- Consume kw EXCEPTION 
            plparse_token_stream.consume;
            -- exception block is actually decision with WHEN ... THEN statementList branches
            RETURN plparse_AST_Decision(plparse.ast_ExceptionBlock, branchList);
        END IF;
        RETURN NULL;
    END;

    ----------------------------------------------------------------------------  
    FUNCTION blockCode RETURN plparse_AST_BlockCode IS
        l_statements plparse_AstChildren;
    BEGIN
        IF currentTokenType = plex.tk_BEGIN THEN
            plparse_token_stream.consume;
            -- statements list
            l_statements := statementList();
            -- optional exception block
            IF currentTokenType = plex.tk_EXCEPTION THEN
                appendToList(blockException(), l_statements);
            END IF;
            --
            takeBlockEnd();
            RETURN plparse_AST_BlockCode.createNew(l_statements);
        END IF;
        RETURN NULL;
    END;

    ----------------------------------------------------------------------------
    FUNCTION packageBody RETURN plparse_AST_Block IS
        l_Name VARCHAR2(255);
    BEGIN
        plparse_token_stream.takeReservedWord(plex.tk_PACKAGE);
        plparse_token_stream.takeReservedWord(plex.tk_BODY);
        l_Name := qualifiedNameLocal();
        takeAny(plex.tk_IS, plex.tk_AS);
        RETURN plparse_ast_block.createNew(l_Name, plparse.ast_PackageBody, blockDeclPart(), blockCode());
    END;

    ----------------------------------------------------------------------------
    FUNCTION parse RETURN plparse_ast IS
    BEGIN
        IF currentTokenType = plex.tk_FUNCTION THEN
            RETURN functionDefinition;
        ELSIF currentTokenType = plex.tk_PROCEDURE THEN
            RETURN procedureDefinition;
        ELSE
            RETURN packageBody;
        END IF;
    END;

END;
/
