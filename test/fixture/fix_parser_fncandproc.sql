CREATE OR REPLACE PACKAGE fix_parser_fncandproc AS

END;
/
CREATE OR REPLACE PACKAGE BODY fix_parser_fncandproc AS

    PROCEDURE procWithoutParams IS
    BEGIN
        NULL;
    END procWithoutParams;

    PROCEDURE procWithParams(P PLS_INTEGER) IS
    BEGIN
        NULL;
    END procWithParams;

    FUNCTION fncWithoutParams RETURN PLS_INTEGER IS
    BEGIN
        RETURN NULL;
    END fncWithoutParams;

    FUNCTION fncWithParams(P PLS_INTEGER) RETURN PLS_INTEGER IS
    BEGIN
        RETURN NULL;
    END fncWithParams;

    PROCEDURE prcWithInlinePrc IS
        PROCEDURE inlinePrc IS
        BEGIN
            NULL;
        END inlinePrc;
    BEGIN
        inlinePrc;
    END prcWithInlinePrc;

END;
/
