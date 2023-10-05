## closset-kopp_2018
dataset_id <- "closset-kopp_2018"

if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
  url <- "https://besjournals.onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1111%2F1365-2745.13118&file=jec13118-sup-0002-TableS1.xlsx"
  if (!file.exists("./data/cache/closset-kopp_2018_jec13118-sup-0002-tables1.xlsx")) {
    curl::curl_download(url = url, destfile = "./data/cache/closset-kopp_2018_jec13118-sup-0002-tables1.xlsx", mode = "wb")
  }

  ddata <- readxl::read_xlsx(
    "./data/cache/closset-kopp_2018_jec13118-sup-0002-tables1.xlsx",
    sheet = 1, skip = 1, n_max = 244
  )
  data.table::setDT(ddata)

  dir.create(paste0("data/raw data/", dataset_id), showWarnings = FALSE)
  base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
}
