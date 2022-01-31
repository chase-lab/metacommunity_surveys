# valtonen_2018
dataset_id <- "valtonen_2018"

if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
  ddata <- readxl::read_xlsx(rdryad::dryad_download("10.5061/dryad.9m6vp")[[1]], sheet = 1)
  data.table::setDT(ddata)

  dir.create(paste0("./data/raw data/", dataset_id), showWarnings = FALSE)
  base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
}
