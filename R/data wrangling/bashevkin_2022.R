dataset_id <- 'bashevkin_2022'

# data preparation ----
ddata <- base::readRDS('data/raw data/bashevkin_2022/rdata.rds')
data.table::setnames(ddata, tolower(colnames(ddata)))
data.table::setnames(ddata, 1:2, c('regional','local'))

ddata[, month := base::as.integer(base::format(date, '%m'))]

data.table::setkeyv(ddata, cols = c('regional', 'local', 'year','month', 'sampleid'))

# data standardisation ----
## Keeping only sites that were not undersampled ----
ddata <- ddata[(!undersampled)][, undersampled := NULL]

## Keeping only sites sampled at twice least 10 years apart ----
ddata <- ddata[ddata[, diff(range(year)), by = local][V1 >= 9L][, V1 := NULL], on = 'local']

## When a site is sampled several times a year, selecting the 6 most frequently sampled months from the 8 most sampled months ----
ddata[, month_order := (1L:8L)[match(month, c(6L, 5L, 4L, 7L, 8L, 3L, 10L, 9L), nomatch = NULL)]]
data.table::setkey(ddata, month_order)

ddata <- ddata[!is.na(month_order)][, nmonths := data.table::uniqueN(month), by = .(regional, local, year)][nmonths >= 6L][, nmonths := NULL]

ddata <- ddata[unique(ddata[, .(regional, local, year, month)])[, .SD[1L:6L], by = .(regional, local, year)], on = .(regional, local, year, month)][, month_order := NULL]

## When a site is sampled twice a month, selecting the first visit ----
ddata <- ddata[unique(ddata[, .(local, year, month, sampleid)])[, .SD[1L], by = .(local, year, month)], on = .(local, year, month, sampleid)][, month := NULL][, sampleid := NULL]

## Pooling all samples from a year together ----
ddata <- ddata[, .(value = sum(cpue), effort = sum(volume), latitude = mean(latitude), longitude = mean(longitude)), by = .(regional, local, year, species = taxname)]

# Community data ----
ddata[, ":="(
   dataset_id = dataset_id,

   metric = "density",
   unit = "cpue"
)]

# metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, latitude, longitude, effort)])
meta[, ":="(
   taxon = "Invertebrates",
   realm = "Freshwater",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = NA,
   alpha_grain_unit = "m2",
   alpha_grain_type = "plot",
   alpha_grain_comment = "",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",


   comment = "Extracted from the EDI repository Bashevkin, S.M., R. Hartman, M. Thomas, A. Barros, C.E. Burdi, A. Hennessy, T. Tempel, K. Kayfetz, K. Alstad, and C. Pien. 2023. Interagency Ecological Program: Zooplankton abundance in the Upper San Francisco Estuary from 1972-2021, an integration of 7 long-term monitoring programs ver 4. Environmental Data Initiative. https://doi.org/10.6073/pasta/8b646dfbeb625e308212a39f1e46f69b ",
   comment_standardisation = "Keeping only sites that were not undersampled
Keeping only sites sampled at twice least 10 years apart
When a site is sampled several times a year, selecting the 6 most frequently sampled months from the 8 most sampled months
When a site is sampled twice a month, selecting the first visit
Pooling all samples from a year together",
doi = 'https://doi.org/10.6073/pasta/8b646dfbeb625e308212a39f1e46f69b'
)][, ":="(
   gamma_bounding_box = geosphere::areaPolygon(data.frame(na.omit(longitude), na.omit(latitude))[grDevices::chull(na.omit(longitude), na.omit(latitude)), ]) / 10^6,
   gamma_sum_grains = sum(alpha_grain)
),
by = .(regional, year)
]

ddata[, c('longitude','latitude','effort') := NULL]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised_metadata.csv"),
                   row.names = FALSE
)

