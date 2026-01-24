select e1.last_name,
       count(*) highsal
  from employees e1
  join employees e2
on ( e1.salary < e2.salary )
 group by e1.employee_id,
          e1.last_name
 order by e1.last_name asc;