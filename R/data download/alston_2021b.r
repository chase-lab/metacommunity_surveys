dataset_id <- "alston_2021b"

if (!file.exists("./data/raw data/alston_2021b/rdata.rds")) {
   # loading data
   ddata <- data.table::fread(file = rdryad::dryad_download("10.5061/dryad.1g1jwstxw")[[1L]][7L], # SMALL_MAMMALS_2009-2019.csv
                              drop = c("condition","age","sex","left_hind_foot_mm","left_tag","original_tag","marks","weight_g","notes"))
   ddata <- ddata[treatment == "OPEN"][, treatment := NULL]

   # loading coordinates
   coords <- data.table::fread(file = rdryad::dryad_download("10.5061/dryad.1g1jwstxw")[[1L]][4L],
                               drop = 3L:4L)
   # merging data and coords
   data.table::setnames(coords, c("dd_lat","dd_long"), c("latitude","longitude"))
   ddata[, site := c("NORTH","CENTRAL","SOUTH")[match(site, c("N","C","S"))]]
   coords <- coords[, .(longitude = mean(longitude), latitude = mean(latitude)), by = .(site, block)]
   ddata <- ddata[coords, on = c("site", "block")]


   # extracting species names from metadata
   taxo <- tabulizer::extract_tables(
      file = rdryad::dryad_download("10.5061/dryad.1g1jwstxw")[[1L]][6L],
      pages = 16L)[[1]]
   taxo <- data.table::data.table(taxo[4L:29L, 3L])
   taxo[, c("short","long","V1") := data.table::tstrsplit(V1, " = ")]
   taxo <- taxo[!is.na(V1) | short == "Unkn"][, V1 := NULL]
   ddata[, species := taxo$long[match(species, taxo$short)]]

   dir.create("./data/raw data/alston_2021b", showWarnings = FALSE)
   base::saveRDS(ddata, "./data/raw data/alston_2021b/rdata.rds")
}
