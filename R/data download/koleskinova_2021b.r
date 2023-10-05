dataset_id <- "koleskinova_2021b"

if (!file.exists("data/raw_data/koleskinova_2021b/rdata.rds")) {
   # downloading ----
   if (!file.exists("data/cache/koleskinova_2021b_dwca-lpk-v1.3.zip")) {
      curl::curl_download(url = "http://ib.komisc.ru:8088/ipt/archive.do?r=lpk&v=1.3",
                    destfile = "data/cache/koleskinova_2021b_dwca-lpk-v1.3.zip",
                    mode = "wb")
   }

   # reading data ----
   ddata <- read.delim(unz(
      description = "data/cache/koleskinova_2021b_dwca-lpk-v1.3.zip",
      filename = "occurrence.txt"), encoding = "UTF-8")
   event <- read.delim(unz(
      description = "data/cache/koleskinova_2021b_dwca-lpk-v1.3.zip",
      filename = "event.txt"), encoding = "UTF-8")
   data.table::setDT(ddata)
   data.table::setDT(event)

   # excluding impacted sites ----
   event <- event[grepl("buffer", locationID)]

   # selecting occurrences with the event table and adding coordinates and sampleSizeValue to ddata ----
   event[, local := sub(pattern = "[0-9]{4}-", replacement = "", x = locationID)]
   ddata <- ddata[event[, .(eventID, local, year, month, day, decimalLatitude, decimalLongitude, sampleSizeValue)], on = "eventID"]

   # selecting data ----
   deleted_columns <- which(!colnames(ddata) %in% c("taxonRank", "scientificName", "local", "individualCount", "year", "month", "day","decimalLatitude", "decimalLongitude","sampleSizeValue"))
   ddata[, (deleted_columns) := NULL]
   ddata <- ddata[individualCount != 0L]

   # saving ----
   dir.create("data/raw data/koleskinova_2021b/", showWarnings = FALSE)
   saveRDS(ddata, "data/raw data/koleskinova_2021b/rdata.rds")
}
