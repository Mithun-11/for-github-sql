SET SERVEROUTPUT ON
CREATE OR REPLACE TRIGGER trg_salary_demotion
BEFORE UPDATE OF salary ON TEMP_EMPLOYEES 
-- here table name should be temp_employees
FOR EACH ROW
DECLARE 
    min_sal NUMBER;
    is_manager NUMBER;
    min_mgr_sal NUMBER;
    dept_mgr_sal NUMBER;
    actual_mgr_id NUMBER;
BEGIN
    SELECT min(SALARY) into min_sal
    FROM EMPLOYEES 
    WHERE JOB_ID=:new.job_id and EMPLOYEE_ID!=:new.employee_id;

    if min_sal is not NULL and :new.salary<min_sal THEN
        raise_application_error(-20000,'Case 1 failed');
    end if;

    SELECT count(*) into is_manager
    FROM EMPLOYEES 
    WHERE MANAGER_ID=:new.employee_id;

    if is_manager=0 THEN
        SELECT min(m.salary) into min_mgr_sal
        FROM EMPLOYEES m 
        join EMPLOYEES sub on m.EMPLOYEE_ID=sub.MANAGER_ID
        where sub.JOB_ID=:new.job_id;

        if min_mgr_sal is not null and :new.salary>=min_mgr_sal THEN
            raise_application_error(-20001,'Case 2 failed');
        end if;

    else 
        SELECT e.SALARY,d.MANAGER_ID into dept_mgr_sal,actual_mgr_id
        FROM EMPLOYEES e 
        join DEPARTMENTS d on d.MANAGER_ID=e.EMPLOYEE_ID
        where d.DEPARTMENT_ID=:new.department_id;

        if dept_mgr_sal is not NULL and 
            :new.salary >= dept_mgr_sal and 
                :new.employee_id!= actual_mgr_id THEN

            raise_application_error(-20002,'Case 3 failed');
        END if;

    end if;

END;
/


UPDATE TEMP_EMPLOYEES
SET SALARY = 100000
WHERE EMPLOYEE_ID = 198;

