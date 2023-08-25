# bashevkin_2022
if (!file.exists('data/raw data/bashevkin_2022/rdata.rds')) {
   if (!file.exists('data/cache/bashevkin_2022_zooplankton_community.csv')) {
      download.file(url = 'https://portal.edirepository.org/nis/dataviewer?packageid=edi.539.4&entityid=58dd1dde8e38614a9cc48794f527bdec',
                    destfile = 'data/cache/bashevkin_2022_zooplankton_community.csv'
      )}

   dir.create(path = 'data/raw data/bashevkin_2022/', showWarnings = FALSE)
   base::saveRDS(object = data.table::fread(
      file = 'data/cache/bashevkin_2022_zooplankton_community.csv',
      select = c('Source','Station','Latitude','Longitude','Year','Date','SampleID',
                 'Volume','Taxname','SizeClass','CPUE','Undersampled'),
      stringsAsFactors = TRUE, sep = ',', header = TRUE, na.strings = "", dec = "."
   )[CPUE > 0],
   file = 'data/raw data/bashevkin_2022/rdata.rds')
}
