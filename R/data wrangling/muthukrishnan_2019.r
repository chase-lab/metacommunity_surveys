## muthukrishnan_2019

dataset_id <- "muthukrishnan_2019"
ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))

#Raw data ----
data.table::setnames(
  ddata,
  c("survey_year", "county", "lake_id", "Lake_acres", "sample_point_num", "vegetation_scientific_name"),
  c("year", "regional", "local", "alpha_grain", "rake", "species")
)
data.table::setkey(ddata, regional, local, year)

## exlcude unknown species and unsurveyed sample points  ----
ddata <- ddata[species != "No Vegetation Present" &
                 species != "" &
                 sample_point_surveyed == "yes"]


##community data ----
ddata[, ":="(
  dataset_id = dataset_id,
  
  value = 1L,
  metric = "pa",
  unit = "pa"
)]

##meta data ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  realm = "Freshwater",
  taxon = "Plants",
  
  latitude = 40L,
  longitude = -89L,
  
  study_type = "ecological_sampling",
  
  data_pooled_by_authors = FALSE,
  
  alpha_grain = .7,
  alpha_grain_unit = "m2",
  alpha_grain_type = "sample",
  alpha_grain_comment = "area of one rake sample",
  
  comment = "Extracted from Muthukrishnan and Larkin 2020 Dryad repo (https://datadryad.org/stash/dataset/doi:10.5061/dryad.15dv41nt2). Macrophytes from 212 lakes distributed in 50 US counties were sampled 1 to 11 years between 2002 and 2014. Regional is the county name and local the lake_id.",
  comment_standardisation = "unknown species excluded, sample_point_surveyed = no excluded",
  doi = 'https://doi.org/10.5061/dryad.15dv41nt2 | https://doi.org/10.1111/geb.13053'
)]

##save data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
deleted_columns <- c("County_code", "record_num", "lake_name", "alpha_grain","survey_id","survey_date", "rake", "sample_point_surveyed","depth_ft","secchi_ft","substrate","veg_code","vegetation_common_name")

data.table::fwrite(
  x = ddata[, !..deleted_columns],
  file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
  row.names = FALSE
)

data.table::fwrite(
  x = meta,
  file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
  row.names = FALSE
)

#Standardized data ----

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
  .(regional, local, year, species, dataset_id, value, metric, unit)]
)

##meta data ----
meta <- meta[unique(ddata[, .(dataset_id, local, regional, year)]),
             on = .(local, regional, year)]

meta[,":="(
  effort = min_rake_number,
  
  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "sample",
  gamma_sum_grains_comment = "sum of the areas of rake samples each year",
  
  comment_standardisation = "Some lakes were sampled more than 1 time a year and a single survey was randomly selected. Empty samples were excluded. Sample based standardisation: Lakes with less than 6 rake samples were excluded and other lakes had 6 rake samples randomly selected and then pooled together."
)][, gamma_sum_grains := sum(alpha_grain), by = .(regional, year)]

## gamma scale ----
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

##save data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
  x = ddata,
  file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized.csv"),
  row.names = FALSE
)

data.table::fwrite(
  x = meta,
  file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized_metadata.csv"),
  row.names = FALSE
)
