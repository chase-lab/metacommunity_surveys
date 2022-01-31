# gaget_2021
dataset_id <- "gaget_2021"

if (!file.exists(paste0("./data/raw data/", dataset_id, "/rdata.rds"))) {
  ddata <- readxl::read_xlsx(
    path = rdryad::dryad_download(dois = "10.5061/dryad.1rn8pk0rx")[[1]],
    sheet = 1
  )
  data.table::setDT(ddata)

  dir.create(paste0("./data/raw data/", dataset_id), showWarnings = FALSE)
  base::saveRDS(object = ddata, file = paste0("./data/raw data/", dataset_id, "/rdata.rds"))
}
