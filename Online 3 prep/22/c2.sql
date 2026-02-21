set SERVEROUTPUT on;
CREATE OR REPLACE PROCEDURE UPDATE_SALARIES IS
    v_latest_hire_date DATE;
BEGIN
    -- 1. Find the "today's date" equivalent (newest employee's hire date) 
    -- We do this ONCE outside the loop to save processing power.
    SELECT MAX(hire_date) INTO v_latest_hire_date FROM employees_copy;

    -- 2. The procedure loops through all employees
    -- We join the JOBS table right here so we don't need messy subqueries!
    FOR emp IN (
        SELECT 
            e.employee_id,
            e.salary AS old_sal,
            NVL(e.commission_pct, 0) AS comm_pct, -- NVL handles NULL commissions safely
            e.hire_date,
            j.min_salary,
            j.max_salary,
            -- Scalar subquery for average department salary
            (SELECT AVG(salary) FROM employees_copy WHERE department_id = e.department_id) AS dept_avg_sal
        FROM employees_copy e
        JOIN jobs j ON e.job_id = j.job_id
    ) LOOP
        
        DECLARE
            v_new_sal NUMBER;
            v_months_worked NUMBER;
        BEGIN
            -- Calculate months worked against the newest employee's hire date
            v_months_worked := MONTHS_BETWEEN(v_latest_hire_date, emp.hire_date);

            -- Condition 1: Only update if work period is MORE than 1 year (12 months)
            IF v_months_worked > 12 THEN
                
                -- Calculate the new salary formula
                v_new_sal := emp.old_sal + 
                             (emp.comm_pct * emp.old_sal) + 
                             (0.1 * emp.min_salary) + 
                             (0.1 * emp.dept_avg_sal);

                -- Condition 2: Cap at maximum salary
                IF v_new_sal > emp.max_salary THEN
                    v_new_sal := emp.max_salary;
                END IF;

                -- Perform the update on the copy table
                UPDATE employees_copy
                SET salary = v_new_sal
                WHERE employee_id = emp.employee_id;
                
            END IF;

        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error on employee ' || emp.employee_id || ': ' || SQLERRM);
        END;
        
    END LOOP;
    
    -- Save the updates
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Fatal Procedure Error: ' || SQLERRM);
END;
/


SELECT e.employee_id, e.salary as Old_Salary, ec.salary as New_Salary,
j.min_salary, j.max_salary, e.hire_date
FROM employees_copy ec join employees e
on ec.employee_id=e.employee_id
join jobs j on e.job_id=j.job_id;