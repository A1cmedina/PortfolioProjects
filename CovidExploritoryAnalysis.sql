Select *
From PortfolioProject..CovidDeaths$
Where continent is not null
Order By 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--Order By 3,4

--Select the data that is to be used

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Order By 1,2

-- Looking at the total Cases vs Total Deaths
-- Likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths$
Where location = 'United States'
Order By 1,2


-- Lookin at Total Cases  vs Population
-- Shows what percentage of population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 AS CovidInfectionPercentage
From PortfolioProject..CovidDeaths$
Where location = 'United States'
Order By 1,2

-- Looking at countries with highest infection rate compared to Population

Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS CovidInfectionPercentage
From PortfolioProject..CovidDeaths$
--Where location = 'United States'
Group By location, population
Order By CovidInfectionPercentage DESC


-- Showing the countries with the highest death count per population

Select location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location = 'United States'
Where continent is not null
Group By location
Order By TotalDeathCount DESC


-- BREAKDOWN BY CONTINENT

Select continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location = 'United States'
Where continent is not null
Group By continent
Order By TotalDeathCount DESC



-- Showing continents with the highest death count per population

Select continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location = 'United States'
Where continent is not null
Group By continent
Order By TotalDeathCount DESC


-- GLOBAL NUMBERS

Select SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage --, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null
--Group By date
Order By 1,2



-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) AS RollingCountVaccinations
--, (RollingCountVaccinations/population)*100
From PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
Order By 2,3

-- CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingCountVaccinations)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) AS RollingCountVaccinations
--, (RollingCountVaccinations/population)*100
From PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
Select *, (RollingCountVaccinations/population)*100
From PopvsVac

-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingCountVaccinations numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) AS RollingCountVaccinations
--, (RollingCountVaccinations/population)*100
From PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--Where dea.continent is not null
--Order By 2,3

Select *, (RollingCountVaccinations/population)*100
From #PercentPopulationVaccinated




-- Creating view to store data for later visualization
USE PortfolioProject

Create View PercentPopulationVaccinated$ AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) AS RollingCountVaccinations
--, (RollingCountVaccinations/population)*100
From PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null


Select *
From PercentPopulationVaccinated$