# edgar_2022_fish

## Data were downloaded by hand from the online repository
if (!file.exists("data/raw data/egar_2022_fish/rdata.rds")) {
   base::dir.create(path = "data/raw data/egar_2022_fish", showWarnings = FALSE)
   base::saveRDS(
      object = data.table::fread(
         file = "data/cache/edgar_2022_fish/IMOS_-_National_Reef_Monitoring_Network_Sub-Facility_-_Global_reef_fish_abundance_and_biomass.csv",
         skip = 69, header = TRUE, sep = ",",
         stringsAsFactors = TRUE,
         select = c("class","location","survey_date","site_code","latitude","longitude","method","species_name","total")
      )
      ,
      file = "data/raw data/egar_2022_fish/rdata.rds"
   )
}
