   SET SERVEROUTPUT ON;
CREATE or REPLACE PROCEDURE IS_SENIOR
is 
BEGIN
    i:=0;
    FOR it IN (
        SELECT HIRE_DATE
        FROM EMPLOYEES
    )
    LOOP
        years:= (MONTHS_BETWEEN(sysdate,it.HIRE_DATE))/12;
        IF years >=10 THEN
            i:=i+1;
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(i);
END;
/

