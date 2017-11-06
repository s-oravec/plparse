CREATE OR REPLACE Type plparse_ast AS OBJECT
(
    id_registry           INTEGER,
    symbol_type           VARCHAR2(30), -- plparse.as_symbol_type
    token                 plex_token,
    sourceLine_start      INTEGER,
    sourceLineIndex_start INTEGER,
    sourceLine_end        INTEGER,
    sourceLineIndex_end   INTEGER,
    children              plparse_AstChildren,

    CONSTRUCTOR FUNCTION plparse_ast(token plex_token) RETURN SELF AS Result,

    STATIC FUNCTION createNew(token IN plex_token) RETURN plparse_ast,

    CONSTRUCTOR FUNCTION plparse_ast
    (
        symbol_type           IN VARCHAR2,
        sourceLine_start      INTEGER,
        sourceLineIndex_start INTEGER,
        sourceLine_end        INTEGER,
        sourceLineIndex_end   INTEGER
    ) RETURN SELF AS Result,

    STATIC FUNCTION createNew
    (
        symbol_type           IN VARCHAR2,
        sourceLine_start      INTEGER,
        sourceLineIndex_start INTEGER,
        sourceLine_end        INTEGER,
        sourceLineIndex_end   INTEGER
    ) RETURN plparse_ast,

    MEMBER PROCEDURE addChild(child plparse_ast),

    MEMBER FUNCTION toString
    (
        lvl       INTEGER DEFAULT 0,
        verbosity INTEGER DEFAULT 0
    ) RETURN VARCHAR2,

    MEMBER FUNCTION executeAst RETURN plparse_ast

)
NOT FINAL;
/
