# meier_2021 ----

if (!file.exists("./data/raw data/meier_2021/rdata.rds")) {
   # downloading data ----
   if (!file.exists("./data/cache/meier_2021.pdf")) {
      download.file(
         url = "https://www.tuexenia.de/publications/tuexenia/Tuexenia_2021_NS_041_0203-0226.pdf",
         method = "curl", destfile = "./data/cache/meier_2021.pdf", mode = "wb"
      )
   }

   # extracting abundances from pdf file ----
   table_areas <- list(c(top = 110, left = 39, bottom = 4230, right = 2966))
   rdata <- data.table::as.data.table(
      tabulizer::extract_tables(
         file = "./data/cache/meier_2021.pdf", pages = 28L,
         area = table_areas, guess = FALSE,
         output = "data.frame")
   )

   # cleaning data ----
   ## separating values in several columns where needed ----
   rdata <- rdata[-5L]
   rdata[, paste0("tmp", 1:2) := data.table::tstrsplit(X6.7, " +")]
   rdata[, paste0("tmp", 3:4) := data.table::tstrsplit(X60.61, " +")]
   rdata[, paste0("tmp", 5:6) := data.table::tstrsplit(X80.81, " +")]
   rdata[, c("X.2","X6.7","X60.61","X80.81") := NULL]

   # melting ----
   ## transposing ----
   rdata <- data.table::transpose(rdata, make.names = "Sequential.number")

   ## melting species ----
   rdata[rdata == "."] <- NA_character_
   rdata <- data.table::melt(
      data = rdata,
      id.vars = c("Relevé number","Year","Plot size [m2]"),
      measure.vars = grep("^[A-Z]", colnames(rdata)[15L:289L], value = TRUE),
      variable.name = "species",
      na.rm = TRUE
   )
   rdata[, Relevé.number := gsub("[ab]", "", `Relevé number`)]

   # extracting coordinates from pdf file ----
   coords <- data.table::as.data.table(
      tabulizer::extract_tables(file = "./data/cache/meier_2021.pdf", pages = 29L, output = "data.frame")
   )
   coords <- rbind(coords[, 1L:2L], coords[, 3L:4L], use.names = FALSE)

   # merging community data and coordinates ----
   rdata[, coordinates := coords$Coordinates[match(Relevé.number, coords$Relevé.number)]]

   # saving ----
   base::dir.create("./data/raw data/meier_2021", showWarnings = FALSE)
   base::saveRDS(rdata, "./data/raw data/meier_2021/rdata.rds")
}
