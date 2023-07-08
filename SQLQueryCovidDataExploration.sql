--Data exploaration using Covid-19 vaccination and death data sourced from  https://ourworldindata.org/covid-deaths
--Select * 
--From PortfolioProject..CovidDeaths$
--Order by 3,4

-- Select specific data 
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Order by location, date

--Looking at Total Cases vs Total Deaths in the UK
--Percentage of people dying if they contracted Covid19
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths$
Where location like '%kingdom%'
Order by location, date


--Looking at Total Cases vs Population in the US
--Percentage of population that contracted Covid19
Select location, date, total_cases, population, (total_cases/population)*100 as population_percentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
Order by location, date

-- Looking at countries infection rate compared to population, sorted with highest infection rate first
Select location, population, MAX(total_cases) as highest_infection_count, MAX(total_cases/population)*100 as infected_population_percentage
From PortfolioProject..CovidDeaths$
Group by location, population
Order by infected_population_percentage desc

-- Showing the countries with Highest Death Count per population
Select location, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by location
Order by total_death_count desc

-- Showing seven closest countries neighbouring the UK by total Death Count per population
Select location, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths$
Where continent is not null AND
		location IN ('United Kingdom', 'France', 'Belgium', 'Netherlands',
		'Denmark', 'Germany', 'Luxembourg', 'Ireland')
Group by location
Order by total_death_count desc


--Creating view to store data for later visualisation
--Showing seven closest countries neighbouring the UK by total Death Count per population
GO
Create view UKNeighboursTotalDeaths as
Select location, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths$
Where continent is not null AND
		location IN ('United Kingdom', 'France', 'Belgium', 'Netherlands',
		'Denmark', 'Germany', 'Luxembourg', 'Ireland')
Group by location
GO

Select *
From UKNeighboursTotalDeaths

-- Showing the continent with Highest Death Count per population
Select continent, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
Order by total_death_count desc


--Global numbers
--Calculating Global percentage of total new cases compared to total new deaths by date
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by date

--Calculating Global percentage of total new cases compared to total new deaths
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths$
Where continent is not null


--Total population vs vaccinations, new vaccinations per day and total new vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as sum_new_vaccinations
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location	
	and dea.date = vac.date
Order by dea.location, dea.date

-- Use CTE to calculate rolling percentage of population vaccinated
with PopvsVac(Continent, location, date, population, new_vaccinations, sum_new_vaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as sum_new_vaccinations
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location	
	and dea.date = vac.date
--Order by dea.location, dea.date
)
Select *, (sum_new_vaccinations/population)*100 as percentage_population_vaccinated
From PopvsVac



-- Use Temp Table to calculate rolling percentage of population vaccinated
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
sum_new_vaccinations numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as sum_new_vaccinations
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location	
	and dea.date = vac.date
--Order by dea.location, dea.date

Select *, (sum_new_vaccinations/population)*100 as percentage_population_vaccinated
From #PercentPopulationVaccinated

--Creating view to store data for later visualisation
--Percentageof Population Vaccinated view
--Create view PercentagePopulationVaccinated as
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as sum_new_vaccinations
--From PortfolioProject..CovidDeaths$ dea
--Join PortfolioProject..CovidVaccinations$ vac
--	On dea.location = vac.location	
--	and dea.date = vac.date
