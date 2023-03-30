## muthukrishnan_2019

dataset_id <- "muthukrishnan_2019"
ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))

data.table::setnames(
  ddata,
  c("survey_year", "county", "lake_id", "Lake_acres", "sample_point_num", "vegetation_scientific_name"),
  c("year", "regional", "local", "alpha_grain", "rake", "species")
)
data.table::setkey(ddata, regional, local, year)

# Standardisation ----
ddata <- ddata[species != "No Vegetation Present" &
                  species != "" &
                  sample_point_surveyed == "yes"]

## standardising the number of surveys per year: 1 ----
set.seed(42)
ddata <- ddata[ddata[, .(survey_id = sample(survey_id, 1L)), by = .(regional, local, year)], on = .(regional, local, year, survey_id)]

## delete lakes that were sampled only one year ----
ddata <- ddata[ddata[, .(nyear = length(unique(year))), by = .(regional, local)], on = .(regional, local)]

## delete lakes from counties (regional scale) where there is only one lake ----
# ddata <- ddata[ddata[, length(unique(survey_id)), by = .(regional, year)][(V1 >= 4L)], on = .(regional, year)]

## randomly subsampling an equal number of rakes in all lakes ----
min_rake_number <- 6L
ddata <- ddata[ # data.table style join
   ddata[, .(n_rake_samples = length(unique(rake))), by = .(regional, local, year)][n_rake_samples >= min_rake_number, .(regional, local, year)],
   on = .(regional, local, year)]

set.seed(42)
ddata <- unique(ddata[ # data.table style join
   ddata[, .(rake = sample(rake, min_rake_number, replace = FALSE)), by = .(regional, local, year)],
   on = .(regional, local, rake, year)
][,
  .(regional, local, year, species)]
)

# Community data ----
ddata[, ":="(
  dataset_id = dataset_id,

  value = 1L,
  metric = "pa",
  unit = "pa"
)]

# Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  realm = "Freshwater",
  taxon = "Plants",

  latitude = 40L,
  longitude = -89L,

  effort = min_rake_number,

  study_type = "ecological_sampling",

  data_pooled_by_authors = FALSE,

  alpha_grain = .7,
  alpha_grain_unit = "m2",
  alpha_grain_type = "sample",
  alpha_grain_comment = "area of one rake sample",

  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "sample",
  gamma_sum_grains_comment = "sum of the areas of rake samples each year",

  comment = "Extracted from Muthukrishnan and Larkin 2020 Dryad repo (https://datadryad.org/stash/dataset/doi:10.5061/dryad.15dv41nt2). Macrophytes from 212 lakes distributed in 50 US counties were sampled 1 to 11 years between 2002 and 2014. Regional is the county name and local the lake_id.",
  comment_standardisation = "Some lakes were sampled more than 1 time a year and a single survey was randomly selected. Empty samples were excluded. Sample based standardisation: Lakes with less than 6 rake samples were excluded and other lakes had 6 rake samples randomly selected and then pooled together."
)][, gamma_sum_grains := sum(alpha_grain), by = .(regional, year)]

# gamma scale
county_areas <- data.table::fread(paste0("data/raw data/", dataset_id, "/county_areas.csv"), skip = 1)
county_areas[, ":="(
  county = gsub(" County", "", county),
  area = as.numeric(gsub(",| .*", "", area))
)]

meta[, ":="(
  gamma_bounding_box = county_areas$area[match(regional, county_areas$county)],
  gamma_bounding_box_unit = "mile2",
  gamma_bounding_box_type = "administrative",
  gamma_bounding_box_comment = "county area extracted from wikipedia with https://wikitable2csv.ggor.de/"
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
