SET SERVEROUTPUT on;

CREATE or REPLACE FUNCTION IS_READY_FOR_PROMOTION(
    em_id IN NUMBER
)
RETURN VARCHAR2
IS 
total_day NUMBER;
midpoint NUMBER;
em_sal NUMBER;
sub_count NUMBER;
msg VARCHAR2(100);

BEGIN
    SELECT (MONTHS_BETWEEN(SYSDATE,HIRE_DATE))/12,salary 
        into total_day,em_sal
    FROM EMPLOYEES 
    WHERE EMPLOYEE_ID=em_id;

    SELECT COUNT(*) into sub_count
    from EMPLOYEES
    WHERE MANAGER_ID=em_id;

    SELECT (j.min_salary + j.max_salary) / 2 INTO midpoint
    FROM EMPLOYEES e
    JOIN JOBS j ON e.job_id = j.job_id
    WHERE e.employee_id = em_id;

    IF total_day>=5 and em_sal>midpoint AND sub_count>0 THEN
        msg:='YES';
    ELSE
        msg:='NO';
    END IF;

    RETURN msg;

    EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
            RETURN 'Employee is not present in database.' ; 
        WHEN OTHERS THEN 
            RETURN 'I dont know what happened!' ;

END;
/

-- better solution

BEGIN
    -- We select all 4 pieces of information in one go
    -- and dump them directly into the 4 variables.
    SELECT 
        (MONTHS_BETWEEN(SYSDATE, e.hire_date)) / 12,           -- 1. Years worked
        e.salary,                                              -- 2. Current salary
        (j.min_salary + j.max_salary) / 2,                     -- 3. Job Midpoint
        (SELECT COUNT(*) FROM employees sub 
         WHERE sub.manager_id = e.employee_id)                 -- 4. Subordinate Count
         
    INTO 
        total_day, 
        em_sal, 
        midpoint, 
        sub_count
        
    FROM employees e
    JOIN jobs j ON e.job_id = j.job_id
    WHERE e.employee_id = em_id;

    -- Now all your variables are populated and ready to evaluate!
    IF total_day >= 5 AND em_sal > midpoint AND sub_count > 0 THEN
        RETURN 'YES';
    ELSE
        RETURN 'NO';
    END IF;

EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
        RETURN 'Employee is not present in database.'; 
    WHEN OTHERS THEN 
        RETURN 'I dont know what happened!';
END;



BEGIN
    FOR emp IN (SELECT employee_id FROM employees ORDER BY employee_id) LOOP
        DBMS_OUTPUT.PUT_LINE('IS ' || emp.employee_id || ' READY FOR PROMOTION? ' || IS_READY_FOR_PROMOTION(emp.employee_id));
    END LOOP;
END;
/