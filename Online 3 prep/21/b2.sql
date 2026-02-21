set SERVEROUTPUT on
CREATE OR REPLACE TRIGGER Update_LPET_Tag_Trigger
BEFORE INSERT ON lowest_paid_employees
FOR EACH ROW
DECLARE
    v_max_global_saldiff NUMBER;
BEGIN
    -- =========================================================================
    -- Step 1: The Sanity Check 
    -- Find the max(max_sal - min_sal) across all departments.
    -- =========================================================================
    SELECT MAX(MAX(salary) - MIN(salary)) 
    INTO v_max_global_saldiff
    FROM employees
    GROUP BY department_id;

    -- If the inserted saldiff is bigger than the absolute maximum possible gap, crash it.
    IF :NEW.saldiff > v_max_global_saldiff THEN
        RAISE_APPLICATION_ERROR(-20001, 'Sanity check failed: saldiff exceeds maximum global saldiff.');
    END IF;

    -- =========================================================================
    -- Step 2: Update the Tag
    -- Because this is a BEFORE INSERT trigger, we can just assign the text 
    -- directly to :NEW.tag and Oracle will save it for us automatically.
    -- =========================================================================
    IF :NEW.saldiff < 10000 THEN
        :NEW.tag := 'low';
    ELSIF :NEW.saldiff >= 10000 AND :NEW.saldiff < 20000 THEN
        :NEW.tag := 'very low';
    ELSIF :NEW.saldiff >= 20000 THEN
        :NEW.tag := 'extremely low';
    END IF;

END;
/