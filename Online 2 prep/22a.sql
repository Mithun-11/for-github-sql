SELECT *
FROM EMPLOYEES e 
WHERE 
    -- 1. The Gatekeeper (Your Code)
    (e.DEPARTMENT_ID IN (
        SELECT DEPARTMENT_ID 
        FROM EMPLOYEES 
        GROUP BY DEPARTMENT_ID
        HAVING COUNT(*) > 5
    )
    OR e.JOB_ID IN (
        SELECT JOB_ID -- Fixed: Select JOB_ID, not *
        FROM JOBS 
        WHERE MIN_SALARY > 10000
    ))

    -- 2. The Trap (The Exclusion Logic)
    AND (
        e.DEPARTMENT_ID NOT IN (
            -- Subquery: Find Depts where Manager < Avg
            SELECT d.DEPARTMENT_ID
            FROM DEPARTMENTS d
            JOIN EMPLOYEES mgr ON d.MANAGER_ID = mgr.EMPLOYEE_ID
            WHERE mgr.SALARY < (
                -- Correlated Subquery: Avg of that specific dept
                SELECT AVG(SALARY) 
                FROM EMPLOYEES 
                WHERE DEPARTMENT_ID = d.DEPARTMENT_ID
            )
        )
        OR e.DEPARTMENT_ID IS NULL -- Safety: Don't accidentally drop people with no department (like Grant)
    );




SELECT 
    c.country_name,
    (
        SELECT COUNT(*)
        FROM departments d
        JOIN locations l ON d.location_id = l.location_id
        WHERE l.country_id = c.country_id -- The link to the outer row
    ) as department_count
FROM countries c
ORDER BY c.country_name;

-- or the same problem can be solved like 

SELECT c.COUNTRY_NAME, COUNT(d.DEPARTMENT_ID) as cnt
FROM COUNTRIES c 
LEFT JOIN LOCATIONS l ON c.COUNTRY_ID=l.COUNTRY_ID
LEFT JOIN DEPARTMENTS d on d.LOCATION_ID=l.LOCATION_ID 
GROUP BY c.COUNTRY_ID,c.COUNTRY_NAME
order by c.COUNTRY_NAME asc ;





SELECT e.EMPLOYEE_ID, (e.FIRST_NAME || ' ' || e.LAST_NAME) as full_name,
    e.SALARY,d.DEPARTMENT_NAME,j.JOB_TITLE
FROM EMPLOYEES e 
JOIN DEPARTMENTS d ON e.DEPARTMENT_ID=d.DEPARTMENT_ID
join JOBS j ON e.JOB_ID=j.JOB_ID
WHERE 1 = (  
    SELECT COUNT(DISTINCT m.SALARY)
    FROM EMPLOYEES m 
    WHERE e.DEPARTMENT_ID=m.DEPARTMENT_ID AND m.SALARY>e.SALARY
) 

-- where code is the template for finding 2nd best salary

ORDER BY 
    e.SALARY desc,
    d.DEPARTMENT_NAME,
    e.EMPLOYEE_ID ; 












-- Union of both conditions
select employee_id,
       first_name,
       salary
  from employees e
 where e.manager_id in (
   select employee_id
     from employees
    where salary > 15000
)
    or e.department_id in (
   select d.department_id
     from departments d
     join locations l
   on d.location_id = l.location_id
    where l.city = 'Seattle'
)
minus

-- Intersection of both conditions
select employee_id,
       first_name,
       salary
  from employees e
 where e.manager_id in (
   select employee_id
     from employees
    where salary > 15000
)
   and e.department_id in (
   select d.department_id
     from departments d
     join locations l
   on d.location_id = l.location_id
    where l.city = 'Seattle'
)
 order by salary desc,
          employee_id asc;








SELECT e.FIRST_NAME, e.LAST_NAME, d.DEPARTMENT_NAME, e.SALARY,
CASE 
    WHEN e.salary > 10000 THEN 'High'
    WHEN e.salary BETWEEN 5000 AND 10000 THEN 'Medium' -- "Between" is cleaner
    ELSE 'Low'
END AS salary_category
FROM EMPLOYEES e 
JOIN DEPARTMENTS d ON e.DEPARTMENT_ID = d.DEPARTMENT_ID
WHERE 
-- 1. Earns more than own Dept Average (You got this correct!)
e.SALARY > (
    SELECT AVG(em.SALARY)
    FROM EMPLOYEES em 
    WHERE em.DEPARTMENT_ID = e.DEPARTMENT_ID
)
AND 
-- 2. The Department Filter (The Fix)
e.DEPARTMENT_ID IN (
    SELECT e1.DEPARTMENT_ID
    FROM employees e1
    WHERE EXISTS (
        SELECT 1 
        FROM EMPLOYEES e2 
        WHERE e2.SALARY < (SELECT AVG(salary) FROM EMPLOYEES)
          AND e2.DEPARTMENT_ID = e1.DEPARTMENT_ID -- << CRITICAL FIX: Match the Dept!
    )
    AND EXISTS (
        SELECT 1
        FROM EMPLOYEES e2 
        WHERE e2.SALARY > (SELECT AVG(salary) FROM EMPLOYEES)
          AND e2.DEPARTMENT_ID = e1.DEPARTMENT_ID -- << CRITICAL FIX: Match the Dept!
    )
);

