
Select *
From [Portfolio Project]..CovidDeaths
Where continent is not null
Order by 3 ,4

Select *
From [Portfolio Project]..CovidVaccinations
Order by 3, 4

--Select Data That We Are Going To Using

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
Order by 1, 2


--Looking At Total Cases Vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where location like '%japan%'
Order by 1, 2


--Looking At Total Cases Vs Population
--Shows what percentage of population got Covid
Select location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
--Where location like '%japan%'
Order by 1, 2


--Looking At Countries With Highest Infection Rate Compared To Popultion
Select location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 
as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
--Where location like '%japan%'
Group by Location, Population
Order by PercentPopulationInfected desc


--Showing Countries With Highest Death Count Per Population
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%japan%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc


--Let's Break Things Down By Continent
--Showing Continents With The Highest Death Count Per Population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%japan%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


--Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) 
as total_deaths, SUM(cast(New_deaths as int))/SUM(New_Cases)*100 
as DeathPercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%japan%'
Where continent is not null
--Group by date
Order by 1, 2


--Looking At Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table
Drop Table if exists #PercetPopulationVaccinated
Create Table #PercetPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercetPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercetPopulationVaccinated


--Creating View #PerventPopulationVaccinated
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated








