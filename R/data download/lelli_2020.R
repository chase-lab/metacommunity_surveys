# lelli_2020
dataset_id <- "lelli_2020"
if (!file.exists("./data/raw data/lelli_2020/rdata.rda")) {

  # coordinates
  if (!file.exists("./data/cache/lelli_2020_appendixS1.pdf")) {
    download.file(
      url = "https://onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1111%2Fjvs.12939&file=jvs12939-sup-0001-AppendixS1.pdf",
      destfile = "./data/cache/lelli_2020_appendixS1.pdf", method = "auto", mode = "wb"
    )
  }
  if (!file.exists("./data/cache/lelli_2020_appendixS1.pdf")) {
    download.file(
      url = "https://onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1111%2Fjvs.12939&file=jvs12939-sup-0001-AppendixS1.pdf",
      destfile = "./data/cache/lelli_2020_appendixS1.pdf", method = "curl", mode = "wb"
    )
  }

  # historical sampling ----
  if (!file.exists("./data/cache/lelli_2020_appendixS6.pdf")) {
    download.file(
      url = "https://onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1111%2Fjvs.12939&file=jvs12939-sup-0006-AppendixS6.pdf",
      destfile = "./data/cache/lelli_2020_appendixS6.pdf", method = "auto", mode = "wb"
    )
  }
  if (!file.exists("./data/cache/lelli_2020_appendixS6.pdf")) {
    download.file(
      url = "https://onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1111%2Fjvs.12939&file=jvs12939-sup-0006-AppendixS6.pdf",
      destfile = "./data/cache/lelli_2020_appendixS6.pdf", method = "curl", mode = "wb"
    )
  }

  # resurvey ----
  if (!file.exists("./data/cache/lelli_2020_appendixS7.pdf")) {
    download.file(
      url = "https://onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1111%2Fjvs.12939&file=jvs12939-sup-0007-AppendixS7.pdf",
      destfile = "./data/cache/lelli_2020_appendixS7.pdf", method = "auto", mode = "wb"
    )
  }

  if (!file.exists("./data/cache/lelli_2020_appendixS7.pdf")) {
    download.file(
      url = "https://onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1111%2Fjvs.12939&file=jvs12939-sup-0007-AppendixS7.pdf",
      destfile = "./data/cache/lelli_2020_appendixS7.pdf", method = "curl", mode = "wb"
    )
  }


  # pdf data extraction ----
  coordinates <- data.table::rbindlist(
    lapply(
      tabulizer::extract_tables(file = "./data/cache/lelli_2020_appendixS1.pdf", pages = 2L:3L),
      as.data.frame
    )
  )


  historical <- data.table::rbindlist(
    lapply(
      tabulizer::extract_tables(file = "./data/cache/lelli_2020_appendixS6.pdf", pages = 1:8),
      as.data.frame
    )
  )

  resurvey1 <- data.table::rbindlist(
    lapply(
      tabulizer::extract_tables(
        file = "./data/cache/lelli_2020_appendixS7.pdf",
        pages = 1:8, method = "lattice"
      ),
      as.data.frame
    )
  )

  resurvey2 <- data.table::rbindlist(
    lapply(tabulizer::extract_tables(file = "./data/cache/lelli_2020_appendixS7.pdf", pages = 9:13, method = "stream"), as.data.frame),
    fill = TRUE
  )


  save(coordinates, historical, resurvey1, resurvey2, file = "./data/raw data/lelli_2020/rdata.rda")
}

load("./data/raw data/lelli_2020/rdata.rda")

coordinates <- coordinates[-c(1L, 2L)]
coordinates[52L, c("V1", "V3", "V4") := list("18A", "11.898816", "44.0713170")]
coordinates[, local := gsub("[ABC]", "", V1)]
saveRDS(
  object = coordinates[, .(latitude = mean(as.numeric(V4)), longitude = mean(as.numeric(V3))), by = local],
  file = "./data/raw data/lelli_2020/coordinates.rds"
)



data.table::setnames(historical, c("species", unlist(historical[1L, -1L])))
historical <- historical[-1L]


data.table::setnames(resurvey1, c("species", unlist(resurvey1[1L, -1L])))
resurvey1 <- resurvey1[-1L]
resurvey1[species == "Centaurea", species := "Centaurea nigrescens subsp. pinnatifida"]
resurvey1[species == "Drymochloa", ":="(species = "Drymochloa sylvatica", `2A` = "1", `2B` = "1")]
resurvey1[species == "Lonicera", species := "Lonicera xylosteum"]
resurvey1[, species := gsub("\r", " ", species, fixed = TRUE)]
resurvey1 <- rbind(
  resurvey1,
  data.table::data.table(species = "Asperula taurina L. subsp. taurina", `12A` = "+"),
  data.table::data.table(species = "Geum urbanum", `1A` = "r", `9C` = "+", `12C` = "r"),
  data.table::data.table(species = "Populus tremula"),
  fill = TRUE
)


resurvey2 <- data.table::fread(
  file = "./data/raw data/lelli_2020/manual_correction_lelli_appendix7_survey2.csv",
  sep = ",",
  select = 1L:30,
  header = TRUE
)

resurvey <- cbind(resurvey1, resurvey2)

data.table::fwrite(historical, file = paste0("./data/raw data/", dataset_id, "/historical.csv"), sep = ",")
data.table::fwrite(resurvey, file = paste0("./data/raw data/", dataset_id, "/resurvey.csv"), sep = ",")
