# burlakova_2021
dataset_id <- "burlakova_2021"
ddata <- base::readRDS(file = "./data/raw data/burlakova_2021/rdata.rds")

# melting species
ddata <- data.table::melt(ddata,
  id.vars = c("Year", "Station", "Depth_m", "Latitude", "Longitude"),
  variable.name = "species"
)
ddata <- ddata[value != 0]
data.table::setnames(ddata, c(1L, 2L, 4L, 5L), c("year", "local", "latitude", "longitude"))


# standardisation ----

## selecting standard years ----
ddata <- ddata[year %in% c(1990, 1995, 2003, 2013, 2018)]

## effort ----
ddata[, effort := c(0.053, 0.053, 0.053 * 3, 0.048 * 3, 0.0523 * 3)[match(year, c(1990, 1995, 2003, 2013, 2018))]]
ddata[year %in% c(1990, 1995) & local %in% c("41", "81A", "93", "93A"), effort := 0.053 * 3]
ddata[, sample_size := as.integer(sum(value)), by = .(local, year)]
min_sample_size <- as.integer(ddata[effort == min(effort), min(sample_size)])

## resampling based on the smallest sample size from the smallest grabs ----
ddata[, species := as.character(species)]
data.table::setkey(ddata, species)

resampling <- function(species, value, min_sample_size, replace = FALSE) {
  comm <- table(sample(x = rep(species, times = value), min_sample_size, replace = replace))
  if (length(comm) < length(value)) {
    comm <- comm[match(species, names(comm), nomatch = NA)]
  }
  return(comm)
}

set.seed(42)
ddata[sample_size > min_sample_size, value := resampling(species, value, min_sample_size), by = .(local, year)]
ddata[sample_size < min_sample_size, value := resampling(species, value, min_sample_size, replace = TRUE), by = .(local, year)]
ddata[, value := as.integer(value)]
ddata <- na.omit(ddata)

## keeping only stations sampled more than once (data.table style join to select sites sampled more than once)
ddata <- ddata[ddata[, length(unique(year)), by = local][V1 > 1L][, .(local)], on = "local"]

# ddata ----
ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Lake Ontario",

  metric = "abundance",
  unit = "count",

  Depth_m = NULL
)]

# Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, latitude, longitude, year, effort)])

meta[, ":="(
  taxon = "Invertebrates",
  realm = "Freshwater",


  study_type = "ecological_sampling",
  effort = 1L,

  data_pooled_by_authors = FALSE,
  sampling_years = NA,

  alpha_grain = effort,
  alpha_grain_unit = "m2",
  alpha_grain_type = "sample",
  alpha_grain_comment = "area of sediment sampler * number of samples",

  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "sample",
  gamma_sum_grains_comment = "sum of sampler areas per year",

  gamma_bounding_box = 18960L, # area of the Ontario lake
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "lake_pond",

  comment = "Extracted from 'Density data for Lake Ontario benthic invertebrate assemblages from 1964 to 2018' data paper doi: 10.1002/ECY.3528. Methods: 'All benthic invertebrate data were collected during lake-wide surveys conducted in summer and fall months between 1964 and 2018'. Effort is the sampled area, all samplers are not strictly identical and in some cases only one replicate was made per station instead of three.",
  comment_standardisation = "Only samples from the following years were kept because they followed a comparable sampling design: 1990, 1995, 2003, 2013, 2018. Only locations sampled more than once were kept. Since the exact size of the grab samplers and the number of samples varied, we standardised by randomly sampling the minimal number of individuals found in one of the smallest grabs in every other community. This resampling sometimes reduced the specific richness compared to the full observed sample. In rare cases, larger grabs had fewer individuals and we sampled with replacement to get to the target number of individuals."
)][, gamma_sum_grains := sum(alpha_grain), by = year]

ddata[, c("latitude", "longitude", "effort", "sample_size") := NULL]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
