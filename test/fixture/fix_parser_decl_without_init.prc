CREATE OR REPLACE PROCEDURE fix_parser_decl_without_init IS
    -- subtype
    SUBTYPE small_int IS PLS_INTEGER RANGE 1 .. 255 NOT NULL;
    -- subtype 2
    SUBTYPE my_Range IS NUMBER(10, 2);
    -- not null subtype
    SUBTYPE not_empty_string IS VARCHAR2(10) NOT NULL;
    -- subtype as table rowtype
    SUBTYPE rec2 IS user_tables%ROWTYPE;
    -- cursor without params
    CURSOR crs1 IS
        SELECT 1 N FROM dual;
    -- cursor with params
    CURSOR crs2(P INTEGER) IS
        SELECT 1 N FROM dual;
    -- type - record
    Type rec1 IS RECORD(
        i INTEGER,
        v VARCHAR2(10));
    -- type - table
    Type tab1 IS TABLE OF PLS_INTEGER;
    -- type - dictionary 
    Type tab2 IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
    -- type - varray
    Type var1 IS VARRAY(10) OF PLS_INTEGER;
    -- variable 1 - simple
    v1 INTEGER;
    -- variable 5 of table.column%type
    v2 user_tables.table_name%Type;
    -- variable 6 of table%rowtype
    v3 user_tables%ROWTYPE;
BEGIN
    NULL;
END;
/
