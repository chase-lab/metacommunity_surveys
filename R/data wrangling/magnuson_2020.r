# magnuson_2020
dataset_id <- "magnuson_2020"

## loading data ----
ddata <- base::readRDS(paste0("./data/raw data/", dataset_id, "/rdata.rds"))
data.table::setnames(ddata, c("lakeid", "year4", "taxon","number_indiv"), c("local", "year", "species","value"))

ddata[, species := as.character(species)][species %in% c("CHAOBORUS PUPAE", "CHAOBORUS LARVAE"), species := "CHAOBORUS"]
ddata[, effort := length(unique(rep)), by = .(local, year)]
ddata <- ddata[, .(value = sum(value)), by = .(local, year, species, effort)][value != 0L]

## standardisation ----
### computing min total abundance for the local/year where the effort is the smallest ----
ddata[, sample_size := sum(value), by = .(year, local)]
min_sample_size <- ddata[effort == min(effort), min(sample_size)]

### resampling abundances down to the minimal total abundance observed among the surveys with the minimal effort ----
source("./R/functions/resampling.r")
set.seed(42)
ddata[sample_size > min_sample_size, value := resampling(species, value, min_sample_size), by = .(year, local)]
ddata[sample_size < min_sample_size, value := resampling(species, value, min_sample_size, replace = TRUE), by = .(year, local)]
ddata <- ddata[!is.na(value)]


## community data ----
ddata[, ":="(
  dataset_id = dataset_id,
  regional = "North Temperate Lakes",
  local = c("Big Muskellunge", "Allequash", "Crystal Bog", "Crystal Lake", "Sparkling", "Trout Bog", "Trout")[match(local, c("BM", "AL", "CB", "CR", "SP", "TB", "TR"))],

  metric = "abundance",
  unit = "count",

  sample_size = NULL
)]

## coordinates ----
coords <- data.table::data.table( # copy pasted values from the data set metadata
  local = rep(c("AL", "BM", "CB", "CR", "SP", "TB", "TR"), each = 4),
  coords = c(
    "West bounding coordinate:	-89.6458",
    "East bounding coordinate:	-89.6124",
    "North bounding coordinate:	46.0481",
    "South bounding coordinate:	46.0252",
    "West bounding coordinate:	-89.6335",
    "East bounding coordinate:	-89.5935",
    "North bounding coordinate:	46.0273",
    "South bounding coordinate:	46.0051",
    "West bounding coordinate:	-89.6068",
    "East bounding coordinate:	-89.6057",
    "North bounding coordinate:	46.008",
    "South bounding coordinate:	46.0071",
    "West bounding coordinate:	-89.6191",
    "East bounding coordinate:	-89.6082",
    "North bounding coordinate:	46.0047",
    "South bounding coordinate:	45.9989",
    "West bounding coordinate:	-89.7045",
    "East bounding coordinate:	-89.6945",
    "North bounding coordinate:	46.0158",
    "South bounding coordinate:	46.0024",
    "West bounding coordinate:	-89.6869",
    "East bounding coordinate:	-89.6854",
    "North bounding coordinate:	46.0417",
    "South bounding coordinate:	46.0407",
    "West bounding coordinate:	-89.7038",
    "East bounding coordinate:	-89.6464",
    "North bounding coordinate:	46.079",
    "South bounding coordinate:	46.0131"
  )
)
coords[, c("border", "coordinate") := data.table::tstrsplit(coords, " bounding coordinate:\t")][, ":="(
  border = c("latitude", "latitude", "longitude", "longitude")[match(border, c("North", "South", "East", "West"))],
  local = c("Big Muskellunge", "Allequash", "Crystal Bog", "Crystal Lake", "Sparkling", "Trout Bog", "Trout")[match(local, c("BM", "AL", "CB", "CR", "SP", "TB", "TR"))],
  coords = NULL
)]
gamma_bounding_box <- geosphere::areaPolygon(
   x = data.frame(longitude = coords[border == "longitude", coordinate], latitude = coords[border == "latitude", coordinate])[grDevices::chull(
      coords[border == "longitude", coordinate], coords[border == "latitude", coordinate]
      ), ]
   ) / 10^6


## metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, effort = min(effort))])

meta[, ":="(
  realm = "Freshwater",
  taxon = "Invertebrates",

  study_type = "ecological_sampling",

  data_pooled_by_authors = FALSE,

  latitude = coords[border == "latitude", coordinate][match(local, coords[border == "latitude", local])],
  longitude = coords[border == "longitude", coordinate][match(local, coords[border == "longitude", local])],

  alpha_grain = 36.7,
  alpha_grain_unit = "ha",
  alpha_grain_type = "lake_pond",
  alpha_grain_comment = "area of lake Sparkling given by the authors",

  gamma_sum_grains_unit = "ha",
  gamma_sum_grains_type = "functional",
  gamma_sum_grains_comment = "sum of the areas of the lakes.",

  gamma_bounding_box = gamma_bounding_box,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "convex-hull",
  gamma_bounding_box_comment = "coordinates extracted fromm the data set metadata",

  comment = "Extracted from EDI data repository knb-lter-ntl.13.34 by John Magnuson et al. The authors sampled macroinvertebrates of 7 lakes every year between 1983 and 2021. Effort is the smallest number of replicates per year per lake (1 to 5) and alpha_grain is the size of the lake with the smallest effort.",
  comment_standardisation = "Chaoborus pupae and larvae were pooled with the adults. 1 to 5 replicate samples per lake per year were pooled together and abundances were resampled based on the smallest observed total abundance (73 individuals) in Sparkling Lake which was sampled only once in 2014.",
  doi = 'https://doi.org/10.6073/pasta/40229f97abd97f274bc2a8c1e3ef4ab7'
)][, gamma_sum_grains := sum(alpha_grain), by = year]

ddata[, effort := NULL]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
