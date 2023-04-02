dataset_id <- "countryside_survey_macrophytes_2017"

ddata <- data.table::rbindlist(list(
  `1998` = data.table::fread(file = "./data/raw data/countryside_survey_macrophytes_2017/e0b638d5-8271-4442-97ef-cf46ea220f5d/data/STREAM_MACROPHYTES_98.csv"),
  `2007` = data.table::fread(file = "./data/raw data/countryside_survey_macrophytes_2017/249a90ec-238b-4038-a706-6633c3690d20/data/STREAM_MACROPHYTES_07.csv")
),
use.names = TRUE, idcol = TRUE
)

#Raw Data ----
data.table::setnames(ddata, c(".id", "SQUARE", "EZ_DESC_07", "PLANT_NAME"), c("year", "local", "regional", "species"))


## community data  ----
ddata[, ":="(
  dataset_id = dataset_id,
  regional = stringi::stri_extract_first_regex(str = regional, pattern = "(?<=\\().*(?=\\))"),
  
  metric = "pa",
  unit = "pa",
  value = 1L,
  
  YEAR = NULL,
  SITE_ID = NULL,
  SURVEY_DATE = NULL,
  PROPORTION = NULL,
  LC07 = NULL,
  LC07_NUM = NULL,
  COUNTY07 = NULL,
  COUNTRY = NULL
)]

##meta data ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  taxon = "Plants",
  realm = "Freshwater",
  
  study_type = "resurvey",
  
  data_pooled_by_authors = FALSE,
  
  latitude = c(52.3, 53, 57)[match(regional, c("Wales", "England", "Scotland"))],
  longitude = c(-3.6, -1, -4)[match(regional, c("Wales", "England", "Scotland"))],
  
  alpha_grain = 1L,
  alpha_grain_unit = "km2",
  alpha_grain_type = "plot",
  
  comment = "Extracted from 2 published Environmental Information Data Centre data sets, DOIs https://doi.org/10.5285/e0b638d5-8271-4442-97ef-cf46ea220f5d and https://doi.org/10.5285/249a90ec-238b-4038-a706-6633c3690d20. Authors sampled macrophytes in 1 100m long stream reaches per 1km2 grid cells in England, Scotland and Wales.",
  comment_standardisation = "none needed"
)]

##save data 
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
                   row.names = FALSE
)

#Standardized data ----
##meta data ----
meta[,":="(
  effort = 1L,
  
  gamma_sum_grains_unit = "km2",
  gamma_sum_grains_type = "plot",
  gamma_sum_grains_comment = "sum of the plots per year per region",
  
  gamma_bounding_box = c(20779L, 130279L, 77933L)[match(regional, c("Wales", "England", "Scotland"))],
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "administrative",
  gamma_bounding_box_comment = "ecological zone area is unknown so gamma has been set to the country"
)][, gamma_sum_grains := length(unique(local)), by = .(regional, year)]

##save data 
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized_metadata.csv"),
                   row.names = FALSE
)
