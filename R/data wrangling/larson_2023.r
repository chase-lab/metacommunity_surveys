dataset_id = 'larson_2023'

ddata <- base::readRDS(file = 'data/raw data/larson_2023/rdata.rds')

# Preparing data ----
data.table::setnames(ddata, new = base::tolower(base::colnames(ddata)))
data.table::setnames(ddata,
                     old = c('fldnum', 'pool', 'visual1', 'east1', 'north1', 'sppcd'),
                     new = c('regional', 'local', 'value', 'longitude', 'latitude', 'species'))
ddata[, date := data.table::as.IDate(base::strptime(date, "%m/%d/%Y"))]

# Raw data ----
## Communities ----
ddata[, ':='(
   dataset_id = dataset_id,
   regional = base::factor(c('Lake City, MN','Onalaska, WI','Bellevue, IA'))[base::match(regional, 1L:3L)],
   local = base::paste(local, sitecd, rivmile, sep = '_'),

   year = data.table::year(date),
   month = data.table::month(date),
   day = data.table::mday(date),

   value = value + visual2 + visual3 + visual4 + visual6,
   metric = 'relative abundance index',
   unit = 'score',

   latitude = data.table::fifelse(base::is.na(north2), latitude, latitude + north2 / 2),
   longitude = data.table::fifelse(base::is.na(east2), longitude, longitude + east2 / 2),

   rivmile = NULL,

   north2 = NULL,
   east2 = NULL,
   zone = NULL
)][, base::grep('visual', base::colnames(ddata), value = TRUE) := NULL]

ddata <- ddata[value != 0L]

# Metadata ----
## Coordinate conversion ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, month, day, longitude, latitude)])

coords <- stats::na.omit(meta)
coords_sf <- sf::st_as_sf(coords, coords = c('longitude', 'latitude'), crs = sf::st_crs(paste0('+proj=utm +zone=15')))
coords_sf <- sf::st_transform(coords_sf, crs = sf::st_crs('+proj=longlat +datum=WGS84'))

coords[, longitude := sf::st_coordinates(coords_sf)[, 1]][, latitude := sf::st_coordinates(coords_sf)[, 2]]

## Merging coordinates back in meta ----
meta[coords,
     ":="(latitude = i.latitude, longitude = i.longitude),
     on = .(regional, local, year)]

meta[, ':='(
   taxon = 'Plants',
   realm = 'Freshwater',

   study_type = 'ecological_sampling',
   data_pooled_by_authors = FALSE,

   alpha_grain = 44L,
   alpha_grain_unit = 'm2',
   alpha_grain_type = 'plot',
   alpha_grain_comment = 'investigated area around the boat, given by authors',

   comment = 'Data extracted from  Larson, Danelle M., Carhart, Alicia M., and Lund, Eric M.. 2023. " Aquatic Vegetation Types Identified during Early and Late Phases of Vegetation Recovery in the Upper Mississippi River." Ecosphere 14( 3): e4468. https://doi.org/10.1002/ecs2.4468 . REGIONAL corresponds to the field station number: FLDNUM, LOCAL corresponds to POOL, SITECD and RIVMILE concatanated together. METHOD:"Species occurrence data were summarized at the ~44-m2 plot scale to represent a relative abundance index as follows. Any [...] species that occurred at a subplot was given a score of "1" for each subplot. Finally, we summed the occurrence data from each of the six subplots [...] within the entire plot for each species".',
   comment_standardisation = 'Occurences from the 6 subplots summed.',
   doi = 'https://doi.org/10.1002/ecs2.4468'
)]

ddata[, c('latitude','longitude') := NULL]

## Saving raw data ----
dir.create(paste0('data/wrangled data/', dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata[, !c("voucher","sitecd","projcd","date")],
   file = paste0('data/wrangled data/', dataset_id, '/', dataset_id, '_raw.csv'),
   row.names = FALSE
)

data.table::fwrite(
   x = meta,
   file = paste0('data/wrangled data/', dataset_id, '/', dataset_id, '_raw_metadata.csv'),
   row.names = FALSE
)


# Standardised data ----

## Selecting data ----
ddata <- ddata[!base::grepl("^NO", species)
][projcd == 'M-98A'][, projcd := NULL
][!(regional == 3L & local == 13L & sitecd == 425L & date == '07/05/2005' & species == 'MYSP2' & !is.na(voucher))][, voucher := NULL]
# Columns "addspp|qecode|voucher" were causing redundancy so we are good!
ddata[, ":="(
   value = 1L,
   metric = 'pa',
   unit = 'pa',

   month = NULL,
   day = NULL,

   sitecd = NULL,
   date = NULL
)]

## Metadata ----
meta <- meta[unique(ddata[, .(regional, local, year)]),
             on = .(regional, local, year)]
meta[, ":="(
   effort = 1L,

   gamma_sum_grains_unit = 'm2',
   gamma_sum_grains_type = 'plot',
   gamma_sum_grains_comment = 'sum of the sampled areas from all samples on a given year',

   gamma_bounding_box_unit = 'km2',
   gamma_bounding_box_type = 'convex-hull',
   gamma_bounding_box_comment = 'coordinates in UTM given by authors used to compute convex-hull',

   comment = 'Data extracted from  Larson, Danelle M., Carhart, Alicia M., and Lund, Eric M.. 2023. " Aquatic Vegetation Types Identified during Early and Late Phases of Vegetation Recovery in the Upper Mississippi River." Ecosphere 14( 3): e4468. https://doi.org/10.1002/ecs2.4468 . REGIONAL corresponds to the field station number: FLDNUM, LOCAL corresponds to POOL, SITECD and RIVMILE concatanated together. METHOD:"Species occurrence data were summarized at the ~44-m2 plot scale to represent a relative abundance index as follows. Any [...] species that occurred at a subplot was given a score of "1" for each subplot. Finally, we summed the occurrence data from each of the six subplots [...] within the entire plot for each species". Only data from project M-98A were included here.',
   comment_standardisation = 'Relative abundance index turned into presence absence.',

   month = NULL,
   day = NULL
)][, ":="(
   gamma_bounding_box = geosphere::areaPolygon(data.frame(na.omit(longitude), na.omit(latitude))[grDevices::chull(na.omit(longitude), na.omit(latitude)), ]) / 10^6,
   gamma_sum_grains = sum(alpha_grain)
), by = .(regional, year)]

## Saving standardised data ----
data.table::fwrite(
   x = ddata,
   file = paste0('data/wrangled data/', dataset_id, '/', dataset_id, '_standardised.csv'),
   row.names = FALSE
)

data.table::fwrite(
   x = meta,
   file = paste0('data/wrangled data/', dataset_id, '/', dataset_id, '_standardised_metadata.csv'),
   row.names = FALSE
)
