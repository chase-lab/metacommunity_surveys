# Meier_2021
dataset_id <- 'meier_2021'

ddata <- base::readRDS(file = "data/raw data/meier_2021/rdata.rds")
data.table::setnames(x = ddata,
                     old = c('Year', 'Plot size [m2]', 'Relevé.number'),
                     new = c('year', 'alpha_grain', 'local'))
# Raw data ----
## Communities ----

ddata[, ':='(
   dataset_id = base::paste('meier_2021_grain', alpha_grain, 'm2', sep = '_'),

   regional = "Germany",

   year = base::as.integer(year),

   metric = 'Braun-Blanquet scale',
   unit = 'score',

   `Relevé number` = NULL # This column has one name per relevé per year
)][value == "", value := NA_character_]

# Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, coordinates, alpha_grain)])

meta[, c('latitude', 'longitude') := data.table::tstrsplit(coordinates, '; ')
][, coordinates := NULL]

meta[, ':='(
   taxon = "Plants",
   realm = "Terrestrial",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   latitude = parzer::parse_lat(latitude),
   longitude = parzer::parse_lon(longitude),

   alpha_grain = as.numeric(alpha_grain),
   alpha_grain_unit = "m2",
   alpha_grain_type = "plot",
   alpha_grain_comment = "area of the sampling points",

   comment = "Data extracted from the pdf found here: https://www.tuexenia.de/publications/tuexenia/Tuexenia_2021_NS_041_0203-0226.pdf . Original data are Relevés from dry or semi dry grasslands of Germany. METHODS: 'Seven study areas were selected from two regions in Central Germany that have pronounced occurrences of xerothermic grasslands: (1) Saaletal northwest of Halle (Saale) and (2) Kyffhäuser [...] The previous plots were identified using location sketches or vegetation maps prepared by the authors of the studies (SCHNEIDER 1996, RICHTER 2002). Using GoogleEarth (image overlay), the position for each plot could be relocated and its GPS coordinate specified, while GPS coordinates were already available in PUSCH & BARTHEL (2003). The new vegetation relevés were carried out using the same methodology as that adopted in the original study (including area size, recording time, cover-abundance values).'
   The original Braun-Blanquet scores can be turned into cover 'according to DIERSCHKE 1994: r = 0.1%, + = 0.5%, 1 = 2.5%, 2 = 15%, 3 = 37.5%, 4 = 62.5%, 5 = 87.5%'.",
   comment_standardisation = "Plots of similar sizes were split into different data sets.",
   doi = 'https://doi.org/10.14471/2021.41.009'
)]

ddata[, coordinates := NULL]

## Saving raw data ----
data.table::setkey(ddata, dataset_id)
data.table::setkey(meta, dataset_id)
dataset_ids <- unique(meta$dataset_id)

for (dataset_id_i in dataset_ids) {
   dir.create(paste0("data/wrangled data/", dataset_id_i), showWarnings = FALSE)
   data.table::fwrite(
      x = ddata[dataset_id_i, !"alpha_grain"],
      file = paste0("data/wrangled data/", dataset_id_i, "/", dataset_id_i, "_raw.csv"),
      row.names = FALSE
   )
   data.table::fwrite(
      x = meta[dataset_id_i],
      file = paste0("data/wrangled data/", dataset_id_i, "/", dataset_id_i, "_raw_metadata.csv"),
      row.names = FALSE
   )
}

# Standardised data ----
## Data selection -----
ddata <- ddata[alpha_grain != '20'
][, alpha_grain := NULL][
   !ddata[is.na(value), .(dataset_id, local, year)],
   on = .(dataset_id, local, year)]

ddata[, ":="(
   species = gsub(" juv.", "", species, fixed = TRUE),

   value = 1L,
   metric = 'pa',
   unit = 'pa'
)]

## datasets / years with less than 4 localities are excluded. ----
ddata <- ddata[
   !ddata[, data.table::uniqueN(local), by = .(dataset_id, year)][V1 < 4L],
   on = .(dataset_id, year)]

## datasets / years not sampled at least twice 10 years apart are excluded. ----
ddata <- ddata[
   !ddata[, diff(range(year)), by = .(dataset_id, local)][V1 < 9L],
   on = .(dataset_id, local)]

## Metadata ----
meta <- meta[unique(ddata[, .(dataset_id, local, year)]),
             on = .(dataset_id, local, year)]
meta[, ":="(
   effort = 1L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",

   comment_standardisation = "Plots of similar sizes were grouped in regions.
20sqm plots were excluded.
Observations from incomplete records were excluded.
Braun-Blanquet scores turned into presence absence.
'juv.' suffix in species names removed.
datasets / years with less than 4 localities are excluded.
datasets / years not sampled at least twice 10 years apart are excluded."
)][, ":="(
   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6,
   gamma_sum_grains = sum(alpha_grain)
), by = .(dataset_id, year)]

## Saving standardised data ----
data.table::setkey(ddata, dataset_id)
data.table::setkey(meta, dataset_id)
dataset_ids <- unique(meta$dataset_id)

for (dataset_id in dataset_ids) {
   data.table::fwrite(
      x = ddata[dataset_id],
      file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised.csv"),
      row.names = FALSE
   )
   data.table::fwrite(
      x = meta[dataset_id],
      file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised_metadata.csv"),
      row.names = FALSE
   )
}
