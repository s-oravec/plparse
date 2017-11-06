create or replace package plparse as

    -- TODO: Semver

    /**
    Source lines
    */
    type source_lines_type is table of all_source.text%type;

    /**
    AST Symbol Type
    */
    subtype ast_symbol_type IS VARCHAR2(30);

    -- AST Symbols
    -- TODO: Docs
    ast_Block           constant ast_symbol_type := 'Block';
    ast_BlockCode       constant ast_symbol_type := 'BlockCode';
    ast_BlockDeclPart   constant ast_symbol_type := 'BlockDeclPart';
    ast_Branch          constant ast_symbol_type := 'Branch';
    ast_ConstantDecl    constant ast_symbol_type := 'ConstantDecl';
    ast_Decision        constant ast_symbol_type := 'Decision';
    ast_ExceptionBlock  constant ast_symbol_type := 'ExceptionBlock';
    ast_FunctionDef     constant ast_symbol_type := 'FunctionDef';
    ast_FunctionDecl    constant ast_symbol_type := 'FunctionDecl';
    ast_InnerBlock      constant ast_symbol_type := 'InnerBlock';
    ast_OtherDecl       constant ast_symbol_type := 'OtherDecl';
    ast_ExecutableDecl  constant ast_symbol_type := 'ExecutableDecl';
    ast_PackageBody     constant ast_symbol_type := 'PackageBody';
    ast_ProcedureDef    constant ast_symbol_type := 'ProcedureDef';
    ast_ProcedureDecl   constant ast_symbol_type := 'ProcedureDecl';
    ast_SimpleStatement constant ast_symbol_type := 'SimpleStatement';

    /**
    Initializes parser with source lines

    %param source_lines lines of stored procedure (procedure, package, ...) - source text separated by chr(10)
    */
    procedure initialize(source_lines in source_lines_type);

    /**
    Parse source lines passed using initialize and return root AST

    %return plparse_ast Abstract Syntax Tree root node
    */
    function parse return plparse_ast;

end;
/
