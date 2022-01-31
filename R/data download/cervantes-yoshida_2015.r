## cervantes-yoshida_2015
dataset_id <- "cervantes-yoshida_2015"

if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
  ddata <- readxl::read_xlsx(path = rdryad::dryad_download("10.5061/dryad.54hr0")[[1]][1], sheet = 1L)
  data.table::setDT(ddata)

  base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
}
