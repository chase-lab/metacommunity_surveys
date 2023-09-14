dataset_id <- 'rennie_2017_bats'

ddata <- base::readRDS(file = "data/raw data/rennie_2017_bats/rdata.rds")
data.table::setnames(ddata,
                     new = c('regional', 'date', 'local', 'species', 'value'))
# Raw data ----
## Community data ----
ddata[, date := data.table::as.IDate(date, format = '%d-%b-%y')]

## Pooling individuals from the same point and day ----
ddata <- ddata[, .(value = sum(value)),
               by = .(regional, local, date, species)]

ddata[, ":="(
   dataset_id = dataset_id,

   year  = data.table::year(date),
   month = data.table::month(date),
   day = data.table::mday(date),

   metric = "abundance",
   unit = "count"
)]

# Coordinates ----
coords <- data.table::as.data.table(matrix(
   dimnames = list(c(), c('regional', 'regional_name', 'latitude', 'longitude')),
   byrow = TRUE, ncol = 4L, data = c(
      'T01', 'Drayton', '52°11`37.95"N','1°45`51.95"W',
      'T02', 'Glensaugh', '56°54`33.36"N', '2°33`12.14"W',
      'T03', 'Hillsborough', '54°27`12.24"N', '6° 4`41.26"W',
      'T04', 'Moor House – Upper Teesdale', '54°41`42.15"N', '2°23`16.26"W',
      'T05', 'North Wyke', '50°46`54.96"N', '3°55`4.10"W',
      'T06', 'Rothamsted', '51°48`12.33"N', '0°22`21.66"W',
      'T07', 'Sourhope', '55°29`23.47"N', '2°12`43.32"W',
      'T08', 'Wytham', '51°46`52.86"N', '1°20`9.81"W',
      'T09', 'Alice Holt', '51° 9`16.46"N', '0°51`47.58"W',
      'T10', 'Porton Down', '51° 7`37.83"N', '1°38`23.46"W',
      'T11', 'Y Wyddfa – Snowdon', '53° 4`28.38"N', '4° 2`0.64"W',
      'T12', 'Cairngorms', '57° 6`58.84"N', '3°49`46.98"W')
))

## metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, month, day)])
meta[coords,
     ":="(latitude = i.latitude, longitude = i.longitude),
     on = 'regional']

meta[, ":="(
   taxon = "Invertebrates",
   realm = "Terrestrial",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   latitude = parzer::parse_lat(latitude),
   longitude = parzer::parse_lon(longitude),

   alpha_grain = .5 * 3,
   alpha_grain_unit = "km2",
   alpha_grain_type = "plot",
   alpha_grain_comment = "half of a 1km2 square samplesd 3 times",

   comment = "Data were downloaded from https://doi.org/10.5285/2588ee91-6cbd-4888-86fc-81858d1bf085. Authors assessed bat communities by walking along two parallel 1km transects inside a 1km square several times a year. Local scale is a TRANSECT. regional coordinates were found in the Supporting documentation",
   comment_standardisation = "none needed",
   doi = 'https://doi.org/10.5285/2588ee91-6cbd-4888-86fc-81858d1bf085'
)]

## Saving raw data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata[value != 0L, !"date"],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta[unique(ddata[value != 0L, .(regional, local, year)]), on = .(regional, local, year)],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)

# Standardised data ----
# Standardisation ----

## Selecting the first visit per month ----
ddata[, ndates := length(unique(date)), by = .(regional, year, local, month)]

data.table::setkeyv(ddata, c('regional', 'year', 'local', 'month', 'date'))
ddata <- ddata[
   ddata[, .(regional, local, year, month, date)][, .SD[1L], by = .(regional, local, year, month)],
   on = .(regional, local, year, month, date)
]

## When a site is sampled several times a year, selecting the 3 most frequently sampled months from the 4 sampled months ----
ddata[, month_order := (1L:4L)[match(month, c(7L, 8L, 6L, 9L), nomatch = NULL)]]
data.table::setkey(ddata, month_order)

ddata <- ddata[!is.na(month_order)][, nmonths := data.table::uniqueN(month), by = .(regional, local, year)
][nmonths >= 3L][, nmonths := NULL]

ddata <- ddata[
   unique(ddata[, .(regional, local, year, month)])[, .SD[1L:3L], by = .(regional, local, year)],
   on = .(regional, local, year, month)][, month_order := NULL]

## Pooling all 3 samples from a year together ----
ddata <- ddata[, .(value = sum(value)), by = .(dataset_id, regional, local, year, metric, unit, species)]

## removing surveys with no observation ----
ddata <- ddata[value != 0L]

## Selecting sites/regions sampled at least 10 years apart ----
ddata <- ddata[
   !ddata[, diff(range(year)), by = .(regional, local)][(V1 < 9L)],
   on = .(regional, local)
]

## Metadata ----
meta[, c("month","day") := NULL]
meta <- unique(meta)
meta <- meta[
   unique(ddata[, .(regional, local, year)]),
   on = .(regional, local, year)]

meta[, ":="(
   effort = 3L,

   gamma_sum_grains_unit = "km2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "sum of the areas of the transects in a region/site and for one year",

   gamma_bounding_box = 1L,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "box",
   gamma_bounding_box_comment = "area of a sampling square",

   comment_standardisation = "Selecting the first visit per month
When a site is sampled several times a year, selecting the 3 most frequently sampled months from the 4 sampled months.
Pooling all 3 samples from a year together.
removing surveys with no observation.
removing surveys that were not sampled at least twice 10 years apart."
)][, gamma_sum_grains := sum(alpha_grain), by = year]

## Saving standardised data ----
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
