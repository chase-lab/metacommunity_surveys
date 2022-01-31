# gomez-gras_2021

if (!file.exists("./data/raw data/gomez-gras_2021/ddata.rds")) {
  dir.create("./data/raw data/gomez-gras_2021/", showWarnings = FALSE)

  base::saveRDS(
    object = data.table::fread(
      file = rdryad::dryad_download(dois = "10.5061/dryad.69p8cz91g")[[1]][5],
      dec = ",", sep = ";"
    ),
    file = "./data/raw data/gomez-gras_2021/ddata.rds"
  )
}
