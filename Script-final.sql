
-----Mini project by Postgre SQL------

-- create tabel for publications :
create table publications (
    Id SERIAL primary key,
    Fach text,  
    "Autor/in" text,
    Titel text,
    Typ text,
    Meldetag date,
    Punktzahl float,
    ZahlOldenburgerAutoren integer,
    Jahr integer
);

select count(*) from publications p 



-- create dimension tables
create table dim_time (
    dimension_time_id serial primary key,
    jahr date
);

creat table dim_title (
    title_id SERIAL primary key,
    title text unique
);

create table dim_author (
    dimension_author_id serial primary key,
    author_name varchar(255)
);

create table dim_subject (
    dimension_sub_id serial primary key,
    fach varchar(255)
);

create table dim_typ (
    dimension_type_id serial primary key,
    type_name varchar(255)
);

-- create fact table
create table fact_publications (
    id serial primary key,
    dimension_time_id int,
    dimension_author_id int,
    dimension_sub_id int,
    dimension_type_id int,
    meldetag date,
    punktzahl decimal,
    zahloldenburgerautoren int,
    foreign key (dimension_time_id) references dim_time(dimension_time_id),
    foreign key (dimension_author_id) references dim_author(dimension_author_id),
    foreign key (dimension_sub_id) references dim_subject(dimension_sub_id),
    foreign key (dimension_type_id) references dim_typ(dimension_type_id)
);


-- load data into dimensions
insert into dim_time (jahr) 
select distinct to_date(jahr::text, 'YYYY') from publications;

insert into dim_author (author_name)
select distinct publications."Autor/in" from publications;

insert into dim_title (title)
select distinct titel from publications;


insert into dim_subject (fach)
select distinct fach from publications;

insert into dim_typ (type_name)
select distinct typ from publications;

select jahr, count(*)
from dim_time
group by jahr
having count(*) > 1;

select author_name, COUNT(*)
from dim_author
group by author_name
having COUNT(*) > 1;

select fach, count (*)
from dim_subject
group by fach
having count (*)>1;





-- load data into fact_publications
insert into fact_publications (
    dimension_time_id, 
    dimension_author_id, 
    dimension_sub_id, 
    dimension_type_id, 
    meldetag, 
    punktzahl, 
    zahloldenburgerautoren
)
select 
    (select dimension_time_id from dim_time where jahr = to_date(publications.jahr::text, 'YYYY')),
    (select dimension_author_id from dim_author where author_name = publications."Autor/in"),
    (select dimension_sub_id from dim_subject where fach = publications.fach),
    (select dimension_type_id from dim_typ where type_name = publications.typ),
    publications.meldetag,
    publications.punktzahl,
    publications.zahloldenburgerautoren
from publications;

select count(*) from fact_publications
--SELECT table_name 
--FROM information_schema.tables 
--WHERE table_schema = 'public'; 


-- check the data loaded
--select * from dim_time;
--select * from dim_author;
--select * from dim_subject;
--select * from dim_typ;
--select * from fact_publications;

-- --- calculate KPI 

-- total publications per year
select dt.jahr, count(fp.id) as total_publications
from fact_publications fp
join dim_time dt on fp.dimension_time_id = dt.dimension_time_id
group by dt.jahr
order by dt.jahr;

-- total publications by author
select da.author_name, count(fp.id) as total_publications
from fact_publications fp
join dim_author da on fp.dimension_author_id = da.dimension_author_id
group by da.author_name
order by total_publications desc;

-- average score by subject
select ds.fach, avg(fp.punktzahl) as avg_score
from fact_publications fp
join dim_subject ds on fp.dimension_sub_id = ds.dimension_sub_id
group by ds.fach
order by avg_score desc;

-- publications by type
select dt.type_name, count(fp.id) as total_publications
from fact_publications fp
join dim_typ dt on fp.dimension_type_id = dt.dimension_type_id
group by dt.type_name
order by total_publications desc;

-- 1. How many publications are published in a week, in a month, in a year? 
-- publications per week
select date_part('week', fp.meldetag) as week,
       count(fp.id) as total_publications
from fact_publications fp
group by week
order by week;

-- publications per month
select date_part('month', fp.meldetag) as month,
       count(fp.id) as total_publications
from fact_publications fp
group by month 
order by month ;

-- publications per year

select to_char(to_date (extract (year from fp.meldetag) || '-01-01', 'YYYY-MM-DD'), 'YYYY') as year,
       count(fp.id) AS total_publications
from fact_publications fp
group by year
order by year;


--select column_name
--from information_schema.columns
--where table_name = 'fact_publications'


-- 2. Which department has the most publications to offer?
select ds.fach as department, 
	   count(*) as total_publications
from fact_publications fp 
join dim_subject ds
on fp.dimension_sub_id = ds.dimension_sub_id
group by ds.fach
order by total_publications desc
limit 1;


-- 3. Who cooperated with other authors the most?

select da.author_name, 
       count(fp.id) as total_coauthord_papers
from fact_publications fp
join dim_author da
on fp.dimension_author_id = da.dimension_author_id
where fp.zahloldenburgerautoren >1 
group by da.author_name
order by total_coauthord_papers desc
limit 1;




--4.What are the differences in titles between departments?
 -- from before we have:

select ds.fach as department, 
	   count(*) as total_publications
from fact_publications fp 
join dim_subject ds
on fp.dimension_sub_id = ds.dimension_sub_id
group by ds.fach
order by total_publications desc;

--add column of title_id
alter table fact_publications add column title_id int;
alter table fact_publications add foreign key (title_id) references dim_title(title_id);

select * from fact_publications

select column_name 
from information_schema.columns 
where table_name = 'fact_publications';


select fp.title_id, dt.title 
from fact_publications fp 
join dim_title dt on fp.title_id = dt.title_id
limit 10;


select * from publications

--5. Which publication has the most citations (according to the given dataset)?
select ds.fach as department, 
       fp.title_id as publication_title
from fact_publications fp
join dim_subject ds on fp.dimension_sub_id = ds.dimension_sub_id
where fp.title_id is not null
order by ds.fach, fp.title_id;


---6. 10 top most authors for year year? just for finding exact day in the year you can put it in formula or use year for it too
select da.author_name, 
       count(fp.id) as total_publications
from fact_publications fp
join dim_author da on fp.dimension_author_id = da.dimension_author_id
join dim_time dt on fp.dimension_time_id = dt.dimension_time_id
where extract (year from dt.jahr) = 2016  --- it is an example year bcs question does not say it
group by da.author_name
order by total_publications desc 
limit 3;


---7. Which subject(department) has the highest average publication score in the years?

select ds.fach as department, 
       avg(fp.punktzahl) as avg_score
from fact_publications fp
join dim_subject ds on fp.dimension_sub_id = ds.dimension_sub_id
group by ds.fach
order by avg_score desc
limit 1;


---- KPI ---- 

-- 1.Unique publications published every month

select 
    date_part('year', fp.meldetag) as year, 
    date_part('month', fp.meldetag) as month,
    count(distinct fp.title_id) as unique_publications
from fact_publications fp
group by year, month
order by year, month;

--  2. Average publication for each department

select ds.fach as department, 
       avg(fp.punktzahl) as avg_publication_score
from fact_publications fp
join dim_subject ds on fp.dimension_sub_id = ds.dimension_sub_id
group by ds.fach
order by avg_publication_score desc;


-- 3. How many authors collaborate on average of each publication per year?

select
	extract(year from fp.meldetag) as year,
    avg(fp.zahloldenburgerautoren) as avg_authors_per_publication
FROM fact_publications fp
group by year
order by year;


