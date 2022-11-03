SELECT *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3, 4


--verify import

--SELECT *
--From PortfolioProject..CovidVaccinations
--order by 3, 4

--Select Data to be used

Select Location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject.. CovidDeaths
order by 1, 2

--Looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in specific country

Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.. CovidDeaths
Where location like '%states%'
order by 1, 2

--Looking at Total Cases vs Population
--shows what percentage of population got Covid

Select Location, date, population,total_cases, (total_cases/population)*100 as DeathPercentage
From PortfolioProject.. CovidDeaths
--Where location like '%states%'
order by 1, 2

--Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.. CovidDeaths
--Where location like '%states%'
Group by Location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

Select Location,Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject.. CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc
--verified TotalDeathCount on worldometers

--Break down by Continent

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject.. CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Select location, Max(cast(Total_deaths as int)) as TotalDeathCount
--From PortfolioProject.. CovidDeaths
----Where location like '%states%'
--Where continent is null
--Group by location
--order by TotalDeathCount desc

--Showing contintents with the highest death count per population

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject.. CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers

Select SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM
	(New_Cases)*100 as DeathPercentage
From PortfolioProject.. CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group By date
order by 1,2

-- Join tables
--Select *

--From PortfolioProject..CovidDeaths dea
--Join PortfolioProject..CovidVaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	Sum(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--	,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE 

with PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	Sum(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--	,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Create View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	Sum(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--	,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

--Query off the View
Select *
From PercentPopulationVaccinated