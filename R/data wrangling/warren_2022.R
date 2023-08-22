dataset_id <- "warren_2022"

ddata <- base::readRDS("data/raw data/warren_2022/rdata1.rds")
spatial <- base::readRDS("data/raw data/warren_2022/rdata2.rds")

#remove duplicated entries in ddata
ddata <- unique(ddata)
#unique site-code entries in spatial data
spatial <- unique(spatial, by = "site_code")
#combine spatial and observational data
ddata[spatial, ":="(regional = location_type, latitude = i.lat, longitude = i.long), on = "site_code"]

# data preparation ----
data.table::setnames(
   x = ddata,
   old = c("site_code", "common_name", "bird_count"),
   new = c("local", "species", "value")
)

ddata[, survey_date := data.table::as.IDate(survey_date)][, ":="(
   year = data.table::year(survey_date),
   month = data.table::month(survey_date),
   day = data.table::mday(survey_date)
)]

# Raw data ----
## community data ----
# many duplicated rows after deletion of columns due to identifying information in deleted columns
# in standardised data the sum is build of duplicated rows for summing values for different distance, direction and  detection  method and
ddata <- ddata[!is.na(value)]

ddata[, ":="(
   dataset_id = dataset_id,

   metric = "abundance",
   unit = "count",

   local = paste(local, observer, distance, seen, heard, direction, time_start, time_end, sep = "_"),

   survey_id = NULL,
   survey_date = NULL,
   time_start = NULL,
   time_end = NULL,
   code = NULL,
   distance = NULL,
   observation_notes = NULL,
   seen = NULL,
   heard = NULL,
   direction = NULL,
   qccomment = NULL
)][, ":="(
   latitude = mean(latitude),
   longitude = mean(longitude)),
   by = .(regional, local)]

# pooling observations ----
ddata <- ddata[,
               .(value = sum(value)),
               by = .(dataset_id, regional, local, latitude, longitude,
                      year, month, day, observer, species, metric, unit)]

## meta ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, month, day, latitude, longitude)])
meta[, ":="(
   taxon = "Birds",
   realm = "Terrestrial",

   study_type = "ecological_sampling", #two possible values, or NA if not sure

   data_pooled_by_authors = FALSE,

   alpha_grain = 150L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "listening_point",
   alpha_grain_comment = "Open Radius sampling of birds seen or heard",

   comment = "Long term bird survey of greater Phoenix metropolitan area. Each bird survey location is visited independently by three birders who count all birds seen or heard within a 15-minute window. The frequency of surveys has varied through the life of the project. The first year of the project (2000) was generally a pilot year in which each site was visited approximately twice by a varying number of birders. The monitoring became more formalized beginning in 2001, and each site was visited in each of four seasons by three birders. The frequency of visits was reduced to three seasons in 2005, and to two season (spring, winter) beginning in 2006.",
   comment_standardisation = "local is built as site_code, observer, distance, seen, heard, direction, time_start, time_end",
   doi = 'https://doi.org/10.6073/pasta/1d54aead11fc7ccf43e889fe1863aa81'
)]


## save data sets----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata[, !c("observer", "longitude", "latitude")],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)

# Standardised Data ----

## Removing sector name from local column ----
ddata[, local := sub("_.*$", "", local, FALSE, TRUE)]
meta[, local := sub("_.*$", "", local, FALSE, TRUE)]

## effort standardisation ----
# When one site as sampled twice in the same day by two different observers, delete the day
ddata <- ddata[
   !ddata[, data.table::uniqueN(observer), by = .(regional, local, year,month, day)][V1 != 1L],
   on = .(regional, local, year,month, day)
][, observer := NULL]

ddata <- ddata[
   !ddata[(regional == "ESCA" | regional == "riparian") & month == "12" & year == "2003"],
   on = c("year", "regional", "local")]

## When a site is sampled several times a year, selecting the 3 most frequently sampled month from the 4 sampled months ----
month_order <- ddata[, data.table::uniqueN(day), by = .(local, month)][, sum(V1), by = month][order(-V1)]
ddata[, month_order := (1L:4L)[match(month, month_order, nomatch = NULL)]]
data.table::setkey(ddata, month_order)

# Some years have less than 3 months so these year/local have to be excluded
ddata <- ddata[
   !ddata[, data.table::uniqueN(month), by = .(regional, local, year)][V1 < 3L],
on = .(regional, local, year)]

ddata <- ddata[
   unique(ddata[, .(regional, local, year, month)])[, .SD[1L:3L], by = .(regional, local, year)],
   on = .(regional, local, year, month)][, month_order := NULL]

## When a site is sampled twice a month, selecting the first visit ----
ddata <- ddata[
   unique(ddata[, .(regional, local, year, month, day)])[, .SD[1L], by = .(regional, local, year, month)],
   on = .(regional, local, year, month, day)][, month := NULL][, day := NULL]

### Pooling all samples from a year together ----
ddata[, ":="(latitude = mean(latitude), longitude = mean(longitude)), by = .(regional, local)]
ddata <- ddata[, .(value = sum(value)),
               by = .(dataset_id, regional, local, latitude, longitude, year, species, metric, unit)]

# meta ----
meta[, c("month","day","latitude","longitude") := NULL]
meta <- unique(meta)
meta <- meta[
   unique(ddata[, .(regional, local, latitude, longitude, year)]),
   on = .(regional, local, year)]

meta[, ":="(
   effort = 1L,

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "box",
   gamma_bounding_box_comment = "",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "sampled area per year",

   comment_standardisation = "reducing dataset to one sampling event per year in same season. reducing to one observer per sampling event per year. removing NA in bird_count. Summing bird_counts for different direction, condition and distance to one abundance value"
)][, ":="(
   gamma_sum_grains = sum(alpha_grain),
   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6
), by = .(year, regional)]

ddata[, c("latitude","longitude") := NULL]

##save data sets ----
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised_metadata.csv"),
   row.names = FALSE
)

