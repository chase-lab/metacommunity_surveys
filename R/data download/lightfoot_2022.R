#lightfoot_2022

dataset_id <- "lightfoot_2022"
if (!file.exists("./data/raw data/lightfoot_2022/lizard_pitfall_data_89-06.rds")) {
  download.file(url = "https://pasta.lternet.edu/package/data/eml/knb-lter-jrn/210007001/38/731f52d77045dfc5957589d35c2e6227",destfile = "./data/cache/lightfoot_2022/lizard_pitfall_data_89-06.csv", mode = "wb")

  ddata <- read.csv(
      file = "./data/cache/lightfoot_2022/lizard_pitfall_data_89-06.csv"
  )
  data.table::setDT(ddata)
  dir.create("./data/raw data/lightfoot_2022", showWarnings = FALSE)
  saveRDS(ddata, "./data/raw data/lightfoot_2022/lizard_pitfall_data_89-06.rds")
}
