CREATE OR REPLACE Type plparse_ast_block UNDER plparse_AST
(
    -- named - procedure/function definition, package procedure/function definition
    -- or anonymous block - inner
    
    Name VARCHAR2(4000),

    CONSTRUCTOR FUNCTION plparse_ast_block
    (
        Name          IN VARCHAR2,
        symbol_type   IN VARCHAR2,
        blockDeclPart IN plparse_ast_BlockDeclPart,
        blockCode     IN plparse_ast_BlockCode
    ) RETURN SELF AS Result,

    STATIC FUNCTION createNew
    (
        Name          IN VARCHAR2,
        symbol_type   IN VARCHAR2,
        blockDeclPart IN plparse_ast_BlockDeclPart,
        blockCode     IN plparse_ast_BlockCode
    ) RETURN plparse_ast_block,

    OVERRIDING MEMBER FUNCTION toString
    (
        lvl       INTEGER DEFAULT 0,
        verbosity INTEGER DEFAULT 0
    ) RETURN VARCHAR2

)
;
/
