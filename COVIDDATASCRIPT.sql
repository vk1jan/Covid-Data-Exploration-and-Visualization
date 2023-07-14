SELECT * 
FROM covidvaccines
ORDER BY 3,4

SELECT * 
FROM coviddeaths
ORDER BY 3,4


 --CASES VS DEATHS
--SELECT SUM(new_cases) AS TOTAL_CASES,SUM(cast(new_deaths as numeric)) AS TOTAL_DEATHS,
--(cast(new_deaths as numeric))/ cast(new_cases as numeric)*100 AS DEATHPERCENTAGE
--FROM coviddeaths
--WHERE CONTINENT IS NOT NULL
--ORDER BY 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as numeric)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


--CASES VS POPULATION
SELECT LOCATION,DATE,TOTAL_CASES,population,
(cast(total_cases as numeric)/population)*100 
FROM coviddeaths
WHERE location LIKE '%INDIA%'
ORDER BY 1,2



ALTER TABLE COVIDDEATHS ALTER COLUMN TOTAL_CASES INT
ALTER TABLE COVIDDEATHS ALTER COLUMN TOTAL_DEATHS INT

 --COUNTRY WITH HIGHEST INFECTION
SELECT LOCATION,POPULATION,
MAX(total_cases) AS HIGHESTINFECTIONCOUNT,
MAX((total_cases/population))*100 AS HIGHESTINFECTIONPERCENT
FROM coviddeaths
GROUP BY location,POPULATION
ORDER BY HIGHESTINFECTIONPERCENT DESC


--HIGHEST DEATH COUNT
--BY LOCATION
SELECT LOCATION,MAX(TOTAL_DEATHS) AS HIGHESTDEATHS
FROM coviddeaths
WHERE CONTINENT IS NOT NULL
GROUP BY LOCATION
ORDER BY HIGHESTDEATHS DESC

--BY CONTINENT
SELECT CONTINENT,MAX(TOTAL_DEATHS) AS HIGHESTDEATHS
FROM coviddeaths
WHERE CONTINENT IS NOT NULL
GROUP BY CONTINENT
ORDER BY HIGHESTDEATHS DESC


--TOTAL NEW CASES EVERYDAY GLOBALLY
SELECT DATE,SUM(NEW_CASES) AS GLOBALNEWCASES,SUM(NEW_DEATHS) AS GLOBALNEWDEATHS,
CASE
	WHEN SUM(NEW_CASES) <> 0 THEN SUM(NEW_DEATHS)/SUM(NEW_CASES)*100 
END AS GLOBALNEWDEATHPERCENTAGE
FROM coviddeaths
WHERE CONTINENT IS NOT NULL
GROUP BY DATE
ORDER BY 1

-- TOTAL POPULATION VS FULLY VACCINATED
-- CTE SO THAT WE CAN USE ROLLINGSUM
WITH POPVSVAC(CONTINENT,LOCATION,DATE,POPULATION,NEW_VACCINATIONS,ROLLINGSUMVACCINATIONS)
AS
(
SELECT DTH.continent,DTH.location,DTH.date,DTH.POPULATION,VAC.new_vaccinations,
SUM(CONVERT(bigint,VAC.new_vaccinations)) OVER (PARTITION BY DTH.LOCATION ORDER BY DTH.location,DTH.date) AS ROLLINGSUMVACCINATION
FROM COVIDDEATHS DTH
JOIN covidvaccines VAC
ON DTH.location=VAC.location
AND DTH.DATE=VAC.DATE
WHERE DTH.CONTINENT IS NOT NULL
)
SELECT *,(ROLLINGSUMVACCINATIONS/POPULATION)*100
FROM POPVSVAC

CREATE VIEW ROLLINGPEOPLEVAC AS
SELECT DTH.continent,DTH.location,DTH.date,DTH.POPULATION,VAC.new_vaccinations,
SUM(CONVERT(bigint,VAC.new_vaccinations)) OVER (PARTITION BY DTH.LOCATION ORDER BY DTH.location,DTH.date) AS ROLLINGSUMVACCINATION
FROM COVIDDEATHS DTH
JOIN covidvaccines VAC
ON DTH.location=VAC.location
AND DTH.DATE=VAC.DATE
WHERE DTH.CONTINENT IS NOT NULL

SELECT *
FROM ROLLINGPEOPLEVAC


Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..covidvaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3


