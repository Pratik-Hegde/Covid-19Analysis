 
--Select * 
--From Portfolio1..CovidDeaths


Select *
From Portfolio1..CovidDeaths
Where continent is not null
order by 3,4

-- Select the data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths,population
From Portfolio1..CovidDeaths
Order by 1,2


-- Looking at total cases VS total deaths
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio1..CovidDeaths
Where location like '%France%'
Order by 1,2


-- Looking at total cases VS population
-- show what percentage of population got Covid
Select Location, date, total_cases, population, (total_cases/population)*100 as AffectedPercentage
From Portfolio1..CovidDeaths
--Where location like '%France%'
Order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From Portfolio1..CovidDeaths
Group By location, population
--Where location like '%Kingdom%'
Order by 4 desc

-- Let's break down by continent
Select continent, MAX(cast(total_deaths as int)) as totaldeath
From Portfolio1..CovidDeaths
where continent is not null
Group By continent
--Where location like '%Kingdom%'
Order by totaldeath desc

--Showing countries with highest death count per population
Select Location, population, MAX(cast(total_deaths as int)) as totaldeath
From Portfolio1..CovidDeaths
where continent is not null
Group By location, population
--Where location like '%Kingdom%'
Order by totaldeath desc


-- Global Numbers
Select   Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, 
Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From Portfolio1..CovidDeaths
Where continent is not null
--Group by date
order by 1,2


-- Group of CovidDeaths and CovidVaccination tables
-- Looking at Total population VS vaccination

select *
From Portfolio1..CovidDeaths dea
Join Portfolio1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	order by vac.total_vaccinations desc


select vac.date, dea.location, population, dea.total_deaths, vac.total_vaccinations
From Portfolio1..CovidDeaths dea
Join Portfolio1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where total_vaccinations is not null and total_deaths is not null
	order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location) as tot
--Sum(Convert(int, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date)
--Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.Location)
From Portfolio1..CovidDeaths dea
Join Portfolio1..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPepsVaccinated
From Portfolio1..CovidDeaths dea
Join Portfolio1..CovidVaccinations vac
	On dea.date = vac.date
	and dea.location = vac.location
where dea.continent is not null and vac.new_vaccinations is not null
order by 2,3 

--Using CTE

with vaccinatedPercentage ( continent, location, date, population, new_vaccinations, RollingPepsVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(int, new_vaccinations)) over (partition by dea.location order by dea.date, dea.location) as RollingPepsVaccinated
from Portfolio1..CovidDeaths dea
Join Portfolio1..CovidVaccinations vac
	On dea.date = vac.date
	and dea.location = vac.location
where dea.continent is not null and vac.new_vaccinations is not null 
)
select * , (RollingPepsVaccinated/population)*100 as TotalVaccinationPercentage
from vaccinatedPercentage


--Temp Table Creation 
Drop table if exists PercentPopulationVaccinated
Create table PercentPopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPepsVaccinated numeric
)
Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(numeric,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPepsVaccinated
From Portfolio1..CovidDeaths dea
Join Portfolio1..CovidVaccinations vac
	On dea.date = vac.date
	and dea.location = vac.location
--where dea.continent is not null and vac.new_vaccinations is not null
--order by 2,3

select * , (RollingPepsVaccinated/population)*100 as TotalVaccinationPercentage
from PercentPopulationVaccinated

select * 
from PercentPopulationVaccinated


--Create a view

Create view PercentPopulationVaccinatedview
as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPepsVaccinated
From Portfolio1..CovidDeaths dea
Join Portfolio1..CovidVaccinations vac
	On dea.date = vac.date
	and dea.location = vac.location
where dea.continent is not null and vac.new_vaccinations is not null