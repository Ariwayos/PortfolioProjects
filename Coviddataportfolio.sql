Select * From PortfolioProject..Deathcovid
Where continent is not null
order by 3,4

Select * From PortfolioProject..Vaccinations
Where continent is not null
order by 3,4

-- select the Data the we will be using


Select Location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..Deathcovid
Where continent is not null
order by 1,2

--- Looking at Total cases versus Total deaths by countries

Select Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..Deathcovid
where Location like '%states%'
and continent is not null
order by 1,2


--- Looking at Total cases versus Population by countries
--- Shows what percentage of population got covid
Select Location,date,Population,total_cases,(total_cases/Population)*100 as PercentPopluationinfected
From PortfolioProject..Deathcovid
---where Location like '%states%'
Where continent is not null
order by 1,2


--- Looking at Countries with highest infection rate compared to Population
Select Location,Population, MAX(total_cases) as Highestinfectioncount,MAX((total_cases/Population))*100 as PercentPopluationinfected
From PortfolioProject..Deathcovid
---where Location like '%states%'
Where continent is not null
Group by Location, Population
order by PercentPopluationinfected desc

----Showing countries with highest death count per population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathcount
From PortfolioProject..Deathcovid
---where Location like '%states%'
---Where continent is not null
Where continent is null
Group by Location
order by TotalDeathcount desc
---We discovered that the query by continent below was not correct due use of "Where continent is not null" but when we
use "where continent is null"

----Showing continent with highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathcount
From PortfolioProject..Deathcovid
---where Location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathcount desc

GLOBAL NUMBERS

Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..Deathcovid
--- where Location like '%states%'
Where continent is not null
---Group by date
order by 1,2


--Looking at Total Population vs Vaccination

Select * 
From PortfolioProject..Deathcovid dea
Join PortfolioProject..Vaccinations vac
	On dea.location= vac.location
	and dea.date= vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
---SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location)
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Location, dea.Date) as RollingPeopleVaccinated
---(RollingPeopleVaccinated/population)*100
From PortfolioProject..Deathcovid dea
Join PortfolioProject..Vaccinations vac
	On dea.location= vac.location
	and dea.date= vac.date
Where dea.continent is not null
order by 2,3


USE CTE 

With PopvsVac(Continent,Location,Date, Population,New_Vaccinations,RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
---SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location)
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Location, dea.Date) as RollingPeopleVaccinated
---(RollingPeopleVaccinated/population)*100
From PortfolioProject..Deathcovid dea
Join PortfolioProject..Vaccinations vac
	On dea.location= vac.location
	and dea.date= vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

TEMP TABLE

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
insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
---SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location)
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Location, dea.Date) as RollingPeopleVaccinated
---(RollingPeopleVaccinated/population)*100
From PortfolioProject..Deathcovid dea
Join PortfolioProject..Vaccinations vac
	On dea.location= vac.location
	and dea.date= vac.date
---Where dea.continent is not null
order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

---- Creating view to store data for later visualization

DROP Table if exists #PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
---SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location)
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Location, dea.Date) as RollingPeopleVaccinated
---(RollingPeopleVaccinated/population)*100
From PortfolioProject..Deathcovid dea
Join PortfolioProject..Vaccinations vac
	On dea.location= vac.location
	and dea.date= vac.date
Where dea.continent is not null
--order by 2,3
DROP Table if exists #PercentPopulationVaccinated

Select * From  PercentPopulationVaccinated