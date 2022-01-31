# sperandii_2020

if (!file.exists("./data/raw data/sperandii_2020/rdata.rds")) {
  ddata <- readxl::read_xlsx(rdryad::dryad_download(dois = "10.5061/dryad.np5hqbzr8")[[1]],
    range = "A6:HH674"
  )
  data.table::setDT(ddata)

  dir.create("./data/raw data/sperandii_2020")
  base::saveRDS(ddata, "./data/raw data/sperandii_2020/rdata.rds")
}
