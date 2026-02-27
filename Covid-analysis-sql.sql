select *
From my_portfolio.coviddeaths
order by 3,4;

/*Select Data that we are going to be starting with */


Select location,date,total_cases,new_cases,total_deaths,population
From coviddeaths
where continent is not null
order by 3,4;




/*Total Case vs Population*/
/*shows what percentage of population infected with covid*/

Select location,date,Population,total_cases, (total_cases/population) * 100 as PercentPopulationInfected
From coviddeaths
/*where location like '% Africa%'*/
order by 1,2;




/* Countries with highest Death Count per population*/

Select location,population, MAX(total_cases)  as HighestInfectionCount,
MAX((total_cases/population))* 100 as PercentpopulationInfected
From coviddeaths
/*where location like '% Africa%'*/
Group by location,population
order by PercentpopulationInfected desc;


/* Countries with highest Death count per population*/


Select location, MAX(CAST(total_deaths AS SIGNED )) as TotalDeathCount
From coviddeaths
/*where location like '% Africa%'*/
Where continent is not null
Group by location
order by TotalDeathCount desc;


/* Breaking things down by continent*/

/*showing continent with the highest death death count per population*/

SELECT continent ,
MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


/* Global Numbers*/

Select date,
SUM(new_cases) AS total_cases,
SUM(CAST(new_deaths AS SIGNED))  AS total_deaths,
(SUM(CAST(new_deaths AS SIGNED))/SUM(new_cases))*100 AS DeathPercentage
From coviddeaths
Group by date
order by date;


/* TOtal population vs Vaccination*/
/* shows percentage of population that has recieved at least one covid vaccine*/

SELECT
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,

SUM(CAST(vac.new_vaccinations AS SIGNED)) 
OVER (
       PARTITION BY dea.location
       ORDER BY dea.date)AS RollingPeopleVaccinated,
       (SUM(CAST(vac.new_vaccinations AS SIGNED))
 OVER
     (PARTITION BY dea.location
     ORDER BY dea.date) / dea.population
     )* 100 AS PercentVaccinated
 FROM coviddeaths dea
 JOIN covidvaccinations vac
  ON dea.location = vac.location 
  AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
  ORDER BY dea.location, dea.date;
  
  /* Using CTE  to perfome calculations on partition by in previous query*/
  
  with PopvsVac ( 
  continent,
  location,
  date,
  population,
  new_vaccinations,
  RollingPeoplevaccinated)
  AS(
      select
      dea.continent,
      dea.location,
      dea.date,
      dea.population,
      vac.new_vaccinations,
      SUM(CAST(vac.new_vaccinations AS SIGNED))
      OVER(
            PARTITION BY dea.location
            ORDER BY dea.date
      )AS RollingPeopleVaccinated
      FROM coviddeaths dea
      JOIN covidvacccinations vac
      ON dea.date = vac.location
      AND dea.date = vac.date
      WHERE dea.continent IS NOT NULL
      )
      Select *,(RollingpeopleVaccinated/population)*100
      FROM PopvsVac;
      
      
/* Using Temp table to perfome calculations on partition by in previous query*/

/* Drop temp table if exists*/
DROP TABLE if exists test;

/* create temporary table*/
CREATE TEMPORARY TABLE test
(
  continent VARCHAR(255),
  location  VARCHAR(255),
  date DATETIME,
  population DECIMAL(20,2),
  new_vaccinations DECIMAL(20,2),
  RollingPeoplevaccinated DECIMAL(20,2)
  );
  
  INSERT INTO test
  SELECT 
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  
  SUM(CAST(vac.new_vaccinations AS SIGNED))
  OVER(
        PARTITION BY dea.location
        ORDER BY dea.date
  )AS RollingPeopleVaccinated
  FROM coviddeaths dea
  JOIN covidvaccinations vac
  ON dea.location =vac.location
  AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL;
  
  /*FINAL RESULT*/
  SELECT *,(RollingPeopleVaccinated * 100 / population) AS PercentVaccinated
  FROM test;
  
  
  /* Creating view to store data for later visualizations*/
  
  CREATE VIEW test AS
  SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS SIGNED)) 
  OVER(
        partition by dea.location
        ORDER BY dea.date
    ) AS RollingPeoplevaccinated
    FROM coviddeaths dea
    JOIN covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
  
  
  
  

