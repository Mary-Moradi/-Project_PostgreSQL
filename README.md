Project Name: BI Mini-Project 
Course: BI Course at University of Oldenburg

Project Overview:
This project is mini project of my BI course, where I am working with a dataset containing publication records.
The goal is to create a database using PostgreSQL, apply the star schema model,and perform data analysis using SQL queries. 
I also calculate some KPIs (Key Performance Indicators) to understand trends in the publication data.

What I Did in This Project:
Explored the dataset and understood its structure.
Designed a star schema with fact and dimension tables.
Created tables in PostgreSQL using Script.sql.
Used ETL (Extract, Transform, Load) to clean and import data.
Wrote SQL queries to answer important questions about the data.
Database Schema:
The database follows a star schema, which means there is one fact table that connects to multiple dimension tables.

Fact Table: fact_publications - Stores information about publications.
Dimension Tables:
dim_author - Contains author names.
dim_subject - Lists departments (Fach).
dim_typ - Stores publication types (e.g., Journal, Conference Paper).
dim_time - Holds publication dates.
dim_title - Stores publication titles.
I created these tables using SQL and imported data from the dataset.

Key Performance Indicators (KPIs):
I calculated several KPIs to analyze the publication trends:

Total number of publications per week, month, and year.
Department with the highest number of publications.
Top 10 authors with the most publications in a given year.
Most collaborative author (who worked with others the most).
Publication with the highest citations.
Unique publications published each month.
Average publication score for each department.
Collaboration Index (average number of authors per publication per year).
I wrote SQL queries for these KPIs in Script-final.sql.

How to Run This Project:
Clone the Repository:
git clone https://github.com/Mary-Moradi/-Project_PostgreSQL.git  
cd -Project_PostgreSQL  
Set Up the Database:
Open DBeaver or use PostgreSQL psql.
Run Script.sql to create tables.
Execute Import_data.ipynb to process and load data.
Run KPI Queries:
Open Script-final.sql and execute the queries to see the results.
Files in This Repository:

Script.sql - SQL script for creating the database tables.
Import_data.ipynb - Jupyter Notebook for processing and importing data.
Script-final.sql - SQL queries for KPI analysis.
P03 - Task.pdf - Project details and requirements.
README.md - This file (explains the project).

What I Learned from This Project:
How to design a star schema for structured data storage.
How to write SQL queries to analyze and extract insights.
How to use DBeaver and PostgreSQL for database management.
How to perform ETL operations to clean and load data efficiently.
