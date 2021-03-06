## lindholm_2019
dataset_id <- "lindholm_2019"


ddata <- base::readRDS("./data/raw data/lindholm_2019/ddata.rds")
data.table::setnames(ddata, 1L, "localyear")

# melting species
ddata <- data.table::melt(ddata,
  id.vars = "localyear",
  variable.name = "species"
)
ddata <- ddata[value != 0L]

# splitting site and period
ddata[, c("local", "year") := data.table::tstrsplit(localyear, "(?<=[a-z])(?=[0-9])", perl = TRUE)]

# species names: replacement of the abbreviations
specieslong <- base::readRDS(file = "./data/raw data/lindholm_2019/specieslong.rds")

ddata[, ":="(
  dataset_id = dataset_id,
  regional = base::enc2utf8("Kokemäenjoki watershed"),

  year = c(1950L, 1978L, 1993L, 2008L, 2017L)[data.table::chmatch(data.table::fifelse(year %in% c("40", "70", "90"), paste0("19", year), paste0("20", year)), c("1940","1970","1990","2000","2010"))],

  species = base::enc2utf8(specieslong$Species.name[match(species, specieslong$Abbreviation)]),
  metric = "pa",
  unit = "pa",

  localyear = NULL
)]

## coordinates - loading and conversion
env <- base::readRDS(file = "./data/raw data/lindholm_2019/env.rds")

data.table::setnames(env, c("V1", "X", "Y", "Area"), c("localyear", "longitude", "latitude", "alpha_grain"))
env[, c("local", "year") := data.table::tstrsplit(localyear, "(?<=[a-z])(?=[0-9])", perl = TRUE)][, year := c(1950L, 1978L, 1993L, 2008L, 2017L)[data.table::chmatch(data.table::fifelse(year %in% c("40", "70", "90"), paste0("19", year), paste0("20", year)), c("1940","1970","1990","2000","2010"))]]
sp::coordinates(env) <- ~ longitude + latitude
sp::proj4string(env) <- sp::CRS(SRS_string = "EPSG:5048") # ETRS-TM35FIN
env <- sp::spTransform(env, sp::CRS(SRS_string = "EPSG:4326"))

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta <- merge(meta, env[, c("local", "year", "alpha_grain")])
meta[, ":="(
  realm = "Freshwater",
  taxon = "Plants",

  latitude = sp::coordinates(env)[match(local, env$local), "latitude"],
  longitude = sp::coordinates(env)[match(local, env$local), "longitude"],

  effort = 1L,
  study_type = "ecological_sampling",

  data_pooled_by_authors = TRUE,
  data_pooled_by_authors_comment = "lakes were sampled once per period",
  sampling_years = c("1947-1950", "1975-1978", "1991-1993","2005-2008", "2017")[match(year, c(1950L, 1978L, 1993L, 2008L, 2017L))],

  alpha_grain_unit = "ha",
  alpha_grain_type = "lake_pond",
  alpha_grain_comment = "areas provided by the authors in the Dryad repo",

  gamma_sum_grains = sum(alpha_grain),
  gamma_sum_grains_unit = "ha",
  gamma_sum_grains_type = "lake_pond",
  gamma_sum_grains_comment = "sum of the areas of the lakes given by the authors",

  gamma_bounding_box = 27100L,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "watershed",

  comment = "Extracted from Dryad (https://doi.org/10.5061/dryad.t1g1jwsxv). The authors sampled macrophytes from 27 boreal lakes from a Finnish watershed during the 1940s, 1970s, 1990s, 2000s and 2010s. Effort depends on the lake size: the whole lakes have been sampled at each survey and size varies from 2 10E-1 to 2 10E2.",
  comment_standardisation = "none needed"

)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)

data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
