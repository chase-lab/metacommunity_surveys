# perry_2023
dataset_id <- 'perry_2023'

ddata <- unique(base::readRDS('data/raw data/perry_2023/rdata.rds'))
data.table::setnames(ddata, tolower(colnames(ddata)))
data.table::setnames(ddata,
                     old = c("lab", "stationcode", "organisms_per_ml", "name"),
                     new = c("regional", "local", "value", "species"))

# raw data ----
## Communities ----
ddata[, ":="(
   dataset_id = dataset_id,

   regional = factor("Sacramento-San Joaquin Bay-Delta"),

   year = data.table::year(sampledate),
   month = data.table::month(sampledate),
   day = data.table::mday(sampledate),

   metric = "density",
   unit = "individuals per mL"
)]

# Pooling densities from 'Good' and 'Fragmented' observations
ddata_standardised <- data.table::copy(ddata)
ddata <- ddata[, .(value = sum(value)),
               by = .(dataset_id, regional, local, latitude, longitude,
                      year, month, day, species, metric, unit)]

## Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, month, day, latitude, longitude)])

meta[, ":="(
   taxon = "Invertebrates", # Phytoplankton
   realm = "Freshwater",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   comment = "Extracted from Perry, S.E., T. Brown, and V. Klotz. 2023. Interagency Ecological Program: Phytoplankton monitoring in the Sacramento-San Joaquin Bay-Delta, collected by the Environmental Monitoring Program, 2008-2021 ver 1. Environmental Data Initiative. https://doi.org/10.6073/pasta/389ea091f8af4597e365d8b8a4ff2a5a (Accessed 2023-02-23). METHODS: 'Phytoplankton samples are collected with a submersible pump or a Van Dorn sampler from a water depth of one meter (approximately three feet) below the water surface.' density vlues were retrieved from column 'organisms_per_mL' LOCAL is a stationcode and REGIONAL is the whole Sacramento-San Joaquin Bay-Delta with a split depending on the lab in charge of identifying algae organisms.",
   comment_standardisation = "In some samples, one species was observed and considered 'Good' quality observations and it was also observed in a 'Fragmented' state. When this happened, we pooled densities together.",
   doi = 'https://doi.org/10.6073/pasta/044ee4a506ef1860577a990e20ea4305'
)]

ddata[, c('latitude','longitude') := NULL]

## Saving raw data ----
base::dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)

# Standardised data ----

## subsetting data for equal number of visits per year + good quality ----
## When there are 2 dates per month, select one ----
# data.table style join
ddata <- ddata_standardised[
   i = ddata_standardised[
      i = qualitycheck == 'Good',
      j = .(sampledate = sampledate[1L]),
      by = .(regional, year, month, local)],
   on = .(regional, year, month, local, sampledate)
]

### selecting 10 samples in sites/years with 11 or 12 samples ----
ddata[, order_month := order(table(month), decreasing = TRUE)[base::match(month, 1L:12L)]]
data.table::setorder(ddata, regional, local, year, order_month)
ddata <- ddata[
   i = unique(ddata[, .(regional, local, year, month)])[, .SD[1L:10L], by = .(regional, local, year)],
   on = .(regional, local, year, month)
] # (data.table style join)

month_order <- ddata[, data.table::uniqueN(sampledate), by = .(regional, year, month)][, sum(V1), by = month][order(-V1)][1L:12L, month]
ddata[, month_order := (1L:12L)[match(month, month_order, nomatch = NULL)]]
data.table::setkey(ddata, month_order)

ddata <- ddata[i = !is.na(month_order),
               j = nmonths := data.table::uniqueN(month),
               by = .(regional, local, year)][nmonths >= 10L][, nmonths := NULL]

ddata <- ddata[
   i = unique(ddata[, .(regional, local, year, month)])[,
                                                        j = .SD[1L:10L],
                                                        by = .(regional, local, year)],
   on = .(regional, local, year, month), nomatch = NULL][, month_order := NULL]

## Pooling monthly samples together ----
ddata <- ddata[, j = .(value = mean(value)),
               keyby = .(dataset_id, year, regional, local,
                         species, metric, unit)][!is.na(species)]

## Excluding sites that were not sampled at least twice 10 years apart ----
ddata <- ddata[
   i = !ddata[, diff(range(year)) < 9L, by = .(regional, local)][(V1)],
   on = .(regional, local)]

## Metadata ----
meta[, c("month", "day") := NULL]
meta <- unique(meta)
meta <- meta[unique(ddata[, .(regional, local, year)]),
             on = .(regional, local, year)]

meta[, ":="(
   effort = 10L,

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment_standardisation = "Only samples rated as 'Good' are kept.
Only sites/years with at least 10 months sampled are kept.
When more than 10 months are sampled, the 10 most frequently sampled months (overall) are kept.
Sites that were not sampled at least twice 10 years apart were excluded."
)][, ":="(
   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6),
   by = year]

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
