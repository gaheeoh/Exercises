/*Movie ( mID, title, year, director )
English: There is a movie with ID number mID, a title, a release year, and a director.

Reviewer ( rID, name )
English: The reviewer with ID number rID has a certain name.

Rating ( rID, mID, stars, ratingDate )
English: The reviewer rID gave the movie mID a number of stars rating (1-5) on a certain ratingDate.
*/

drop table if exists Movie;
drop table if exists Reviewer;
drop table if exists Rating;

create table Movie (mID int, title varchar(30), year int, director varchar(30));
create table Reviewer (rID int, name varchar(30));
create table Rating (rID int, mID int, stars float, ratingDate date);


insert into Movie values (101,	'Gone with the Wind',	1939,	'Victor Fleming');
insert into Movie values (102,	'Star Wars',	1977,	'George Lucas');
insert into Movie values (103,	'The Sound of Music',	1965,	'Robert Wise');
insert into Movie values (104,	'E.T.',	1982,	'Steven Spielberg');
insert into Movie values (105,	'Titanic',	1997,	'James Cameron');
insert into Movie values (106,	'Snow White',	1937,	NULL);
insert into Movie values (107,	'Avatar',	2009,	'James Cameron');
insert into Movie values (108,	'Raiders of the Lost Ark',	1981,	'Steven Spielberg');

insert into Reviewer values (201,	'Sarah Martinez');
insert into Reviewer values (202,	'Daniel Lewis');
insert into Reviewer values (203,	'Brittany Harris');
insert into Reviewer values (204,	'Mike Anderson');
insert into Reviewer values (205,	'Chris Jackson');
insert into Reviewer values (206,	'Elizabeth Thomas');
insert into Reviewer values (207,	'James Cameron');
insert into Reviewer values (208,	'Ashley White');

insert into Rating values (201,	101,	2,	'2011-01-22');
insert into Rating values (201,	101,	4,	'2011-01-27');
insert into Rating values (202,	106,	4,	NULL);
insert into Rating values (203,	103,	2,	'2011-01-20');
insert into Rating values (203,	108,	4	,'2011-01-12');
insert into Rating values (203,	108,	2	,'2011-01-30');
insert into Rating values (204,	101,	3	,'2011-01-09');
insert into Rating values (205,	103,	3	,'2011-01-27');
insert into Rating values (205,	104,	2	,'2011-01-22');
insert into Rating values (205,	108,	4	,NULL);
insert into Rating values (206,	107,	3	,'2011-01-15');
insert into Rating values (206,	106,	5	,'2011-01-19');
insert into Rating values (207,	107,	5	,'2011-01-20');
insert into Rating values (208,	104,	3	,'2011-01-02');


/*'Q1 Find the titles of all movies directed by Steven Spielberg. '*/
select title
from Movie
where director = 'Steven Spielberg';

/*Q2 Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order.  */

SELECT distinct year
FROM Movie, Rating
WHERe movie.mID=Rating.mID AND (stars=4 or stars=5)
order by year;

/*Q3 Find the titles of all movies that have no ratings. */

select title
from movie
where movie.mID not in (select rating.mID from rating );


/*Q5 Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars. */

 select name, title, stars, ratingDate
 from movie, rating, reviewer
 where movie.mID=Rating.mID and rating.rid=reviewer.rid
 order by name, title, stars;

/*Q6  For all cases where the same reviewer rated the same movie twice
	and gave it a higher rating the second time, return the reviewer's name and the title of the movie. */
select distinct name, title
from (	
	select A1.mID, rID, title
	from (
			select  distinct ra2.rID, ra2.mID
			from Rating Ra1, rating ra2
			where (Ra1.ratingdate<ra2.ratingdate) 
					AND (ra2.stars >ra1.stars)
					and ra1.rid=ra2.rid
					and ra2.mid=ra1.mid
					AND ((select count(*) from rating ra3  where ra3.rID=ra2.rID)=2)
		) A1
		join movie
	on A1.mID=movie.mID
	) B1 join reviewer
on reviewer.rID=B1.rID;



/*
	Q7  For each movie that has at least one rating, find the highest number of stars that movie received. 
	Return the movie title and number of stars. Sort by movie title. 
*/

	select title, max(stars) as maxstars
	from rating , movie
	where rating.mID=movie.mID
	group by title;


/* Q8. For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie.
	Sort by rating spread from highest to lowest, then by movie title. 
*/
select title, (mx-mn) as df
from (
	select title, max(stars) as mx, min(stars) as mn
	from rating , movie
	where rating.mID=movie.mID
	group by title
	) M
order by df desc, title;
;

/*
	Q9. Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. 
	(Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. 
	Don't just calculate the overall average rating before and after 1980.) 
*/
select avgbf1980-avgaf1980
from 
	(select avg(avgs) as avgbf1980
	from 
		(select title, movie.mid, avg(stars) avgs, year
		from rating, movie
		where rating.mid=movie.mid and year<1980
		group by movie.mID, title, year) BB
	) C, 

	(select avg(avgs) as avgaf1980
	from 
		(select title, movie.mid, avg(stars) avgs, year
		from rating, movie
		where rating.mid=movie.mid and year>=1980
		group by movie.mID, title, year) CC
	) D ;

/* Extra Q1 Find the names of all reviewers who rated Gone with the Wind. */
select distinct name
from movie, reviewer, rating
where title='Gone with the Wind' and movie.mid=rating.mid and reviewer.rID=rating.rID;


/*Extra Q2 For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars. */

