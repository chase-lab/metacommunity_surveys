# countryside_survey_invertebrates
dataset_id <- "countryside_survey_invertebrates_2017"
ddata <- base::readRDS(file = "data/raw data/countryside_survey_invertebrates_2017/rdata.rds")

ddata[, date := data.table::as.IDate(date, format = "%d-%b-%y")]
ddata[, ":="(month = data.table::month(date),
             day = data.table::mday(date))]

# Raw Data ----
## community data ----
ddata[, ":="(
   dataset_id = dataset_id,

   metric = "abundance",
   unit = "count",

   SITE_ID = NULL,
   SPECIES_CODE = NULL,
   LC07 = NULL,
   LC07_NUM = NULL,
   COUNTY07 = NULL,
   date = NULL
)]

## Meta data ----
meta <- unique(ddata[, .(dataset_id, COUNTRY, regional, local, year, month, day)])

meta[, ":="(
   taxon = "Invertebrates",
   realm = "Freshwater",

   study_type = "resurvey",

   data_pooled_by_authors = FALSE,

   latitude = c(52.3, 53, 57)[match(COUNTRY, c("WAL", "ENG", "SCO"))],
   longitude = c(-3.6, -1, -4)[match(COUNTRY, c("WAL", "ENG", "SCO"))],

   alpha_grain = 1L,
   alpha_grain_unit = "km2",
   alpha_grain_type = "plot",

   comment = "Extracted from 3 published Environmental Information Data Centre data sets, DOIs https://doi.org/10.5285/18849325-358b-4af1-b20d-d750b1c723a3 ,  https://doi.org/10.5285/fd0ce233-3b4d-4a5e-abcb-c0a26dd71c95 , https://doi.org/10.5285/b4c17f35-1b50-4ed7-87d2-b63004a96ca2 . Authors sampled invertebrates in streams located in 1km2 grid cells in England, Scotland and Wales. Effort: Each square was sampled only once a year. Each Square was sampled in only one site_id. Effort could be more accurately measured by using the sampling time given in the environment table. alpha grain could be more precisely computed by multiplying river width in the environment table by 5-15m, the length of stream typically sampled.",
   comment_standardisation = "none needed",
   doi = 'https://doi.org/10.5285/18849325-358b-4af1-b20d-d750b1c723a3 | https://doi.org/10.5285/b4c17f35-1b50-4ed7-87d2-b63004a96ca2 | https://doi.org/10.5285/fd0ce233-3b4d-4a5e-abcb-c0a26dd71c95'
)]

ddata[, COUNTRY := NULL]

##save data ----
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
##community data ----
ddata[, c("month", "day") := NULL]
ddata <- ddata[
   !ddata[is.na(value)],
   on = .(regional, local, year)
]

## Excluding sites that were not sampled at least twice 10 years apart ----
ddata <- ddata[!ddata[, diff(range(year)) < 9L, by = .(regional, local)][(V1)],
               on = .(regional, local)]

### cleaning species names? ----
# ddata[, sum(grepl("ae$", species)) / data.table::uniqueN(species), by = .(regional, local, year)]

##meta data ----
meta[, c("month", "day") := NULL]
meta <- meta[
   unique(ddata[, .(regional, local, year)]),
   on = .(regional, local, year)
]

meta[,":="(
   effort = 1L,

   gamma_sum_grains_unit = "km2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "sum of the plots per year per region",

   gamma_bounding_box = c(20779L, 130279L, 77933L)[match(COUNTRY, c("WAL", "ENG", "SCO"))],
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "administrative",
   gamma_bounding_box_comment = "ecological zone area is unknown so gamma has been set to the country",

   comment_standardisation = "Samples with NA abundance values were excluded.
Sites that were not sampled at least twice 10 years apart were excluded.",

   COUNTRY = NULL
)][, gamma_sum_grains := sum(alpha_grain), by = .(regional, year)]

##save data ----
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
