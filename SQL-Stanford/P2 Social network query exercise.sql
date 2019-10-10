/*Highschooler ( ID, name, grade )
English: There is a high school student with unique ID and a given first name in a certain grade.

Friend ( ID1, ID2 )
English: The student with ID1 is friends with the student with ID2. 
Friendship is mutual, so if (123, 456) is in the Friend table, so is (456, 123).

Likes ( ID1, ID2 )
English: The student with ID1 likes the student with ID2.
Liking someone is not necessarily mutual, so if (123, 456) is in the Likes table, there is no guarantee that (456, 123) is also present. 

*/

/* Q1 Find the names of all students who are friends with someone named Gabriel. */



select h1.name
from friend, Highschooler H1, Highschooler H2
where id1=h1.id and id2=h2.id and h2.name='Gabriel';


/*
	Q2  For every student who likes someone 2 or more grades younger than themselves,
	return that student's name and grade, and the name and grade of the student they like. 
*/
select h1.name, h1.grade, h2.name, h2.grade
from Likes, Highschooler H1, Highschooler H2
where id1=h1.id and id2=h2.id and h2.grade <= h1.grade-2


/*  
	Q3 For every pair of students who both like each other, return the name and grade of both students. 
	Include each pair only once, with the two names in alphabetical order. 

*/

select h1.name, h1.grade, h2.name, h2.grade
from Likes ,  Highschooler H1, Highschooler H2
where id1=h1.id and id2=h2.id and h1.name < h2.name and exists (select *
											from Likes L2
											where likes.id1=L2.id2 and likes.id2=l2.id1 )
order by h1.name, h2.name ;

/*

	Q4  Find all students who do not appear in the Likes table (as a student who likes or is liked) 
	and return their names and grades. Sort by grade, then by name within each grade. 

	*/

select name, grade
from Highschooler
where  not exists (select * from (select id1 as list from likes union select id2 as list from likes) A where list=id)
order by grade, name;


/* 
	Q5 For every situation where student A likes student B, but we have no information about whom B likes 
	(that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades. 
	*/

select h1.name, h1.grade, h2.name, h2.grade
from Likes L1, Highschooler H1, Highschooler H2
where id1=h1.id and id2=h2.id and not exists (select l1.id1 from likes L2 where L1.id2=l2.id1);


/*

	Q6  Find names and grades of students who only have friends in the same grade. 
	Return the result sorted by grade, then by name within each grade. 

	*/

select distinct name, grade
from friend f2, Highschooler
where f2.id1=id and f2.id1 not in (select f1.id1
				from friend f1, Highschooler H1, Highschooler H2
				where f1.id1=h1.id and f1.id2=h2.id and h1.grade<>h2.grade)
order by grade, name;


/*

	Q7 For each student A who likes a student B where the two are not friends, find if they have a friend C in common 
	(who can introduce them!). For all such trios, return the name and grade of A, B, and C. 

*/

select (select name  from Highschooler where id=likes.id1) as Aname ,
		(select grade  from Highschooler where id=likes.id1) as Agrade,
		(select name  from Highschooler where id=likes.id2) as Bname ,
		(select grade  from Highschooler where id=likes.id2) as Bgrade,
		(select name  from Highschooler where id=f1.id2) as Cname ,
		(select grade  from Highschooler where id=f1.id2) as Cgrade
from Likes, friend f1, friend f2
where  not exists (select * from friend where likes.id1=friend.id1 and likes.id2=friend.id2)
		and f1.id1=likes.id1 and likes.id2=f2.id1 and f1.id2=f2.id2;


/*

 Q8 Find the difference between the number of students in
 the school and the number of different first names. 

 */

select numstudent-numname
from (	
	select count(*) as numstudent, (select count(*)  from (select distinct name from Highschooler) A) as numname
	from Highschooler
	) B
;

/* Q9  Find the name and grade of all students who are liked by more than one other student.  */
select name, grade
from likes, Highschooler
where id2=id
group by id2,name, grade
having count(id2)>1;


/* Extra Q1 
	For every situation where student A likes student B, but student B likes a different student C, return the names and grades of A, B, and C. 
*/
select (select name  from Highschooler where id=l1.id1) as Aname ,
		(select grade  from Highschooler where id=l1.id1) as Agrade ,
		(select name  from Highschooler where id=l1.id2) as Bname ,
		(select grade  from Highschooler where id=l1.id2) as Bgrade ,
		(select name  from Highschooler where id=l2.id2) as Cname ,
		(select grade  from Highschooler where id=l2.id2) as Cgrade 
from likes l1 , likes l2
where l1.id2=l2.id1 and l1.id1 <> l2.id2 



/* extra Q2

 Find those students for whom all of their friends are in different grades from themselves. Return the students' names and grades. 
 */


select distinct h1.name, h1.grade
from friend, Highschooler H1, Highschooler H2
where id1=h1.id  and  id2=h2.id
except
select distinct h1.name, h1.grade
from friend, Highschooler H1, Highschooler H2
where id1=h1.id  and  id2=h2.id and h1.grade=h2.grade;




/*extra Q3
What is the average number of friends per student? (Your result should be just one number.*/
select avg(fnum)
from (
select count(*) as fnum
from friend
group by id1) A
;


/* Extra Q4

Find the number of students who are either friends with Cassandra or are friends of friends of Cassandra. 
Do not count Cassandra, even though technically she is a friend of a friend. 

*/
select  count(distinct id1)-1
from friend
where id2 in (select distinct id2
				from friend, Highschooler H1, Highschooler H2
				where  (id2=h2.id and h2.name='Cassandra')
				or (id1=h1.id and  h1.name='Cassandra'));


/*Extra Q5  Find the name and grade of the student(s) with the greatest number of friends. */
with friend_num (fcount, id1) as
	(select count(*), id1
	from friend
	group by id1)
select name, grade
from (select max(fcount) as mx from friend_num) F1, friend_num, Highschooler
where mx=fcount and id=id1;

/*SQLite...*/
select name, grade
from (select max(fcount) as mx from (select count(*) as fcount, id1
	from friend
	group by id1) A) F1	, 
	(select count(*) as fcount, id1
	from friend
	group by id1) F2	, Highschooler
where mx=fcount and id=id1;


/* Modification Q1 
It's time for the seniors to graduate. Remove all 12th graders from Highschooler.  */



delete from Highschooler
where grade=12;

/* Modification Q2
If two students A and B are friends, and A likes B but not vice-versa, remove the Likes tuple. */


delete from likes
where likes.id1=
	(select id1
	from (select likes.id1, likes.id2 from friend, likes where likes.id1=friend.id1 and likes.id2=friend.id2) A
	where not exists (select *
						from likes
						where A.id2=likes.id1 and A.id1=likes.id2) and likes.id2=A.id2);

/* Modification Q3
For all cases where A is friends with B, and B is friends with C, add a new friendship for the pair A and C. 
Do not add duplicate friendships, friendships that already exist, or friendships with oneself. (This one is a bit challenging; congratulations if you get it right.) 
*/

insert into friend
	select distinct f1.id1 , f2.id2
	from friend f1, friend f2
	where f1.id2=f2.id1 and not f1.id1=f2.id2 and not exists (select * from friend where f1.id1=friend.id1 and f2.id2=friend.id2);