--select *
--from PortfolioProject..covid_deaths
--order by 3,4

--select *
--from PortfolioProject..covid_vaccinations
--order by 3,4

--select data we're using

select 
location,
date,
total_cases,
new_cases,
total_deaths,
population
from PortfolioProject..covid_deaths
order by 1,2

-- Looking at total cases vs. total deaths
-- shows likelihood of dying if contracting covid in each country
select 
location,
date,
total_cases,
total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..covid_deaths
where location like '%states%'
order by 1,2

-- Looking at total cases vs population
--Shows what percentage of population got Covid
select 
location,
date,
population,
total_cases,
(total_cases/population)*100 as CovidPercentage
from PortfolioProject..covid_deaths
where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to population
select 
location,
population,
max(total_cases) as HighestInfectionCount,
max((total_cases/population))*100 as CovidPercentage
from PortfolioProject..covid_deaths
--where location like '%states%'
group by location, population
order by CovidPercentage desc

--showing countries with highest death count per population
select 
location,
max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covid_deaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--Breaking things down by continent (not quite right):
select 
continent,
max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covid_deaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Breaking things down by continent (correct):
select 
location,
max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covid_deaths
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc

--global numbers
select 
date,
sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..covid_deaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

select 
sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..covid_deaths
--where location like '%states%'
where continent is not null
order by 1,2


--Total Population vs Vaccinations

--CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinations)
as
(
select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinations
from PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingVaccinations/population)*100
from PopvsVac

--temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingVaccinations numeric
)
insert into #PercentPopulationVaccinated
select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinations
from PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingVaccinations/population)*100
from #PercentPopulationVaccinated


-- Creating views for visualizations

--View 1

create view PercentPopulationVaccinated as
select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinations
from PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated

--View 2

create view DeathsByContinent as
select 
continent,
max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covid_deaths
--where location like '%states%'
where continent is not null
group by continent
--order by TotalDeathCount desc