dataset_id <- "koleskinova_2021b" # collembola

ddata <- readRDS("data/raw data/koleskinova_2021b/rdata.rds")

# Raw Data ----

data.table::setnames(
   ddata,
   old = c("individualCount","scientificName","decimalLatitude","decimalLongitude","sampleSizeValue"),
   new = c("value","species","latitude","longitude","effort")
)

## community data ----
ddata[, ":="(
   dataset_id = dataset_id,

   regional = substr(local, 16L, 19L),

   metric = "abundance",
   unit = "count",
   taxonRank = NULL
)]

## meta data ----
meta <- unique(ddata[, .(dataset_id, regional, local, latitude, longitude, year)])

meta[, ":="(
   taxon = "Invertebrates",
   realm = "Terrestrial",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,
   sampling_years = NA,

   alpha_grain = 0.0025,
   alpha_grain_unit = "m2",
   alpha_grain_type = "sample",
   alpha_grain_comment = "area of sampling core",

   comment = "Extracted from GBIF.org (17 May 2022) GBIF Occurrence Download  https://doi.org/10.15468/dl.uefcy6 described in data paper https://doi.org/10.3897/BDJ.9.e75586. Authors sampled colembola with soil cores along a pollution gradient close to a paper pulp factory in Russia. The local/alpha scale is a single core sample and region is a site. 2 sampling cores were used and accounted for, see comment_standardisation section.",
   comment_standardisation = "None needed",
   doi = 'https://doi.org/10.15468/dl.uefcy6 | https://doi.org/10.3897/BDJ.9.e75586'
)]
ddata[, c("latitude", "longitude") := NULL]

## save data----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata[,!"effort"],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)

# Standardised Data ----
## selecting sites sampled at least twice with at least 10 years in between using a data.table style joint ----
ddata <- ddata[ddata[, diff(range(unique(year))), by = local][V1 >= 9L, local], on = "local"]

## resampling ----
source("R/functions/resampling.r")
ddata[, sample_size := sum(value), by = .(local, year)]
min_sample_size <- ddata[effort == min(effort), min(sample_size)]

## resampling based on the smallest sample size from the smallest cores ----
data.table::setkey(ddata, species)

set.seed(42)
ddata[effort == 0.01, value := resampling(species, value, min_sample_size), by = .(local, year)]
ddata <- ddata[!is.na(value)]

ddata[, c("effort","sample_size") := NULL]

## meta data---
meta <- meta[unique(ddata[, .(local, regional, year)]),
             on = .(local, regional, year)]
meta[,":="(
   effort = 1L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of sampler areas per year",

   gamma_bounding_box = pi * 14^2,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "box",
   gamma_bounding_box_comment = "area of a circle of 14km radius around the factory",

   comment_standardisation = "Abundances from large samples (0.01m2) were resampled down to the minimal abundance found in one of the smaller samples: 23 individuals."
)][, gamma_sum_grains := sum(alpha_grain), by = .(regional, year)]


## save standardised data----
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
