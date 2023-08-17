# matthews_2016
dataset_id <- "matthews_2016"

ddata <- data.table::fread(
   file = paste0("data/raw data/", dataset_id, "/rdata.csv"),
   header = TRUE, skip = 1L
)

#Raw Data ----
data.table::setnames(ddata, c("Year", "Station"), c("year", "local"))

ddata <- data.table::melt(ddata,
                          id.vars = c("Season", "year", "local"),
                          value.name = "value",
                          variable.name = "species"
)
ddata <- ddata[value != 0L]

# Raw data ----
## community data ----

ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Piney Creek",

   month = c(4L, 7L, 1L)[data.table::chmatch(Season, c("apr","sum","win"))],

   metric = "abundance",
   unit = "count"
)]

# Coordinates ----
coords <- sf::st_read("data/GIS data/matthews_2016_site_coordinates.kml")
coords <- data.table::data.table(local = coords$Name, sf::st_coordinates(coords))

# Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, month)])
meta <- meta[coords[, .(local, latitude = Y, longitude = X)], on = 'local']

meta[, ":="(
   realm = "Freshwater",
   taxon = "Fish",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = 2500L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "sample",
   alpha_grain_comment = "each sampling site is a reach 200 to 300m long and 5 to 30m wide",

   comment = "Extracted from Matthews & Marsh-Matthews supplementary material (https://doi.org/10.1890/14-2179.1)(DataS1 excel table. Piney Ck 12-site data). Authors sampled fish in streams belonging to the Piney Creek watershed. effort, location and methodology were comparable throughout the period. Coordinates are approximate locations estimated from map. More accurate coordinates can be extracted from appendix S2. The average sampled area is considered to be 250m long and 10 meter wide.",
   comment_standardisation = "None needed",
   doi = 'https://doi.org/10.1890/14-2179.1'
)]

## save raw data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata[, !"Season"],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)

data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)

# Standardised Data ----
ddata <- ddata[Season == "sum"][, Season := NULL][, month := NULL] # summer only

## meta data ----
meta[, month := NULL]
meta <- unique(meta)
meta <- meta[unique(ddata[, .(local, year)]),
             on = .(local, year)]

meta[,":="(
   effort = 1L,

   gamma_sum_grains = 2500L * 12L,
   gamma_sum_grains_unit = "km2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of the area of the 12 sampled creek stretches",

   gamma_bounding_box = geosphere::areaPolygon(coords[grDevices::chull(coords$X, coords$Y), c("X", "Y")]) / 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "Coordinates are approximate locations estimated from map",

   comment_standardisation = "Only Summer samples were included"
)]

## save standardised data ----
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised.csv"),
   row.names = FALSE
)

data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised_metadata.csv"),
   row.names = FALSE
)
