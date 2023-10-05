# burlakova_2021
if (!file.exists("./data/raw data/burlakova_2021/rdata.rds")) {
  if (!file.exists("./data/cache/burlakova_2021_ecy3528-sup-0001-DataS1.zip")) {
    curl::curl_download(
      url = "https://esajournals.onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1002%2Fecy.3528&file=ecy3528-sup-0001-DataS1.zip",
      destfile = "./data/cache/burlakova_2021_ecy3528-sup-0001-DataS1.zip",
      mode = "wb"
    )
  }

  ddata <- read.csv(
    file = base::unz(
      description = "./data/cache/burlakova_2021_ecy3528-sup-0001-DataS1.zip",
      filename = "OntarioBenthosSpeciesDensity.csv"
    ),
    nrows = 545L
  )

  data.table::setDT(ddata)

  dir.create(path = "./data/raw data/burlakova_2021", showWarnings = FALSE)
  base::saveRDS(ddata, file = "./data/raw data/burlakova_2021/rdata.rds")
}
