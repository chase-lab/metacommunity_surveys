dataset_id <- 'rennie_2017_carabids'

ddata <- base::readRDS(file = "data/raw data/rennie_2017_carabids/rdata.rds")
data.table::setnames(x = ddata,
                     new = c('regional','plot','date','local','value','species'))

# Raw data ----
## Community data ----
ddata[, date := data.table::as.IDate(date, format = '%d-%b-%y')]

## Pooling individuals from the same trap and day ----
ddata <- ddata[, .(value = sum(value)),
          by = .(regional, plot, local, date, species)]

ddata[, ":="(
   dataset_id = dataset_id,

   local = as.factor(paste(plot, local, sep = '_')),

   year  = data.table::year(date),
   month = data.table::month(date),
   day   = data.table::mday(date),

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

# metadata ----
meta <- unique(ddata[, .(dataset_id, regional, plot, local, year, month, day)])
meta[coords,
     ":="(latitude = i.latitude, longitude = i.longitude),
     on = 'regional']

meta[, ":="(
   taxon = "Invertebrates",
   realm = "Terrestrial",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,
   data_pooled_by_authors_comment = NA,
   sampling_years = NA,

   alpha_grain = 5 * pi * (7.5 / 2) ^ 2,
   alpha_grain_unit = "cm2",
   alpha_grain_type = "sample",
   alpha_grain_comment = "aperture of the pitfall traps * 5 samples per year",

   comment = "Data were downloaded from https://doi.org/10.5285/8385f864-dd41-410f-b248-028f923cb281. Authors assessed Carabid community composition with pitfall traps. The local scale is a pitfall trap and its name is constituted as LCODE_TRAP. Site coordinates were extracted from IG_dataStructure.rtf found in the Supporting documentation.",
   comment_standardisation = "none needed",
   doi = 'https://doi.org/10.5285/8385f864-dd41-410f-b248-028f923cb281'
)]

## Saving raw data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata[value != 0L & !species %in% c('XX', '', 'UU'), !c("date","plot")],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8"
)
data.table::fwrite(
   x = meta[unique(ddata[value != 0L & !species %in% c('XX', '', 'UU'), .(regional, local, year)]), on = .(regional, local, year), !"plot"],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8"
)

# Standardised data ----
# Standardisation ----
## When a site is sampled several times a year, selecting the 5 most frequently sampled months from the 6 most sampled months ----
ddata[, month_order := (1L:6L)[match(month, c(6L, 7L, 10L, 9L, 8L, 5L), nomatch = NULL)]]
data.table::setkey(ddata, month_order)

ddata <- ddata[!is.na(month_order)]
ddata[, nmonths := data.table::uniqueN(month), by = .(regional, local, year)]
ddata <- ddata[nmonths >= 5L][, nmonths := NULL]

ddata <- ddata[
   unique(ddata[, .(regional, plot, local, year, month)])[, .SD[1L:5L], by = .(regional, plot, local, year)],
   on = .(regional, plot, local, year, month)][, month_order := NULL]

## When a site is sampled 2+ a month, selecting the first visit ----
ddata <- ddata[
   unique(ddata[, .(regional, plot, local, year, month, date)])[, .SD[1L], by = .(regional, plot, local, year, month)],
   on = .(regional, plot, local, year, month, date)
][, date := NULL][, month := NULL][, day := NULL]

## Pooling all 5 samples from a year together ----
ddata <- ddata[, .(value = sum(value)), by = .(dataset_id, regional, plot, local, year, metric, unit, species)]

## removing empty traps ----
ddata <- ddata[value != 0L & !species %in% c('XX', '', 'UU')]

## Keeping only sites sampled at least twice 10 years apart ----
ddata <- ddata[
   !ddata[, diff(range(year)), by = .(regional, local)][(V1 < 9L)],
   on = .(regional, local)
]

## Metadata ----
meta[, c("month","day") := NULL]
meta <- unique(meta[
   unique(ddata[, .(regional, plot, local, year)]),
   on = .(regional, plot, local, year)]
)

meta[, ":="(
   effort = 5L,

   gamma_sum_grains_unit = "cm2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "trap area * nb traps per site per year",

   gamma_bounding_box_unit = "m2",
   gamma_bounding_box_type = "ecosystem",
   gamma_bounding_box_comment = "sum of the area of the 90m long transects of a site on a given year",

   comment_standardisation = "Keeping only sites sampled at least twice 10 years apart.
When a site is sampled several times a year, selecting the 5 most frequently sampled months from the 6 most sampled months.
When a site is sampled 2+ a month, selecting the first visit.
Pooling all 5 samples from a year together.
Removing empty traps."
)][, ":="(
   gamma_sum_grains = sum(alpha_grain),
   gamma_bounding_box = data.table::uniqueN(plot) * 90L * 1L),
   by = .(regional, year)][, plot := NULL]

ddata[, plot := NULL]

## Saving standardised data ----
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
