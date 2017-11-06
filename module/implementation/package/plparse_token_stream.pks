CREATE OR REPLACE PACKAGE plparse_token_stream AS

    PROCEDURE initialize(p_source_lines IN plparse.source_lines_type);

    FUNCTION getIndex RETURN PLS_INTEGER;

    FUNCTION currentToken RETURN plex_token;

    PROCEDURE consume;

    FUNCTION eof RETURN BOOLEAN;

    FUNCTION peek(p_lookahead PLS_INTEGER) RETURN plex_token;

    PROCEDURE takeSnapshot;

    PROCEDURE rollbackSnapshot;

    PROCEDURE commitSnapshot;

    FUNCTION capture(ast plparse_ast) RETURN plparse_ast;

    FUNCTION take RETURN plex_token;
    FUNCTION take(tokenType plex.token_type) RETURN plex_token;
    PROCEDURE take(tokenType plex.token_type);

    FUNCTION takeReservedWord(Text VARCHAR2) RETURN plex_token;
    PROCEDURE takeReservedWord(Text VARCHAR2);

    FUNCTION alt(ast plparse_ast) RETURN BOOLEAN;

END;
/
