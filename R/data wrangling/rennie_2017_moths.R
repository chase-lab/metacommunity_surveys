dataset_id <- 'rennie_2017_moths'

ddata <- base::readRDS(file = "data/raw data/rennie_2017_moths/rdata.rds")
data.table::setnames(ddata, c('site','local','date','value','species'))

# Standardisation ----
ddata[, date := data.table::as.IDate(date, format = '%d-%b-%y')]
ddata[, year := data.table::year(date)][, month := data.table::month(date)]

## Selecting the first 4 visits per month ----
ddata[, ndates := length(unique(date)), by = .(site, year, local, month)]

data.table::setkeyv(ddata, c('site', 'year', 'local', 'month', 'date'))
ddata <- ddata[
   unique(ddata[ndates >= 4L, .(site, local, year, month, date)])[, .SD[1L:4L], by = .(site, local, year, month)],
   on = .(site, local, year, month, date)
]#[, month := NULL][, date := NULL]

## Selecting the 7 most frequently sampled months: April to October  ----
#table(unique(ddata[, .(site, local, date, month, year)])$month)
ddata <- ddata[month %in% 4L:10L]

## Keeping sites sampled all 6 months ----
ddata <- ddata[, nmonths := data.table::uniqueN(month), by = .(site, local, year)
][nmonths == 7L][, nmonths := NULL]

## Pooling all 28 samples from a year together ----
ddata <- ddata[, .(value = sum(value)), by = .(site, local, year, species)]

## removing surveys with no observation ----
ddata <- ddata[value != 0L]

# Community data ----
ddata[, ":="(
   dataset_id = dataset_id,

   regional = 'England',
   local = paste(site, local, sep = '_'),

   metric = "abundance",
   unit = "count"
)]

# Coordinates ----
coords <- data.table::as.data.table(matrix(
   dimnames = list(c(), c('site', 'site_name', 'latitude', 'longitude')),
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
meta <- unique(ddata[, .(dataset_id, regional, site, local, year)])
meta <- meta[coords, on = 'site', nomatch = NULL]

meta[, ":="(
   taxon = "Invertebrates",
   realm = "Terrestrial",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   effort = 28L,

   latitude = parzer::parse_lat(latitude),
   longitude = parzer::parse_lon(longitude),

   alpha_grain = 30L * 60L * 4L * 28L,
   alpha_grain_unit = "cm2",
   alpha_grain_type = "sample",
   alpha_grain_comment = "trap opening `window`",

   gamma_sum_grains_unit = "cm2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of the areas of the traps for all 11 sites and for one year",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment = "Data were downloaded from https://doi.org/10.5285/a2a49f47-49b3-46da-a434-bb22e524c5d2. Authors assessed moth communities with one site in each of 11 sites. Local scale is a trap and it's name is built as SITE_CODE_LCODE. Site coordinates were extracted from IM_DATA_STRUCTUREedit.rtf found in the Supporting documentation.",
   comment_standardisation = "Selecting the first 4 visits per month
Selecting the 7 most frequently sampled months: April to October
Keeping sites sampled all 6 months
Pooling all 28 samples from a year together
removing surveys with no observation ",
doi = 'https://doi.org/10.5285/a2a49f47-49b3-46da-a434-bb22e524c5d2'
)][, ":="(
   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6,
   gamma_sum_grains = sum(alpha_grain)
), by = year]

ddata[, site := NULL]
meta[, site := NULL]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
   row.names = FALSE
)
