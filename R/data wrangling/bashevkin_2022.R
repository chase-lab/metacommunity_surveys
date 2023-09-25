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


ddata[, replicate := data.table::tstrsplit(sampleid, " ", keep = 4L, fill = "1")]

ddata[, ":="(
   latitude = as.numeric(as.character(latitude)),
   longitude = as.numeric(as.character(longitude))
)]

ddata_standardised <- data.table::copy(ddata)

# Raw data ----
## Community data ----
ddata[, ":="(
   dataset_id = as.factor(paste(dataset_id, source, sizeclass, sep = "_")),

   local = paste(local, replicate, sep = "_"),

   date = NULL,
   replicate = NULL,
   source = NULL,
   sizeclass = NULL,
   sampleid = NULL,
   undersampled = NULL,
   volume = NULL
)]
data.table::setkeyv(ddata, cols = c('dataset_id', 'local', 'year', 'month', 'day','species'))


### Pooling life stages together ----
ddata[, ":="(latitude = mean(latitude, na.rm = TRUE),
             longitude = mean(longitude, na.rm = TRUE)),
      by = .(dataset_id, local)]
ddata <- ddata[, .(value = sum(value)),
               by = .(dataset_id, local, latitude, longitude, year, month, day,
                      species)]

ddata[, ":="(
   regional = factor("Upper San Francisco Estuary"),

   metric = "density",
   unit = "cpue"
)]
# ddata[, .N, by = .(dataset_id, regional, local, year, month, day, species)][N != 1]

## metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, month, day, latitude, longitude)])
meta[, ":="(
   taxon = "Invertebrates",
   realm = "Freshwater",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = 1L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "sample",
   alpha_grain_comment = "estimated",

   comment = factor("Extracted from the EDI repository Bashevkin, S.M., R. Hartman, M. Thomas, A. Barros, C.E. Burdi, A. Hennessy, T. Tempel, K. Kayfetz, K. Alstad, and C. Pien. 2023. Interagency Ecological Program: Zooplankton abundance in the Upper San Francisco Estuary from 1972-2021, an integration of 7 long-term monitoring programs ver 4. Environmental Data Initiative. https://doi.org/10.6073/pasta/8b646dfbeb625e308212a39f1e46f69b. Data are split by program and size class: 11 distinct studies."),
   comment_standardisation = factor('The original data provides information on the lifestages that were not reproduced here and individuals from the same species at different lifestages were pooled together.
The authors note that in some samples some taxa were not sampled in sufficient numbers to give a good approximations of their relative abundance.
These observations are kept here. In the original data, a column called Undersampled allowed excluding these observations but it is not reproduced here for technical reasons.
Local has the name of the Station and the number of the tow (ie. the last element of sampleid).'),
doi = 'https://doi.org/10.6073/pasta/8b646dfbeb625e308212a39f1e46f69b'
)]

ddata[, c('longitude','latitude') := NULL]

## Saving raw data ----
data.table::setkey(ddata, dataset_id)
data.table::setkey(meta, dataset_id)
dataset_ids <- unique(meta$dataset_id)

for (dataset_id_i in dataset_ids) {
   dir.create(paste0("data/wrangled data/", dataset_id_i), showWarnings = FALSE)
   data.table::fwrite(
      x = ddata[dataset_id_i],
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
## data standardisation ----
### Keeping only sites that were not undersampled ----
ddata <- ddata_standardised[(!undersampled)][, undersampled := NULL]

## Community data ----
ddata[, ":="(
   dataset_id = as.factor(paste(dataset_id, source, sizeclass, sep = "_")),

   value = as.integer(value * volume),

   replicate = NULL,
   source = NULL,
   sizeclass = NULL
)]

data.table::setkeyv(ddata, cols = c('dataset_id', 'local', 'year','month','sampleid','species'))

### When a site is sampled several times a year, selecting the 6 most frequently sampled months from the 8 most sampled months ----
month_order <- ddata[, data.table::uniqueN(sampleid),
                     by = .(dataset_id, month)][, sum(V1), by = month][order(-V1)][1L:8L, month]
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
      ':='(latitude = mean(latitude), longitude = mean(longitude)),
      by = .(dataset_id, local)]

ddata[, effort := sum(volume), by = .(dataset_id, local, year)]

ddata <- ddata[, .(value = sum(value)),
               by = .(dataset_id, local, year, effort, latitude, longitude, species)]

### Excluding sites that were not sampled at least twice 10 years apart ----
ddata <- ddata[!ddata[, diff(range(year)) < 9L, by = .(dataset_id, local)][(V1)],
               on = .(dataset_id, local)]

### Individual based rarefaction to account for varying volume ----
## computing min total abundance for the local/year where the effort is the smallest ----
ddata[, sample_size := sum(value), by = .(dataset_id, local, year)]

## deleting samples with less than 10 individuals
ddata <- ddata[sample_size >= 10L]
min_sample_size <- ddata[i = ddata[, .(effort = min(effort)), by = dataset_id],
                         on = .(dataset_id, effort),
                         j = .(min_sample_size = min(sample_size)),
                         by = dataset_id]

## resampling abundances down to the minimal total abundance observed among the surveys with the minimal effort
source("R/functions/resampling.r")
ddata[, species := as.character(species)]
set.seed(42)
for (i in seq_len(nrow(min_sample_size))) {
   ddata[dataset_id == min_sample_size[i, dataset_id] & sample_size > min_sample_size[i, min_sample_size],
         value := resampling(species, value, min_sample_size[i, min_sample_size]),
         by = .(local, year)]

   ddata[dataset_id == min_sample_size[i, dataset_id] & sample_size < min_sample_size[i, min_sample_size],
         value := resampling(species, value, min_sample_size[i, min_sample_size], replace = TRUE),
         by = .(local, year)]
}
ddata <- ddata[!is.na(value)]


ddata[, ":="(
   regional = factor("Upper San Francisco Estuary"),

   metric = factor("density"),
   unit = factor("cpue")
)]
# ddata[, .N, by = .(dataset_id, regional, local, year, species)][N != 1]

## Metadata ----
meta[, c("latitude","longitude","month","day") := NULL][
   , local := gsub("_.*$", "", local)]
meta <- unique(meta)
meta <- meta[
   unique(ddata[, .(dataset_id, local, year, effort, latitude, longitude)]),
   on = .(dataset_id, local, year)]
meta[, effort := min(effort), by = dataset_id]
meta[, ":="(
   gamma_sum_grains = NA,
   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of estimated areas sampled per year and region",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment_standardisation = factor(
      'Keeping only observations that were not undersampled.
The original data provides information on the lifestages that were not reproduced
here and individuals from the same species at different lifestages were pooled together.
When a site is sampled several times a year, selecting the 6 most frequently sampled months from the 8 most sampled months.
When a site is sampled more than once a month, selecting the first visit.
Pooling all samples from a year together.
Keeping only sites sampled twice at least 10 years apart.
CPUEs multiplied by volume to get abundances (rounded if few cases)
Since the volume sampled varies, we standardised by randomly sampling the minimal number of individuals found in the smallest sample per dataset_id (source _ sizeclass) in every other community.
This resampling sometimes reduced the specific richness compared to the full observed sample.
In rare cases, larger samples had fewer individuals and we resampled with replacement to get to the target number of individuals.')
)][, ":="(
   gamma_bounding_box = geosphere::areaPolygon(data.frame(na.omit(longitude), na.omit(latitude))[grDevices::chull(na.omit(longitude), na.omit(latitude)), ]) / 10^6),
   by = .(dataset_id, year)]

ddata[, c("effort","latitude","longitude") := NULL]

## Saving standardised data ----
data.table::setkey(ddata, dataset_id)
data.table::setkey(meta, dataset_id)
dataset_ids <- unique(meta$dataset_id)

for (dataset_id_i in dataset_ids) {
   data.table::fwrite(
      x = ddata[dataset_id_i],
      file = paste0("data/wrangled data/", dataset_id_i, "/", dataset_id_i, "_standardised.csv"),
      row.names = FALSE
   )
   data.table::fwrite(
      x = meta[dataset_id_i],
      file = paste0("data/wrangled data/", dataset_id_i, "/", dataset_id_i, "_standardised_metadata.csv"),
      row.names = FALSE
   )
}
