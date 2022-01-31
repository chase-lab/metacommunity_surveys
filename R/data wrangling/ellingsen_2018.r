# ellingsen_2018
dataset_id <- "ellingsen_2018"


ddata <- base::readRDS(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
data.table::setnames(ddata, "stat", "local")

# melting species
ddata <- data.table::melt(ddata,
  id.vars = c("year", "local", "rep"),
  variable.name = "species",
  na.rm = TRUE
)
# ddata[, effort := length(unique(rep)), by = .(year, stat)]  # effort is constant: always 5 replicates
ddata <- ddata[!(species == "ScientificName" | value == 0)]

# Pooling replicates together
ddata <- ddata[, value := as.integer(value)][, .(value = sum(value)), by = .(local, year, species)]

# data
ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Ekofisk-region",
  

  metric = "abundance",
  unit = "count"
)]

# metadata
meta <- unique(ddata[, .(dataset_id, regional, local, year)])

meta[, ":="(
  taxon = "Invertebrates",
  realm = "Marine",

  latitude = c(57.15, 56.92, 56.55, 56.25, 57.00, 56.75, 56.50, 56.04, 57.12, 56.24, 56.96)[match(local, sort(unique(local)))],
  longitude = c(2.77, 3.33, 3.46, 3.83, 2.50, 2.67, 2.75, 3.46, 3.18, 3.16, 2.99)[match(local, sort(unique(local)))]
)][, ":="(

  effort = 1L,
  
  study_type = "ecological_sampling",

  data_pooled_by_authors = FALSE,

  alpha_grain = 0.1,
  alpha_grain_unit = "m2",
  alpha_grain_type = "sample",
  alpha_grain_comment = "area of the sediment sample",

  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "convex-hull",
  gamma_bounding_box_comment = "area of the convex-hull covering the stations",


  comment = "Data extracted from the dryad repository Ellingsen, Kari E. et al. (2018), Data from: Long-term environmental monitoring for assessment of change: measurement inconsistencies over time and potential solutions, Dryad, Dataset, https://doi.org/10.5061/dryad.2v7m4. The authors sampled benthic invertebrates in 11 stations on an oil field with several platforms every third year since 1996. Method data were also available in the paper https://doi.org/10.1007/s10661-017-6317-4. Coordinates are given in table 1 in the paper.",
  comment_standardisation = "In each station, each year, all 5 replicates were pooled together and abundances summed. IMPORTANT: To avoid taxonomical issues, the data set r1bio.new2.n was used ; see data download/ellingsen_2018.r script or the authors helper MOD-DRYAD.R script for details on taxonomy cleaning."
)][, gamma_bounding_box := geosphere::areaPolygon(meta[grDevices::chull(meta[, .(longitude, latitude)]), .(longitude, latitude)]) / 10^6]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
