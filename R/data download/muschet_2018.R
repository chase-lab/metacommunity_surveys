# muschet_2018
dataset_id <- "muschet_2018"

if (!file.exists("./data/raw data/muschet_2018/muschet_2018-CLSAamphibiansCounts.csv")) {
  dir.create("./data/raw data/muschet_2018/", showWarnings = FALSE)
  # Downloading amphibian counts ----
  download.file(
    url = "https://www.sciencebase.gov/catalog/file/get/59cab066e4b017cf314094e2?name=CLSA_Amphibians.csv",
    destfile = "./data/raw data/muschet_2018/muschet_2018-CLSAamphibiansCounts.csv"
  )
}
