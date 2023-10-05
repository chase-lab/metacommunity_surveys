if (!file.exists('data/raw data/jacinto_2022/rdata.rds')) {
   if (!file.exists('data/cache/jacinto_2022_Fish_Query_Clean_R_031120_CSV copy.csv'))
      curl::curl_download(
         url = 'https://zenodo.org/record/7822308/files/Fish_Query_Clean_R_031120_CSV%20copy.csv?download=1',
         destfile = 'data/cache/jacinto_2022_Fish_Query_Clean_R_031120_CSV copy.csv'
      )

   base::dir.create(path = 'data/raw data/jacinto_2022', showWarnings = FALSE)
   base::saveRDS(
      object = data.table::fread(
         file = 'data/cache/jacinto_2022_Fish_Query_Clean_R_031120_CSV copy.csv',
         stringsAsFactors = FALSE, drop = c("FishID","Status","Length","TripID","V9","V10")),
      file = 'data/raw data/jacinto_2022/rdata.rds'
   )
}
