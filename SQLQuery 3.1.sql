select *
from covid_deaths
order by 3,4;

--select *
--from covid_vaccinations
--order by 3,4;

--select data that i am going to use 

select location,date,total_cases,new_cases,total_deaths,population
from covid_deaths
order by 1,2;

--looking at total cases vs total deaths

--shows likelihood of dying if you contract covid in the specific caountries accross three differnt years
--United States death_percentage decrease in the last three years, from 1,7 To 1.0 in 2021 and 2023 respectivelly. 
--Norway death_percentage decrease in the last three years, from 0.8 To 0.3 in 2021 and 2023 respectivelly.
--Ethiopia death_percentage stable in the last three years, 1,5, 1,6 and 1,5 in 2021,2022, and 2023 respectivelly.

--select location,date, total_cases, total_deaths,(total_deaths) /(total_cases) * 100 as Death_Percentage
--from covid_deaths
--order by 1,2;

SELECT location,date, total_cases, total_deaths, (CAST(total_deaths as decimal) / CAST(total_cases AS DECIMAL)) *100  AS Death_Percentage
from covid_deaths
where location = 'United States'
order by date asc;

SELECT location,date, total_cases, total_deaths, (CAST(total_deaths as decimal) / CAST(total_cases AS DECIMAL)) *100  AS Death_Percentage
from covid_deaths
where location = 'Norway'
order by date asc;

SELECT location,date, total_cases, total_deaths, (CAST(total_deaths as decimal) / CAST(total_cases AS DECIMAL)) *100  AS Death_Percentage
from covid_deaths
where location = 'Ethiopia'
order by date asc;

--SELECT location, date, total_cases, total_deaths,
--       CAST(total_deaths AS DECIMAL) / CAST(total_cases AS DECIMAL) * 100 AS Death_Percentage
--FROM covid_deaths
--WHERE ISNUMERIC(total_cases) = 1 AND ISNUMERIC(total_deaths) = 1;


--select *
--from dbo.Covid_Deaths
--WHERE LOCATION = 'nORWAY' ;

--looking at the total_cases vs  population 
--shows what percentage of popuation got covid, when is the highest

SELECT location,date, population,total_cases,  (CAST(total_cases as decimal) / CAST(population AS DECIMAL)) *100  AS Population_contracted_Covid
from covid_deaths
where location = 'United States'
order by Population_contracted_Covid asc;

--which country has the highest population contracted covid?

--This query will select the maximum value of the total_cases column for each location, divide it by the population for that location, 
--and multiply the result by 100 to get the percentage. The NULLIF function is used to avoid a division by zero error. 
--The results will be sorted by the Population_contracted_Covid column in ascending order
--cyprus has the highest with 70 percent of its population being infected by covid-19.

SELECT location, population,
       MAX(total_cases) Highest_infectection_count,
       (CAST(MAX(total_cases) AS DECIMAL) / NULLIF(CAST(population AS DECIMAL), 0)) * 100 Population_contracted_Covid
FROM covid_deaths
GROUP BY location, population
order by Population_contracted_Covid desc;


--showing countries with the highest death count per population
--This is a SQL query that selects the location and the maximum number of deaths (Total_Death_Count) 
--from the "covid_deaths" table, where the continent is not an empty string (i.e., not a zero-length string). 
--The data is grouped by location and sorted in descending order by Total_Death_Count.


SELECT location, 
       (CAST(MAX(total_deaths) AS DECIMAL)) Total_Death_Count
FROM covid_deaths
WHERE continent != ' '
GROUP BY location
order by Total_Death_Count desc;

---According to continent
--This is a SQL query that selects the location and the maximum number of deaths (Total_Death_Count) from the "covid_deaths" table, 
--where the continent is an empty string (i.e., a zero-length string). 
--The data is grouped by location and sorted in descending order by Total_Death_Count.

SELECT location,
       (CAST(MAX(total_deaths) AS DECIMAL)) Total_Death_Count
FROM covid_deaths
WHERE continent = ' '
GROUP BY location
order by Total_Death_Count desc;

--Global Numbers

SELECT location,date, total_cases , total_deaths, (CAST(total_deaths as decimal) / CAST(total_cases AS DECIMAL)) *100  AS Death_Percentage
from covid_deaths
where continent != ' ' and total_cases != 0
order by Death_Percentage, date asc
;

--The final result of this SELECT statement will be a table with one row per date, 
--showing the total number of new cases and deaths on that date, and 
--the death percentage calculated as the ratio of deaths to cases multiplied by 100.

SELECT date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
       (CAST(sum(new_deaths) as decimal) / CAST(sum(new_cases) AS DECIMAL)) *100  AS Death_Percentage
