# countryside_survey_invertebrates
dataset_id <- "countryside_survey_invertebrates_2017"

ddata <- data.table::rbindlist(list(
  `1990` = data.table::fread(file = "./data/raw data/countryside_survey_invertebrates_2017/b4c17f35-1b50-4ed7-87d2-b63004a96ca2/data/STREAM_INVERT_TAXA_90.csv"),
  `1998` = data.table::fread(file = "./data/raw data/countryside_survey_invertebrates_2017/fd0ce233-3b4d-4a5e-abcb-c0a26dd71c95/data/STREAM_INVERT_TAXA_98.csv"),
  `2007` = data.table::fread(file = "./data/raw data/countryside_survey_invertebrates_2017/18849325-358b-4af1-b20d-d750b1c723a3/data/STREAM_INVERT_TAXA_07.csv")
),
fill = TRUE, use.names = TRUE, idcol = FALSE
)

data.table::setnames(ddata, c("YEAR", "SQUARE", "EZ_DESC_07", "NAME"), c("year", "local", "regional", "species"))


# 1 visit per square per year.
# 1 site per plot per year

# CLEANING SPECIES NAMES
ddata <- ddata[!grepl("ae$", species)]

# Ddata ----
ddata[, ":="(
  dataset_id = dataset_id,
  regional = stringi::stri_extract_first_regex(str = regional, pattern = "(?<=\\().*(?=\\))"),



  metric = "pa",
  unit = "pa",
  value = 1L,

  SITE_ID = NULL,
  SPECIES_CODE = NULL,
  LC07 = NULL,
  LC07_NUM = NULL,
  COUNTRY = NULL,
  COUNTY07 = NULL,
  ABUNDANCE = NULL,
  SAMPLE_DATE = NULL
)]

# Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])

meta[, ":="(
  taxon = "Invertebrates",
  realm = "Freshwater",

  effort = 1L,

  study_type = "resurvey",

  data_pooled_by_authors = FALSE,

  latitude = c(52.3, 53, 57)[match(regional, c("Wales", "England", "Scotland"))],
  longitude = c(-3.6, -1, -4)[match(regional, c("Wales", "England", "Scotland"))],

  alpha_grain = 1L,
  alpha_grain_unit = "km2",
  alpha_grain_type = "plot",

  gamma_sum_grains_unit = "km2",
  gamma_sum_grains_type = "plot",
  gamma_sum_grains_comment = "sum of the plots per year per region",

  gamma_bounding_box = c(20779L, 130279L, 77933L)[match(regional, c("Wales", "England", "Scotland"))],
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "administrative",
  gamma_bounding_box_comment = "ecological zone area is unknown so gamma has been set to the country",

  comment = "Extracted from 3 published Environmental Information Data Centre data sets, DOIs https://doi.org/10.5285/18849325-358b-4af1-b20d-d750b1c723a3 ,  https://doi.org/10.5285/fd0ce233-3b4d-4a5e-abcb-c0a26dd71c95 , https://doi.org/10.5285/b4c17f35-1b50-4ed7-87d2-b63004a96ca2 . Authors sampled invertebrates in streams located in 1km2 grid cells in England, Scotland and Wales. Effort: Each square was sampled only once a year. Each Square was sampled in only one site_id. Effort could be more accurately measured by using the sampling time given in the environment table. alpha grain could be more precisely computed by multiplying river width in the environment table by 5-15m, the length of stream typically sampled.",
  comment_standardisation = "Abundances from 2007 were turned into presence absence. Family level taxa were excluded."
)][, gamma_sum_grains := length(unique(local)), by = .(regional, year)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
