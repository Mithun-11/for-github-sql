set SERVEROUTPUT on;
CREATE OR REPLACE PROCEDURE LONGEST_SERVING_EMPLOYEE_PRAC(
    v_region regions.region_name%TYPE
)
IS
full_name VARCHAR2(100);
v_job_title jobs.JOB_TITLE%TYPE;
v_hire_date DATE;
v_country countries.COUNTRY_NAME%TYPE;
v_dept departments.DEPARTMENT_NAME%TYPE;
v_city locations.CITY%TYPE;

BEGIN
    SELECT
        e.FIRST_NAME|| ' '|| e.LAST_NAME,
        j.JOB_TITLE,
        e.HIRE_DATE,
        c.COUNTRY_NAME,
        d.DEPARTMENT_NAME,
        l.CITY
        INTO full_name,v_job_title,v_hire_date,v_country,v_dept,v_city
    FROM EMPLOYEES e 
    JOIN JOBS j on e.JOB_ID=j.JOB_ID
    join DEPARTMENTS d on e.DEPARTMENT_ID=d.DEPARTMENT_ID
    join LOCATIONS l on l.LOCATION_ID=d.LOCATION_ID
    join COUNTRIES c on c.COUNTRY_ID=l.COUNTRY_ID
    join REGIONS r on r.REGION_ID=c.REGION_ID
    WHERE r.REGION_NAME=v_region 
    and e.EMPLOYEE_ID = (
        select e2.EMPLOYEE_ID
        from EMPLOYEES e2
        JOIN DEPARTMENTS d2 on e2.DEPARTMENT_ID=d2.DEPARTMENT_ID
        join LOCATIONS l2 on d2.LOCATION_ID=l2.LOCATION_ID
        join COUNTRIES c2 on c2.COUNTRY_ID=l2.COUNTRY_ID
        join REGIONS r2 on r2.REGION_ID=c2.REGION_ID
        where r2.REGION_NAME=v_region 
        ORDER BY e2.HIRE_DATE asc
        FETCH FIRST 1 ROW ONLY 
        -- this fetch first isn't in sql 11g
    ) ;


    DBMS_OUTPUT.PUT_LINE('Longest serving in region'|| v_region);
    DBMS_OUTPUT.PUT_LINE('Name: '||full_name);
    DBMS_OUTPUT.PUT_LINE('Job Title: '||v_job_title);
    DBMS_OUTPUT.PUT_LINE('Hire Date: '|| v_hire_date);
    DBMS_OUTPUT.PUT_LINE('Country: '|| v_country);
    DBMS_OUTPUT.PUT_LINE('Department: '||v_dept);
    DBMS_OUTPUT.PUT_LINE('City: '||v_city);

END;
/


 exec LONGEST_SERVING_EMPLOYEE_PRAC('Americas');