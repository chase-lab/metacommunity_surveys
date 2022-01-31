# willig_2010
dataset_id <- "willig_2010"

if (!file.exists("./data/raw data/willig_2010/LFDPSnailCaptures.csv")) {
  dir.create("./data/raw data/willig_2010/", showWarnings = FALSE)
  download.file(
    url = "https://portal.edirepository.org/nis/dataviewer?packageid=knb-lter-luq.107.9996737&entityid=7b9c3b52ea20b841637aba71e870f368",
    destfile = "./data/raw data/willig_2010/LFDPSnailCaptures.csv"
  )
}
