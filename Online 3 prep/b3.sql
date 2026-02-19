CREATE TABLE Transfers (
    employee_id NUMBER,
    employee_working_instead_of_him NUMBER,
    new_department NUMBER,
    transfer_date DATE
);

SET SERVEROUTPUT on;

CREATE or REPLACE TRIGGER trig_employee_transfer
BEFORE UPDATE OF department_id on employees_copy 
for EACH ROW
DECLARE
    PRAGMA autonomous_transaction;
    v_rep_emp_id NUMBER;
    v_old_mgr_count NUMBER;
    v_new_mgr_id NUMBER;
BEGIN
    IF :old.manager_id is not NULL then 
        BEGIN
            SELECT employee_id INTO v_rep_emp_id
            FROM (
                SELECT employees_copy.EMPLOYEE_ID
                FROM employees_copy
                WHERE employees_copy.MANAGER_ID= :OLD.manager_id
                and employees_copy.EMPLOYEE_ID != :old.employee_id
                ORDER BY abs(SALARY-:old.salary) asc
            )
            WHERE ROWNUM=1;

            UPDATE employees_copy
            SET SALARY=SALARY + (0.5* :old.salary)
            WHERE EMPLOYEE_ID= v_rep_emp_id;
        END;

        BEGIN 
            SELECT COUNT(*) into v_old_mgr_count
            FROM employees_copy
            WHERE MANAGER_ID=:old.manager_id;

            SELECT employee_id into v_new_mgr_id
            FROM (
                SELECT m.EMPLOYEE_ID 
                FROM employees_copy m
                WHERE m.DEPARTMENT_ID= :new.department_id
                and m.EMPLOYEE_ID IN (SELECT manager_id FROM employees_copy)
                ORDER BY abs((
                    SELECT count(*)
                    from employees_copy e 
                    where e.manager_id=m.EMPLOYEE_ID
                )-v_old_mgr_count)
            )
            WHERE ROWNUM=1;

            :new.manager_id := v_new_mgr_id;
        END;
        END IF;

      -- TASK 3: Log the transfer
    INSERT INTO Transfers (employee_id, employee_working_instead_of_him, new_department, transfer_date) 
    VALUES (:OLD.employee_id, v_rep_emp_id, :NEW.department_id, SYSDATE);

    -- 2. The Mandatory Save
    COMMIT;  
END;
/


UPDATE EMPLOYEES_COPY
SET DEPARTMENT_ID=90
WHERE EMPLOYEE_ID=105;

SELECT * FROM TRANSFERS;