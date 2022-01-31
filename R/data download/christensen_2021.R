# christensen_2021

if (!file.exists("./data/raw data/christensen_2021/taxo.rds")) {
  if (!file.exists("./data/cache/christensen_2021/ecy3530-sup-0002-DataS2.zip")) {
    dir.create(path = "./data/cache/christensen_2021", showWarnings = FALSE)
    download.file(
      url = "https://esajournals.onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1002%2Fecy.3530&file=ecy3530-sup-0002-DataS2.zip",
      destfile = "./data/cache/christensen_2021/ecy3530-sup-0002-DataS2.zip",
      mode = "wb"
    )
  }

  annual_species <- read.csv(unz(description = "./data/cache/christensen_2021/ecy3530-sup-0002-DataS2.zip", filename = "Jornada_csv_files/Jornada_quadrat_annual_plant_counts.csv"))

  perennial_species <- read.csv(unz(description = "./data/cache/christensen_2021/ecy3530-sup-0002-DataS2.zip", filename = "Jornada_csv_files/Jornada_quadrat_perennials.csv"))

  taxo <- read.csv(unz(description = "./data/cache/christensen_2021/ecy3530-sup-0002-DataS2.zip", filename = "Jornada_csv_files/Jornada_quadrat_species_list.csv"))

  data.table::setDT(annual_species)
  data.table::setDT(perennial_species)
  data.table::setDT(taxo)

  perennial_species <- perennial_species[, .(value = .N), by = .(quadrat, year, month, species_code)]

  dir.create(path = "./data/raw data/christensen_2021", showWarnings = FALSE)
  base::saveRDS(annual_species, file = "./data/raw data/christensen_2021/annual_species.rds")
  base::saveRDS(perennial_species, file = "./data/raw data/christensen_2021/perennial_species.rds")
  base::saveRDS(taxo, file = "./data/raw data/christensen_2021/taxo.rds")
}
