# verdu_2022
if (!file.exists('data/raw data/verdu_2022/rdata.rds')) {
   if (!file.exists('data/cache/verdu_2022-ecy3923-sup-0001-datas1.zip')) {
      download.file(url = 'https://esajournals.onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1002%2Fecy.3923&file=ecy3923-sup-0001-DataS1.zip',
                    destfile = 'data/cache/verdu_2022-ecy3923-sup-0001-datas1.zip',
                    mode = 'wb')

      utils::unzip(zipfile = 'data/cache/verdu_2022-ecy3923-sup-0001-datas1.zip',
                   exdir = 'data/cache/verdu_2022/')
   }

   base::dir.create('data/raw data/verdu_2022', showWarnings = FALSE)

   base::saveRDS(
      object = data.table::fread(file = 'data/cache/verdu_2022/Data_S1/RecruitNet.csv',
                                 sep = ',', header = TRUE, stringsAsFactors = TRUE,
                                 encoding = 'UTF-8', select = c('Study_site','Location','Country',
                                                                'Latitude','Longitude','PlotdimX',
                                                                'PlotdimY','Sampling_date','Plot',
                                                                'Standardized_Canopy','Standardized_Recruit',
                                                                'Frequency','Sampling_method')),
      file = 'data/raw data/verdu_2022/rdata.rds'
   )
}
