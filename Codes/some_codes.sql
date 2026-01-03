SELECT first_name, last_name, job_id,
    LOWER(
        REPLACE(REPLACE(first_name, ' ', ''), '_', '') || '.' ||
        REPLACE(REPLACE(last_name, ' ', ''), '_', '') || '@' ||
        REPLACE(REPLACE(job_id, ' ', ''), '_', '') || '.buet.ac.bd'
    ) AS dept_mail
FROM employees
WHERE INSTR(last_name, ' ') > 0 OR INSTR(first_name, ' ') > 0;

-- the above code shows us how to do double replace 