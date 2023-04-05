select *
from Portfolio_Project..covid_deaths

select *
from Portfolio_Project..covid_vaccination

select location, date, total_cases, new_cases, population, total_deaths
from Portfolio_Project..covid_deaths
order by 1,2

--looking at Total cases vs Total deaths

select location, date, total_cases, total_deaths,(CONVERT(decimal(18,0), total_deaths)/CONVERT(decimal(18,0), total_cases)) * 100 as DeathPercentage
from Portfolio_Project..covid_deaths
where location like '%kingdom%'
order by 1,2

--looking at Total cases vs Population
--shows what percentage of the population got infected

select location, date, population, total_cases,(CONVERT(decimal(18,0), total_cases)/CONVERT(decimal(18,0), population))
* 100 as Percentpopulationinfected
from Portfolio_Project..covid_deaths
where location like '%kingdom%'
order by 1,2

--countries with highest infection case

select location, population, MAX(total_cases) as Highest_Infection_count,
MAX(CONVERT(decimal(18,0), total_cases)/CONVERT(decimal(18,0), population))* 100 as Percentpopulationinfected
from Portfolio_Project..covid_deaths
--where location like '%kingdom%'
Group by location, population
order by Percentpopulationinfected desc


--showing countries with the highest death count
select location, MAX(cast (total_deaths as int)) as Totaldeathcount
from Portfolio_Project..covid_deaths
Group by location
order by Totaldeathcount desc


--showing death count by continent
select continent, MAX(cast (total_deaths as int)) as Totaldeathcount
from Portfolio_Project..covid_deaths
where continent is not null
Group by continent
order by Totaldeathcount desc

-- calculating for Global numbers

select date, SUM(convert(decimal (18,0),new_deaths)) as Total_deaths, SUM(new_cases) as Total_cases, 
SUM(new_cases)/nullif (SUM(convert(int,new_deaths)),0) *100 as Deathpercentage
from Portfolio_Project..covid_deaths
where continent is not null
group by date
order by 1,2

---showing total population vs vaccinations

select d.continent, d.location, d.date, d.population, v.new_vaccinations
from portfolio_project..covid_vaccination v
join Portfolio_Project..covid_deaths d
	on v.location = d.location
	and v.date = d.date
where d.continent is not null
order by 1,2,3

---showing total population vs vaccinations and a rolling count of vaccinations

select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(convert(int, v.new_vaccinations)) over (partition by d.location order by d.location, d.date)
as rollingpeoplevaccination, 
--(rollingpeoplevaccination/population)*100
from portfolio_project..covid_vaccination v
join Portfolio_Project..covid_deaths d
	on v.location = d.location
	and v.date = d.date
where d.continent is not null
order by 2,3

---use CTE

with popvsvac (continent,location, date, population, new_vaccinations, rollingpeoplevaccination)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(cast(v.new_vaccinations as decimal)) over (partition by d.location order by d.location, d.date)
as rollingpeoplevaccination 
--(rollingpeoplevaccination/population)*100
from portfolio_project..covid_vaccination v
join Portfolio_Project..covid_deaths d
	on v.location = d.location
	and v.date = d.date
where d.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccination/population)*100
from popvsvac


-- Creating a Temp table

Drop table if exists PercentPopulationVaccinations
Create table PercentPopulationVaccinations
(
Continent Nvarchar (255),
Location Nvarchar (255),
Date Datetime,
Population Numeric,
new_vaccinations Numeric,
rollingpeoplevaccination numeric
)
Insert into PercentPopulationVaccinations

select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(cast(v.new_vaccinations as decimal)) over (partition by d.location order by d.location, d.date)
as rollingpeoplevaccination 
--(rollingpeoplevaccination/population)*100
from portfolio_project..covid_vaccination v
join Portfolio_Project..covid_deaths d
	on v.location = d.location
	and v.date = d.date
where d.continent is not null
--order by 2,3

select *, (rollingpeoplevaccination/population)*100
from PercentPopulationVaccinations



--creating view to store data to use for visualisation later

create view PercentPopulationVaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(cast(v.new_vaccinations as decimal)) over (partition by d.location order by d.location, d.date)
as rollingpeoplevaccination 
--(rollingpeoplevaccination/population)*100
from portfolio_project..covid_vaccination v
join Portfolio_Project..covid_deaths d
	on v.location = d.location
	and v.date = d.date
where d.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated


create view ContinentDeathCount as
select continent, MAX(cast (total_deaths as int)) as Totaldeathcount
from Portfolio_Project..covid_deaths
where continent is not null
Group by continent
--order by Totaldeathcount desc

select *
from ContinentDeathCount
