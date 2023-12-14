USE [Portfolio Project]

-- Select everything from table

Select * From Covid_Death$;

Select * From Covid_Vaccination$;

Select * 
From Covid_Death$
order by 3,4;

-- Select total-death as per location

Select location,SUM(CONVERT(float, total_deaths))as Total_Death
from Covid_Death$
where total_deaths is not null
group by location
order by Total_Death;

--  Looking at Total Cases v/s Total Deaths
-- Shows likelihood of dying if anyone contract Covid

Select location,date,total_cases,total_deaths,
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
from Covid_Death$
where location like '%state%'
order by 1,2;

--Looking at Total Cases v/s Population
--Shows what percentage of population got Covid

Select location,date,total_cases,population,
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PopulationInfected
from Covid_Vaccination$
where location like '%state%'
Order by 1,2;

-- Looking at Countries with Highest Infection Rate compared to Population

Select location,Population,Max(total_cases) as HighestInfectionCount,
Max((total_cases/population))*100 as PercentPopulationInfected
from Covid_Vaccination$
Group by location,Population
Order by PercentPopulationInfected DESC;

-- Showing countries with Highest Death Count per population 

Select Location, MAX(cast(total_deaths as int))as Total_deathsCount
FROM Covid_Death$
where continent is not null
group by location
order by Total_deathsCount desc;

-- Breaking the data down by continent

Select continent, MAX(cast(total_deaths as int))as Total_deathsCount
FROM Covid_Death$
where continent is not Null
group by continent
order by Total_deathsCount desc;

-- Covid Vaccination

Select *
 From Covid_Vaccination$;

 -- Joining Table

 Select *
 From Covid_Death$ dea
 join Covid_Vaccination$ vac
 on dea.location = vac.location
 and dea.date = vac.date;

 --Total Population v/s Vaccinations
 
Select dea.continent,dea.location,dea.date,vac.population,vac.new_vaccinations
From Covid_Death$ dea
join Covid_Vaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;

 --Total Population v/s Vaccinations

 Select dea.continent,dea.location,dea.date,vac.population,vac.new_vaccinations,
 Sum(convert(bigint,new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rolling_Vaccination
From Covid_Death$ dea
join Covid_Vaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- USE CTE

with popvsvac(continent,location,date,population,new_vaccinations,rolling_vaccinations)
as
(
Select dea.continent,dea.location,dea.date,vac.population,vac.new_vaccinations,
 Sum(convert(bigint,new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rolling_Vaccination
From Covid_Death$ dea
join Covid_Vaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *, (Rolling_vaccinations/population)*100
from popvsvac;

--USE Temp Table

Create table #Percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_vaccinations numeric,
)

Insert into #Percentpopulationvaccinated
Select dea.continent,dea.location,dea.date,vac.population,vac.new_vaccinations,
 Sum(convert(bigint,new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rolling_Vaccination
From Covid_Death$ dea	
join Covid_Vaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;

Select *, (Rolling_vaccinations/population)*100
from #Percentpopulationvaccinated;

-- Creating views to store data for Visualization

Create View Percentpopulationvaccinated as

Select dea.continent,dea.location,dea.date,vac.population,vac.new_vaccinations,
 Sum(convert(bigint,new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rolling_Vaccination
From Covid_Death$ dea	
join Covid_Vaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;

Select * From Percentpopulationvaccinated

