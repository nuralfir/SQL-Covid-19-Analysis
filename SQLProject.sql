
Select location, date, total_cases, new_cases, total_deaths, population
From SQLProject..[covid-deaths]
Order By 1,2 -- Mengurutkan data sesuai dengan kolom yang ditentukan (1 = location, 2 = date)


-- Menampilkan hasil dari Total Cases vs. Total Deaths
-- Menunjukkan kemungkinan kematian jika tertular covid di sebuah negara (persentase_kematian)
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as persentase_kematian
From SQLProject..[covid-deaths]
Where location = 'Indonesia'
Order By 1,2


-- Menampilkan hasil dari Total Cases vs. Population
-- Menunjukkan persentase populasi yang terkena covid
Select location, date, total_cases, new_cases, population, (total_cases/population)*100 as persentase_kematian
From SQLProject..[covid-deaths]
Where location = 'Indonesia'
Order By 1,2


-- Mencari negara dengan angka infeksi covid tertinggi per populasi
Select location, population, MAX(total_cases) as infeksi_tertinggi, MAX((total_cases/population))*100 as persentase_populasi_terinfeksi
From SQLProject..[covid-deaths]
Group By location, population
Order By persentase_populasi_terinfeksi desc


-- Mencari negara dengan angka kematian tertinggi
Select location, MAX(total_deaths) as kematian_tertinggi
From SQLProject..[covid-deaths]
Where continent is not null
Group By location
Order By kematian_tertinggi desc


-- Menampilkan total angka kasus dan kematian keseluruhan semua negara
Select SUM(new_cases) as total_kasus, SUM(new_deaths) as total_kematian
From SQLProject..[covid-deaths]


-- Menampilkan total angka kasus dan kematian keseluruhan semua negara per hari
Select date, SUM(new_cases) as total_kasus, SUM(new_deaths) as total_kematian
From SQLProject..[covid-deaths]
Group By date
Order By 1


-- Menampilkan total populasi dengan vaksinasi
-- new_vaccinations ditampilkan dalam bentuk rolling count, seperti frekuensi kumulatif
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location Order By dea.location, dea.date) as fkumulatif_new_vaccinations
From SQLProject..[covid-deaths] dea
Join SQLProject..[covid-vaccination] vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null	
Order By 2,3


-- Menggunakan CTE untuk mengetahui persentase populasi yang telah divaksin
With PopvsVac (continent, location, date, population, new_vaccinations, fk_new_vaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location Order By dea.location, dea.date) as fk_new_vaccinations
From SQLProject..[covid-deaths] dea
Join SQLProject..[covid-vaccination] vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null	
)
Select *, (fk_new_vaccinations/population)*100
From PopvsVac
Order By 2,3
