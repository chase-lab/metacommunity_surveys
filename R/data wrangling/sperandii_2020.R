dataset_id <- "sperandii_2020"

ddata <- base::readRDS("./data/raw data/sperandii_2020/rdata.rds")
data.table::setnames(ddata, 1L:2L, c("local", "timepoints"))

# melting species
ddata <- data.table::melt(ddata,
  id.vars = c("local", "timepoints", "Habitat_code"),
  variable.name = "species"
)

ddata <- ddata[value != 0]

# select only sites sampled twice
ddata[, local := gsub("rev", "", local)]
ddata <- ddata[ddata[, length(unique(timepoints)), by = local][V1 == 2L][, local], on = .(local)]

# Ddata ----
ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Coastal dunes, Italy",


  year = c(2007L, 2017L)[match(timepoints, 0:1)],

  metric = "abundance",
  unit = "count",

  Habitat_code = NULL,
  timepoints = NULL
)]

# Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  taxon = "Plants",
  realm = "Terrestrial",

  effort = 1L,

  study_type = "resurvey",

  data_pooled_by_authors = TRUE,
  data_pooled_by_authors_comment = "one sampling per site per sampling period",
  sampling_years = c("2002, 2005, 2007", "2017")[match(year, c(2007L, 2017L))],

  latitude = 42.01,
  longitude = 13.48,

  alpha_grain = 4L,
  alpha_grain_unit = "m2",
  alpha_grain_type = "sample",

  gamma_sum_grains = 4L * length(unique(local)),
  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "quadrat",

  gamma_bounding_box = 130 * 0.1 + 70 * 0.1,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "shore",
  gamma_bounding_box_comment = "length of coast of the Lazio and Molise regions * 0.1km",

  comment = "Extracted from sperandii et al Dryad repository '10.5061/dryad.np5hqbzr8'. Authors sampled plants in 4m2 plots along Adriatic and Mediterranean coasts of central Italy. Methods: 'The selected 188 plots were originally sampled between 2002 and 2007 (hereafter T0) throughout the first portion of the coastal zonation, therefore including annual pioneer communities of the upper beach, embryonic dunes, mobile dunes and coastal stable dune grasslands. Specifically, 63 plots were sampled in 2002, 56 were sampled in 2005 and 59 in 2007.[...]Historical plots were revisited and resampled in 2017 (hereafter T1), following the same methods used by the original surveyors. This allowed us to evaluate changes occurred over 10–15 years. During the resurvey, special care was taken to perform the resampling during the same months in which the original sampling was done (April-May).'This dataset is part of database http://www.givd.info/ID/EU-IT-020",
  comment_standardisation = "excluding sites sampled only once",
  doi = 'https://doi.org/10.5061/dryad.np5hqbzr8 | https://doi.org/10.1016/j.ecolind.2018.09.039 | https://doi.org/10.1127/phyto/2017/0198'
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
