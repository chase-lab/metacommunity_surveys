dataset_id <- 'bashevkin_2022'

# data preparation ----
ddata <- base::readRDS('data/raw data/bashevkin_2022/rdata.rds')
data.table::setnames(ddata, new = tolower(colnames(ddata)))
data.table::setnames(
   ddata,
   old = c("station", "taxname", "cpue"),
   new = c("local", "species", "value"))

ddata[, ":="(month = data.table::month(date),
             day   = data.table::mday(date)
)]

data.table::setkeyv(ddata, cols = c('source', 'local', 'year', 'month', 'day', 'sampleid'))

# Raw data ----
ddata[, replicate := data.table::tstrsplit(sampleid, " ", keep = 4L, fill = "1")]

## Community data ----
ddata[, ":="(
   dataset_id = as.factor(paste(dataset_id, source, sizeclass, sep = "_")),

   regional = factor("Upper San Francisco Estuary"),
   local = paste(local, replicate, sep = "_"),

   metric = "density",
   unit = "cpue",

   date = NULL,
   replicate = NULL,
   source = NULL,
   sizeclass = NULL
)]

### Pooling life stages together ----
ddata <- ddata[, .(value = sum(value), regional = regional, metric = metric, unit = unit),
               by = .(dataset_id, local, year, month, day, latitude, longitude,
                      sampleid, volume, species, undersampled)]

## metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, month, day, latitude, longitude)])
meta[, ":="(
   taxon = "Invertebrates",
   realm = "Freshwater",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = NA,
   alpha_grain_unit = NA,
   alpha_grain_type = NA,

   comment = factor("Extracted from the EDI repository Bashevkin, S.M., R. Hartman, M. Thomas, A. Barros, C.E. Burdi, A. Hennessy, T. Tempel, K. Kayfetz, K. Alstad, and C. Pien. 2023. Interagency Ecological Program: Zooplankton abundance in the Upper San Francisco Estuary from 1972-2021, an integration of 7 long-term monitoring programs ver 4. Environmental Data Initiative. https://doi.org/10.6073/pasta/8b646dfbeb625e308212a39f1e46f69b. Data are split by program and size class: 11 distinct studies."),
   comment_standardisation = factor('The original data provides information on the lifestages that were not reproduced here and individuals from the same species at different lifestages were pooled together.
   The authors note that in some samples some taxa were not sampled in sufficient numbers to give a good approwximations of there relative abundance. These observations are kept here. In the original data, a column called Undersampled allowed excluding these observations. Local has the name of the Station and the number of the tow (ie. the last element of sampleid).'),
   doi = 'https://doi.org/10.6073/pasta/8b646dfbeb625e308212a39f1e46f69b'
)]

# ddata[, c('longitude','latitude') := NULL]

## Saving raw data ----
data.table::setkey(ddata, dataset_id)
data.table::setkey(meta, dataset_id)
dataset_ids <- unique(meta$dataset_id)

for (dataset_id in dataset_ids) {
   dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
   data.table::fwrite(
      x = ddata[dataset_id, !c("sampleid","undersampled", "volume", "latitude", "longitude")],
      file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
      row.names = FALSE
   )
   data.table::fwrite(
      x = meta[dataset_id],
      file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
      row.names = FALSE
   )
}

# Standardised data ----

## data standardisation ----
### Keeping only sites that were not undersampled ----
ddata <- ddata[(!undersampled)][, undersampled := NULL]

### Keeping only sites sampled at twice least 10 years apart ----
ddata[, local := gsub("_.*$", "", local)]
ddata <- ddata[
   ddata[, diff(range(year)), by = .(dataset_id, local)][V1 >= 9L][, V1 := NULL],
   on = .(dataset_id, local)]

### When a site is sampled several times a year, selecting the 6 most frequently sampled months from the 8 most sampled months ----
month_order <- ddata[, data.table::uniqueN(sampleid), by = .(dataset_id, month)][, sum(V1), by = month][order(-V1)][1L:8L, month]
ddata[, month_order := (1L:8L)[match(month, month_order, nomatch = NULL)]]
data.table::setkey(ddata, month_order)

ddata <- ddata[!is.na(month_order)][, nmonths := data.table::uniqueN(month),
                                    by = .(dataset_id, local, year)][nmonths >= 6L][, nmonths := NULL]

ddata <- ddata[
   unique(ddata[,
                .(dataset_id, local, year, month)])[, .SD[1L:6L],
                                                    by = .(dataset_id, local, year)],
   on = .(dataset_id, local, year, month), nomatch = NULL][, month_order := NULL]

### When a site is sampled twice a month, selecting the first visit ----
ddata <- ddata[
   unique(ddata[,
                .(dataset_id, local, year, month, sampleid)])[, .SD[1L],
                                                              by = .(dataset_id, local, year, month)],
   on = .(dataset_id, local, year, month, sampleid)][, month := NULL][, sampleid := NULL]

### Pooling all samples from a year together ----
ddata[,
      ':='(effort = sum(volume), latitude = mean(latitude), longitude = mean(longitude)),
      by = .(dataset_id, regional, local, year)]
ddata <- ddata[, .(value = sum(value)),
               by = .(dataset_id, local, year, effort, latitude, longitude, species)]

## Metadata ----
meta[, c("latitude","longitude","month","day") := NULL][
   , local := gsub("_.*$", "", local)]
meta <- unique(meta)
meta <- meta[
   unique(ddata[, .(dataset_id, local, year, effort, latitude, longitude, effort)]),
   on = .(dataset_id, local, year)]

meta[, ":="(
   gamma_sum_grains = NA,
   gamma_sum_grains_unit = NA,
   gamma_sum_grains_type = NA,
   gamma_sum_grains_comment = NA,

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment_standardisation = factor(
      'Keeping only observations that were not undersampled.
The original data provides information on the lifestages that were not reproduced
here and individuals from the same species at different lifestages were pooled together.
Keeping only sites sampled twice at least 10 years apart.
When a site is sampled several times a year, selecting the 6 most frequently sampled months from the 8 most sampled months.
When a site is sampled more than once a month, selecting the first visit.
Pooling all samples from a year together')
)][, ":="(
   gamma_bounding_box = geosphere::areaPolygon(data.frame(na.omit(longitude), na.omit(latitude))[grDevices::chull(na.omit(longitude), na.omit(latitude)), ]) / 10^6),
   by = .(dataset_id, year)]

ddata[, c("effort","latitude","longitude") := NULL]

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
