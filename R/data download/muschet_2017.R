# muschet_2017
dataset_id <- "muschet_2017"

if (!file.exists("./data/raw data/muschet_2017/rdata.rds")) {
  # Downloading insect counts ----
  if (!file.exists("./data/cache/muschet_2017-CLSAInvertebrateCounts.csv")) {
    download.file(
      url = "https://www.sciencebase.gov/catalog/file/get/599d9555e4b012c075b964a6?name=CLSAInvertebrateCounts.csv",
      destfile = "./data/cache/muschet_2017-CLSAInvertebrateCounts.csv"
    )
  }
  dir.create("./data/raw data/muschet_2017/", showWarnings = FALSE)
  base::saveRDS(object = data.table::fread("./data/cache/muschet_2017-CLSAInvertebrateCounts.csv"), file = "./data/raw data/muschet_2017/rdata.rds")
}
