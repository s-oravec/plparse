CREATE OR REPLACE PROCEDURE fix_parser_case IS
    l_Value INTEGER;
BEGIN
    -- branch statement on separate line
    CASE l_Value
        WHEN 0 THEN
            RETURN;
    END CASE;
    -- NoFormat Start
    -- branch statement on same line
    CASE l_value
        WHEN 0 THEN RETURN;
    END CASE;
    -- case with label
    <<case_label>>
    CASE l_Value
        WHEN NULL THEN
            NULL;
    END CASE case_label;
    -- NoFormat End
    -- else branch
    CASE l_Value
        WHEN 0 THEN
            RETURN;
        ELSE
            NULL;
    END CASE;
    -- with when condition
    CASE
        WHEN l_Value IS NULL THEN
            NULL;
    END CASE;
END;
/
