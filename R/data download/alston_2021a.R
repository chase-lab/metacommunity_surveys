dataset_id <- "alston_2021a"

if (!file.exists("./data/raw data/alston_2021a/rdata.rds")) {
   # loading data
   ddata <- data.table::fread(file = rdryad::dryad_download("10.5061/dryad.1g1jwstxw")[[1L]][8L],
                              drop = 9L:15L)
   # loading coordinates
   coords <- data.table::fread(file = rdryad::dryad_download("10.5061/dryad.1g1jwstxw")[[1L]][4L],
                               drop = 3L:4L)
   # merging data and coords
   data.table::setnames(coords, c("dd_lat","dd_long"), c("latitude","longitude"))
   ddata[, site := c("NORTH","CENTRAL","SOUTH")[match(site, c("N","C","S"))]]
   coords <- coords[, .(longitude = mean(longitude), latitude = mean(latitude)), by = .(site, block)]
   ddata <- unique(ddata[coords, on = c("site", "block")])

   dir.create("./data/raw data/alston_2021a", showWarnings = FALSE)
   saveRDS(ddata, "./data/raw data/alston_2021a/rdata.rds")
}
