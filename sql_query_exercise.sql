/*
DATABASE SYSTEM CONCEPTS中关于查询的若干例题，
并尽力给出不同的解法。
使用Notepad++打开，语言设为SQL后视觉效果更佳。
*/


/*
Retrieve the names of all instructors, along with 
their department names and department building 
name. (P66)
*/
-- solution 1 (使用cartesian product的版本):
select name, instructor.dept_name, building
from instructor, department
where instructor.dept_name = department.dept_name;

-- solution 2 (使用natural join的版本):
select name, instructor.dept_name, building
from instructor natural inner join department;

-- solution 3 (使用inner join的版本):
select name, instructor.dept_name, building
from instructor inner join department using (dept_name);

-- solution 4 (使用inner join的版本):
select name, instructor.dept_name, building
from instructor inner join department 
     on instructor.dept_name = department.dept_name;


/*
List the names of instructors along with the  
titles of courses that they teach. (P73)
*/
-- solution 1 (使用cartesian product的版本):
select name, title
from instructor, teaches, course
where instructor.ID = teaches.ID and 
      teaches.course_id = course.course_id;
	  
-- solution 2 (使用natural join的版本):
select name, title
from instructor natural join teaches, course
where teaches.course_id = course.course_id;

-- wrong solution! (You made a big mistake!):
-- course表中的dept_name是指面向哪个系开课，
-- 而非授课教师来自哪个系。	 
select name, title
from instructor natural join teaches natural join course;

-- solution 3 (使用natural join的版本):
select name, title
from (instructor natural join teaches) join course 
     using (course_id);
	 

/*
Find the names of all instructors whose salary is
greater than at least one instructor in the Biology 
department. (P75)
*/
-- solution 1 (使用cartesian product的版本):
select distinct T.name
from instructor as T, instructor as S
where T.salary > S.salary and S.dept_name = 'Biology';

-- solution 2 (使用subqueries in the from clause的版本):
select distinct T.name
from instructor as T, (select salary
                       from instructor 
                       where dept_name = 'Biology') as S
where T.salary > S.salary;

-- solution 3 (使用the with clause简化solution 2):
with Bio_dept_salary as
     (select salary
      from instructor 
      where dept_name = 'Biology')
select distinct name
from instructor, Bio_dept_salary
where instructor.salary > Bio_dept_salary.salary;	 

-- solution 4 (使用scalar subqueries的版本):
select name
from instructor 
where salary > (select min (salary)
                from instructor
                where dept_name = 'Biology');
				 				
-- solution 5 (使用set comparision的版本):
select name
from instructor
where salary > some (select salary
                     from instructor
                     where dept_name = 'Biology');
				
				
/*
Find all courses taught either in Fall 2009 or in
Spring 2010, or both. (P80)
*/
-- solution 1 (使用set Operation的版本):
(select distinct course_id
 from section
 where semester = 'Fall' and year= 2009)
union
(select distinct course_id
 from section
 where semester = 'Spring' and year= 2010);
 
-- solution 2 (使用cartesian product的版本):
select distinct S.course_id
from section as S,section as T
where ((S.semester = 'Fall' and S.year = 2009) or
      (T.semester = 'Spring' and T.year = 2010)) and
      (S.course_id = T.course_id);
	  
-- solution 3 (使用inner join的版本,与solution 2差不太多):	
select distinct course_id
from section as S join section as T using(course_id)
where (S.semester = 'Fall' and S.year = 2009) or
      (T.semester = 'Spring' and T.year = 2010);

-- solution 4 (使用set membership的版本):	  
select distinct course_id
from section 
where (semester = 'Fall' and year = 2009) or
      course_id in (select distinct course_id
                    from section
                    where semester = 'Spring' and year = 2010)
order by course_id;

-- solution 5 (使用test for empty relation的版本):
select distinct course_id
from section as S
where (semester = 'Fall' and year= 2009) or
      exists (select *
              from section as T
              where semester = 'Spring' and year= 2010 and
              S.course_id = T.course_id);
				
				
/*				
Find all the courses taught in both the Fall 2009
and Spring 2010 semesters. (P81)
*/
-- solution 1 (使用set Operation的版本):
(select course_id
 from section
 where semester = 'Fall' and year= 2009)
intersect
(select course_id
 from section
 where semester = 'Spring' and year= 2010); 

-- solution 2 (使用cartesian product的版本):
select distinct S.course_id
from section as S,section as T
where (S.semester = 'Fall' and S.year = 2009) and
      (T.semester = 'Spring' and T.year = 2010) and
      (S.course_id = T.course_id);

-- solution 3 (使用inner join的版本,与solution 2差不太多):
select course_id
from section as S join section as T using(course_id)
where (S.semester = 'Fall' and S.year = 2009) and
      (T.semester = 'Spring' and T.year = 2010);	  

-- solution 4 (使用set membership的版本):
select course_id
from section 
where semester = 'Fall' and year = 2009 and
       course_id in (select distinct course_id
                     from section
                     where semester = 'Spring' and year = 2010);

-- solution 5 (使用nested subqueries的test for empty relation的版本):					 
select distinct course_id
from section as S
where semester = 'Fall' and year= 2009 and
      exists (select *
              from section as T
              where semester = 'Spring' and year= 2010 and
              S.course_id = T.course_id);
					 

/*
Find all courses taught in the Fall 2009 semester
but not in the Spring 2010 semester. (P82)
*/
-- solution 1 (使用Set Operation的版本，也是最直观的版本):
(select course_id
 from section
 where semester = 'Fall' and year= 2009)
except
(select course_id
 from section
 where semester = 'Spring' and year= 2010);

-- wrong solution! (You made a big mistake!)
select distinct S.course_id, S.semester, S.year,
                T.semester, T.year 
from section as S,section as T
where (S.semester = 'Fall' and S.year = 2009) and
      (not(T.semester = 'Spring' and T.year = 2010)) and
      (S.course_id = T.course_id); 

-- solution 2 (使用set membership的版本):
select distinct course_id
from section
where semester = 'Fall' and year= 2009 and
      course_id not in(select course_id
                       from section
                       where semester = 'Spring' and year= 2010);

-- solution 3 (使用test for empty relation的版本):				   
select distinct course_id
from section as S
where (semester = 'Fall' and year= 2009) and
      not exists (select *
                  from section as T
                  where semester = 'Spring' and year= 2010 and
                  S.course_id = T.course_id);

					   
/*
Find the departments that have the highest average
salary (P92)
*/
-- solution 1:
select dept_name
from(select avg(salary) as avg_salary, dept_name
     from instructor
     group by dept_name
     order by avg_salary desc
     limit 1) as S;

-- solution 2:
select dept_name
from instructor
group by dept_name
having avg(salary) >= all (select avg(salary)
                          from instructor
                          group by dept_name);
						  
-- solution 3:
select dept_name
from instructor
group by dept_name
having avg(salary) = (select max (avg_salary)
                       from(select avg(salary) as avg_salary
                            from instructor
                            group by dept_name) as S)						  

-- solution 4:					
with dept_avg_salary(salary) as
     (select avg(salary)
      from instructor
      group by dept_name),
     dept_max_avg_salary(salary) as
     (select max(salary)
      from dept_avg_salary)      
select dept_name
from instructor
group by dept_name
having avg(salary) = (select salary
                      from dept_max_avg_salary);
						  

						   

