# larkin_2015

if (!file.exists("./data/raw data/larkin_2015/ddata.rds")) {
  dir.create("./data/raw data/larkin_2015/", showWarnings = FALSE)

  base::saveRDS(
    object = data.table::fread(rdryad::dryad_download("10.5061/dryad.763v6")[[1L]][1L],
      header = TRUE
    ),
    file = "./data/raw data/larkin_2015/ddata.rds"
  )
  base::saveRDS(
    object = data.table::fread(rdryad::dryad_download("10.5061/dryad.763v6")[[1L]][4L],
      header = TRUE
    ),
    file = "./data/raw data/larkin_2015/taxonomy.rds"
  )
}
