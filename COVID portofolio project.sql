select * 
from PortofolioProject..CovidDeaths 
where continent is not null 
order by 3,4

-- Select data that i'll be using

select location, date, total_cases, total_deaths, population 
from PortofolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking for total_cases vs total_deaths
-- Shows likelihood of dying if someone contract covid
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at total_cases vs population
-- Shows what percentage of how population got covid 
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortofolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at countries with highest infection compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortofolioProject..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc

-- Showing a country with a highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathsCount
from PortofolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathsCount desc

-- Showing continent with a highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
from PortofolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathsCount desc


-- Global numbers
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

-- Total population vs vaccinations
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(convert(int,cv.new_vaccinations))
OVER (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths  cd
join PortofolioProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 2,3

-- Use CTE

with PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(convert(int,cv.new_vaccinations))
OVER (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths  cd
join PortofolioProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- Use TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(convert(int,cv.new_vaccinations))
OVER (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths  cd
join PortofolioProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- creating view to stored data for visualizations
create view PercentPopulationVaccinated as 
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(convert(int,cv.new_vaccinations))
OVER (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths  cd
join PortofolioProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null

select * from PercentPopulationVaccinated
