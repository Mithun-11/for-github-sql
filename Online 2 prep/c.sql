SELECT 
    e.employee_id, 
    e.first_name, 
    e.last_name, 
    e.salary, 
    d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN (
    SELECT department_id, AVG(salary) as avg_sal, COUNT(*) as emp_cnt
    FROM employees
    GROUP BY department_id
) stats ON e.department_id = stats.department_id
WHERE stats.emp_cnt > 4
  AND e.salary > stats.avg_sal;




SELECT 
    e.employee_id, 
    e.first_name, 
    e.salary,
    CASE 
        WHEN e.salary > mgr.salary THEN 'Higher Than Manager'
        ELSE 'Above Dept Avg'
    END AS condition_type
FROM employees e
LEFT JOIN employees mgr ON e.manager_id = mgr.employee_id
JOIN (
    SELECT department_id, AVG(salary) as avg_sal
    FROM employees
    GROUP BY department_id
) stats ON e.department_id = stats.department_id
WHERE e.salary > mgr.salary 
   OR e.salary > stats.avg_sal;



SELECT 
    e.employee_id, 
    e.first_name || ' ' || e.last_name AS full_name,
    d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN locations l ON d.location_id = l.location_id
JOIN employees mgr ON e.manager_id = mgr.employee_id
JOIN departments dm ON mgr.department_id = dm.department_id
JOIN locations lm ON dm.location_id = lm.location_id
WHERE l.city = lm.city;








