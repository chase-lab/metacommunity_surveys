# muschet_2017
dataset_id <- "muschet_2017"

if (!base::file.exists("data/raw data/muschet_2017/rdata.rds")) {

   # Downloading insect counts from https://www.sciencebase.gov/catalog/item/624c779ad34e21f82764df2e ----
   if (!base::file.exists("data/cache/muschet_2017_invertebrates_v2/CLSAInvertebrateCounts1992_2021.csv")) {
      base::dir.create(path = "data/cache/muschet_2017_invertebrates_v2/", showWarnings = FALSE)
      curl::curl_download(
         url = "https://www.sciencebase.gov/catalog/file/get/624c779ad34e21f82764df2e?name=CLSAInvertebrateCounts1992_2021.csv",
         destfile = "data/cache/muschet_2017_invertebrates_v2/CLSAInvertebrateCounts1992_2021.csv"
      )
   }

   if (!base::file.exists("data/cache/muschet_2017_invertebrates_v2/CLSAInvertebrateCounts1992_2021.xml")) {
      base::dir.create(path = "data/cache/muschet_2017_invertebrates_v2/", showWarnings = FALSE)
      curl::curl_download(
         url = "https://www.sciencebase.gov/catalog/file/get/624c779ad34e21f82764df2e?name=CLSAInvertebrateCounts1992_2021.xml",
         destfile = "data/cache/muschet_2017_invertebrates_v2/CLSAInvertebrateCounts1992_2021.xml"
      )
   }

   # Extracting taxonomy from metadata ----
   if (!base::file.exists("data/cache/muschet_2017_invertebrates_v2/CLSAInvertebrateCounts_metadata_taxonomy.csv")) {
      tax <- XML::xmlToList("data/cache/muschet_2017_invertebrates_v2/CLSAInvertebrateCounts1992_2021.xml")

      codes <- unlist(sapply(tax$eainfo[[1]], function(element) element$attrlabl))
      lnames <- unlist(sapply(tax$eainfo[[1]], function(element) element$attrdef))
      lnames <- stringi::stri_extract_first_regex(str = lnames, pattern = "(?<=identified as? ).*(?= present)")

      write.table(
         x = na.omit(data.frame(codes = codes, long_names = lnames)),
         sep = ",", row.names = FALSE,
         file = "data/cache/muschet_2017_invertebrates_v2/CLSAInvertebrateCounts_metadata_taxonomy.csv"
      )
   }

   ## Adding coordinates ----
   rdata <- data.table::fread(
      file = "data/cache/muschet_2017_invertebrates_v2/CLSAInvertebrateCounts1992_2021.csv",
      header = TRUE, sep = ",", stringsAsFactors = TRUE)
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

   # Saving ----
   base::dir.create("data/raw data/muschet_2017/", showWarnings = FALSE)
   base::saveRDS(
      object = rdata,
      file = "data/raw data/muschet_2017/rdata.rds")

   base::saveRDS(
      object = data.table::fread(
         file = "data/cache/muschet_2017_invertebrates_v2/CLSAInvertebrateCounts_metadata_taxonomy.csv",
         sep = ",", header = TRUE),
      file = "data/raw data/muschet_2017/taxonomy.rds"
   )
}
