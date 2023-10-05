
## starko_2019
dataset_id <- "starko_2019"
if (!file.exists(paste("data/raw data", dataset_id, "ddata_historical.rds", sep = "/"))) {
  curl::curl_download(
    url = "https://doi.org/10.1371/journal.pone.0213191.s002",
    destfile = "./data/cache/starko_2019_supp2.xlsx", mode = "wb"
  )
  ddata <- readxl::read_xlsx(
    path = "./data/cache/starko_2019_supp2.xlsx",
    sheet = 3, skip = 0
  )
  data.table::setDT(ddata)
  base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata_historical.rds", sep = "/"))


  curl::curl_download(
    url = "https://doi.org/10.1371/journal.pone.0213191.s001",
    destfile = "./data/cache/starko_2019_supp1.csv"
  )

  base::saveRDS(
    object = data.table::fread("data/cache/starko_2019_supp1.csv"),
    file = paste("data/raw data", dataset_id, "coords.rds", sep = "/")
  )
}
