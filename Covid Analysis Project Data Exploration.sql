SELECT *
FROM CovidDeaths
where continent is not null
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

-- Select the Data that we will be using

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying from Covid if you contract it in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
WHERE Location like '%states%' and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select Location, date, population, total_cases, (total_cases/population) * 100 as CasePercentage
From CovidDeaths
--WHERE Location = 'United States'
where continent is not null
order by 1,2

-- Look at Countries with highest infection rates compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as HighestInfectionRate
FROM CovidDeaths
where continent is not null
Group By Location, Population
order by HighestInfectionRate DESC

-- Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int))  as TotalDeathCount
From CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing Continent with highest death counts
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is null and not (location like '%income%' or location like  '%union%')
Group by location
order by TotalDeathCount desc

-- Global numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100
as DeathPercentage
From CovidDeaths
where continent is not null
Group by date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100
as DeathPercentage
From CovidDeaths
where continent is not null
--Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by 
dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingVaccinationCount
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingVaccinationCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by 
dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingVaccinationCount
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingVaccinationCount/Population) * 100
From PopvsVac

-- Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinationCount numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by 
dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingVaccinationCount
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

-- Rolling Vaccination Count
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by 
dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingVaccinationCount
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated

-- Death Toll on Each continent

Create View DeathsPerContinent as
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is null and not (location like '%income%' or location like  '%union%')
Group by location


