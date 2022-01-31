## vojik_2018


dataset_id <- "vojik_2018"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))
data.table::setnames(ddata, 1, "section")
# melting, splitting and melting period and site
ddata <- data.table::melt(ddata,
  id.vars = c("section", "species", "layer")
)
ddata[, c("period", "local") := data.table::tstrsplit(variable, " ")]

ddata[, value := as.integer(data.table::fifelse(value == "." | is.na(value), 0L, 1L))]
ddata <- ddata[, .(value = sum(value)), by = .(local, period, species, section)]
ddata <- ddata[value != 0]


ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Klinec forest",
  local = paste0("s", local),
  year = c(1957L, 2015L, 2015L)[match(period, c("historical", "modern", "modern\n"))],

  metric = "pa",
  value = 1L,
  unit = "pa",

  section = NULL,
  period = NULL
)]

ddata <- unique(ddata)

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  realm = "Terrestrial",
  taxon = "Plants",

  latitude = "49.9008N",
  longitude = "14.3426E",

  effort = 1L,
  study_type = "resurvey",

  data_pooled_by_authors = FALSE,

  alpha_grain = 500L,
  alpha_grain_unit = "m2",
  alpha_grain_type = "sample",

  gamma_sum_grains = 500L * 29L,
  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "plot",
  gamma_sum_grains_comment = "29 plots of 500m2",

  gamma_bounding_box = 1000L,
  gamma_bounding_box_unit = "ha",
  gamma_bounding_box_type = "functional",

  comment = "Extracted from supplementary material Table 1 in Vojik and Boublik 2018 (https://doi.org/10.1007/s11258-018-0831-5). Historical vegetation records of the Klinec forest, Czech Republic, were made in 1957. In 2015, M Vojik resampled the same 29 plots of 500m2 each using the same methodology.",
  comment_standardisation = "tree, shrub and herb layers pooled together"
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)

data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
