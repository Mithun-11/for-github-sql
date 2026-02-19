set SERVEROUTPUT on;
CREATE OR REPLACE PROCEDURE LOCATION_SALARY_REPORT IS
    CURSOR c IS 
        SELECT 
            count(e.EMPLOYEE_ID) as em_count,
            round(avg(e.salary),2) as avg_sal,
            l.city as c_city,
            
            (SELECT j.job_title
                FROM employees e2
                JOIN jobs j ON e2.job_id = j.job_id
                JOIN departments d2 ON e2.department_id = d2.department_id
                WHERE d2.location_id = l.location_id -- Correlated to the outer query's location
                AND e2.salary = (
                    -- Sub-subquery to find the max salary for THIS location
                    SELECT MAX(e3.salary)
                    FROM employees e3
                    JOIN departments d3 ON e3.department_id = d3.department_id
                    WHERE d3.location_id = l.location_id
                )
                AND ROWNUM = 1 -- Added this tiny safety net so it doesn't crash during your demo if there's a tie
            ) AS high

        FROM EMPLOYEES e 
        join DEPARTMENTS d on d.DEPARTMENT_ID=e.DEPARTMENT_ID
        join LOCATIONS l on l.LOCATION_ID=d.LOCATION_ID
        GROUP BY l.LOCATION_ID,l.CITY
        ORDER by count(e.EMPLOYEE_ID) asc, avg(e.salary) DESC;
    
    v_rank NUMBER;
BEGIN
    v_rank:=0;
    FOR r_jobs in c LOOP
        v_rank:=v_rank+1;
         DBMS_OUTPUT.PUT_LINE('Rank: ' || v_rank || 
                             ' | City: ' || r_jobs.c_city || 
                             ' | Employees: ' || r_jobs.em_count || 
                             ' | Avg Salary: ' || r_jobs.avg_sal || 
                             ' | Highest Paying Job: ' || r_jobs.high);
    END LOOP;
END;
/ 

exec LOCATION_SALARY_REPORT;
    

        
