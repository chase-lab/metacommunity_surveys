# arntzen_2017

if (!file.exists("./data/raw data/arntzen_2017/rdata.rds")) {
  tempfile_path <- "./data/cache/arntzen_2017_appendix2.xlsx"
  if (!file.exists(tempfile_path)) {
    download.file(
      url = "https://static-content.springer.com/esm/art%3A10.1007%2Fs10531-017-1307-y/MediaObjects/10531_2017_1307_MOESM2_ESM.xlsx",
      destfile = tempfile_path,
      mode = "wb", method = "auto"
    )
  }

  if (!file.exists(tempfile_path)) {
    download.file(
      url = "https://static-content.springer.com/esm/art%3A10.1007%2Fs10531-017-1307-y/MediaObjects/10531_2017_1307_MOESM2_ESM.xlsx",
      destfile = tempfile_path,
      mode = "wb", method = "curl"
    )
  }

  ddata <- data.table::rbindlist(
    list(
      `1975` = readxl::read_xlsx(tempfile_path, range = "B12:W221"),
      `1992` = readxl::read_xlsx(tempfile_path, range = "B225:W320"),
      `2012` = readxl::read_xlsx(tempfile_path, range = "B324:W513")
    ),
    use.names = FALSE,
    idcol = TRUE
  )

  dir.create("./data/raw data/arntzen_2017/", showWarnings = FALSE)
  base::saveRDS(ddata, file = "./data/raw data/arntzen_2017/rdata.rds")
}
