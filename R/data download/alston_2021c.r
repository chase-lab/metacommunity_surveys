dataset_id <- "alston_2021c"

if (!file.exists("./data/raw data/alston_2021c/rdata.rds")) {
   # loading data
   ddata <- data.table::fread(file = rdryad::dryad_download("10.5061/dryad.1g1jwstxw")[[1L]][11L], # UNDERSTORY_LGQUAD_2008-2019.csv
                              drop = c("survey","Bare_ground","treatment"))
   ddata <- ddata[grepl("OPEN", plot)]

   # loading coordinates
   coords <- data.table::fread(file = rdryad::dryad_download("10.5061/dryad.1g1jwstxw")[[1L]][4L],
                               drop = 3L:4L)
   # merging data and coords
   data.table::setnames(coords, c("dd_lat","dd_long"), c("latitude","longitude"))
   ddata[, site := c("NORTH","CENTRAL","SOUTH")[match(site, c("N","C","S"))]]
   coords <- coords[, .(longitude = mean(longitude), latitude = mean(latitude)), by = .(site, block)]
   ddata <- ddata[coords, on = c("site", "block")]

   dir.create("./data/raw data/alston_2021c", showWarnings = FALSE)
   saveRDS(ddata, "./data/raw data/alston_2021c/rdata.rds")
}
