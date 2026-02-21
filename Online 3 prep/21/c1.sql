CREATE TABLE TEMP_EMPLOYEES (
EMPLOYEE_ID VARCHAR2(10),
NAME VARCHAR2(100),
EMAIL VARCHAR2(50),
MANAGER_ID NUMBER(4,0),
MANAGER_CRED VARCHAR2(20)
);
INSERT INTO TEMP_EMPLOYEES (EMPLOYEE_ID, NAME, EMAIL, MANAGER_ID)
SELECT EMPLOYEE_ID, FIRST_NAME || ' ' || LAST_NAME, EMAIL, MANAGER_ID
FROM EMPLOYEES;

SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE POPULATE_CREDS(
    MIN_EMP_COUNT IN NUMBER,
    MIN_JOB_COUNT IN NUMBER
) IS

    job_served NUMBER;
    emp_managed NUMBER;
    v_cred VARCHAR2(20);

BEGIN
    -- Added m.EMAIL to your cursor so we can use it to build the credential
    FOR mgr in (
        SELECT DISTINCT m.EMPLOYEE_ID as mgr_id, m.EMAIL
        FROM EMPLOYEES m 
        JOIN EMPLOYEES sub ON m.EMPLOYEE_ID = sub.MANAGER_ID
    ) LOOP


    -- or we can do like 
    -- -- The clean cursor without DISTINCT or JOINs
    -- FOR mgr in (
    --     SELECT employee_id AS mgr_id, email
    --     FROM employees
    --     WHERE employee_id IN (
    --         SELECT manager_id 
    --         FROM employees 
    --         WHERE manager_id IS NOT NULL
    --     )
    -- ) LOOP
        -- Keep your exact same job_served and emp_managed logic here!

        -- 1. Count past jobs and add 1 for the current job
        SELECT COUNT(*) INTO job_served
        FROM JOB_HISTORY
        WHERE EMPLOYEE_ID = mgr.mgr_id;

        job_served := job_served + 1;

        -- 2. Count subordinates
        SELECT COUNT(*) INTO emp_managed
        FROM EMPLOYEES
        WHERE MANAGER_ID = mgr.mgr_id;

        -- 3. Evaluate Eligibility
        IF job_served >= MIN_JOB_COUNT OR emp_managed >= MIN_EMP_COUNT THEN
            
            -- Build the string: First 2 + '**' + Last 2 + '-' + Count
            v_cred := SUBSTR(mgr.EMAIL, 1, 2) || '**' || SUBSTR(mgr.EMAIL, -2, 2) || '-' || emp_managed;
            
            -- Perform the update on the TEMP table
            UPDATE TEMP_EMPLOYEES
            SET MANAGER_CRED = v_cred
            WHERE EMPLOYEE_ID = mgr.mgr_id;
            
        END IF;

    END LOOP;
    
    -- Always commit your updates at the end of a procedure!
    COMMIT;
END;
/


-- or another solve given by gemini 

CREATE OR REPLACE PROCEDURE POPULATE_CREDS(
    MIN_EMP_COUNT IN NUMBER,
    MIN_JOB_COUNT IN NUMBER
) IS
    v_cred VARCHAR2(20);
BEGIN
    -- 1 & 2: The "Fat Cursor" does all the heavy lifting at once
    FOR mgr IN (
        SELECT 
            m.employee_id, 
            m.email,
            sub.emp_count AS emp_managed, 
            NVL(jh.past_jobs, 0) + 1 AS job_served
        FROM employees m
        JOIN (
            SELECT manager_id, COUNT(*) as emp_count 
            FROM employees 
            WHERE manager_id IS NOT NULL 
            GROUP BY manager_id
        ) sub ON m.employee_id = sub.manager_id
        LEFT JOIN (
            SELECT employee_id, COUNT(*) as past_jobs 
            FROM job_history 
            GROUP BY employee_id
        ) jh ON m.employee_id = jh.employee_id
    ) LOOP

        -- 3: The logic is now instantly evaluated in memory without extra queries
        IF mgr.job_served >= MIN_JOB_COUNT OR mgr.emp_managed >= MIN_EMP_COUNT THEN
            
            v_cred := SUBSTR(mgr.email, 1, 2) || '**' || SUBSTR(mgr.email, -2, 2) || '-' || mgr.emp_managed;
            
            UPDATE TEMP_EMPLOYEES
            SET MANAGER_CRED = v_cred
            WHERE EMPLOYEE_ID = mgr.employee_id;
            
        END IF;

    END LOOP;
    
    COMMIT;
END;
/

