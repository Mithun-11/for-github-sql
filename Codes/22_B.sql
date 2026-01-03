SELECT 
    employee_id,
    first_name || ' ' || last_name AS full_name,
    department_id,
    salary * (1 + NVL(commission_pct, 0)) AS total_monthly_salary
FROM employees
WHERE first_name LIKE 'D%'
    AND SUBSTR(last_name, 4, 1) = 'n'
    AND department_id BETWEEN 20 AND 70;


SELECT JOB_ID
FROM JOB_HISTORY
WHERE (END_DATE-START_DATE)<=1500 
GROUP BY JOB_ID 
HAVING COUNT(*) >=2; 

SELECT LAST_NAME 
FROM EMPLOYEES 
WHERE MOD((LENGTH(LAST_NAME) - 
            LENGTH(TRANSLATE(LOWER(LAST_NAME),
                '@aeiou','@'))),2) !=0 ;