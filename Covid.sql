select *
from PortfolioProject..CovidDeath
Where continent is not null
order by 3,4

-- select *
-- from PortfolioProject..CovidVaccinations
-- order by 3,4

-- Lấy dữ liệu cần sử dụng

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeath
Where continent is not null
order by 1,2

-- Tính tỷ lệ người chết so với người bị nhiễm
-- Hiển thị khả năng chết trong đất nước bất kỳ

select location, date, total_cases, total_deaths, (convert(float, total_deaths) / convert(float, total_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeath
Where location = 'Vietnam'
and continent is not null
order by 1,2


-- Tỷ lệ dân số nhiễm covid

select location, date, total_cases, total_deaths, (convert(float, total_cases) / convert(float, population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeath
-- Where location = 'Vietnam'
Where continent is not null
order by 1,2

-- Hiển thị quốc gia có tỷ lệ lây nhiễm cao nhất

select location, population, max(total_cases) as HighestInfectionCount, max((convert(float, total_cases) / convert(float, population)))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeath
--Where location = 'Vietnam'
Where continent is not null
group by location, population
order by PercentPopulationInfected desc

-- Hiển thị quốc gia có số dân chết cao nhất

select location, max(cast(total_deaths as int)) as TotalDeathCount  -- Hàm cast = hàm convert
from PortfolioProject..CovidDeath
--Where location = 'Vietnam'
Where continent is not null
group by location
order by TotalDeathCount desc

-- Hiển thị theo châu lục

select continent, max(cast(total_deaths as int)) as TotalDeathCount  -- Hàm cast = hàm convert
from PortfolioProject..CovidDeath
--Where location = 'Vietnam'
Where continent is not null
group by continent
order by TotalDeathCount desc

-- Hiển thị châu lục có số lượng chết cao nhất

select continent, max(cast(total_deaths as int)) as TotalDeathCount  -- Hàm cast = hàm convert
from PortfolioProject..CovidDeath
--Where location = 'Vietnam'
Where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Number : Số lượng toàn cầu

select date, sum(new_cases) as TotalCases, sum(convert(int, new_deaths)) as TotalDeaths --((sum(convert(int, new_deaths)))/(sum(new_cases)))*100 as DeathPercentage
from PortfolioProject..CovidDeath
-- Where location = 'Vietnam'
where continent is not null
group by date
order by 1,2

-- So sánh tổng số người được tiêm vắc xin vs tổng dân số

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float, new_vaccinations)) over (partition by dea.population order by dea.location,dea.date) as RollingPeopleVaccinated -- để tính tổng số ca mắc mới theo khu vực
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	AND dea.date = vac.date
order by 1,2,3

-- Use CTE : Common Table Expression

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float, new_vaccinations)) over (partition by dea.population order by dea.location,dea.date) as RollingPeopleVaccinated -- để tính tổng số ca mắc mới theo khu vực
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	AND dea.date = vac.date
)

select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

-- Temp table
Create table #PercentPopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

alter table #PercentPopulationVaccinated
alter column new_vaccinations float

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float, new_vaccinations)) over (partition by dea.population order by dea.location,dea.date) as RollingPeopleVaccinated -- để tính tổng số ca mắc mới theo khu vực
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated