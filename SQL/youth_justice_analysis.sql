/*
YOUTH JUSTICE SUPERVISION ANALYSIS
Victoria Youth Justice Dataset (2020–21 to 2024–25)

Business Question:
How have youth justice supervision levels in Victoria changed over the past five years across supervision types and demographic groups?

Purpose:
Validate data quality and analyse supervision trends
across demographic groups and supervision types to
support trends and evidence-based reporting.
*/

-- SECTION 1: DATA VALIDATION

/*Purpose:
Check for missing values across all key variables */
SELECT
    SUM(CASE WHEN Year IS NULL THEN 1 ELSE 0 END) AS Year_Null,
    SUM(CASE WHEN Sex IS NULL THEN 1 ELSE 0 END) AS Sex_Null,
    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS Age_Null,
    SUM(CASE WHEN Indigenous_status IS NULL THEN 1 ELSE 0 END) AS Indigenous_Status_Null,
    SUM(CASE WHEN Avg_daily_counts IS NULL THEN 1 ELSE 0 END) AS Avg_Daily_Counts_Null,
    SUM(CASE WHEN Supervision_type IS NULL THEN 1 ELSE 0 END) AS Supervision_Type_Null
FROM Youth_Justice;

/*
Purpose:
Validate categorical values.
*/
select distinct(sex)
from Youth_Justice;

select distinct(year)
from Youth_Justice;

select distinct(Indigenous_status)
from Youth_justice;

select distinct(Supervision_type)
from Youth_justice;

select distinct(Age)
from Youth_justice;

/*
Purpose:
Verify numerical range of supervision counts.
*/
select min(Avg_daily_counts) as min_val, max(Avg_daily_counts) as max_val
from Youth_Justice;

/*
Purpose:
Identify duplicate records.
Expected result: 0 rows returned.
*/
select year, sex,age,Indigenous_status,Supervision_type,count(*) as tot_count
from Youth_Justice
group by year, sex,age,Indigenous_status,Supervision_type
having count(*)>1;

/* 
SECTION 2: OVERALL SUPERVISION TRENDS
*/


/*
Purpose:
Analyse overall supervision trends by supervision type
using total population counts.
*/
select Year, max(case when Supervision_type="Supervision" then Avg_daily_counts end) as Supervision_avg_counts, max(CASE when Supervision_type="Community Supervision"  then Avg_daily_counts end) as Community_avg_counts, max(case when Supervision_type="Detention" then Avg_daily_counts end) as Detention_avg_counts
from Youth_Justice
where Age="All_Ages" and Sex="Total" and Indigenous_status="Total"
group by Year;

/* 
SECTION 3: SEX PROFILE ANALYSIS
 */

/*
Purpose:
Compare supervision trends between males and females.
*/
select Year,Supervision_type,max(case when sex="Female" then Avg_daily_counts end) as female_avg_counts,max(case when sex="Male" then Avg_daily_counts end) as Male_avg_counts
from Youth_Justice
where Age="All_Ages" and Indigenous_status="Total"
group by Year,Supervision_type;

/* 
SECTION 4: INDIGENOUS STATUS ANALYSIS
*/

/*
Purpose:
Compare supervision trends by Indigenous status.
*/
select Year,Supervision_type,max(case when Indigenous_status="First Nations" then Avg_daily_counts end) as First_nations_avg_counts,max(case when Indigenous_status="Non-Indigenous" then Avg_daily_counts end) as Non_indigenous_avg_counts, max(case when Indigenous_status="Not stated" then Avg_daily_counts end) as Not_stated_avg_counts
from Youth_Justice
where Age="All_Ages" and Sex="Total"
group by Year,Supervision_type;

/* 
SECTION 5: AGE PROFILE ANALYSIS
*/

/*
Purpose:
Examine supervision levels by individual age.
Aggregated age bands and totals are excluded to avoid
double counting and overlapping age categories.
*/
select Year,Supervision_type, Age, Avg_daily_counts
from Youth_Justice
where Indigenous_status="Total" and Sex="Total" and Age not in ("10–13","10–17","14–17","All_Ages");

/* 
SECTION 6: YEAR-OVER-YEAR CHANGE ANALYSIS
*/

/*
Purpose:
Measure annual percentage change in supervision,
community supervision and detention.
*/
with finval as(select Year,max(case when supervision_type="Supervision" then Avg_daily_counts end) as current_year_super,max(case when supervision_type="Community Supervision" then Avg_daily_counts end) as current_year_community,max(case when supervision_type="Detention" then Avg_daily_counts end) as current_year_detention
from Youth_Justice
where Age="All_Ages" and Sex="Total" and Indigenous_status="Total"
group by Year
),
finval2 as(select Year, current_year_super,lag(current_year_super) OVER(order by year asc) as previous_year_super,current_year_community, lag(current_year_community) OVER(order by year asc) as previous_year_community,current_year_detention,lag(current_year_detention) OVER(order by year asc) as previous_year_detention
from finval)
select Year,round(((current_year_super-previous_year_super)/previous_year_super*100),2)  as yoy_super, round(((current_year_community-previous_year_community)/previous_year_community*100),2) as yoy_community,round(((current_year_detention-previous_year_detention)/previous_year_detention *100),2)as yoy_detention
from finval2;
