SET SERVEROUTPUT ON 
CREATE OR REPLACE PROCEDURE RANK_JOBS IS
    -- 1. Define the cursor to calculate rankings
    CURSOR c_job_ranks IS
        SELECT 
            j.job_title,
            COUNT(e.employee_id) AS total_employees,
            ROUND(AVG(e.salary)) AS avg_salary, -- Rounded to match screenshot
            MAX(e.salary)        AS max_salary,
            MIN(e.salary)        AS min_salary
        FROM 
            employees e
            JOIN jobs j ON e.job_id = j.job_id
        GROUP BY 
            j.job_title
        ORDER BY 
            COUNT(e.employee_id) DESC, -- Rule 1: Highest employees first
            AVG(e.salary) DESC;        -- Rule 2: High avg salary breaks ties

    -- 2. Variable to track the rank number (1, 2, 3...)
    v_rank_counter NUMBER := 0;

BEGIN
    -- 3. Loop through the pre-sorted results
    FOR r_job IN c_job_ranks LOOP
        
        -- Increment rank for each row found
        v_rank_counter := v_rank_counter + 1;

        -- 4. Print in the requested format
        DBMS_OUTPUT.PUT_LINE('Rank: ' || v_rank_counter);
        DBMS_OUTPUT.PUT_LINE('-----------');
        DBMS_OUTPUT.PUT_LINE('Job Title: ' || r_job.job_title);
        DBMS_OUTPUT.PUT_LINE('Employees: ' || r_job.total_employees);
        DBMS_OUTPUT.PUT_LINE('Avg Salary: ' || r_job.avg_salary);
        DBMS_OUTPUT.PUT_LINE('Max Salary: ' || r_job.max_salary);
        DBMS_OUTPUT.PUT_LINE('Min Salary: ' || r_job.min_salary);
        DBMS_OUTPUT.PUT_LINE(''); -- Empty line for spacing
        
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);
END;
/
exec RANK_JOBS;
