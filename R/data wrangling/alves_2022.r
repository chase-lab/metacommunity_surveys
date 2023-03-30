dataset_id <- "alves_2022"

ddata <- base::readRDS(file = "./data/raw data/alves_2022/rdata.rds")
ddata <- ddata[ Cover != 0 ][, Cover := NULL]
ddata <- ddata[ !General.Type %in% c("Substrate","Dead","Equipment","Fish","Rubble","Sand.sediment","Unknown","Water","N.c","CTB")][, ":="(Specific.Type = NULL, General.Type = NULL)]
ddata <- unique(ddata)

data.table::setnames(ddata, c("year","local","transect","species"))

# Standardisation of effort ----
# For each site, exclude transects sampled only once, then randomly select one transect. data.table style join
set.seed(42)
ddata <- ddata[
   ddata[,
         .(n_surveys = length(unique(year))),
         by = .(local, transect)][n_surveys != 1L
         ][,
           .(transect = transect[sample(x = 1:.N, size = 1L)]),
           by = local],

   on = c("local", "transect")
]

# GIS Data ----
coords <- sf::st_read("./data/GIS data/alves_2022_site_coordinates.kml")
data.table::setDT(coords)
data.table::setnames(coords, "Name","local")
coords[, c("longitude", "latitude","z") := do.call(rbind.data.frame, geometry)]
coords[, c("geometry", "Description", "z") := NULL]


# community data ----
ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Belizean Barrier Reef",

   species = gsub(pattern = ".", replacement = " ", x = species, fixed = TRUE),
   value = 1L,
   metric = "pa",
   unit = "pa",
   transect = NULL
)]

# metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta <- coords[meta, on = "local"]
meta[, ":="(
   taxon = "Invertebrates",
   realm = "Marine",

   effort = 6L,

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,
   sampling_years = NA,

   alpha_grain = 25L * 2L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "plot",
   alpha_grain_comment = "area of a 25m*2m transect",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of the areas of all transects of all sites on a given year",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "sites located by hand on maps",

   comment = "Data were downloaded from https://github.com/calves06/Belizean_Barrier_Reef_Change associated to the article: Alves C, Valdivia A, Aronson RB, Bood N, Castillo KD, et al. (2022) Twenty years of change in benthic communities across the Belizean Barrier Reef. PLOS ONE 17(1): e0249155. https://doi.org/10.1371/journal.pone.0249155. Authors measured cover of the substrate by recording images along transects. Site coordinates were looked for on maps",
   comment_standardisation = "Items from the following types were excluded: Substrate, Dead, Equipment, Fish, Rubble, Sand.sediment, Unknown, Water, N.c, CTB. For each location, we excluded transects sampled only once, then randomly selected one transect per year."
)][, ":="(
   gamma_sum_grains = sum(alpha_grain),
   gamma_bounding_box = geosphere::areaPolygon(coords[grDevices::chull(coords$longitude, coords$latitude), c("longitude", "latitude")]) / 10^6),
   by = .(regional, year)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
   row.names = FALSE
)
