## werner_2014

dataset_id <- "werner_2014"

if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
  ddata <- readxl::read_xlsx(path = rdryad::dryad_download("10.5061/dryad.js47k")[[1]][2], sheet = 2L)
  data.table::setDT(ddata)

  base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
}
