--Select *
	--From PortfolioProject..['Covid Deaths']
	--order by 3,4

--Select *
--From PortfolioProject..['Covid Vacinations$']
--order by 3,4

--selecy data to be used

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..['Covid Deaths']
order by 1,2

-- Total Cases vs Total Deaths
-- chance of dying if you contract covid in the "United States"
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..['Covid Deaths']
Where location like '%states%'
order by 1,2

--Total Cases vs Population
--percentage of population with covid
select Location, date, population, total_cases, (total_cases/population)*100 as Infection_Rate
from PortfolioProject..['Covid Deaths']
Where location like '%states%'
order by 1,2

--Countries with highest infection rate

select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..['Covid Deaths']
--Where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

--Countries with Highest Death Rate
select Location, MAX(cast( total_deaths as int)) as TotalDeathCount
from PortfolioProject..['Covid Deaths']
Where continent is not null
group by location
order by TotalDeathCount desc

-- Analysis by Continent
select location, MAX(cast( total_deaths as int)) as TotalDeathCount
from PortfolioProject..['Covid Deaths']
Where continent is null
group by location
order by TotalDeathCount desc

-- Global #'s
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
From PortfolioProject..['Covid Deaths']
where continent is not null
--Group by date
order by 1,2


Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
From PortfolioProject..['Covid Deaths']
where continent is not null
Group by date
order by 1,2

--working with vaccinations

select *
from PortfolioProject..['Covid Deaths'] dea
Join PortfolioProject..['Covid Vacinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
from PortfolioProject..['Covid Deaths'] dea
Join PortfolioProject..['Covid Vacinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

select *
from PortfolioProject..['Covid Vacinations$']

--NEEDS CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..['Covid Deaths'] dea
Join PortfolioProject..['Covid Vacinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..['Covid Deaths'] dea
Join PortfolioProject..['Covid Vacinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View for Visualization

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..['Covid Deaths'] dea
Join PortfolioProject..['Covid Vacinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3