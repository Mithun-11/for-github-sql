SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE LONGEST_SERVING_EMPLOYEE(
    p_region_name IN VARCHAR2
)
IS
    -- 1. Declare variables to hold the results
    v_full_name      VARCHAR2(100);
    v_job_title      jobs.job_title%TYPE;
    v_hire_date      employees.hire_date%TYPE;
    v_country_name   countries.country_name%TYPE;
    v_dept_name      departments.department_name%TYPE;
    v_city           locations.city%TYPE;
    
BEGIN
    -- 2. The Main Query (Using your Subquery Logic)
    SELECT 
        e.first_name || ' ' || e.last_name,
        j.job_title,
        e.hire_date,
        c.country_name,
        d.department_name,
        l.city
    INTO 
        v_full_name, v_job_title, v_hire_date, v_country_name, v_dept_name, v_city
    FROM 
        regions r
        JOIN countries c     ON r.region_id = c.region_id
        JOIN locations l     ON c.country_id = l.country_id
        JOIN departments d   ON l.location_id = d.location_id
        JOIN employees e     ON d.department_id = e.department_id
        JOIN jobs j          ON e.job_id = j.job_id
    WHERE 
        UPPER(r.region_name) = UPPER(p_region_name) -- Handle case-sensitivity (e.g. 'americas' vs 'Americas')
        AND e.hire_date = (
            -- Subquery: Find the earliest date for THIS region only
            SELECT MIN(e2.hire_date)
            FROM employees e2
            JOIN departments d2 ON e2.department_id = d2.department_id
            JOIN locations l2   ON d2.location_id = l2.location_id
            JOIN countries c2   ON l2.country_id = c2.country_id
            JOIN regions r2     ON c2.region_id = r2.region_id
            WHERE r2.region_name = r.region_name
        )
    AND ROWNUM = 1; -- Safety: If 2 people match the date, pick the first one found.

    -- 3. Print the Results
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Longest Serving Employee in Region: ' || p_region_name);
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Name           : ' || v_full_name);
    DBMS_OUTPUT.PUT_LINE('Job Title      : ' || v_job_title);
    DBMS_OUTPUT.PUT_LINE('Hire Date      : ' || v_hire_date);
    DBMS_OUTPUT.PUT_LINE('Country        : ' || v_country_name);
    DBMS_OUTPUT.PUT_LINE('Department     : ' || v_dept_name);
    DBMS_OUTPUT.PUT_LINE('City           : ' || v_city);
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');

EXCEPTION
    -- 4. Exception Handling
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: No employees found for region "' || p_region_name || '".');
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Error: Multiple employees found with the same earliest date.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected Error: ' || SQLERRM);
END;
/
EXEC LONGEST_SERVING_EMPLOYEE('Europe');