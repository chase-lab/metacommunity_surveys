# green_2021
dataset_id <- "green_2021"

ddata <- base::readRDS(file = "./data/raw data/green_2021/docx_extraction.rds")
data.table::setnames(ddata, c("species", "month", "year", "local", "value"))

# Standardisation ----
## computing min total abundance for the local/year where the effort is the smallest ----
ddata[, value := as.integer(value)]
ddata[, sample_size := sum(value), by = .(local, year)]
## deleting samples with less than 20 individuals
ddata <- ddata[sample_size >= 20L]
## including pond area ----
ddata[, alpha_grain := c(4.4, 3.71, 7.3, 4.02, 4.48, 36.08, 21.71)[match(local, 1:7)]]
min_sample_size <- ddata[alpha_grain == min(alpha_grain), min(sample_size)]

## resampling abundances down to the minimal total abundance observed among the surveys with the minimal effort
source("./R/functions/resampling.r")
set.seed(42)
ddata[sample_size > min_sample_size, value := resampling(species, value, min_sample_size), by = .(year, local)]
ddata <- ddata[!is.na(value)]


# community data ----
ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Vancouver Island, Canada",

  metric = "abundance",
  unit = "count",

  month = NULL,
  alpha_grain = NULL,
  sample_size = NULL
)]

# Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  taxon = "Fish",
  realm = "Marine",

  study_type = "ecological_sampling",
  effort = 1L,

  data_pooled_by_authors = FALSE,

  latitude = "48.737685°",
  longitude = "-125.118645°",

  alpha_grain = 3.71,
  alpha_grain_unit = "m2",
  alpha_grain_type = "lake_pond",

  gamma_bounding_box = 1200L,
  gamma_bounding_box_unit = "m2",
  gamma_bounding_box_type = "ecosystem",
  gamma_bounding_box_comment = "estimated from aerial picture of the beach",

  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "sample",
  gamma_sum_grains_comment = "sum of the areas of the sampled pounds",

  comment = "Extracted from Green and al. supplementary docx file table S5 (https://doi.org/10.1111/ddi.13387). Methods: 'Fish sampling was conducted on 13 occasions between 1966 and 2016[...]Sampling captured all fish in each pool and consisted of dispersing rotenone into a pool when it was isolated at low tide followed by a thorough search of the pool during which all fish were recovered with small dip nets (Gibson, 1999; Green, 1971). This approach is unique in collecting rare and cryptic species (the full species list for the study period is reported in Table S1). Tidepools were sampled on the same low tide on each sampling date, led by the first author (JMG).'",
  comment_standardisation = "individual based standardisation: all abundances were resampled down to the smallest abundance from the smallest pond: 22 individuals.",
  doi = 'https://doi.org/10.1111/ddi.13387'
)][, gamma_sum_grains := sum(alpha_grain), by = year]


dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
