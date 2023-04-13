--SELECT * --location, date, total_cases, new_cases, total_deaths, population
--FROM CovidAnalysisProject..CovidDeaths
--ORDER by 1,2

--SELECT *
--FROM CovidAnalysisProject..CovidVaccination
--ORDER by 3,4

--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM CovidAnalysisProject..CovidDeaths
--ORDER BY  1,2

--Total case vs Total Deaths
SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidAnalysisProject..CovidDeaths
where location like '%India%'
order by 1,2

--Total Case vs Population
SELECT location,date,population,total_cases, (total_cases/population)*100 as InfectedPercentage
FROM CovidAnalysisProject..CovidDeaths
where location like '%India%'
order by 1,2

--Looking at countries with Highest Infection Rate compared to population
SELECT location,population,MAX(total_cases) as InfectedCount, MAX((total_cases/population))*100 as InfectedPercentage
FROM CovidAnalysisProject..CovidDeaths
--where location like '%India%'
GROUP BY location,population
order by InfectedPercentage desc

--Countries with the highest Death count pre Population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM CovidAnalysisProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--Globally

SELECT  SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(cast(new_deaths as int))/(SUM(new_cases)))*100 as DeathPercentage
FROM CovidAnalysisProject..CovidDeaths
WHERE continent	is not null
--Group by date
order by 1,2

--Joins
--Looking at total population and vaccinated
SELECT dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinated
FROM CovidAnalysisProject..CovidDeaths as dea
 JOIN CovidAnalysisProject..CovidVaccination as vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
 ORDER by 3,1

 --using cte
 With PopvsVac  (date, Coninent, Location, population, new_vaccinations, PeopleVaccinated)
 as
 (
 SELECT dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinated
FROM CovidAnalysisProject..CovidDeaths as dea
 JOIN CovidAnalysisProject..CovidVaccination as vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
 --ORDER by 3,1
 )
 Select *
 FROM PopvsVac

 --Temp Table
 DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccination numeric,
PeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT  dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinated
FROM CovidAnalysisProject..CovidDeaths as dea
 JOIN CovidAnalysisProject..CovidVaccination as vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
 --ORDER by 3,1

 Select *, (PeopleVaccinated/Population)*100
 From #PercentPopulationVaccinated
ORDER by 1,3

--Creating View for Visualizzation
CREATE VIEW PercentPopulationVaccinated AS
SELECT  dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinated

FROM CovidAnalysisProject..CovidDeaths as dea
 JOIN CovidAnalysisProject..CovidVaccination as vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
