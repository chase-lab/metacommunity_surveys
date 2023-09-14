# edgar_2022_cryptic

## Data were downloaded by hand from the online repository
if (!file.exists("data/raw data/edgar_2022_cryptic/rdata.rds")) {
   base::dir.create(path = "data/raw data/edgar_2022_cryptic", showWarnings = FALSE)
   base::saveRDS(
      object = data.table::fread(
         file = "data/cache/edgar_2022_cryptic/edgar_2022_cryptic_IMOS_-_National_Reef_Monitoring_Network_Sub-Facility_-_Global_cryptobenthic_fish_abundance.csv",
         skip = 69, header = TRUE, sep = ",",
         stringsAsFactors = TRUE,
         select = c("country","area","ecoregion","location","site_code","block","latitude","longitude","survey_date","program","species_name","total")
      ),
      file = "data/raw data/edgar_2022_cryptic/rdata.rds"
   )
}
