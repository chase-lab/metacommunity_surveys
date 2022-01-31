## santana_2017
dataset_id <- "santana_2017"

if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
  ddata <- data.table::fread(
    file = rdryad::dryad_download("10.5061/dryad.kp3fv")[[1]][2],
    header = TRUE, sep = ","
  )

  base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
}
