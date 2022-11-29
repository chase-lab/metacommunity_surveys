# rogalski_2017
dataset_id <- "rogalski_2017"

if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
   ddata <- readxl::read_xlsx(
      rdryad::dryad_download("10.5061/dryad.2vh5c")[[1]],
      sheet = 1L
   )
   data.table::setDT(ddata)

   ddata[, c(2:3, 5:15) := NULL]

   dir.create(paste0("./data/raw data/", dataset_id), showWarnings = FALSE)
   base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
}
