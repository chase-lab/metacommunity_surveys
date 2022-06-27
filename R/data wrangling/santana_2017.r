## santana_2017


dataset_id <- "santana_2017"
ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))

data.table::setnames(
  ddata, c("Year", "Transect", "Date"),
  c("year", "local", "date")
)

ddata <- data.table::melt(ddata,
  id.vars = c("year", "local", "Rowname", "Farmland_area", "date", "Recorder"),
  variable.name = "species",
  value.name = "value"
)
ddata <- ddata[value > 0]

# One sampling per year
# table(ddata[,.(tot = length(unique(date))), by = .(local, year)]$tot)


ddata[, ":="(
  dataset_id = dataset_id,
  regional = paste("SPA Castro Verde", Farmland_area),

  metric = "abundance",
  unit = "count",

  date = NULL,
  Rowname = NULL,
  Recorder = NULL,
  Farmland_area = NULL
)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  realm = "Terrestrial",
  taxon = "Birds",

  latitude = data.table::fifelse(grepl("High-intensity", regional), "38°03'N", "37°41N"),
  longitude = data.table::fifelse(grepl("High-intensity", regional), "8°06'W", "8°00'W"),

  effort = 1L,
  study_type = "ecological_sampling",

  data_pooled_by_authors = FALSE,

  alpha_grain = 32.12,
  alpha_grain_unit = "ha",
  alpha_grain_type = "sample",
  alpha_grain_comment = "transect 250m buffer",

  gamma_sum_grains_unit = "ha",
  gamma_sum_grains_type = "sample",
  gamma_sum_grains_comment = "sum of the sampled transect areas per region per year",

  gamma_bounding_box = data.table::fifelse(grepl("High-intensity", regional), 423.92, 456.08),
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "ecosystem",
  gamma_bounding_box_comment = "areas of the high and low intensity areas estimated from figure 1",

  comment = "Extracted from Santana et al 2017 Dryad repo (https://datadryad.org/stash/dataset/doi:10.5061/dryad.kp3fv). Authors sampled birds in two rural areas of Portugal. Both areas differ by the agriculture intensity. No standardization needed, one sampling per year during 6 years, values are numbers of individual per transect. Each local is a buffer of 250 m along a transect (71 transects).",
  comment_standardisation = "none needed"
)][, gamma_sum_grains := 32.12 * length(unique(local)), by = .(regional, year)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
