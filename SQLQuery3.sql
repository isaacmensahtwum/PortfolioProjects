
--select *
--from PortfolioProject.. CovidDeaths
--order by 3,4;

--select *
--from PortfolioProject.. CovidVaccinations
--order by 3,4;

--Selecting data that will be needed from the Tables

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.. CovidDeaths
order by 1,2;

-- Total Cases vs Total deaths (shows likelihood of dying if you had Covid)

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as "% of Death/Cases"
from PortfolioProject.. CovidDeaths
--where Location like '%states%'
where Location = 'United States'
order by 1,2;

-- Total Cases vs Population (Percent of Pop with Covid)
-- Percentage of population with Covid
select Location, date, total_cases, population, (total_cases/population)*100 as "% of Cases/Popu."
from PortfolioProject..CovidDeaths
order by 1,2;

-- Max Total Cases from each region

select Location, population, max(total_cases) as MaxTotalCases, max((total_cases/population))*100 as HighestInfection
from PortfolioProject..CovidDeaths
group by Location, population
order by HighestInfection desc;

-- Countries with Highest death per population
-- %tage of death through covid per population
select Location, population, max(cast(total_deaths as int)) as MaxTotalDeath, max((total_deaths/population))*100 as HighestDeath
from PortfolioProject..CovidDeaths
group by Location, population
order by HighestDeath desc;

select Location, max(cast(total_deaths as int)) as TotalDeath
from PortfolioProject..CovidDeaths
where continent is not null
group by Location
order by TotalDeath desc;


-- By Continent

select continent, max(cast(total_deaths as int)) as TotalDeath
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeath desc;

select Location, max(cast(total_deaths as int)) as TotalDeath
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeath desc;


select Continent, max(cast(total_deaths as int)) as TotalDeath
from PortfolioProject..CovidDeaths
-- where continent is not null
group by continent
order by TotalDeath desc;

-- Showing the continents with highest death counts

select continent, max(cast(Total_deaths as int)) as TotalDeaths
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeaths desc;

--Total cases across the world per day.
select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2;

-- Overall cases and %tage of death across the world
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;


-- Joining two Tables
--select *
--from CovidDeaths de, CovidVaccinations va
--where de.location = va.location;

select * 
from PortfolioProject.. CovidDeaths dea
join PortfolioProject.. CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date;

-- Looking at Total Populationa vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject.. CovidDeaths dea
join PortfolioProject.. CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- Adding a column that sums the new_vaccinations as it increases
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as 'CummulativeVaccination'
from PortfolioProject.. CovidDeaths dea
join PortfolioProject.. CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;

--A code to show that indeed the "sum() over (partion by...)" gives the total count
--select sum(cast(new_vaccinations as int))
--from PortfolioProject..CovidVaccinations
--where location = 'Albania';



--Total vaccination per population

-- 1. Using CTE
With Popvsvac (continent, location, date, population, new_vaccinations, CummulativeVaccination) 
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as CummulativeVaccination
from PortfolioProject.. CovidDeaths dea
join PortfolioProject.. CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (CummulativeVaccination/population)*100
from Popvsvac


-- 2. Temp Table
Drop Table if exists #PercentPopVaccinated
Create table #PercentPopVaccinated
(
continent nvarchar (255),
location nvarchar (255),
Date datetime,
Population numeric,
new_vaccinations numeric,
CummulativeVaccination numeric
)

Insert into #PercentPopVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as CummulativeVaccination
from PortfolioProject.. CovidDeaths dea
join PortfolioProject.. CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (CummulativeVaccination/population)*100
from #PercentPopVaccinated


-- Creating View to store for Visualization
Create view PercentPopVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as CummulativeVaccination
from PortfolioProject.. CovidDeaths dea
join PortfolioProject.. CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;


--Global Percentage of death to total population
With PercTotDeath (continent, TotalPop, TotalDeath)
as 
(
select continent, sum(Population) as TotalPop, sum(cast(total_deaths as int)) as TotalDeath
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
)
select *, (TotalDeath/TotalPop)*100 as 'Percent of Death'
from PercTotDeath
order by 'Percent of Death';


--Global Percentage of death to total cases
With PercTotCases (continent, TotalCases, TotalDeath)
as 
(
select continent, sum(total_cases) as TotalCases, sum(cast(total_deaths as int)) as TotalDeath
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
)
select *, (TotalDeath/TotalCases)*100 as 'Percent of Death'
from PercTotCases
order by 'Percent of Death';

