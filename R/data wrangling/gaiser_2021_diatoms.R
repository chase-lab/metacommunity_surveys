# gaiser_2021_diatoms
dataset_id <- "gaiser_2021_diatoms"

ddata <- base::readRDS("data/raw data/gaiser_2021_diatoms/rdata.rds")
data.table::setnames(ddata,  1L:11L, tolower(colnames(ddata)[1L:11L]))
data.table::setnames(ddata, c('easting_utm', 'northing_utm', 'lsu_name'), c('longitude', 'latitude', 'local'))

# melting species ----
species_list <- 12L:ncol(ddata)
ddata[, (species_list) := lapply(.SD, function(column) replace(column, column == 0, NA_real_)), .SDcols = species_list] # replace all 0 values by NA
ddata <- data.table::melt(ddata,
                          id.vars = 1L:11L,
                          variable.name = "species",
                          na.rm = TRUE
)

# standardising data ----
ddata[local == "Western Perrine Marl Prairie; Taylor Slough", local := paste(local, lsu)]
ddata[, c('episode','wetland_basin','lsu','draw','field_replicate') := NULL]
ddata[, year := as.integer(format(obs_date, "%Y"))][, month := format(obs_date, "%m")]

## Keeping only sites sampled at twice least 10 years apart ----
ddata <- ddata[ddata[, diff(range(year)), by = local][V1 >= 9L][, V1 := NULL], on = 'local']

## When a site is sampled several times a year, selecting the 1 most frequently sampled month from the 4 sampled months ----
ddata[, month_order := (1L:4L)[data.table::chmatch(month, c('11','10','09','12'))]]
data.table::setkey(ddata, month_order)

ddata <- ddata[unique(ddata[, .(local, year, month)])[, .SD[1L], by = .(local, year)], on = .(local, year, month)][, month_order := NULL]

## When a site is sampled twice a month, selecting the first visit ----
ddata <- ddata[unique(ddata[, .(local, year, month, obs_date)])[, .SD[1L], by = .(local, year, month)], on = .(local, year, month, obs_date)][, month := NULL][, obs_date := NULL][, tag.hyphen.id := NULL]

## When a site is sampled twice a day, select the first draw ----
ddata <- ddata[unique(ddata[, .(local, year, primary_sampling_unit)])[, .SD[1L], by = .(local, year)], on = .(local, year, primary_sampling_unit)][, primary_sampling_unit := NULL]

# Communities ----
ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Florida Coastal Everglades LTER",

   metric = "relative abundance",
   unit = "percent"
)]

# Metadata ----
## Coordinate conversion ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, longitude, latitude)])
meta[longitude == -9999L | latitude == -9999L, c('longitude', 'latitude') := NA_integer_]

coords <- stats::na.omit(meta)
coords_sf <- sf::st_as_sf(coords, coords = c('longitude', 'latitude'), crs = sf::st_crs(paste0('+proj=utm +zone=17')))
coords_sf <- sf::st_transform(coords_sf, crs = sf::st_crs('+proj=longlat +datum=WGS84'))

coords[, longitude := sf::st_coordinates(coords_sf)[, 1]][, latitude := sf::st_coordinates(coords_sf)[, 2]]

## Merging coordinates back in meta ----
meta <- coords[meta[,.(regional, local, year)], on = .(regional, local, year)]

meta[, ":="(
   taxon = "Algae",
   realm = "Freshwater",

   study_type = "ecological_sampling",
   effort = 1L,

   data_pooled_by_authors = FALSE,
   sampling_years = NA,

   alpha_grain = 800L * 800L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "plot",
   alpha_grain_comment = "area of a primary sampling unit",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "sum of primary sampling unit areas per year",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment = "Extracted from Gaiser, E. 2021. Relative Abundance Diatom Data from Periphyton Samples Collected from the Greater Everglades, Florida USA from September 2005 to November 2014 ver 4. Environmental Data Initiative. https://doi.org/10.6073/pasta/a9dca89331d33221c59a6aa0ae96278a .
   This data package contains relative diatom taxon abundances collected annually during the wet season between 2005 and 2014 from sites distributed throughout the greater Everglades ecosystem. This project is part of the Comprehensive Everglades Restoration Program's Monitoring and Assessment Plan intended to document baseline variability in periphyton attributes for assessing the effectiveness of restoration projects. A total of 200 primary sampling units (PSU) of 800 m x 800 m are nested in 32 landscape units and each year, random coordinates are 'drawn' within each PSU and one sampleable draw is visited in each. Sampled periphyton is processed for diatoms, slides are prepared, and 500 frustules are enumerated and identified to the lowest possible taxonomic resolution per slide. Taxon abundances are then relativized to the total count. These data accompany environmental, periphyton biomass, and soft algal abundance datasets. Post-2014 data are available upon request to the project PI, Evelyn Gaiser.",
   comment_standardisation = "Keeping only sites sampled at twice least 10 years apart When a site is sampled several times a year, selecting the 1 most frequently sampled month from the 4 sampled months When a site is sampled twice a month, selecting the first visit When a site is sampled twice a day, select the first draw",
   doi = 'https://doi.org/10.6073/pasta/a9dca89331d33221c59a6aa0ae96278a'
)][, ":="(
   gamma_bounding_box = geosphere::areaPolygon(data.frame(na.omit(longitude), na.omit(latitude))[grDevices::chull(na.omit(longitude), na.omit(latitude)), ]) / 10^6,
   gamma_sum_grains = sum(alpha_grain)
),
by = .(regional, year)
]

ddata[, c("latitude", "longitude") := NULL]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)



