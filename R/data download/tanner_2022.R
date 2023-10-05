if (!file.exists("data/cache/tanner_2022_coral_maps_exposed_crest.zip")) {
   curl::curl_download(
      url = "https://springernature.figshare.com/ndownloader/files/37459597",
      mode = "wb",
      destfile = "data/cache/tanner_2022_coral_maps_exposed_crest.zip"
   )
}

NCNE <- readxl::read_xlsx(path = "data/cache/tanner_2022_coral_maps_exposed_crest/Compiled Data/NCNE.xlsx",
                          range = "Summary!A2:C2088")
NCNW <- readxl::read_xlsx(path = "data/cache/tanner_2022_coral_maps_exposed_crest/Compiled Data/NCNW.xlsx",
                          range = "Summary!A1:C2428")
NCSE <- readxl::read_xlsx(path = "data/cache/tanner_2022_coral_maps_exposed_crest/Compiled Data/NCSE.xlsx",
                          range = "Summary!A2:C1746")
NCSW <- readxl::read_xlsx(path = "data/cache/tanner_2022_coral_maps_exposed_crest/Compiled Data/NCSW.xlsx",
                          range = "Summary!A1:C2120")
NCNR <- readxl::read_xlsx(path = "data/cache/tanner_2022_coral_maps_exposed_crest/Compiled Data/NCNR.xlsx",
                          range = "Summary!A1:C380")
species_names <- readxl::read_xlsx(path = "data/cache/tanner_2022_coral_maps_exposed_crest/Compiled Data/NCNR.xlsx",
                                   range = "Species!A5:F82", col_names = FALSE)
data.table::setDT(species_names)
species_names <- rbind(species_names[, 1:2], species_names[, 3:4], species_names[, 5:6], use.names = FALSE)

rdata <- data.table::rbindlist(
   l = list(NCNE = NCNE, NCNW = NCNW, NCSE = NCSE, NCSW = NCSW, NCNR = NCNR),
   use.names = TRUE, idcol = TRUE
)

rdata[, SPECIES := as.character(SPECIES)][SPECIES %in% species_names$...1, SPECIES := species_names$...2[match(SPECIES, species_names$...1)]]
rdata[, COLONY_ID := NULL]

rdata <- unique(rdata)

dir.create(path = "data/raw data/tanner_2022/", showWarnings = FALSE)
base::saveRDS(
   object = rdata,
   file = "data/raw data/tanner_2022/rdata.rds"
)
