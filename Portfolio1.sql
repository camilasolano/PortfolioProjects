SELECT * 
FROM PortforlioProject..CovidDataDeaths$ 
--Where continent is not null and continent<>''
ORDER BY 3,4 

--SELECT * 
--FROM PortforlioProject..CovidDataVaccinations$
--ORDER BY 3,4 

--Select the data that we are going to be using 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortforlioProject..CovidDataDeaths$ 
Where continent is not null
ORDER BY 1,2

--Looking at total cases vs total deaths
--Shows the likelihood to die if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortforlioProject..CovidDataDeaths$ 
WHERE LOCATION LIKE '%states%'  and continent is not null
ORDER BY 1,2

--Looking at total cases vs population
--Shows what percentage of the population got covid
SELECT Location, date, population, total_cases,  (total_cases/population)*100 as InfectedPercentage
FROM PortforlioProject..CovidDataDeaths$ 
--WHERE LOCATION LIKE '%PERU%'
Where continent is not null
ORDER BY 1,2

--Looking at countries with the highest infection rate compared to population
SELECT Location, population, MAX(total_cases) AS HightestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortforlioProject..CovidDataDeaths$ 
--WHERE LOCATION in ('united states',  'peru', 'south korea','egypt')
Where continent is not null
GROUP BY Location, population
ORDER BY PercentPopulationInfected desc

--Showing countries with the hightest death count per population
SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortforlioProject..CovidDataDeaths$
--WHERE LOCATION in ('united states',  'peru', 'south korea','egypt')
Where continent is not null and continent<>''
GROUP BY Location
ORDER BY TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT 


--Showing the continent with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortforlioProject..CovidDataDeaths$
--WHERE LOCATION in ('united states',  'peru', 'south korea','egypt')
Where continent <>''
GROUP BY continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS
SELECT  SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortforlioProject..CovidDataDeaths$ 
--WHERE LOCATION LIKE '%states%'  
WHERE continent <>'' --and date in ('2020-12-20',  '2021-12-20')
--GROUP BY date
ORDER BY 1,2


--Looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortforlioProject..CovidDataVaccinations$ vac
Join PortforlioProject..CovidDataDeaths$ dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent <>'' --and dea.location like '&albania%' 
ORDER BY 2,3

--USE CTE
With PopvsVac (continent,location,date,population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortforlioProject..CovidDataVaccinations$ vac
Join PortforlioProject..CovidDataDeaths$ dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent <>'' --and dea.location like '&albania%' 
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as mirna
from PopvsVac


--TEMP TABLE

--DROP TABLE #PercentPopulationVaccinated
if object_id ('tempdb ..#PercentPopulationVaccinated')is not null
drop table #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations float,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortforlioProject..CovidDataVaccinations$ vac
Join PortforlioProject..CovidDataDeaths$ dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent <>''  
ORDER BY 2,3

Select *, (RollingPeopleVaccinated/population)*100 as mirna
from #PercentPopulationVaccinated

--falta hacer este en drop table


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION
IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_NAME = '#PercentPopulationVaccinated')
DROP VIEW #PercentPopulationVaccinated
GO
Create view PercentPopulationVaccinatedaaa as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortforlioProject..CovidDataVaccinations$ vac
Join PortforlioProject..CovidDataDeaths$ dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent <>'' 
--ORDER BY 2,3
