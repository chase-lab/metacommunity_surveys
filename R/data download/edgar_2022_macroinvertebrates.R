# edgar_2022_macroinvertebrates

## Data were downloaded by hand from the online repository
if (!file.exists("data/raw data/egar_2022_macroinvertebrates/rdata.rds")) {
   base::dir.create(path = "data/raw data/egar_2022_macroinvertebrates", showWarnings = FALSE)
   base::saveRDS(
      object = data.table::fread(
         file = "data/cache/edgar_2022_macroinvertebrates/IMOS_-_National_Reef_Monitoring_Network_Sub-Facility_-_Global_mobile_macroinvertebrate_abundance.csv",
         skip = 69, header = TRUE, sep = ",",
         stringsAsFactors = TRUE,
         select = c("country","area","ecoregion","location","site_code","block","latitude","longitude","survey_date","program","species_name","total")),
      file = "data/raw data/egar_2022_macroinvertebrates/rdata.rds"
   )
}
