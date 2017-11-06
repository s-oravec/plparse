CREATE OR REPLACE PROCEDURE fix_parser_if IS
BEGIN
    -- if then single end if
    IF TRUE THEN
        NULL;
    END IF;
    -- if then multi end if
    IF TRUE THEN
        NULL;
        NULL;
    END IF;
    -- if then single else single end if
    IF TRUE THEN
        NULL;
    ELSE
        NULL;
    END IF;
    -- if then single elsif then single else single end if
    IF TRUE THEN
        NULL;
    ELSIF FALSE THEN
        NULL;
    ELSE
        NULL;
    END IF;
END;
/
