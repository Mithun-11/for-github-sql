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