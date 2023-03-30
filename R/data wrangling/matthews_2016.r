# matthews_2016


dataset_id <- "matthews_2016"

ddata <- data.table::fread(
  file = paste0("data/raw data/", dataset_id, "/rdata.csv"),
  header = TRUE, skip = 1L
)
data.table::setnames(ddata, c("Year", "Station"), c("year", "local"))

ddata <- data.table::melt(ddata,
  id.vars = c("Season", "year", "local"),
  value.name = "value",
  variable.name = "species"
)

ddata <- ddata[Season == "sum" & value > 0] # summer only

ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Piney Creek",

  metric = "abundance",
  unit = "count",

  Season = NULL
)]

# coordinates
coords <- rgdal::readOGR("./data/GIS data/matthews_2016_site_coordinates.kml", pointDropZ = TRUE, verbose = FALSE)
coords <- data.frame(local = coords$Name, sp::coordinates(coords))

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(

  realm = "Freshwater",
  taxon = "Fish",

  latitude = coords$coords.x2[match(local, coords$local)],
  longitude = coords$coords.x1[match(local, coords$local)],

  effort = 1L,
  study_type = "ecological_sampling",

  data_pooled_by_authors = FALSE,

  alpha_grain = 2500L,
  alpha_grain_unit = "m2",
  alpha_grain_type = "sample",
  alpha_grain_comment = "each sampling site is a reach 200 to 300m long and 5 to 30m wide",

  gamma_sum_grains = 2500L * 12L,
  gamma_sum_grains_unit = "km2",
  gamma_sum_grains_type = "sample",
  gamma_sum_grains_comment = "sum of the area of the 12 sampled creek stretches",

  gamma_bounding_box = geosphere::areaPolygon(coords[grDevices::chull(coords$coords.x1, coords$coords.x2), c("coords.x1", "coords.x2")]) / 1000000,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "convex-hull",
  gamma_bounding_box_comment = "Coordinates are approximate locations estimated from map",

  comment = "Extracted from Matthews & Marsh-Matthews supplementary material (https://doi.org/10.1890/14-2179.1)(DataS1 excel table. Piney Ck 12-site data). Authors sampled fish in streams belonging to the Piney Creek watershed. effort, location and methodology were comparable throughout the period. Coordinates are approximate locations estimated from map. More accurate coordinates can be extracted from appendix S2. The average sampled area is considered to be 250m long and 10 meter wide.",
  comment_standardisation = "Only Summer samples were included"
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)

data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
