<h1>📊 Netflix Content Analysis</h1>

<h2>📌 Project Overview</h2>
This project analyzes Netflix’s Movies and TV Shows catalog using an end-to-end ELT pipeline built with Python and MySQL.
The focus is on analytics-oriented data engineering, where raw, messy data is transformed into clean, normalized, analysis-ready tables to answer real business questions related to content strategy, geography, genres, and growth opportunities.

<h2>📂 Dataset</h2>

- Dataset: Netflix Movies and TV Shows
- Rows : 8807
- Format: CSV
- Contains information such as:<br/>
  *	Show ID
  *	Type (Movie / TV Show)
  *	Title
  *	Director & Cast
  *	Country
  *	Date Added
  *	Release Year
  *	Rating
  *	Duration
  *	Genre (Listed In)

<h2>🎯 Business Objectives</h2>

The project aims to answer key business questions such as:
* How is Netflix’s content split between Movies and TV Shows?
* How has Netflix’s catalog grown over time?
* Which genres and countries dominate Netflix’s content library?
* How does content production differ across regions?
* What genres and regions present growth opportunities?
* How long after release does content typically get added to Netflix?

<h2>🧱 Architecture & Data Flow</h2>

    Raw CSV
       ↓
    Python (Extract & Load)
       ↓
    MySQL Raw Table (netflix_raw)
       ↓
    Staging Layer (cleaning + deduplication)
       ↓
    Normalized Dimension Tables
       ↓
    Analytics Queries


<h2>🛠️ Tech Stack</h2>

* Database: MySQL 8.x
* Language: Python (pandas, SQLAlchemy)
* IDE: VS Code
* SQL Features Used:
  * CTEs
  * Window Functions
  * String parsing & normalization
  * Date handling & transformation

<h2>🔄 Project Steps</h2>

1. 📥 Data Loading (Extract & Load)<br/>
   *	Reads Netflix CSV dataset using pandas
   *	Loads data into MySQL table netflix_raw
   *	Uses SQLAlchemy for database connectivity

2. 🧹 Data Cleaning & Staging Layer<br>
      *	Key transformations:
        - Deduplication using ROW_NUMBER() window function
        - Robust date parsing for mixed formats:
          * 06-Sep-18
          * May 28, 2016
        - ELT approach: raw data preserved, transformations done in SQL

3. 🧩 Data Modeling & Normalization<br/>
   * To avoid comma-separated values during analysis, multi-valued columns were normalized into separate tables using a numbers table technique.
   * Normalized Tables: netflix_genre, netflix_director, netflix_cast, netflix_country
   * This enables:
     - Clean joins
     - Accurate aggregations
     - Scalable analytics queries

4. 📊 Business Analysis & Insights<br/>
      *	Key Analysis Performed:
        -	Movies vs TV Shows split
        -	Year-wise catalog growth
        -	Top genres on Netflix
        -	Dominant content ratings
        -	Top content-producing countries
        -	Country-wise Movies vs TV Shows focus
        -	Genre distribution across regions
        -	Monthly content addition trends
        -	Average time gap between release and Netflix availability
        -	Mature content genre dominance
        -	Popular genres in recent releases
        -	Average movie duration by genre
        -	TV show season distribution
        -	Data quality assessment (missing metadata)
        -	Growth opportunity identification by region & genre
  
