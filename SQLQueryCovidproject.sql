--select top 5 * from dbo.Covid_vacinations  

-- Select data to be used  
select Location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProjectCovid..Covid_deaths
order by 1,2

-- Looking at total cases vs total deaths in us
select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) * 100 as deathpercentage
from PortfolioProjectCovid..Covid_deaths
where location like '%states%'
order by 1,2

-- total cases vs population in us
-- shows what percentage of population got covid
select Location, date, total_cases, population, total_deaths, (total_deaths/total_cases) * 100 as deathpercentage
from PortfolioProjectCovid..Covid_deaths
where location like '%states%'
order by 1,2
 
 -- Countries with highest Infesction rate compated to population 
select location,population, max((total_cases)) as highestinfectioncount, max((total_cases/population)) * 100 as highestpopulationinfected
from dbo.Covid_deaths
--where location like '%states%'
group by location, population 
order by highestpopulationinfected desc

-- Countries with highest death count per population 
select location,max(Cast(total_deaths as int)) as TotalDeathCount
from dbo.Covid_deaths
where continent is not null
group by location
order by TotalDeathCount desc

--break down by continent 

select continent,max(cast(total_deaths as int)) as TotalDeathCount
from dbo.Covid_deaths
where location is not null 
group by continent
order by TotalDeathCount desc

-- Continents with highest death count 
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from dbo.Covid_deaths
where location is not null 
group by continent
order by TotalDeathCount desc

--Global numbers 
select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as Deathpercentage
from dbo.Covid_deaths
where continent is not null 
group by date 
order by 1,2 

-- Looking for total population vs vaccinations

Select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(convert(bigint,v.new_vaccinations )) over (partition by d.location order by d.location,d.date) as RollingVaccinated
from dbo.Covid_deaths d
join dbo.Covid_vacinations v 
on d.location = v.location and d.date = v.date
where d.continent is not null 
order by 2,3

--USE CTE
with PopvsVac ( Contienent, Location, Date, Population,New_vaccinations,RollingPeopleVaccinated) 
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(convert(bigint,v.new_vaccinations )) over (partition by d.location order by d.location,d.date) as RollingVaccinated
from dbo.Covid_deaths d
join dbo.Covid_vacinations v 
on d.location = v.location and d.date = v.date
where d.continent is not null 
)
select *, (RollingPeopleVaccinated/Population) *100 
from PopvsVac

-- temp table 
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(convert(bigint,v.new_vaccinations )) over (partition by d.location order by d.location,d.date) as RollingVaccinated
from dbo.Covid_deaths d
join dbo.Covid_vacinations v 
on d.location = v.location and d.date = v.date
where d.continent is not null 

select * from #PercentPopulationVaccinated

--creating view to store data for later visualizations
create view PercentPopulationVaccinated as 
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert(bigint,v.new_vaccinations )) 
over (partition by d.location order by d.location,d.date) as RollingVaccinated
from dbo.Covid_deaths d
join dbo.Covid_vacinations v 
on d.location = v.location and d.date = v.date
where d.continent is not null 
