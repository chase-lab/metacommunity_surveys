# muschet_2018
dataset_id <- "muschet_2018"

if (!base::file.exists("data/raw data/muschet_2018/rdata.rds")) {
   # Downloading amphibian counts ----

   if (!base::file.exists("data/cache/muschet_2018/muschet_2018-CLSAamphibiansCounts_v2.csv")) {
      base::dir.create(path = "data/cache/muschet_2018/", showWarnings = FALSE)
      curl::curl_download(
         url = "https://www.sciencebase.gov/catalog/file/get/624c7543d34e21f82764df13?name=CLSA_Amphibians1992_2021.csv",
         destfile = "data/cache/muschet_2018/muschet_2018-CLSAamphibiansCounts_v2.csv"
      )
   }

   ## Adding coordinates ----
   rdata <- data.table::fread(
      file = "data/cache/muschet_2018/muschet_2018-CLSAamphibiansCounts_v2.csv",
      sep = ",", header = TRUE, stringsAsFactors = TRUE)
   coords <- data.table::fread(file = "data/GIS data/muschet_2017_site_locations.csv",
                               skip = 1, header = TRUE, sep = ",")
   coords[, Plot_name := data.table::fifelse(
      test = nchar(Plot_name) == 2L,
      yes = paste0(substr(Plot_name, 1, 1), "0", substr(Plot_name, 2, 2)),
      no = Plot_name)]

   data.table::setnames(coords,
                        old = c("Latitude","Longitude"),
                        new = c("latitude", "longitude"))
   rdata[i = coords,
         j = ":="(latitude = i.latitude, longitude = i.longitude),
         on = c("WETLAND" = "Plot_name")]

   base::dir.create("data/raw data/muschet_2018/", showWarnings = FALSE)
   base::saveRDS(
      object = rdata,
      file = "data/raw data/muschet_2018/rdata.rds")
}
