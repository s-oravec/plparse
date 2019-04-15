create or replace package body plparse as

    procedure initialize(source_lines in source_lines_type) is
    begin
        plparse_parser.initialize(source_lines);
    end;

    function parse return plparse_ast is
    begin
        return plparse_parser.parse();
    end;

end;
/
