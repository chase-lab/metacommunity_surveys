dataset_id = 'larson_2023'

ddata <- base::readRDS(file = 'data/raw data/larson_2023/rdata.rds')


# Preparing data ----
data.table::setnames(ddata, base::tolower(base::colnames(ddata)))
data.table::setnames(ddata,
                     c('fldnum', 'pool', 'visual1', 'east1', 'north1', 'sppcd'),
                     c('regional', 'local', 'value', 'longitude', 'latitude', 'species'))

# Selecting data ----
ddata <- ddata[!base::grepl("^NO", species)
               ][projcd == 'M-98A'][, projcd := NULL
                                    ][!(regional == 3L & local == 13L & sitecd == 425L & date == '07/05/2005' & species == 'MYSP2' & !is.na(voucher))][, voucher := NULL]
# Columns "addspp|qecode|voucher" were causing redundancy so we are good!

# Communities ----
ddata[, ':='(
   dataset_id = dataset_id,
   regional = base::factor(c('Lake City, MN','Onalaska, WI','Bellevue, IA'))[base::match(regional, 1L:3L)],
   local = base::paste(local, sitecd, rivmile, sep = '_'),

   year = base::substr(date, 7L, 10L),

   # value = data.table::fifelse(test = any(value != 0L, visual2 != 0L, visual3 != 0L, visual4 != 0L, visual5 != 0L, visual6 != 0L),
   #                             yes = 1L, no = NA_integer_),
   value = 1L,
   metric = 'pa',
   unit = 'pa',

   latitude = data.table::fifelse(base::is.na(north2), latitude, (latitude + north2) / 2),
   longitude = data.table::fifelse(base::is.na(east2), longitude, (longitude + east2) / 2),

   date = NULL,
   sitecd = NULL,
   rivmile = NULL,

   north2 = NULL,
   east2 = NULL,
   zone = NULL
)][, base::grep('visual', base::colnames(ddata), value = TRUE) := NULL]

# Metadata ----
## Coordinate conversion ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, longitude, latitude)])

coords <- stats::na.omit(meta)
coords_sf <- sf::st_as_sf(coords, coords = c('longitude', 'latitude'), crs = sf::st_crs(paste0('+proj=utm +zone=15')))
coords_sf <- sf::st_transform(coords_sf, crs = sf::st_crs('+proj=longlat +datum=WGS84'))

coords[, longitude := sf::st_coordinates(coords_sf)[, 1]][, latitude := sf::st_coordinates(coords_sf)[, 2]]

## Merging coordinates back in meta ----
meta <- coords[meta[,.(regional, local, year)], on = .(regional, local, year)]

meta[, ':='(
   taxon = 'Plants',
   realm = 'Freshwater',

   effort = 1L,

   study_type = 'ecological_sampling',
   data_pooled_by_authors = FALSE,

   alpha_grain = 44L,
   alpha_grain_unit = 'm2',
   alpha_grain_type = 'plot',
   alpha_grain_comment = 'investigated area around the boat, given by authors',

   gamma_sum_grains_unit = 'm2',
   gamma_sum_grains_type = 'plot',
   gamma_sum_grains_comment = 'sum of the sampled areas from all samples on a given year',

   gamma_bounding_box_unit = 'km2',
   gamma_bounding_box_type = 'convex-hull',
   gamma_bounding_box_comment = 'coordinates in UTM given by authors used to compute convex-hull',

   comment = 'Data extracted from  Larson, Danelle M., Carhart, Alicia M., and Lund, Eric M.. 2023. " Aquatic Vegetation Types Identified during Early and Late Phases of Vegetation Recovery in the Upper Mississippi River." Ecosphere 14( 3): e4468. https://doi.org/10.1002/ecs2.4468 . REGIONAL corresponds to the field station number: FLDNUM, LOCAL corresponds to POOL, SITECD and RIVMILE concatanated together. METHOD:"Species occurrence data were summarized at the ~44-m2 plot scale to represent a relative abundance index as follows. Any species that occurred and were detected visually anywhere within the plot were given a score of "1." Then, any species that occurred at a subplot was given a score of "1" for each subplot. Finally, we summed the occurrence data from each of the six subplots and the visual detection within the entire plot for each species". Only data from project M-98A were included here.',
   comment_standardisation = 'Relative abundance index turned into presence absence.',
   doi = 'https://doi.org/10.1002/ecs2.4468'
)][, ":="(
   gamma_bounding_box = geosphere::areaPolygon(data.frame(na.omit(longitude), na.omit(latitude))[grDevices::chull(na.omit(longitude), na.omit(latitude)), ]) / 10^6,
   gamma_sum_grains = sum(alpha_grain)
),
by = .(regional, year)
]

ddata[, c('latitude','longitude') := NULL]

# Saving ----
dir.create(paste0('data/wrangled data/', dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0('data/wrangled data/', dataset_id, '/', dataset_id, '.csv'),
                   row.names = FALSE
)

data.table::fwrite(meta, paste0('data/wrangled data/', dataset_id, '/', dataset_id, '_metadata.csv'),
                   row.names = FALSE
)
