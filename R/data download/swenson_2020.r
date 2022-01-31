## swenson_2020
dataset_id <- "swenson_2020"

if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
  paths <- rdryad::dryad_download("10.5061/dryad.h44j0zpg3")
  ldat <- lapply(paths[[1]][1:3], data.table::fread, header = TRUE)
  lapply(ldat, function(tab) data.table::setnames(tab, new = c("local", colnames(tab)[-ncol(tab)])))

  ddata <- data.table::rbindlist(ldat,
    idcol = "period",
    fill = TRUE,
    use.names = TRUE
  )

  dir.create(path = paste0("./data/raw data/", dataset_id), showWarnings = FALSE)
  base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
}
