## gibb_2019
dataset_id <- "gibb_2019"

if (!file.exists(paste0("./data/raw data/", dataset_id, "/ddata.rds"))) {
  ddata <- readxl::read_xlsx(rdryad::dryad_download("10.5061/dryad.vc80r13")[[1]], sheet = 2)
  env <- readxl::read_xlsx(rdryad::dryad_download("10.5061/dryad.vc80r13")[[1]], sheet = 1)[, 1:9]
  data.table::setDT(ddata)
  data.table::setDT(env)

  dir.create(paste0("./data/raw data/", dataset_id), showWarnings = FALSE)
  base::saveRDS(ddata, file = paste0("./data/raw data/", dataset_id, "/ddata.rds"))
  base::saveRDS(env, file = paste0("./data/raw data/", dataset_id, "/env.rds"))
}
