Select *
From [Portfolio Project]..CovidDeaths
Where continent is not null 
order by 3,4

-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where location like '%ukraine%'
and continent is not null 
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
Select Location, date, total_cases,population, (total_cases/population)*100 as PopulationInfectedPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null 
Where location like '%ukraine%' 
order by 1,2

--Looking at countries with Highest Infection Rate compared to Population
Select location, population, max(total_cases) as HighestInfectionRate, max((total_cases/population))*100 as PopulationInfectedPercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%ukraine%'
Where continent is not null 
group by location, population
order by PopulationInfectedPercentage desc



--Showing Countries with Highest Death Count per Population
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%ukraine%'
Where continent is not null 
group by location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%ukraine%'
Where continent is not null 
group by continent
order by TotalDeathCount desc

--Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%ukraine%'
where continent is not null 
--Group By date
order by 1,2


--Looking at total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
JOiN [Portfolio Project].dbo.CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by  2, 3

--Use CTE

with PopvsVac (Continent, Location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
JOiN [Portfolio Project].dbo.CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by  2, 3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
( Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
JOiN [Portfolio Project].dbo.CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by  2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later viasualization

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
JOiN [Portfolio Project].dbo.CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

