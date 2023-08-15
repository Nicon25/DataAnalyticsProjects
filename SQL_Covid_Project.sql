/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Windows Functions, Aggregate Functions, Converting Data Types, Creating Views

*/

SELECT *
FROM ProjectCovid.coviddeaths
WHERE continent <> ''
ORDER BY 3,4;


-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjectCovid.coviddeaths
WHERE continent <> ''
ORDER BY 1,2;


-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM ProjectCovid.coviddeaths
WHERE location LIKE 'Ireland%'
ORDER BY 1,2;


-- Looking at Total Cases vs Populations
-- SHows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM ProjectCovid.coviddeaths
WHERE continent <> ''
ORDER BY 1,2;


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM ProjectCovid.coviddeaths
WHERE continent <> ''
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


-- Showing Countries with Highest Death Coiunt per Population

SELECT location, MAX(cast(total_deaths as SIGNED)) AS TotalDeathCount
FROM ProjectCovid.coviddeaths
WHERE continent <> ''
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Let's break things down by Continent

SELECT location, MAX(cast(total_deaths as SIGNED)) AS TotalDeathCount
FROM ProjectCovid.coviddeaths
WHERE continent = '' AND location NOT LIKE '%income%'
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Let's group the data by Income level and Countries

SELECT location, MAX(cast(total_deaths as SIGNED)) AS TotalDeathCount
FROM ProjectCovid.coviddeaths
WHERE continent = '' AND location LIKE '%income%'
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as SIGNED)) AS TotalDeathCount
FROM ProjectCovid.coviddeaths
WHERE continent <> ''
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- Global Numbers by Date

SELECT date, SUM(cast(new_cases as SIGNED)) AS total_cases, SUM(cast(new_deaths as SIGNED)) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercantage
FROM ProjectCovid.coviddeaths
WHERE continent <> ''
GROUP BY date
ORDER BY 1,2;


-- Global Numbers

SELECT SUM(cast(new_cases as SIGNED)) AS total_cases, SUM(cast(new_deaths as SIGNED)) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercantage
FROM ProjectCovid.coviddeaths
WHERE continent <> ''
ORDER BY 1,2;


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations AS SIGNED) AS new_vaccinations,
SUM(cast(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM ProjectCovid.coviddeaths dea
JOIN ProjectCovid.covidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent <> ''
ORDER BY 2, 3;


-- Use CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations AS SIGNED) AS new_vaccinations,
SUM(cast(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM ProjectCovid.coviddeaths dea
JOIN ProjectCovid.covidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent <> ''
ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac;


-- Creating View to store data for later visualization

CREATE VIEW PercentPoplationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations AS SIGNED) AS new_vaccinations,
SUM(cast(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM ProjectCovid.coviddeaths dea
JOIN ProjectCovid.covidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent <> '';
