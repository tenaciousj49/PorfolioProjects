SELECT*
FROM PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

--SELECT*
--FROM PortfolioProject..CovidVaccinations$
--order by 3,4

--Select the data we are going to be using

SELECT Location, Date, Total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2

--Looking at Total cases vs total deaths
--Shows the likelihood of you dying if you contract Covid in your country
SELECT Location, Date, Total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
Where location like '%States%'
order by 1,2

--Total Cases vs Population
--shows what percentage of population got Covid

SELECT Location, Date,population, Total_cases,(total_cases/population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--Where location like '%States%'
order by 1,2

--looking at countries with highest infection rate compared to population

SELECT Location, Population, MAX(Total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as 
PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths$
--Where location like '%States%'
Group by Location, population
order by PercentagePopulationInfected desc


-- showing the countries with the highest death count per population

SELECT Location, MAX(cast (Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--Where location like '%States%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--let's break things down by continent

-- Showing the continents with the highest death count per population

SELECT continent, MAX(cast (Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--Where location like '%States%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM
(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--Where location like '%States%'
where continent is not null
--Group by date
order by 1,2

--Looking at total population vs vaccination - the total number of people vaccinated in the world

--Use CTE for RollingPeopleVaccinated since the table doesn't exist

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/population)*100
From PopvsVac

--Use CTE for RollingPeopleVaccinated since the table doesn't exist

--With PopsVac as 

--select*
--from PortfolioProject..CovidDeaths$ dea
--Join PortfolioProject..CovidVaccinations$ vac
--	On dea.location = vac.location 
--	and dea.date = vac.date
	
--Temp Table

--DROP Table if exists #PercentPopluationVaccinated

Create Table #PercentPopluationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopluationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location 
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select*, (RollingPeopleVaccinated/population)*100
From #PercentPopluationVaccinated

--Creating  A View to store data for later visualizations

Create view PercentPopluationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopluationVaccinated

