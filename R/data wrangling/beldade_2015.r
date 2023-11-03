## beldade_2015
dataset_id <- "beldade_2015"

ddata <- data.table::fread(
  file = paste0("data/raw data/", dataset_id, "/rdata.csv"),
  skip = 1, header = TRUE, drop = c("V15", "V16"))
data.table::setnames(ddata, "Taxon", "species")

#Raw Data ----
## melting sites ----
ddata <- data.table::melt(ddata,
                          id.vars = "species",
                          value.name = "value",
                          variable.name = "local"
)

##exclude absences ----
ddata <- ddata[value != ""]

##melting historical and present values ----
ddata[, value := gsub("^/", "0/", value)][, value := gsub("/$", "/0", value)]
ddata[, c("historical", "present") := data.table::tstrsplit(value, "/")]
ddata <- data.table::melt(ddata,
                          id.vars = c("local", "species"),
                          measure.vars = c("historical", "present"),
                          value.name = "value",
                          variable.name = "period"
)
ddata <- ddata[value > 0] # absences not empty traps

##community data ----
ddata[, ":="(
  dataset_id = dataset_id,

  regional = "Mataiva",

  year = c(1981L, 2012L)[match(period, c("historical", "present"))],

  species = gsub("\\*", "", species),

  metric = "density",
  unit = "individuals per 250m2",

  period = NULL
)]

##meta data ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  taxon = "Fish",
  realm = "Marine",

  latitude = "14 55`S",
  longitude = "148 36`W",

  study_type = "resurvey",

  data_pooled_by_authors = FALSE,
  sampling_years = NA,

  alpha_grain = 250L,
  alpha_grain_unit = "m2",
  alpha_grain_type = "sample",
  alpha_grain_comment = "50m long 2.5m wide transect",

  comment = "Extracted from supp material from beldade_2015. 'This small atoll (10 km × 5 km) has an unusual morphology with a reticulated lagoon divided into approximately 70 pools (average depth: 8 m), separated by a network of slightly submerged coral reef partitions [...]. In February 2012, we reassessed coral cover and fish assemblages in the same 13 pools as those surveyed in 1981 by Bell&Galzin (1984).' and 'To estimate fish diversity and density, we faithfully replicated the method of Bell & Galzin (1984). At each site, along one of the transects laid for coral assessment, we recorded the number of each species of reef fish within 2.5 m on either side of the transect line. Data were collected once by each of two observers at a 5 min interval.'",
  comment_standardisation = "none needed",
  doi = 'https://doi.org/10.7717/peerj.745'
)]

##save raw data ----
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

#standardised Data ----
##meta data ----
meta[, ":="(
  effort = 1L,

  gamma_bounding_box = 50L,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "ecosystem",
  gamma_bounding_box_comment = "area of the atoll",

  gamma_sum_grains = 13L * 250L,
  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "transect",
  gamma_sum_grains_comment = "sum of the sampled areas of 13 pools"
)]

##save standardised data ----
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