FROM covid_deaths
WHERE location != ' ' AND new_cases != 0
GROUP BY date
ORDER BY date asc;

--The final result of this SELECT statement will be a table with one row showing the total number of new cases and deaths, 
--and the death percentage calculated as the ratio of deaths to cases multiplied by 100, 
--where the new_cases column is not zero. The total_cases and total_deaths columns are calculated using the SUM() function,
--and the bigint data type is being used to store the results to avoid arithmetic overflow errors.

select sum(cast(new_cases as bigint)) as total_cases, sum (cast (new_deaths as bigint )) as total_deaths,
     (CAST(sum(new_deaths) as decimal) / CAST(sum(new_cases) AS DECIMAL)) *100  AS Death_Percentage
from Covid_Deaths
WHERE new_cases != 0
order by 1,2
;
--- covid_vaccinations tables
select *
from Covid_Vaccinations;

select *
from Covid_Deaths;

--- Join both the tables
select *
from Covid_Deaths Cod
join Covid_Vaccinations Cov
   on Cod.location = Cov.location
   and Cov.date = Cov.date;

---looking at total population vs vaccinations (by innner join the two tables)

select Cov.continent, Cod.location, Cod.date, population,cast(new_vaccinations as bigint) as new_vaccinations
from Covid_Deaths Cod, Covid_Vaccinations Cov
where Cod.location = Cov.location and Cod.date= Cov.date and cast(new_vaccinations as bigint) != 0 and Cod.continent != ' '
order by continent, date;
 
---Window function

select Cov.continent, Cod.location, Cod.date, population,cast(new_vaccinations as bigint) as new_vaccinations,
sum(cast(new_vaccinations as bigint)) over (partition by Cod.location order by Cov.location,Cov.date) as Rolling_People_Vaccinated
---(Rolling_People_Vaccination)/Population *100
from Covid_Deaths Cod, Covid_Vaccinations Cov
where Cod.location = Cov.location and Cod.date= Cov.date and cast(new_vaccinations as bigint) != 0 and Cod.continent != ' '
order by location,date;

--Use CTE
--The SQL statement creates a Common Table Expression (CTE) that calculates a rolling sum of the new_vaccinations column, 
--and then uses the CTE to retrieve all columns and calculate a percentage of the population that has been vaccinated,
--filtering the results to include only rows where the Population column is not NULL and not equal to zero.

with PopVacc (Continent, lovation, Date, Population,new_vaccinations, Rolling_People_Vaccinated)
As
(
select Cov.continent, Cod.location, Cod.date, population,cast(new_vaccinations as bigint) as new_vaccinations,
sum(cast(new_vaccinations as bigint)) over (partition by Cod.location order by Cov.location,Cov.date) as Rolling_People_Vaccinated
from Covid_Deaths Cod, Covid_Vaccinations Cov
where Cod.location = Cov.location and Cod.date= Cov.date and cast(new_vaccinations as bigint) != 0 and Cod.continent != ' '
--order by location,date
)

select *, (cast(Rolling_People_Vaccinated as decimal)/(cast(Population as decimal)))* 100
from PopVacc
where Population is not NULL and Population != 0;

---Temp table
drop table if exists #PercentPopulationVaccinated
create table  #PercentPopulationVaccinated
(
Continent nvarchar (255),
location nvarchar (255),
Date datetime, 
Population numeric,
new_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

insert into #PercentPopulationVaccinated

select Cov.continent, Cod.location, Cod.date, population,cast(new_vaccinations as bigint) as new_vaccinations,
sum(cast(new_vaccinations as bigint)) over (partition by Cod.location order by Cov.location,Cov.date) as Rolling_People_Vaccinated
from Covid_Deaths Cod, Covid_Vaccinations Cov
where Cod.location = Cov.location and Cod.date= Cov.date and cast(new_vaccinations as bigint) != 0 and Cod.continent != ' '
--order by location,date

select *, (cast(Rolling_People_Vaccinated as decimal)/(cast(Population as decimal)))* 100 as Percentage_Population_Vaccinatated
from #PercentPopulationVaccinated
where Population is not NULL and Population != 0
order by location, Percentage_Population_Vaccinatated;

---creating view to store data for later isualizations

create view Percentage_Population_Vaccinated as
select Cov.continent, Cod.location, Cod.date, population,cast(new_vaccinations as bigint) as new_vaccinations,
sum(cast(new_vaccinations as bigint)) over (partition by Cod.location order by Cov.location,Cov.date) as Rolling_People_Vaccinated
from Covid_Deaths Cod, Covid_Vaccinations Cov
where Cod.location = Cov.location and Cod.date= Cov.date and cast(new_vaccinations as bigint) != 0 and Cod.continent != ' '
--order by location,date

--drop view Percentage_Population_Vaccinatated; 




