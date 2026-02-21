CREATE OR REPLACE PROCEDURE Update_Lowest_Paid_Employees(m IN NUMBER, n IN NUMBER)
IS
    -- Your brilliant shortcut
    emp employees%ROWTYPE;
    
    v_years_worked NUMBER;
    v_bonus NUMBER;
    v_sub_count NUMBER;
BEGIN
    FOR dept IN (
        SELECT department_id, MAX(salary) AS max_sal
        FROM employees
        WHERE department_id IS NOT NULL
        GROUP BY department_id
    ) LOOP
        BEGIN
            -- Grab the whole row at once!
            SELECT * INTO emp
            FROM (
                SELECT *
                FROM employees
                WHERE department_id = dept.department_id
                  AND MONTHS_BETWEEN(SYSDATE, hire_date) >= 12
                ORDER BY salary ASC, hire_date ASC 
            )
            WHERE ROWNUM = 1;

            -- The Golden Rule: Check the Primary Key, not the whole row
            IF emp.employee_id IS NOT NULL AND emp.salary < dept.max_sal THEN

                v_years_worked := TRUNC(MONTHS_BETWEEN(SYSDATE, emp.hire_date) / 12);
                v_bonus := m * TRUNC(v_years_worked / n);

                SELECT COUNT(*) INTO v_sub_count
                FROM employees
                WHERE manager_id = emp.employee_id;

                IF v_sub_count >= 5 THEN
                    v_bonus := v_bonus + 5000;
                END IF;

                INSERT INTO lowest_paid_employees (employee_id, department_id, saldiff, bonus, tag)
                VALUES (emp.employee_id, dept.department_id, (dept.max_sal - emp.salary), v_bonus, NULL);

            END IF;

        EXCEPTION
            WHEN OTHERS THEN
                NULL; 
        END;
    END LOOP;
    
    COMMIT;
END;
/