SET SERVEROUTPUT ON 

CREATE OR REPLACE PROCEDURE RANK_JOBS (
    MIN_HIRED_COUNT IN NUMBER
)
IS 
CURSOR c is 
    SELECT j.JOB_TITLE ||'('||upper(substr(j.JOB_TITLE,1,2))||'_'||upper(substr(j.JOB_TITLE,INSTR(j.JOB_TITLE,' ')+1,3))||')' as full_job,
        count(e.EMPLOYEE_ID) as emp_count,
        avg(e.salary) as avg_sal,
        j.JOB_ID as j_id
    FROM EMPLOYEES e 
    join JOBS j on e.JOB_ID=j.JOB_ID
    where e.JOB_ID=upper(substr(j.JOB_TITLE,1,2))||'_'||upper(substr(j.JOB_TITLE,INSTR(j.JOB_TITLE,' ')+1,3))
    GROUP by j.JOB_TITLE,j.JOB_ID
    having count(e.EMPLOYEE_ID)>=MIN_HIRED_COUNT
    ORDER BY avg(e.SALARY) DESC;

    v_rank NUMBER:=0 ;
BEGIN
    FOR r in c LOOP
        v_rank:=v_rank+1;
        DBMS_OUTPUT.PUT_LINE('Rank-'||v_rank);
        DBMS_OUTPUT.PUT_LINE(r.full_job);
        DBMS_OUTPUT.PUT_LINE('Emp Hired: '||r.emp_count);
        DBMS_OUTPUT.PUT_LINE('AVG Salary: '||r.avg_sal);

        INSERT INTO JOB_RANK(JOB_ID,RANK)
        VALUES (r.j_id,v_rank);
    END LOOP;
END;
/


CREATE TABLE JOB_RANK(
    JOB_ID VARCHAR2(100),
    RANK NUMBER
);

BEGIN 
    RANK_JOBS(MIN_HIRED_COUNT=>5);
END;
/

SELECT *
FROM JOB_RANK;