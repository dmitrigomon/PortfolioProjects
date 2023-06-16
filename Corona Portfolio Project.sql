select *
from CovidDeaths
where continent is not null
order by 3,4


--select *
--from CovidVaccinations
--order by 3,4


select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid 
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where Location like '%states'
order by 1,2

-- What percentage got Covid
select Location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
--where Location like '%states'
order by 1,2

-- Looking at countries with highest infection rate compared to population
select Location, Population, MAX(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
--where Location like '%states'
group by Location, population
order by PercentPopulationInfected desc


-- LETS BREAK THINGS DOWN BY CONTINENT
-- Showing Countries with highest Death Count per Population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where Location like '%states'
where continent is not null
group by continent
order by TotalDeathCount desc

-- LETS BREAK THINGS DOWN BY CONTINENTS

select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where Location like '%states'
where continent is null
group by location
order by TotalDeathCount desc


-- Showing continents with the highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where Location like '%states'
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global numbers world
select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
--where Location like '%states'
where continent is not null
--group by date
order by 1,2

-- Global numbers by date
select  date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
--where Location like '%states'
where continent is not null
group by date
order by 1,2


-- Looking at total population vs Vaccination


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert (int,vac.new_vaccinations))
	over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100

from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(convert (int,vac.new_vaccinations))
	over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100

from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopVsVac


-- Temp Table

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(convert (int,vac.new_vaccinations))
	over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

 select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later data visualization

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(convert (int,vac.new_vaccinations))
	over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated