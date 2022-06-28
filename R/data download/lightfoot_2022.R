#lightfoot_2022

if (!file.exists("./data/raw data/lightfoot_2022/lizard_pitfall_data_89-06.csv")) {
  dir.create("./data/raw data/lightfoot_2022/", showWarnings = FALSE)
  download.file(
    url = "https://pasta.lternet.edu/package/data/eml/knb-lter-jrn/210007001/38/731f52d77045dfc5957589d35c2e6227",
    destfile = "./data/raw data/lightfoot_2022/lizard_pitfall_data_89-06.csv", 
    mode = "wb"
  )
}