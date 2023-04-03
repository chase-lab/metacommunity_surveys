# kolasa_2022
## Manual download here: https://borealisdata.ca/dataset.xhtml?persistentId=doi:10.5683/SP3/FNAU9L
if (!file.exists('data/raw data/kolasa_2022/rdata.rds')) {
   if (!file.exists('data/cache/kolasa_2022_rockpools_survey_data.csv'))
      base::message("Data for kolasa_2022 has to be manually downloaded here: https://borealisdata.ca/dataset.xhtml?persistentId=doi:10.5683/SP3/FNAU9L")

   rdata <- data.table::fread(file = 'data/cache/kolasa_2022_rockpools_survey_data.csv',
                              header = TRUE, sep = ',', stringsAsFactors = TRUE,
                              select = c('year','month','pool_id','latin_name','otu_id','otu_absolute_abundance'))
   rdata <- unique(rdata[!is.na(otu_absolute_abundance) & otu_absolute_abundance != 0L])

   base::dir.create(path = 'data/raw data/kolasa_2022/', showWarnings = FALSE)
   base::saveRDS(
      object = rdata,
      file = 'data/raw data/kolasa_2022/rdata.rds')
}
