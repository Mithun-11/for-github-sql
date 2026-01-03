SELECT 
    'Q' || TO_CHAR(hire_date, 'Q') AS quarter,
    TO_CHAR(hire_date, 'Mon') AS month,
    COUNT(*) AS employee_count
FROM employees
GROUP BY TO_CHAR(hire_date, 'Q'), TO_CHAR(hire_date, 'Mon'),TO_CHAR(hire_date, 'MM')
ORDER BY TO_CHAR(hire_date, 'Q') ASC, TO_CHAR(hire_date, 'MM') ASC;



SELECT LPAD((FIRST_NAME || ' ' || LAST_NAME),20,' ' ) as full_name
FROM EMPLOYEES 
ORDER BY LENGTH((FIRST_NAME || ' ' || LAST_NAME)) ASC ;


SELECT 
    country_id,
    street_address || ', ' || city || ', ' || state_province || ' - ' || postal_code AS address
FROM locations
WHERE street_address IS NOT NULL 
    AND city IS NOT NULL 
    AND state_province IS NOT NULL 
    AND postal_code IS NOT NULL
ORDER BY country_id, postal_code DESC;



SELECT (FIRST_NAME || ' ' || LAST_NAME) as full_name
FROM EMPLOYEES 
WHERE LOWER(SUBSTR(FIRST_NAME,1,1)) NOT IN ('a','e','i','o','u') 
     AND UPPER(last_name) NOT LIKE '%B%'
    AND TO_CHAR(HIRE_DATE,'MM')='11' 
ORDER BY full_name;