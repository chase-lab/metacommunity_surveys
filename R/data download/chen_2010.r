## chen_2010
dataset_id <- "chen_2010"

if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
  # download of the supplementary material of roman-palacios and Wiens 2020, see
  # Dryad http://datadryad.org/stash/dataset/doi:10.5061/dryad.4tmpg4f5w
  # Community
  ddata <- readxl::read_xlsx(path = rdryad::dryad_download("10.5061/dryad.4tmpg4f5w")[[1]][1], sheet = 2)
  data.table::setDT(ddata)
  ddata <- ddata[Study == "Chen et al. (2011)"]

  base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))

  # GIS
  coords <- readxl::read_xlsx(path = rdryad::dryad_download("10.5061/dryad.4tmpg4f5w")[[1]][8], sheet = 2)
  data.table::setDT(coords)
  coords <- coords[Study == "Chen et al. (2011)"]

  base::saveRDS(coords, file = paste("data/raw data", dataset_id, "coords.rds", sep = "/"))
}
