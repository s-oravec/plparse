CREATE OR REPLACE Type BODY plparse_integer_stack AS

    ---------------------------------------------------------------------------- 
    CONSTRUCTOR FUNCTION plparse_integer_stack RETURN SELF AS Result IS
    BEGIN
        self.stack_items := plparse_integer_tab();
        RETURN;
    END;

    ---------------------------------------------------------------------------- 
    MEMBER PROCEDURE push
    (
        SELF   IN OUT plparse_integer_stack,
        p_item INTEGER
    ) IS
    BEGIN
        self.stack_items.extend();
        self.stack_items(self.stack_items.count) := p_item;
    END;

    ---------------------------------------------------------------------------- 
    MEMBER FUNCTION pop(SELF IN OUT plparse_integer_stack) RETURN INTEGER IS
        l_Result INTEGER;
    BEGIN
        IF self.stack_items.count != 0 THEN
            l_Result := self.stack_items(self.stack_items.count);
            self.stack_items.trim;
        ELSE
            raise_application_error(-20000, 'Stack is empty!');
        END IF;
        RETURN l_Result;
    END;

    ---------------------------------------------------------------------------- 
    MEMBER PROCEDURE pop(SELF IN OUT plparse_integer_stack) IS
        l_dummy PLS_INTEGER;
    BEGIN
        l_dummy := self.pop();
    END;

    ----------------------------------------------------------------------------
    MEMBER FUNCTION isEmtpy(SELF IN OUT plparse_integer_stack) RETURN INTEGER IS
    BEGIN
        IF self.stack_items.count = 0 THEN
            RETURN 1;
        ELSE
            RETURN 0;
        END IF;
    END;

END;
/
