SELECT *
FROM coviddeaths
ORDER BY 3,4;

SELECT * 
FROM covidvaccinations
ORDER BY 3,4;

-- Select data that we are going to using 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY location, date;

-- Looking at total Cases vs total Deaths calculating the ratio
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM coviddeaths
ORDER BY location, date;

-- Looking at total Cases vs total Deaths calculating the ratio in INDIA
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM coviddeaths
WHERE location LIKE '%Indi%'
ORDER BY location, date;

-- Looking at Total Cases vs Population 
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date,population , total_cases, (total_deaths / population) * 100 AS PercentPopulationInfect
FROM coviddeaths
WHERE location LIKE '%Indi%'
ORDER BY location, date;

-- Looking at Total Cases vs Population 
-- Shows likelihood of dying if you contract covid in all countries
SELECT location, date,population , total_cases, (total_cases / population) * 100 AS PercentPopulationInfect
FROM coviddeaths
ORDER BY location, date;

-- Looking at the countries with highest infection rate as compared to the population 
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfect
FROM coviddeaths
GROUP BY location, population
ORDER BY PercentPopulationInfect DESC;

-- Converting empty strings into NULL -> total_deaths
UPDATE coviddeaths
SET total_deaths = NULL
WHERE total_deaths = '';

-- Converting the data type of the column -> total_deaths
ALTER TABLE coviddeaths
MODIFY COLUMN total_deaths INT;

-- Showing countries with highest Death count per population 
SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- LET's BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY TotalDeathCount DESC
; 

-- Showing the continents with highest death count per population 
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global numbers
SELECT date, SUM(new_cases) AS new_cases
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY location, date;

-- Converting empty strings into NULL -> new_deaths
UPDATE coviddeaths
SET new_deaths = NULL
WHERE new_deaths = '';

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- GLOBAL NUMBERS
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Joining two tables
SELECT *
FROM coviddeaths AS deaths
JOIN covidvaccinations AS vaccine
ON deaths.location = vaccine.location
AND deaths.date = vaccine.date
LIMIT 20000;

-- Converting empty strings into NULL -> new_vaccinations
UPDATE covidvaccinations
SET new_vaccinations = NULL
WHERE new_vaccinations = '';

-- Converting the data type of the column -> new_vaccinations
ALTER TABLE covidvaccinations
MODIFY COLUMN new_vaccinations INT;

-- Looking at Total Population vs. Vaccinations -> just a rough query
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations, SUM(vaccine.new_vaccinations) OVER (PARTITION BY deaths.location)
FROM coviddeaths AS deaths
JOIN covidvaccinations AS vaccine
    ON deaths.location = vaccine.location
    AND deaths.date = vaccine.date
WHERE deaths.continent IS NOT NULL
ORDER BY 2,3
LIMIT 20000;

-- Looking at Total Population vs. Vaccinations
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations, SUM(vaccine.new_vaccinations)
OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM coviddeaths AS deaths
JOIN covidvaccinations AS vaccine
    ON deaths.location = vaccine.location
    AND deaths.date = vaccine.date
WHERE deaths.continent IS NOT NULL
ORDER BY 2,3
LIMIT 20000;

-- Use a CTE for calculations
WITH PopVsVacc(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
    SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations, SUM(vaccine.new_vaccinations)
    OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
    FROM coviddeaths AS deaths
    JOIN covidvaccinations AS vaccine
        ON deaths.location = vaccine.location
        AND deaths.date = vaccine.date
    WHERE deaths.continent IS NOT NULL
    LIMIT 20000
)
SELECT * , (RollingPeopleVaccinated/population)*100 AS PercentPopulationVaccinated
FROM PopVsVacc;


DROP TABLE IF EXISTS PercentPopulationVaccinated;

-- TEMP table (same function as the previous one..) not supported method in MySql.....
CREATE TABLE PercentPopulationVaccinated(
    continent VARCHAR(255),
    location VARCHAR(255),
    date DATETIME,
    population INT,
    new_vaccinations INT,
    RollingPeopleVaccinated INT
);

INSERT INTO PercentPopulationVaccinated;

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations, SUM(vaccine.new_vaccinations)
OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM coviddeaths AS deaths
JOIN covidvaccinations AS vaccine
    ON deaths.location = vaccine.location
    AND deaths.date = vaccine.date
ORDER BY 2,3
LIMIT 20000;


-- Creating TEMPORARY TABLE
CREATE TEMPORARY TABLE PercentPopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations, SUM(vaccine.new_vaccinations)
OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM coviddeaths AS deaths
JOIN covidvaccinations AS vaccine
    ON deaths.location = vaccine.location
    AND deaths.date = vaccine.date
LIMIT 20000;

SELECT * , (RollingPeopleVaccinated/population)*100 AS PercentPopulationVaccinated
FROM PercentPopulationVaccinated;

-- Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations, SUM(vaccine.new_vaccinations)
OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM coviddeaths AS deaths
JOIN covidvaccinations AS vaccine
    ON deaths.location = vaccine.location
    AND deaths.date = vaccine.date
WHERE deaths.continent IS NOT NULL;

SELECT * FROM percentpopulationvaccinated;