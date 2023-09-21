dataset_id <- 'rennie_2017_butterflies'

ddata <- base::readRDS(file = "data/raw data/rennie_2017_butterflies/rdata.rds")
data.table::setnames(ddata, c('regional','plot','date','local','value','species'))

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
   day = data.table::mday(date),

   metric = "abundance",
   unit = "count",

   plot = NULL
)]

# Coordinates ----
coords <- data.table::as.data.table(matrix(
   dimnames = list(c(), c("regional", "regional_name", "latitude", "longitude")),
   byrow = TRUE, ncol = 4L, data = c(
      "T01", "Drayton", "52°11`37.95'N","1°45`51.95'W",
      "T02", "Glensaugh", "56°54`33.36'N", "2°33`12.14'W",
      "T03", "Hillsborough", "54°27`12.24'N", "6° 4`41.26'W",
      "T04", "Moor House – Upper Teesdale", "54°41`42.15'N", "2°23`16.26'W",
      "T05", "North Wyke", "50°46`54.96'N", "3°55`4.10'W",
      "T06", "Rothamsted", "51°48`12.33'N", "0°22`21.66'W",
      "T07", "Sourhope", "55°29`23.47'N", "2°12`43.32'W",
      "T08", "Wytham", "51°46`52.86'N", "1°20`9.81'W",
      "T09", "Alice Holt", "51° 9`16.46'N", "0°51`47.58'W",
      "T10", "Porton Down", "51° 7`37.83'N", "1°38`23.46'W",
      "T11", "Y Wyddfa – Snowdon", "53° 4`28.38'N", "4° 2`0.64'W",
      "T12", "Cairngorms", "57° 6`58.84'N", "3°49`46.98'W")
))

# metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, month, day)])
meta[coords,
     ":="(latitude = i.latitude, longitude = i.longitude),
     on = 'regional']

meta[, ":="(
   taxon = "Invertebrates",
   realm = "Terrestrial",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = 2000L / 15L * 5L * 12L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "transect",
   alpha_grain_comment = "average length of a section * width of the transect * nb of surveys each year",

   comment = "Data were downloaded from https://doi.org/10.5285/5aeda581-b4f2-4e51-b1a6-890b6b3403a3. Authors assessed butterfly communities along fixed transects. Each 1-2km long transect was split in up to 15 fixed sections based on habitats. Local scale is a section and it's name is built as LCODE_SECTION, LCODE being the code of a transect. Site coordinates were extracted from IB_DATA_STRUCTURE.rtf found in the Supporting documentation.",
   comment_standardisation = "none needed",
   doi = 'https://doi.org/10.5285/5aeda581-b4f2-4e51-b1a6-890b6b3403a3'
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

## Standardisation ----
data.table::setkeyv(ddata, c('regional', 'year', 'local', 'month', 'date'))
### When a section is sampled 2+ a month, selecting the first 2 visits ----
ddata[, ndates := data.table::uniqueN(date), by = .(regional, year, local, month)]

ddata <- ddata[
   unique(ddata[ndates >= 2L, .(regional, local, year, month, date)])[, .SD[1L:2L], by = .(regional, local, year, month)],
   on = .(regional, local, year, month, date)
]#[, month := NULL][, date := NULL]

### When a site is sampled several times a year, selecting the 6 most frequently sampled months: April to September ----
#table(unique(ddata[, .(regional, local, plot, date, month, year)])$month)
ddata <- ddata[month %in% 4L:9L]

### Keeping sites sampled all 6 months ----
ddata <- ddata[, nmonths := data.table::uniqueN(month), by = .(regional, local, year)
][nmonths == 6L][, nmonths := NULL]

### Pooling all 12 samples from a year together ----
ddata <- ddata[, .(value = sum(value)), by = .(dataset_id, regional, local, year,
                                               metric, unit, species)]

### removing surveys with no observation ----
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
   effort = 12L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of the areas of the sections for one site and for one year",

   comment_standardisation = "When a section is sampled 2+ a month, selecting the first 2 visits
When a site is sampled several times a year, selecting the 6 most frequently sampled months: April to September.
Keeping sites sampled all 6 months.
Pooling all 12 samples from a year together.
removing surveys with no observation.
removing surveys that were not sampled at least twice 10 years apart."
)][, gamma_sum_grains := sum(alpha_grain), by = .(regional, year)]

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
