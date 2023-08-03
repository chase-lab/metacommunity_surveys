# rennie_2017_bats

if (!file.exists("data/raw data/rennie_2017_bats/rdata.rds")) {
   # community data
   # Downloaded by hand behind this link: https://doi.org/10.5285/2588ee91-6cbd-4888-86fc-81858d1bf085
   rdata <-  data.table::fread(
      file = "data/cache/rennie_2017_bats_ECN_BA1.csv",
      sep = ",", header = TRUE, stringsAsFactors = TRUE,
      drop = c('BATLOC_ID','ACTS','ACTH','ACTF'))

   # saving
   base::dir.create("data/raw data/rennie_2017_bats", showWarnings = FALSE)
   base::saveRDS(
      object = unique(rdata),
      file = "data/raw data/rennie_2017_bats/rdata.rds"
   )
}
