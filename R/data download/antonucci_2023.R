dataset_id <- 'antonucci_2023'
# Data downloaded by hand from https://github.com/josieantonucci/TemporalChange_PPKT_WaddenSea/blob/befbf4575dc63afdca069367b96d57be0d782779/Data/PPKT_count_WaddenSea_1999_2018.csv

base::dir.create('data/raw data/antonucci_2023/', showWarnings = FALSE)
base::saveRDS(
   object = unique(
      data.table::fread(file = 'data/cache/antonucci_2023_PPKT_count_WaddenSea_1999_2018.csv',
                        sep = ';', dec = ',', stringsAsFactors = TRUE, header = TRUE,
                        select = c('Country','StationID','Date','Year','Genus','Species','Functional_group','abundance_l'))),
   file = 'data/raw data/antonucci_2023/rdata.rds'
)
