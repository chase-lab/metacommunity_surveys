# magnuson_2020
dataset_id <- "magnuson_2020"



## loading data ----

ddata <- base::readRDS(paste0("./data/raw data/", dataset_id, "/rdata.rds"))
data.table::setnames(ddata, c("lakeid", "year4", "taxon"), c("local", "year", "species"))

ddata[species %in% c("CHAOBORUS PUPAE", "CHAOBORUS LARVAE"), species := "CHAOBORUS"]
ddata[, effort := length(unique(rep)), by = .(local, year)]
ddata <- unique(ddata[, .(local, year, species, effort)])


## community data ----

ddata[, ":="(
  dataset_id = dataset_id,
  regional = "North Temperate Lakes",
  local = c("Big Muskellunge", "Allequash", "Crystal Bog", "Crystal Lake", "Sparkling", "Trout Bog", "Trout")[match(local, c("BM", "AL", "CB", "CR", "SP", "TB", "TR"))],

  value = 1L,
  metric = "pa",
  unit = "pa"
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
gamma_bounding_box <- geosphere::areaPolygon(data.frame(longitude = coords[border == "longitude", coordinate], latitude = coords[border == "latitude", coordinate])[grDevices::chull(coords[border == "longitude", coordinate], coords[border == "latitude", coordinate]), ]) / 1000000


## metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, effort)])

meta[, ":="(
  realm = "Freshwater",
  taxon = "Invertebrates",

  study_type = "ecological_sampling",

  data_pooled_by_authors = FALSE,

  latitude = coords[border == "latitude", coordinate][match(local, coords[border == "latitude", local])],
  longitude = coords[border == "longitude", coordinate][match(local, coords[border == "longitude", local])],

  alpha_grain = c(396.3, 168.4, 0.5, 36.7, 64, 1.1, 1607.9)[match(local, c("Big Muskellunge", "Allequash", "Crystal Bog", "Crystal Lake", "Sparkling", "Trout Bog", "Trout"))],
  alpha_grain_unit = "ha",
  alpha_grain_type = "lake_pond",
  alpha_grain_comment = "area of the lake given by the authors",

  gamma_sum_grains = sum(c(396.3, 168.4, 0.5, 36.7, 64, 1.1, 1607.9)),
  gamma_sum_grains_unit = "ha",
  gamma_sum_grains_type = "functional",
  gamma_sum_grains_comment = "sum of the areas of the lakes.",

  gamma_bounding_box = gamma_bounding_box,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "convex-hull",

  comment = "Extracted from EDI data repository knb-lter-ntl.13.32 by John Magnuson et al. The authors sampled macroinvertebrates of 7 lakes every year between 1983 and 2020. Effort is the number of replicates per year per lake (1 to 5)",
  comment_standardisation = "abundances were turned into presence/absence. Chaoborus pupae and larvae were counted with the adults. Replicate samples were pooled together"
)]

ddata[, effort := NULL]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
