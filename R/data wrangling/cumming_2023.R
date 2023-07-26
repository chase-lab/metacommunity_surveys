dataset_id <- 'cumming_2023'

ddata <- base::readRDS(file = 'data/raw data/cumming_2023/rdata.rds')

# raw data ----
## Communities ----
ddata[, local := .GRP, by = .(decimalLatitude, decimalLongitude)]
ddata[, ':='(
   dataset_id = dataset_id,

   regional = 'Great Barrier Reef',

   scientificName = base::iconv(scientificName, from = 'UTF-8', to = 'ASCII//translit'),

   value = 1L,
   metric = 'pa',
   unit = 'pa'
)][!is.na(scientificName), species := scientificName][, scientificName := NULL]

## Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, month, day, latitude = decimalLatitude, longitude = decimalLongitude)])
meta[, ":="(
   taxon = "Fish",
   realm = "Marine",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = 250L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "transect",
   alpha_grain_comment = "50m long 5m wide belt transect",

   comment = "Extracted from Zenodo repository Cumming, G.S., & Bellwood, D.R. (2023). Scale and connectivity analysis of coral reef fish communities in the Great Barrier Reef. In Ecological Applications (Version 1). Zenodo. https://doi.org/10.5281/zenodo.7739234 FILE: AIMSfish_vx.xlsx. These data are used in publication Cumming, G.S. and Bellwood, D.R. (2023), Broad-scale analysis of fish community data suggests critical need to support regional connectivity of coral reefs. Ecological Applications. Accepted Author Manuscript e2849. https://doi.org/10.1002/eap.2849 . From these GBIF records, we used latitude and longitude to determine local sites which are transects. METHODS: Fish data come from 'the long-term monitoring data set produced by the Australian Institute of Marine Science (AIMS) for fish on the GBR to explore the relative influences of local and regional influences on fish community composition. The AIMS Long-Term Fish Visual Census of the Great Barrier Reef contains 147,466 individual records for a prescribed list of 212 species sampled periodically at ~50 different reefs from March 1992 to May 2015 [...] the fish count data derive from intensive surveys at three sites along five 50m, 5m-wide belt transects. These are located 250m or more apart (where possible) along the first stretch of continuous reef (excluding vertical drop-offs) [...] Reefs are visited on a rotation every 2-5 years.' ",
   comment_standardisation = "Contrary to Cumming et al https://doi.org/10.1002/ecy.3923 we kept records of Pomacentrus tripunctatus.",
   doi = 'https://doi.org/10.1002/ecy.3923 | https://doi.org/10.5281/zenodo.6567608'
)]

ddata[, c('decimalLatitude','decimalLongitude') := NULL]

## Saving raw data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
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

## data selection ----
### Keeping only sites sampled at twice least 10 years apart ----
ddata <- ddata[ddata[, diff(range(year)), by = local][V1 >= 9L][, V1 := NULL], on = 'local']

### When a site is sampled twice a year, selecting the most frequently sampled month ----
ddata[, order_month := order(table(month), decreasing = TRUE)[match(month, 1:12)]]
data.table::setorder(ddata, local, year, order_month)
ddata <- ddata[
   unique(ddata[, .(local, year, month)])[, .SD[1L],
                                          by = .(local, year)],
   on = .(local, year, month)][, order_month := NULL]

### When a site is sampled twice a month, selecting the first visit ----
ddata <- ddata[
   unique(ddata[, .(local, year, month, day)])[, .SD[1L],
                                               by = .(local, year, month)],
   on = .(local, year, month, day)][, month := NULL][, day := NULL]


## Metadata ----
meta[, c("month", "day") := NULL]
meta <- meta[unique(ddata[, .(local, year)]),
             on = .(local, year)]

meta[, ":="(
   effort = 1L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "transect",
   gamma_sum_grains_comment = "sum of sampled areas per year",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment_standardisation = "When sampled several times a year, sample from the generally most sampled month kept. When two samples a month, only the first is kept. We kept only sites that were sampled at least 10 years apart. Contrary to Cumming et al https://doi.org/10.1002/ecy.3923 we kept records of Pomacentrus tripunctatus."
)][, ":="(gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6,
          gamma_sum_grains = sum(alpha_grain)),
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

