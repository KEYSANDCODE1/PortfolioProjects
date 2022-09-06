Select * 
From PorfolioProject..CovidDeath$
Where continent is not null 
order by 3,4 

--Select * 
--From PorfolioProject..CovidVaccinations$
--order by 3,4 

--Select Data that we are going to be using 

Select Location, total_cases, new_cases, total_deaths,population 
From PorfolioProject..CovidDeath$
Where continent is not null 
order by 1,2

-- Looking at the Total Cases vs Total Deaths 
-- Shows the likelihood of dying if you contract covid in your country 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PorfolioProject..CovidDeath$
Where location like '%states%'
order by 1,2


-- Looking at the Total Cases vs Population 
--Shows what percentage of population contracted Covid

Select Location, date, population total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PorfolioProject..CovidDeath$
Where location like '%states%'
order by 1,2


-- Looking at the Countries with the Highes Infection Rate compared to Population 

Select Location,Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PorfolioProject..CovidDeath$
-- Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing Countries with the Highest Death Count per Population 

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProject..CovidDeath$
-- Where location like '%states%'
Where continent is not null 
Group by Location 
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProject..CovidDeath$
-- Where location like '%states%'
Where continent is not null
Group by continent 
order by TotalDeathCount desc



-- GLOBAL NUMBERS 

Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PorfolioProject..CovidDeath$ 
-- Where location like '%states%'
Where continent is not null
--Group By date
order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.Location Order by dea.Location,
 dea.Date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From PorfolioProject..CovidDeath$ dea
Join PorfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3



-- Use CTE 

With PopvsVac (Continent, Location, Date, Population,New_Vacccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.Location Order by dea.Location,
 dea.Date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From PorfolioProject..CovidDeath$ dea
Join PorfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPopulationPercentage
From PopvsVac


-- TEMP TABLE 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.Location Order by dea.Location,
 dea.Date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From PorfolioProject..CovidDeath$ dea
Join PorfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPopulationPercentage
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.Location Order by dea.Location,
 dea.Date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From PorfolioProject..CovidDeath$ dea
Join PorfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated