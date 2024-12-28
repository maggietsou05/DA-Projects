-- Total cases vs total deaths
SELECT location, date, total_cases, total_deaths, 
ROUND((total_deaths/total_cases)*100, 2) AS death_percentage
FROM dea;


-- Total cases vs population in each country
SELECT location, date, total_cases, population,
(total_deaths/total_cases)*100 AS percent_population_infected
FROM dea;


-- Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS highest_infection_count, 
MAX((total_cases/population)*100) AS percent_population_infected
FROM dea
GROUP BY location, population
HAVING MAX((total_cases/population)*100) IS NOT NULL
ORDER BY MAX((total_cases/population)*100) DESC

-- Countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS integer))
FROM dea
GROUP BY location
HAVING MAX(CAST(total_deaths AS integer)) IS NOT NULL
ORDER BY MAX(CAST(total_deaths AS integer)) DESC

-- Global numbers
SELECT SUM(new_deaths) AS total_deaths, SUM(new_cases) AS total_cases,
CASE
   WHEN SUM(new_cases) = 0 OR SUM(new_cases) is NULL THEN NULL
   ELSE SUM(new_deaths)/SUM(new_cases)*100
END AS death_rate
FROM dea

-- Total population that has been vaccinated
-- View
CREATE OR REPLACE VIEW dea_vac_joined AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
new_cases, new_deaths
FROM dea
INNER JOIN vac
  ON dea.location = vac.location
  AND dea.date=vac.date

-- Using subquery
SELECT continent, location, date, population, new_vaccinations,
rolling_vac, (rolling_vac/population)*100 AS percent_vaccinated

FROM(
SELECT continent, location, date, population, new_vaccinations,
SUM(new_vaccinations) OVER 
(PARTITION BY location ORDER BY location, date) AS rolling_vac
FROM dea_vac_joined
) 

