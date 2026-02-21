set SERVEROUTPUT on ;
CREATE OR REPLACE FUNCTION Exchange_Employees(
    m_id_1 in NUMBER ,
    m_id_2 in NUMBER
) 
RETURN VARCHAR2 
IS 
emp_rec_1 employees_copy%rowtype;
emp_rec_2 employees_copy%rowtype;
increase_amount NUMBER;
msg VARCHAR2(100);
    PROCEDURE print_details(p_id in NUMBER)
    is 
    r_emp employees_copy%rowtype;
    BEGIN 
        SELECT * into r_emp
        FROM employees_copy
        where employee_id=p_id ;

        
        DBMS_OUTPUT.PUT_LINE('Employee Information:');
        DBMS_OUTPUT.PUT_LINE('Employee ID: ' || r_emp.employee_id || '   Name: ' || r_emp.first_name || ' ' || r_emp.last_name);
        DBMS_OUTPUT.PUT_LINE('Email: ' || r_emp.email || '   Phone Number: ' || r_emp.phone_number);
        DBMS_OUTPUT.PUT_LINE('Hire Date: ' || r_emp.hire_date);
        DBMS_OUTPUT.PUT_LINE('Job ID: ' || r_emp.job_id || '   Salary: ' || r_emp.salary);
        DBMS_OUTPUT.PUT_LINE('Commission Percentage: ' || r_emp.commission_pct);
        DBMS_OUTPUT.PUT_LINE('Manager ID: ' || r_emp.manager_id || '   Department ID: ' || r_emp.department_id);
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');

    END ;
BEGIN
      SELECT * INTO emp_rec_1
      FROM EMPLOYEES_COPY
      WHERE MANAGER_ID=m_id_1 AND
      SALARY=(
        SELECT MIN(salary)
        FROM EMPLOYEES_COPY
        WHERE EMPLOYEES_COPY.MANAGER_ID=m_id_1
      ) and ROWNUM=1;

      SELECT * INTO emp_rec_2
      FROM EMPLOYEES_COPY
      WHERE MANAGER_ID=m_id_2 AND
      SALARY=(
        SELECT MIN(salary)
        FROM EMPLOYEES_COPY
        WHERE EMPLOYEES_COPY.MANAGER_ID=m_id_2
      ) and ROWNUM=1;

      DBMS_OUTPUT.PUT_LINE('Before EXCHANGE_EMPLOYEES( '|| m_id_1||', '|| m_id_2||') :');
      print_details(emp_rec_1.employee_id);
      print_details(emp_rec_2.employee_id);


        increase_amount := ABS(emp_rec_1.salary - emp_rec_2.salary) * 0.5;


      UPDATE EMPLOYEES_COPY
      SET MANAGER_ID=emp_rec_2.manager_id,
      department_id=emp_rec_2.department_id,
      salary=SALARY+increase_amount
      where EMPLOYEE_ID=emp_rec_1.employee_id;

      UPDATE EMPLOYEES_COPY
      SET MANAGER_ID=emp_rec_1.manager_id,
      department_id=emp_rec_1.department_id,
      salary=SALARY+increase_amount
      where EMPLOYEE_ID=emp_rec_2.employee_id;


      DBMS_OUTPUT.PUT_LINE('After EXCHANGE_EMPLOYEES( '|| m_id_1||', '|| m_id_2||') :');
      print_details(emp_rec_1.employee_id);
      print_details(emp_rec_2.employee_id);

      RETURN 'success';

END;
/

DECLARE 
msg VARCHAR2(100);
BEGIN 
    msg:=EXCHANGE_EMPLOYEES(100,145);
  END;

ROLLBACK;