dataset_id <- 'antonucci_2023'

ddata <- base::readRDS(file = 'data/raw data/antonucci_2023/rdata.rds')
data.table::setnames(ddata, new = tolower(colnames(ddata)))
data.table::setnames(
   x = ddata,
   old = c('country','stationid','abundance_l'),
   new = c('regional','local','value'))

# Raw data ----
ddata[, date := data.table::as.IDate(date, '%d.%m.%y')]
ddata[, ":="(month = data.table::month(date),
             day    = data.table::mday(date)
)]


## Community data ----
ddata[, ":="(
   dataset_id = dataset_id,

   species = as.factor(paste(functional_group, genus, species, sep = '_')),
   metric = "density",
   unit = "individuals per liter",

   genus = NULL
)]


## Coordinates ----
coords <- data.frame(matrix(byrow = TRUE, ncol = 3L,
                            dimnames = list(c(), c('local','latitude','longitude')),
                            data = c(
                               'MARSDND', 52.9833, 4.7512,
                               'DOOVBWT', 53.0529, 5.0322,
                               'BOOMKDP', 53.3797, 5.1686,
                               'TERSLG4', 53.4152, 5.1505,
                               'TERSLG10', 53.4611, 5.1008,
                               'DANTZGT', 53.4011, 5.7269,
                               'ZUIDOLWOT', 53.4491, 6.5134,
                               'ROTTMPT3', 53.5661, 6.5641,
                               'HUIBGOT', 53.5598, 6.6624,
                               'BOCHTVWTM', 53.3349, 6.9439,
                               'GROOTGND', 53.3042, 7.1566,
                               'Bork_W_1', 53.4790, 6.9175,
                               'Nney_W_2', 53.6970, 7.1650,
                               'JaBu_W_1', 53.5128, 8.1499,
                               'WeMu_W_1', 53.6659, 8.3815
                            )))

## metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, month, day)])
meta <- meta[coords, on = 'local', nomatch = NULL]

meta[, ":="(
   taxon = "Marine plants",
   realm = "Marine",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = NA,
   alpha_grain_unit = "m2",
   alpha_grain_type = "sample",
   alpha_grain_comment = "",

   comment = "Extracted from Josie Antonucci di Carvalho's GitHub repository https://github.com/josieantonucci/TemporalChange_PPKT_WaddenSea/blob/befbf4575dc63afdca069367b96d57be0d782779/Data/PPKT_count_WaddenSea_1999_2018.csv and from the preprint article `Temporal change in phytoplankton diversity and functional group composition` https://doi.org/10.21203/rs.3.rs-2760923/v1
   They aggregated long-term phytoplankton data from coastal stations in Germany and the Netherlands. Provided abundance values are number of individuals per litre.",
   comment_standardisation = 'none needed',
   doi = 'https://doi.org/10.21203/rs.3.rs-2760923/v1'
)]

## saving raw data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata[, !"date"],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)

# Standardised data ----
## community data standardisation ----

### When a site is sampled several times a year, selecting the 4 most frequently sampled months from the 6 most sampled months ----
month_order <- ddata[, data.table::uniqueN(date), by = .(regional, local, year, month)][, sum(V1), by = month][order(-V1)][1L:6L, month]
ddata[, month_order := (1L:6L)[match(month, month_order, nomatch = NULL)]]
data.table::setkey(ddata, month_order)

ddata <- ddata[!base::is.na(month_order)]
ddata[, nmonths := data.table::uniqueN(month), by = .(regional, local, year)]
ddata <- ddata[nmonths >= 4L][, nmonths := NULL]

ddata <- ddata[
   unique(ddata[,
                .(regional, local, year, month)])[, .SD[1L:4L],
                                                  by = .(regional, local, year)],
   on = .(regional, local, year, month)
][, month_order := NULL]

### When a site is sampled several times a month, selecting the first visit ----
ddata <- ddata[
   unique(ddata[, .(local, year, month, date)])[, .SD[1L],
                                                by = .(local, year, month)],
   on = .(local, year, month, date)
][, month := NULL][, date := NULL]

## Pooling all samples from a year together ----
ddata <- ddata[, .(value = sum(value)), by = .(regional, local, year, species)]

## metadata ----
meta <- meta[
   unique(ddata[,.(regional, local, year)]),
   on = .(regional, local, year)
]

meta[, ":="(
   effort = 4L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment_standardisation = 'When a site is sampled several times a year, selecting the 4 most frequently sampled months from the 6 most sampled months ie selecting sites from summer and spring. When a site is sampled several times a month, selecting the first visit. Pooling all 4 samples from a year together.'
)][, ":="(
   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6,
   gamma_sum_grains = sum(alpha_grain)
), by = .(regional, year)]

## saving standardised data ----
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
