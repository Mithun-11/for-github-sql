SELECT e.last_name -- The Manager's Name
FROM   departments d
JOIN   employees e ON d.manager_id = e.employee_id -- Link Dept to its Official Head
JOIN   locations l ON d.location_id = l.location_id
WHERE  l.city IN ('Toronto', 'Oxford')
AND    d.department_id IN (
    -- The "Department Level" Check
    SELECT department_id
    FROM   employees
    GROUP BY department_id
    HAVING AVG(salary) > (SELECT AVG(salary) FROM employees)
);










SELECT * 
FROM EMPLOYEES
WHERE DEPARTMENT_ID IN (
    SELECT DEPARTMENT_ID
    FROM EMPLOYEES
    GROUP BY DEPARTMENT_ID
    HAVING COUNT(*)>5
) AND 
SALARY > ( SELECT AVG(salary) FROM EMPLOYEES);




SELECT
    e.first_name || ' ' || e.last_name AS full_name,
    e.salary,
    d.department_name,
    CASE
        WHEN e.salary > (1.7 * dept_stats.avg_salary) THEN 'Stable High Earner'
        ELSE 'Dept Above Avg'
    END AS status_label
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
JOIN (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
) dept_stats
    ON e.department_id = dept_stats.department_id
WHERE d.manager_id IS NOT NULL
  AND e.salary > dept_stats.avg_salary
  AND NOT EXISTS (
      SELECT 1
      FROM job_history jh
      WHERE jh.employee_id = e.employee_id
  );







SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.department_id,
    e.job_id,
    e.salary
FROM employees e
JOIN jobs j
    ON e.job_id = j.job_id
WHERE e.department_id IN (
        SELECT department_id
        FROM employees
        GROUP BY department_id
        HAVING COUNT(*) > 5
    )
   OR j.min_salary > 10000;




SELECT * 
FROM EMPLOYEES e 
JOIN JOBS j ON e.JOB_ID=j.JOB_ID
WHERE j.MIN_SALARY>10000 OR 
e.DEPARTMENT_ID IN (
    SELECT EMPLOYEES.DEPARTMENT_ID
    FROM EMPLOYEES
    GROUP BY EMPLOYEES.DEPARTMENT_ID
    HAVING COUNT(*)>5
)

MINUS 
SELECT * 
FROM EMPLOYEES e 
JOIN JOBS j ON e.JOB_ID=j.JOB_ID
WHERE j.MIN_SALARY>10000 AND
e.DEPARTMENT_ID IN (
    SELECT EMPLOYEES.DEPARTMENT_ID
    FROM EMPLOYEES
    GROUP BY EMPLOYEES.DEPARTMENT_ID
    HAVING COUNT(*)>5
); 


-- OR another neat way 

SELECT 
    e.employee_id, 
    e.first_name || ' ' || e.last_name AS full_name, 
    e.department_id, 
    e.job_id, 
    e.salary
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
-- Join the department counts (Derived Table for performance)
LEFT JOIN (
    SELECT department_id 
    FROM employees 
    GROUP BY department_id 
    HAVING COUNT(*) > 5
) large_depts ON e.department_id = large_depts.department_id
WHERE 
    (large_depts.department_id IS NOT NULL AND j.min_salary <= 10000) -- Cond 1 True, Cond 2 False
    OR 
    (large_depts.department_id IS NULL AND j.min_salary > 10000);     -- Cond 1 False, Cond 2 True