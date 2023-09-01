dataset_id <- "countryside_survey_macrophytes_2017"

ddata <- base::readRDS(file = "data/raw data/countryside_survey_macrophytes_2017/rdata.rds")
data.table::setnames(ddata, old = "PROPORTION", new = "value")

#Raw Data ----
## community data  ----
ddata[, SURVEY_DATE := data.table::as.IDate(SURVEY_DATE, format = "%d-%b-%y")]
ddata[, ":="(month = data.table::month(SURVEY_DATE),
             day = data.table::mday(SURVEY_DATE))]

ddata[, ":="(
   dataset_id = dataset_id,

   metric = "cover",
   unit = "percent",

   YEAR = NULL,
   SITE_ID = NULL,
   SURVEY_DATE = NULL,
   LC07 = NULL,
   LC07_NUM = NULL,
   COUNTY07 = NULL
)]

##meta data ----
meta <- unique(ddata[, .(dataset_id, COUNTRY, regional, local, year, month, day)])
meta[, ":="(
   taxon = "Plants",
   realm = "Freshwater",

   study_type = "resurvey",

   data_pooled_by_authors = FALSE,

   latitude = c(52.3, 53, 57)[match(COUNTRY, c("WAL", "ENG", "SCO"))],
   longitude = c(-3.6, -1, -4)[match(COUNTRY, c("WAL", "ENG", "SCO"))],

   alpha_grain = 1L,
   alpha_grain_unit = "km2",
   alpha_grain_type = "plot",

   comment = "Extracted from 2 published Environmental Information Data Centre data sets, DOIs https://doi.org/10.5285/e0b638d5-8271-4442-97ef-cf46ea220f5d and https://doi.org/10.5285/249a90ec-238b-4038-a706-6633c3690d20. Authors sampled macrophytes in 1 100m long stream reaches per 1km2 grid cells in England, Scotland and Wales.",
   comment_standardisation = "regional is an ecoregion (eg Westerly lowlands (England), Uplands (Wales))
local is a SQUARE_ID.",
doi = 'https://doi.org/10.5285/249a90ec-238b-4038-a706-6633c3690d20 | https://doi.org/10.5285/e0b638d5-8271-4442-97ef-cf46ea220f5d'
)]

ddata[, COUNTRY := NULL]

## save data
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8"
)
data.table::fwrite(
   x = meta[, !"COUNTRY"],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8"
)

#standardised data ----
ddata[, c("month","day") := NULL]
ddata[, value := as.integer(value)][, ":="(
   value = 1L,

   metric = factor("pa"),
   unit = factor("pa")
)]


## meta data ----
meta[, c("month","day") := NULL]
meta[,":="(
   effort = 1L,

   gamma_sum_grains_unit = "km2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "sum of the plots per year per region",

   gamma_bounding_box = c(20779L, 130279L, 77933L)[match(COUNTRY, c("WAL", "ENG", "SCO"))],
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "administrative",
   gamma_bounding_box_comment = "ecological zone area is unknown so gamma has been set to the country",

   COUNTRY = NULL
)][, gamma_sum_grains := data.table::uniqueN(local), by = .(regional, year)]

##save data
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8"
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised_metadata.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8"
)
