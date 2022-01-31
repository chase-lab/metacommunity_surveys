## muthukrishnan_2019
dataset_id <- "muthukrishnan_2019"

if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
  ddata <- read.csv(unz(description = rdryad::dryad_download("10.5061/dryad.15dv41nt2")[[1]][1], filename = "Lake_plant_diversity_data.csv"))
  data.table::setDT(ddata)

  base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
}
