# bowman_2021
if (!file.exists('data/raw data/bowman_2021/rdata.rds')) {
   if (!file.exists('data/cache/bowman_2021_species_composition.csv')) {
      download.file(url = 'https://portal.edirepository.org/nis/dataviewer?packageid=knb-lter-nwt.202.2&entityid=3ebfe6838cc9717c95906036de9efc59',
                    destfile = 'data/cache/bowman_2021_species_composition.csv'
      )}

   rdata <- data.table::fread(
      file = 'data/cache/bowman_2021_species_composition.csv',
      stringsAsFactors = TRUE
   )

   if (!file.exists('data/cache/bowman_2021_taxon_codes.csv')) {
      download.file(url = 'https://portal.edirepository.org/nis/dataviewer?packageid=knb-lter-nwt.202.2&entityid=d5d6f61323e53d8b2879d04bad5e0ed1',
                    destfile = 'data/cache/bowman_2021_taxon_codes.csv'
      )}

   codes <- data.table::fread(
      file = 'data/cache/bowman_2021_taxon_codes.csv',
      stringsAsFactors = TRUE
   )

   rdata <- rdata[codes, on = 'TAXONID']

   dir.create(path = 'data/raw data/bowman_2021/', showWarnings = FALSE)
   base::saveRDS(object = rdata, file = 'data/raw data/bowman_2021/rdata.rds')
}


