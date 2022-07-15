-- 1.
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
where continent is not null
order by 1,2

-- 2.
select location, MAX(cast(total_deaths as int)) as TotalDeathsCount
from PortofolioProject..CovidDeaths
where continent is null 
and location not in ('World', 'European Union', 'International')
group by location
order by TotalDeathsCount desc

-- 3.
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortofolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfected desc

-- 4.
select location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortofolioProject..CovidDeaths
where continent is not null
group by location, population, date
order by PercentPopulationInfected desc
