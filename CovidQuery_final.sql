SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

--1 Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2;

-- Looking at Total Cases vs Total Deaths
--2 Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/ total_cases) * 100 AS deathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2;

--3 Looking at Total Cases vs Total Deaths in Philippines
SELECT location, date, total_cases, total_deaths, (total_deaths/ total_cases) * 100 AS deathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Philippines'
ORDER BY 1, 2;

-- Looking at Total Cases vs Population
--4 Shows what % of population got Covid
SELECT location, date, total_cases, population, (total_cases/ population) * 100 AS CovidPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2;

--5 Looking at Countries with highest infection rate compared to Population
SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/ population) * 100) AS PercentPopulatiionInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, population
ORDER BY PercentPopulatiionInfected DESC;

--6 Showing counties with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;

-- LET US BREAK THINGS DOWN BY CONTINENT (37:00)

--7 Showing the continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT  NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--8 Global numbers
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS deathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2;

--9 Total Percentage
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS deathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
ORDER BY 1, 2;

--10 Looking total population vs vaccinations

-- USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT  dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated / population) * 100 AS VaccinationPercentage
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated / population) * 100
FROM PopvsVac


--TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated / population) * 100 AS VaccinationPercentage
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated / population) * 100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualization
USE PortfolioProject
GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated / population) * 100 AS VaccinationPercentage
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated


--- NEW QUERIES FOR TABLEAU SESSION

-- 1.) For Total Numbers

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS deathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2;

-- 2.) Total death counts in continents

SELECT location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- 3.) Looking at Countries with highest infection rate compared to Population
SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/ population) * 100) AS PercentPopulatiionInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, population
ORDER BY PercentPopulatiionInfected DESC;

-- 4.)Looking at Countries with highest infection rate compared to Population with date
SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/ population) * 100) AS PercentPopulatiionInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, population, date
ORDER BY PercentPopulatiionInfected DESC;