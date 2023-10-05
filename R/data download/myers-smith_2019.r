## myers-smith_2019
dataset_id <- "myers-smith_2019"

if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
   if (!file.exists("./data/raw data/myers-smith_2019/QikiqtarukHub-v1.0.zip")) {
      dir.create(path = "./data/raw data/myers-smith_2019", showWarnings = FALSE)
      curl::curl_download(
         url = "https://zenodo.org/record/2397996/files/ShrubHub/QikiqtarukHub-v1.0.zip?download=1",
         destfile = "./data/raw data/myers-smith_2019/QikiqtarukHub-v1.0.zip", mode = "wb"
      )
   }

   ddata <- read.csv(
      file = unz(
         description = "./data/raw data/myers-smith_2019/QikiqtarukHub-v1.0.zip",
         filename = "ShrubHub-QikiqtarukHub-5000be2/data/qhi_cover_ITEX_1999_2017.csv"),
      na.strings = c("", "na"), header = TRUE, sep = ","
   )
   ddata <- ddata[, c("sub_name", "sub_lat", "sub_long", "year", "plot", "name", "cover")]

   data.table::setDT(ddata)
   base::saveRDS(
      object = ddata,
      file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
}
