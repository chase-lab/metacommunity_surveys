# magalhaes_2020

if (!file.exists("./data/raw data/magalhaes_2020/rdata.rds")) {
  # downloading
  if (!file.exists("./data/cache/magalhaes_2020 10750_2020_4307_MOESM1_ESM.pdf")) {
    curl::curl_download(
      url = "https://static-content.springer.com/esm/art%3A10.1007%2Fs10750-020-04307-w/MediaObjects/10750_2020_4307_MOESM1_ESM.pdf",
      destfile = "./data/cache/magalhaes_2020 10750_2020_4307_MOESM1_ESM.pdf",
      mode = "wb"
    )
  }

  # extracting from pdf and saving the extraction
  if (!file.exists("./data/raw data/magalhaes_2020/magalhaes_2020 10750_2020_4307_MOESM1_ESM-1.csv")) {
    dir.create("./data/raw data/magalhaes_2020/", showWarnings = FALSE)
    tabulizer::extract_tables(file = "./data/cache/magalhaes_2020 10750_2020_4307_MOESM1_ESM.pdf", pages = 2:3, method = "stream", output = "csv", outdir = "./data/raw data/magalhaes_2020/")
  }

  # standardising and merging both pages
  rdata <- lapply(
    list.files(path = "./data/raw data/magalhaes_2020/", pattern = "csv", full.names = TRUE),
    data.table::fread
  )
  rdata[[1]][V1 == "", V1 := V2][, V2 := NULL]
  sites <- rdata[[1]][1][, -1]
  rdata[[1]] <- rdata[[1]][-(1:4)]
  rdata[[1]][, paste(sites[, 1], c("2000s", "2010s"), sep = "_") := data.table::tstrsplit(V3, " ")][, paste(sites[, 2], c("2000s", "2010s"), sep = "_") := data.table::tstrsplit(V4, " ")][, paste(sites[, 3], c("2000s", "2010s"), sep = "_") := data.table::tstrsplit(V5, " ")][, paste(sites[, 4], c("2000s", "2010s"), sep = "_") := data.table::tstrsplit(V6, " ")][, paste(sites[, 5], c("2000s", "2010s"), sep = "_") := data.table::tstrsplit(V7, " ")]
  rdata[[1]][, paste0("V", 3:7) := NULL]

  rdata <- data.table::rbindlist(l = rdata, use.names = FALSE)

  base::saveRDS(object = rdata, file = "./data/raw data/magalhaes_2020/rdata.rds")
}
