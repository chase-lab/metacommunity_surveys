# gaget_2021
dataset_id <- "gaget_2021"

ddata <- base::readRDS(file = paste0("./data/raw data/", dataset_id, "/rdata.rds"))

# melting species ----
ddata <- data.table::melt(ddata,
  id.vars = c(1:3, 5:6),
  measure.vars = 8:ncol(ddata),
  variable.name = "species"
)

ddata <- ddata[value > 0]

data.table::setnames(ddata, c("regional", "local", "year", "latitude", "longitude", "species", "value"))

# community data ----
ddata[, ":="(
  dataset_id = dataset_id,

  metric = "abundance",
  unit = "count"

)]


meta <- unique(ddata[, .(dataset_id, regional, local, year, latitude, longitude)])
meta[, ":="(

  realm = "Terrestrial",
  taxon = "Birds",

  effort = 1L,

  study_type = "ecological_sampling",

  data_pooled_by_authors = FALSE,

  alpha_grain = pi * (50^2),
  alpha_grain_unit = "m2",
  alpha_grain_type = "sample",
  alpha_grain_comment = "50m radius sampling area of bird listening",

  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "sample",
  gamma_sum_grains_comment = "sum of the area of the listening points",

  gamma_bounding_box = (c(1018L, 415L, 50L) * 10)[match(regional, c("Loire", "Allier", "Doubs"))],
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "buffer",
  gamma_bounding_box_comment = "Area of a 10 km wide buffer along the sampled rivers parts.",

  comment = "Long term bird assessment along 3 French rivers. Data available on Dryad: https://datadryad.org/stash/dataset/doi:10.5061/dryad.1rn8pk0rx. Data shared by the authors on Dryad did not include 'the private data (14 Doubs' points counts) are available from the corresponding author on request'. METHODS constant: 'Breeding birds were monitored in spring during a longitudinal long-term scientific study that recorded point counts of any species heard or seen (Blondel et al., 1981). Two sessions were run (20 min in April and 20 min between mid-May and mid-June), and the highest abundance for each species between the two sessions was retained. Point counts were regularly spaced along the riverbank (1–5 km depending on the river) to limit the risk of double counting birds moving across a large area, and were strictly identical for each session [...] Variability associated with observers was limited, as only 12, experienced ornithologists conducted all censuses, and a given point count was monitored by the same observer, who adopted the same protocol each year.'",
  comment_standardisation = "none needed"
)][, gamma_sum_grains := pi * (50^2) * length(unique(local)), by = .(regional, year)]


ddata[, ":="(
  latitude = NULL,
  longitude = NULL
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
