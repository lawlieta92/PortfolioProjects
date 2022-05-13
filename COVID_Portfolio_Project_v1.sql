Select *
From PortfolioProject..CovidDeaths
Where continent is not null and continent <> ''
Order By 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order By 3,4

-- Select data that we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths
Where continent is not null and continent <> ''
Order By 1,2 --based on location and date

--Looking at Total Cases vs Total Deaths
--Likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (Total_Deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%india%' and continent is not null and continent <> ''
Order By 1,2


--Looking at Total Cases vs population
--Shows what percentage of population has got covid
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentageOfPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%india%' and continent is not null and continent <> ''
Order By 1,2

--Looking at countries with highest infection rate compared to their populations
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentageOfPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null and continent <> ''
Group By location, population
Order By PercentageOfPopulationInfected desc

--Showing countries with the highest death count
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null and continent <> ''
Group By location
Order By TotalDeathCount desc

--Showing continents with highest death counts
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null and continent <> ''
Group By continent 
Order By TotalDeathCount desc

--Global Numbers - by continent
Select continent, SUM(new_cases) as Total_New_Cases, SUM(cast(new_deaths as float)) as Total_New_Deaths, SUM(cast(new_deaths as float))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null and continent <> ''
Group By continent
Order By 1,2

--Global Numbers - total
Select SUM(new_cases) as Total_New_Cases, SUM(cast(new_deaths as float)) as Total_New_Deaths, SUM(cast(new_deaths as float))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null and continent <> ''
--Group By 
Order By 1,2


--Showing total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.continent <> ''
order by 2, 3


--Use CTE
With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.continent <> ''
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac


--Use Temp Table
Drop Table if exists #PercentPopulationVaxxed
Create Table #PercentPopulationVaxxed
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_Vaccinations nvarchar(255),
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaxxed
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null and dea.continent <> ''
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaxxed


--Creating View to Store Data for Viz
Create View PercentPopVaxed
As
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.continent <> ''
--order by 2, 3

Select *
FRom PercentPopVaxed