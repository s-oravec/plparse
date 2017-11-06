CREATE OR REPLACE PROCEDURE fix_parser_decl_with_init IS
    -- constant
    c CONSTANT INTEGER := 10;
    -- variable 2 - with literal initialization
    v1 INTEGER := 10;
    -- variable 3 - with expression initialization
    v2 INTEGER := 10 / 1;
    -- variable 4 - with function call initialization
    v3 INTEGER := to_number('4');
BEGIN
    NULL;
END;
/
