# cumming_2023
if (!base::file.exists('data/raw data/cumming_2023/rdata.rds')) {
   if (!base::file.exists('data/cache/cumming_2023_AIMSfish_v1.xlsx')) {
      base::download.file(url = 'https://zenodo.org/record/7739234/files/AIMSfish_v2.xlsx?download=1',
                          destfile = 'data/cache/cumming_2023_AIMSfish_v1.xlsx')
   }

   rdata <- readxl::read_xlsx(path = 'data/cache/cumming_2023_AIMSfish_v1.xlsx')
   data.table::setDT(rdata)
   rdata[, c('gbifID','catalogNumber','acceptedNameUsageID','class','order','family',
             'genus','specificEpithet','taxonKey','familyKey','genusKey','speciesKey',
             'iucnRedListCategory') := NULL]

   base::dir.create(path = 'data/raw data/cumming_2023/', showWarnings = FALSE)
   base::saveRDS(object = rdata, file = 'data/raw data/cumming_2023/rdata.rds')
}
