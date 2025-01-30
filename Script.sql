-- create publications table
CREATE TABLE publications (
    Id SERIAL PRIMARY KEY,
    Fach TEXT,
    "Autor/in" TEXT,
    Titel TEXT,
    Typ TEXT,
    Meldetag DATE,
    Punktzahl FLOAT,
    ZahlOldenburgerAutoren INTEGER,
    Jahr INTEGER
);



select count(*) from publications p 



-- create dimension tables
create table dim_time (
    dimension_time_id serial primary key,
    jahr date
);

CREATE TABLE dim_title (
    title_id SERIAL PRIMARY KEY,
    title TEXT
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
select distinct titel from publications
on conflict (title) do nothing ;


insert into dim_subject (fach)
select distinct fach from publications;

insert into dim_typ (type_name)
select distinct typ from publications;

select jahr, COUNT(*)
from dim_time
group by jahr
having COUNT(*) > 1;

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
--select * from dim_title dt 

-- calculate KPIs
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
       COUNT(fp.id) AS total_publications
from fact_publications fp
group  yz year
order by year;


--select column_name
--from information_schema.columns
--where table_name = 'fact_publications'


-- 2/Which department has the most publications to offer?
select ds.fach as department, 
	   count(*) as total_publications
from fact_publications fp 
join dim_subject ds
on fp.dimension_sub_id = ds.dimension_sub_id
group by ds.fach
order by total_publications desc
limit 1;


__3/Who cooperated with other authors the most?

select da.author_name, 
       count(fp.id) as total_coauthord_papers
from fact_publications fp
join dim_author da
on fp.dimension_author_id = da.dimension_author_id
where fp.zahloldenburgerautoren >1 
group by da.author_name
order by total_coauthord_papers desc
limit 1;




--4/What are the differences in titles between departments?
 -- from before we have:
select ds.fach as department, 
	   count(*) as total_publications
from fact_publications fp 
join dim_subject ds
on fp.dimension_sub_id = ds.dimension_sub_id
group by ds.fach
order by total_publications desc;

--add column of title_id
alter table fact_publications add column title_id INT;
alter table fact_publications add foreign key (title_id) references dim_title(title_id);

select * from fact_publications

SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'fact_publications';


select fp.title_id, dt.title 
from fact_publications fp 
join dim_title dt on fp.title_id = dt.title_id
limit 10;

select * from fact_publications fp
--now


select ds.fach as department, 
       fp.titel_id as publication_title
from publications p
join dim_subject ds on fp.dimension_sub_id = ds.dimension_sub_id
where fp.titel_id is not null
order by ds.fach, fp.titel_id;






 

