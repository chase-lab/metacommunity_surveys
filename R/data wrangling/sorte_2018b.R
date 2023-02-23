## sorte_2018b - mobile invertebrates

dataset_id <- "sorte_2018b"
ddata <- base::readRDS(file = "data/raw data/sorte_2018/ddata.rds")[taxon == "invertebrates"]

# removing cover and fixing typos in species names
labs <- levels(ddata$species)
labs[grepl('%|percent', labs, fixed = FALSE, ignore.case = TRUE)] <- NA_character_
labs <- gsub(" egg capsules| egg masses|\\.*[0-9]*$", "", labs, fixed = FALSE)
data.table::setattr(ddata$species, 'levels', labs)

# Communities ----
ddata <- ddata[, .(value = sum(value)), by = .(local, period, year, species, taxon)]
ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Gulf of Maine",

  metric = "abundance",
  unit = "count",
  period = NULL
)]



# Metadata ----
env <- base::readRDS(file = "data/raw data/sorte_2018/env.rds")

meta <- unique(ddata[, .(dataset_id, regional, local, year, taxon)])
meta <- unique(merge(meta, unique(env[local %in% c("Canoe Beach", "Chamberlain", "Pemaquid Point", "Grindstone Neck"), .SD[1], by = local, .SDcols = c("latitude", "longitude")]), all.x = TRUE))

meta[, ":="(
  realm = "Marine",
  taxon = "Invertebrates",

  effort = 9L,

  study_type = "ecological_sampling",

  data_pooled_by_authors = FALSE,

  alpha_grain = .25,
  alpha_grain_unit = "m2",
  alpha_grain_type = "sample",
  alpha_grain_comment = "Ten 0.25-m2 quadrats per 30m transect",

  gamma_sum_grains = .25 * 3 * 3 * 4,
  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "quadrat",
  gamma_sum_grains_comment = "3 quadrats per transect, 3 transects per island, 4 islands",

  gamma_bounding_box = 45L,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "shore",
  gamma_bounding_box_comment = "450 km length of shore of the Gulf of Maine covered by the sampling sites, estimated 1/10km wide",

  comment = "Extracted from Sorte et al 2018 Supplementary (https://onlinelibrary.wiley.com/doi/full/10.1111/gcb.13425). Mobile invertebrates data. Authors compiled historical records from the 1970s in 4 beaches and sampled algae and both fixed and mobile invertebrates in quadrats along horizontal transects (parallel to the shore) in the tidal zone. In sorte_2018a, we included observations of fixed organisms. Methodology and effort from historical and recent records are comparable. Regional is the Gulf of Maine, local a beach",
  comment_standardisation = "Two dates from the 2 most sampled months per year were pooled together. There are only 3 transects in some historical samples so only transects 1, 3 and 5 of all sites and years are kept and they were pooled together. Only tide heights of Low, Mid and High (historical) or 0m, 1m, and 2m (modern) were kept and they were pooled together."
)]


ddata[, "taxon" := NULL]


dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
