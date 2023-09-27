# burlakova_2021
dataset_id <- "burlakova_2021"
source("R/functions/resampling.r")

ddata <- base::readRDS(file = "data/raw data/burlakova_2021/rdata.rds")

#Raw Data ----
## melting species ----
ddata <- data.table::melt(
   ddata,
   id.vars = c("Year", "Station", "Depth_m", "Latitude", "Longitude"),
   variable.name = "species"
)
##exclude absences ----
ddata <- ddata[value != 0]

data.table::setnames(
   ddata,
   old = c(1L, 2L, 4L, 5L),
   new = c("year", "local", "latitude", "longitude"))

# ddata ----
ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Lake Ontario",

   metric = "abundance",
   unit = "count",

   Depth_m = NULL
)]

# Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, latitude, longitude, year)])

meta[, ":="(
   taxon = "Invertebrates",
   realm = "Freshwater",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,
   sampling_years = NA,

   alpha_grain = 0.053,
   alpha_grain_unit = "m2",
   alpha_grain_type = "sample",
   alpha_grain_comment = "minimal area of sediment sampler",

   comment = "Extracted from 'Density data for Lake Ontario benthic invertebrate assemblages from 1964 to 2018' data paper doi: 10.1002/ECY.3528. Methods: 'All benthic invertebrate data were collected during lake-wide surveys conducted in summer and fall months between 1964 and 2018'. Effort is the sampled area, all samplers are not strictly identical and in some cases only one replicate was made per station instead of three.",
   comment_standardisation = "none needed",
   doi = 'https://doi.org/10.1002/ECY.3528'
)]


## save raw data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata[,!c("latitude","longitude")],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)

# Standardised Data ----
## selecting standard years ----
ddata <- ddata[year %in% c(1990, 1995, 2003, 2013, 2018)]

## effort ----
ddata[, effort := c(0.053, 0.053, 0.053 * 3, 0.048 * 3, 0.0523 * 3)[match(year, c(1990, 1995, 2003, 2013, 2018))]]
ddata[year %in% c(1990, 1995) & local %in% c("41", "81A", "93", "93A"), effort := 0.053 * 3]
ddata[, value := as.integer(value)][, sample_size := sum(value), by = .(local, year)]
min_sample_size <- as.integer(ddata[effort == min(effort), min(sample_size)])

## resampling based on the smallest sample size from the smallest grabs ----
ddata[, species := as.character(species)]
data.table::setkey(ddata, species)

set.seed(42)
ddata[sample_size > min_sample_size, value := resampling(species, value, min_sample_size), by = .(local, year)]
ddata[sample_size < min_sample_size, value := resampling(species, value, min_sample_size, replace = TRUE), by = .(local, year)]
ddata <- na.omit(ddata) # excluding species that were not selected by the resampling procedure

## Excluding sites that were not sampled at least twice 10 years apart ----
ddata <- ddata[!ddata[, diff(range(year)) < 9L, by = .(regional, local)][(V1)],
               on = .(regional, local)]

##meta data ----
meta <- meta[unique(ddata[, .(local, year)]), on = .(local, year)]
meta[, ":="(
   effort = 1L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of sampler areas per year",

   gamma_bounding_box = 18960L, # area of the Ontario lake
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "lake_pond",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment_standardisation = "Only samples from the following years were kept because they followed a comparable sampling design: 1990, 1995, 2003, 2013, 2018. Only locations sampled more than once were kept. Since the exact size of the grab samplers and the number of samples varied, we standardised by randomly sampling the minimal number of individuals found in one of the smallest grabs in every other community. This resampling sometimes reduced the specific richness compared to the full observed sample. In rare cases, larger grabs had fewer individuals and we sampled with replacement to get to the target number of individuals.
Keeping only sites sampled twice at least 10 years apart."
)][, gamma_sum_grains := sum(alpha_grain), by = year]

ddata[, c("latitude", "longitude", "effort", "sample_size") := NULL]

##save data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
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
