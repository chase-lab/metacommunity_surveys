# muschet_2018
dataset_id <- "muschet_2018"

if (!file.exists("./data/raw data/muschet_2018/muschet_2018-CLSAamphibiansCounts_v2.csv")) {
  dir.create("./data/raw data/muschet_2018/", showWarnings = FALSE)
  # Downloading amphibian counts ----
  download.file(
    url = "https://www.sciencebase.gov/catalog/file/get/624c7543d34e21f82764df13?name=CLSA_Amphibians1992_2021.csv",
    destfile = "./data/raw data/muschet_2018/muschet_2018-CLSAamphibiansCounts_v2.csv"
  )
}
