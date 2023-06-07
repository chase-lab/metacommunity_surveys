#lightfoot_2022

dataset_id <- "lightfoot_2022"
if (!base::file.exists("./data/raw data/lightfoot_2022/rdata.rds")) {
   base::download.file(url = "https://portal.edirepository.org/nis/dataviewer?packageid=knb-lter-jrn.210007001.38&entityid=731f52d77045dfc5957589d35c2e6227",destfile = "./data/cache/lightfoot_2022/lizard_pitfall_data_89-06.csv", mode = "wb")

   base::dir.create("./data/raw data/lightfoot_2022", showWarnings = FALSE)
   base::saveRDS(
      data.table::fread(
         file = "./data/cache/lightfoot_2022/lizard_pitfall_data_89-06.csv",
         sep = ','
      ),
      file = "./data/raw data/lightfoot_2022/rdata.rds"
   )
}
