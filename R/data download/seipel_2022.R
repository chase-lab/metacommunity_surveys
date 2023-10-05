# seipel_2022
if (!file.exists('data/raw data/seipel_2022/rdata.rds')) {
   if (!file.exists("./data/cache/seipel_2022_MIRENplant_records_data_2007-2019.lat.long_v2_2212.csv"))
      curl::curl_download(
         url = "https://zenodo.org/record/7495407/files/MIRENplant_records_data_2007-2019.lat.long_v2_2212.csv?download=1",
         destfile = "./data/cache/seipel_2022_MIRENplant_records_data_2007-2019.lat.long_v2_2212.csv")

   base::dir.create(path = 'data/raw data/seipel_2022/', showWarnings = FALSE)
   base::saveRDS(
      object = data.table::fread(
         file = "./data/cache/seipel_2022_MIRENplant_records_data_2007-2019.lat.long_v2_2212.csv",
         sep = ",", header = TRUE, encoding = "UTF-8", drop = c('Elevation','Status','Cover')),
      file = 'data/raw data/seipel_2022/rdata.rds'
   )
}
