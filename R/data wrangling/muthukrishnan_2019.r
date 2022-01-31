## muthukrishnan_2019

dataset_id <- "muthukrishnan_2019"
ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))

data.table::setnames(
  ddata,
  c("survey_year", "county", "lake_id", "Lake_acres", "sample_point_num", "vegetation_scientific_name"),
  c("year", "regional", "local", "alpha_grain", "block", "species")
)

# delete lakes that were sampled only one year
ddata[, nyear := length(unique(year)), by = .(regional, local)]
ddata <- ddata[nyear > 1L]
# delete lakes from counties (regional scale) where there is only one lake
ddata[, nlake := length(unique(local)), by = regional]
ddata <- ddata[nlake > 1L]

ddata[species == "No Vegetation Present" | species == "", species := NA_character_]

ddata[, ":="(
  dataset_id = dataset_id,

  metric = "pa",
  value = data.table::fifelse(is.na(species), 0L, 1L),
  unit = "pa",

  block = NULL,
  substrate = NULL,
  record_num = NULL,
  County_code = NULL,
  lake_name = NULL,
  survey_id = NULL,
  survey_date = NULL,
  sample_point_surveyed = NULL,
  depth_ft = NULL,
  secchi_ft = NULL,
  veg_code = NULL,
  vegetation_common_name = NULL,

  nyear = NULL,
  nlake = NULL
)]

ddata <- ddata[value > 0L]
ddata <- unique(ddata)

meta <- unique(ddata[, .(dataset_id, regional, local, year, alpha_grain)])
meta[, ":="(
  realm = "Freshwater",
  taxon = "Plants",

  latitude = 40L,
  longitude = -89L,

  effort = 1L,

  study_type = "ecological_sampling",

  data_pooled_by_authors = FALSE,

  alpha_grain_unit = "acres",
  alpha_grain_type = "lake_pond",
  alpha_grain_comment = "area of the lake given by the authors. The sampled area can be approximated with the number of rake samples per plot per lake per survey.",

  comment = "Extracted from Muthukrishnan and Larkin 2020 Dryad repo (https://datadryad.org/stash/dataset/doi:10.5061/dryad.15dv41nt2). Macrophytes from 212 lakes distributed in 50 US counties were sampled 1 to 11 years between 2002 and 2014. Regional is the county name and local the lake_id.",
  comment_standardisation = "Samples (rake) were pooled for each lake/year. Many lakes were sampled only once and excluded. Counties with only one lake were excluded too."
)]

# gamma scale
county_areas <- data.table::fread(paste0("data/raw data/", dataset_id, "/county_areas.csv"), skip = 1)
county_areas[, ":="(
  county = gsub(" County", "", county),
  area = as.numeric(gsub(",| .*", "", area))
)]

meta <- meta[unique(meta[, .(regional, local, year, alpha_grain)])[, .(gamma_sum_grains = sum(alpha_grain)), by = .(regional, year)], on = .(regional, year)]

meta[, ":="(
  gamma_bounding_box = county_areas$area[match(regional, county_areas$county)],
  gamma_bounding_box_unit = "mile2",
  gamma_bounding_box_type = "administrative",
  gamma_bounding_box_comment = "county area extracted from wikipedia with https://wikitable2csv.ggor.de/",

  gamma_sum_grains_unit = "acres",
  gamma_sum_grains_type = "lake_pond",
  gamma_sum_grains_comment = "sum of the areas of the lakes sampled each year"
)]

ddata[, alpha_grain := NULL]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
