dataset_id <- "koleskinova_2021b" # collembola

# loading data ----
ddata <- readRDS("./data/raw data/koleskinova_2021b/rdata.rds")

# standardising data ----
## selecting sites sampled at least twice with at least 10 years in between using a data.table style joint ----
ddata <- ddata[ddata[, diff(range(unique(year))), by = local][V1 >= 10L, local], on = "local"]

data.table::setnames(
   ddata,
   c("individualCount","scientificName","decimalLatitude","decimalLongitude","sampleSizeValue"),
   c("value","species","latitude","longitude","effort")
)

## resampling ----
source("./R/functions/resampling.r")
ddata[, sample_size := sum(value), by = .(local, year)]
min_sample_size <- ddata[effort == min(effort), min(sample_size)]

## resampling based on the smallest sample size from the smallest cores ----
data.table::setkey(ddata, species)

set.seed(42)
ddata[effort == 0.01, value := resampling(species, value, min_sample_size), by = .(local, year)]
ddata <- ddata[!is.na(value)]

# ddata ----
ddata[, ":="(
   dataset_id = dataset_id,
   regional = substr(local, 16L, 19L),

   metric = "abundance",
   unit = "count"
)][, c("taxonRank","effort","sample_size") := NULL]

# Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, latitude, longitude, year)])

meta[, ":="(
   taxon = "Invertebrates",
   realm = "Terrestrial",


   study_type = "ecological_sampling",
   effort = 1L,

   data_pooled_by_authors = FALSE,
   sampling_years = NA,

   alpha_grain = 0.0025,
   alpha_grain_unit = "m2",
   alpha_grain_type = "sample",
   alpha_grain_comment = "area of sampling core",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of sampler areas per year",

   gamma_bounding_box = pi * 14^2,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "box",
   gamma_bounding_box_comment = "area of a circle of 14km radius around the factory",

   comment = "Extracted from GBIF.org (17 May 2022) GBIF Occurrence Download  https://doi.org/10.15468/dl.uefcy6 described in data paper https://doi.org/10.3897/BDJ.9.e75586. Authors sampled colembola with soil cores along a pollution gradient close to a paper pulp factory in Russia. The local/alpha scale is a single core sample and region is a site. 2 sampling cores were used and accounted for, see comment_standardisation section.",
   comment_standardisation = "Abundances from large samples (0.01m2) were resampled down to the minimal abundance found in one of the smaller samples: 23 individuals."
)][, gamma_sum_grains := sum(alpha_grain), by = .(regional, year)]

ddata[, c("latitude","longitude") := NULL]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)