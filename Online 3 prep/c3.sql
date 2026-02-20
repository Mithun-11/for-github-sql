SET SERVEROUTPUT on;

CREATE TABLE Demotions (
    employee_id NUMBER,
    current_salary NUMBER,
    status VARCHAR2(20),
    demotion_date DATE
);


CREATE OR REPLACE TRIGGER trg_salary_demotion
BEFORE UPDATE OF salary ON employees
FOR EACH ROW
DECLARE
    -- The Cheat Code to avoid Mutating Table errors
    PRAGMA AUTONOMOUS_TRANSACTION;
    
    v_current_date DATE;
    v_sub_count NUMBER;
    v_highest_sub_id NUMBER;
BEGIN
    -- Condition: Did the salary decrease by MORE than 20%?
    -- Math: (Old - New) / Old gives us the percentage of the drop.
    IF (:OLD.salary - :NEW.salary) / :OLD.salary > 0.20 THEN
        
        -- Get the "current date" (hire date of the newest employee)
        SELECT MAX(hire_date) INTO v_current_date 
        FROM employees;

        -- Check if this employee is a manager (do they have subordinates?)
        SELECT COUNT(*) INTO v_sub_count FROM employees WHERE manager_id = :OLD.employee_id;

        -- Scenario 1: Not a manager
        IF v_sub_count = 0 THEN
            INSERT INTO Demotions (employee_id, current_salary, status, demotion_date)
            VALUES (:OLD.employee_id, :NEW.salary, 'waiting', v_current_date);
            
        -- Scenario 2: Is a manager (Time to switch!)
        ELSE
            BEGIN
                -- 1. Find the highest-paid employee under them
                SELECT employee_id INTO v_highest_sub_id
                FROM (
                    SELECT employee_id 
                    FROM employees 
                    WHERE manager_id = :OLD.employee_id
                    ORDER BY salary DESC
                ) WHERE ROWNUM = 1;

                -- 2. The chosen subordinate takes the manager's place (reports to the big boss)
                UPDATE employees 
                SET manager_id = :OLD.manager_id 
                WHERE employee_id = v_highest_sub_id;

                -- 3. All the other subordinates now report to this newly promoted person
                UPDATE employees 
                SET manager_id = v_highest_sub_id 
                WHERE manager_id = :OLD.employee_id 
                  AND employee_id != v_highest_sub_id;

                -- 4. The demoted manager now reports to their former subordinate
                -- We use :NEW so we don't accidentally lock the database!
                :NEW.manager_id := v_highest_sub_id;

                -- 5. Log it as 'done'
                INSERT INTO Demotions (employee_id, current_salary, status, demotion_date)
                VALUES (:OLD.employee_id, :NEW.salary, 'done', v_current_date);
                
            -- Safety bubble in case something goes wrong
            EXCEPTION
                WHEN NO_DATA_FOUND THEN NULL;
            END;
        END IF;

        -- The mandatory save for the PRAGMA command
        COMMIT;
    END IF;
END;
/