select name, title, stars
from movie, reviewer, rating
where name=director and movie.mid=rating.mid and reviewer.rID=rating.rID;


/* 
	Extra Q3 Return all reviewer names and movie names together in a single list, alphabetized. 
	(Sorting by the first name of the reviewer and first word in the title is fine; 
	no need for special processing on last names or removing "The".) 
*/
select name
from(
	(select name as name
	from reviewer)
	union
	(select title as name
	from movie)
	) A
order by name;


/* Q4  Find the titles of all movies not reviewed by Chris Jackson.  */
select distinct title
from movie
where movie.mid not in (select distinct mID from reviewer,rating where name='Chris Jackson' and rating.rid=reviewer.rid); 
						

/* Q5  For all pairs of reviewers such that both reviewers gave a rating to the same movie,
	return the names of both reviewers. Eliminate duplicates, don't pair reviewers with themselves, 
	and include each pair only once. For each pair, return the names in the pair in alphabetical order. */
select re1.name as name1, re2.name as name2
from (
	select distinct r1.rid as rid1, r2.rid as rid2
	from rating r1, rating r2
	where r1.mid=r2.mid and r1.rid<>r2.rid
	) A, reviewer re1, reviewer re2
where rid1=re1.rid and rid2=re2.rid and re1.name < re2.name
order by name1;
and name1<name2;


/*  extra Q6 For each rating that is the lowest (fewest stars) currently in the database, 
	return the reviewer name, movie title, and number of stars. 
*/
select name, title, stars
from movie, rating, reviewer
where movie.mid=rating.mid and reviewer.rid=rating.rid and stars=(select min(ra1.stars) from rating ra1);


/* extra q7  List movie titles and average ratings, from highest-rated to lowest-rated. 
If two or more movies have the same average rating, list them in alphabetical order. 

*/
select title, avg(stars)
from rating ra2 join movie
on ra2.mid=movie.mid
group by ra2.mid, title
order by avg(stars) desc, title;


/* Extra Q8 Find the names of all reviewers who have contributed three or more ratings. 
	(As an extra challenge, try writing the query without HAVING or without COUNT.) 
*/
select name
from rating join reviewer
on rating.rid=reviewer.rid
group by name
having count(mid)>=3;

/*without having;*/
select name
from (
	select name, count(mid) as cmid
	from rating , reviewer
	where rating.rid=reviewer.rid
	group by name) A
where cmid>=3;

/* Extra Q9 Some directors directed more than one movie. 
	For all such directors, return the titles of all movies directed by them, along with the director name. 
	Sort by director name, then movie title. (As an extra challenge, try writing the query both with and without COUNT.) 
*/

/*with count*/
select title, director
from movie
where director in  (select director
					from movie
					group by director
					having count(mid)>1)
order by director, title;

/*without count*/
select title, director
from movie m3
where director in  (select distinct m1.director
					from movie m1, movie m2
					where m1.title<>m2.title and m1.director=m2.director)
order by director, title;


/* Extra Q10 Find the movie(s) with the highest average rating. 
Return the movie title(s) and average rating. 
(Hint: This query is more difficult to write in SQLite than other systems; 
you might think of it as finding the highest average rating and then choosing the movie(s) with that average rating.)
*/
select title, avg(ra1.stars) as av
from (select rid, rating.mid, stars, title	from rating join movie  on rating.mid=movie.mid)
	RA1, (select avg(stars) as avgstar
					from rating
					group by mid) B 
group by Ra1.mid, title
having avg(ra1.stars)=max(b.avgstar);


/* Extra Q11 Find the movie(s) with the lowest average rating. 
Return the movie title(s) and average rating. 
(Hint: This query may be more difficult to write in SQLite than other systems;
you might think of it as finding the lowest average rating and then choosing the movie(s) with that average rating.) 
*/

select title, avg(ra1.stars) as av
from (select rid, rating.mid, stars, title	from rating join movie  on rating.mid=movie.mid)
	RA1, (select avg(stars) as avgstar
					from rating
					group by mid) B 
group by Ra1.mid, title
having avg(ra1.stars)=min(b.avgstar);

/* Extra Q12 For each director, return the director's name together with the title(s) of the movie(s) 
they directed that received the highest rating among all of their movies, and the value of that rating. 
Ignore movies whose director is NULL. 
*/
select distinct director, title, stars
from movie M1, rating R1
where m1.mid=r1.mid and m1.director <> 'NULL'
	and not exists	(select stars from rating r2, movie 
				where r2.mid=movie.mid and movie.director=m1.director and r1.stars<r2.stars);


/*Modification Q1
Add the reviewer Roger Ebert to your database, with an rID of 209. */

insert into reviewer values (209, 'Roger Ebert');

select * from reviewer;


/*Modification Q2  Insert 5-star ratings by James Cameron for all movies in the database. Leave the review date as NULL. 
Rating ( rID, mID, stars, ratingDate )*/

insert into rating
	select distinct (select rID from reviewer where name='James Cameron') as rID, mID, 5, NULL
	from movie;


/* Modification Q3 For all movies that have an average rating of 4 stars or higher, add 25 to the release year. (Update the existing tuples; don't insert new tuples.) 
*/
update movie
set year=year+25
where mid in (select mID from rating group by mID having avg(stars)>=4);

/* Modification Q4
Remove all ratings where the movie's year is before 1970 or after 2000, and the rating is fewer than 4 stars. */

delete from rating
where mid in (select rating.mid   from rating, movie where rating.mid=movie.mid and (year<1970 OR year>2000)) and stars<4;
