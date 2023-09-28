# seipel_2022
dataset_id <- 'seipel_2022'

ddata <- base::readRDS(file = 'data/raw data/seipel_2022/rdata.rds')
data.table::setnames(ddata, tolower(colnames(ddata)))
data.table::setnames(
   x = ddata,
   old = c('region', 'plot_id', 'accepted.name.miren', 'abundance'),
   new = c('regional', 'local', 'species', 'value'))

# Raw data ----
## Communities data ----
ddata[, ':='(
   dataset_id = dataset_id,

   metric = 'abundance score',
   unit = 'score',

   road = NULL,
   transect = NULL,
   plot = NULL
)]

## Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, longitude, latitude)])

meta[, ":="(
   realm = "Terrestrial",
   taxon = "Plants",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = 100L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "plot",
   alpha_grain_comment = "2x50m plot",

   comment = factor("Extracted from: https://doi.org/10.5281/zenodo.7495407, data saved at raw data/seipel_2022. Methods: 'The MIREN road survey uses a stratified approach for recording plant species along mountain roads that traverse the major elevation gradient in a mountainous region (Fig. 1). Stratified sampling occurs within a Region along three different Roads. Along each Road there are 20 [Transects] evenly stratified by elevation, and at each [Transect] there are three Plots at different distances from the road'. Here, Region is regional scale and plot is local scale."),
   comment_standardisation = "none needed",
   doi = 'https://doi.org/10.5281/zenodo.7495407'
)]

ddata[, c('longitude','latitude') := NULL]

## Save raw data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)

# Standardised data ----

## data subsetting ----
### subsetting plots where samples are at least 10 years apart ----
ddata <- ddata[
   ddata[, diff(range(year)), by = local][V1 >= 9L][, V1 := NULL],
   on = 'local'
]

## Commuity data ----
ddata[, ":="(
   metric = 'pa',
   unit = 'pa',
   value = 1L
)]

## Metadata ----
meta <- meta[unique(ddata[, .(regional, local, year)]),
             on = .(regional, local, year)]

meta[, ":="(
   effort = 1L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "Sum area of the plots per year per region",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment_standardisation = "Only plots that were sampled over a period of at least 10 years were kept. Categorical abundances were transformed into presence absence"
)][, ":="(
   gamma_sum_grains = sum(alpha_grain),
   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6
), by = .(year, regional)]

## Save standardised data ----
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
