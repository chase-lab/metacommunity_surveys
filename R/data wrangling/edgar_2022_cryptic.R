# edgar_2022_cryptic ----
dataset_id <- "edgar_2022_cryptic"

# reading the data ----
ddata <- base::readRDS(file =  "data/raw data/edgar_2022_cryptic/rdata.rds")
data.table::setnames(x = ddata,
                     old = c("location", "total", "species_name"),
                     new = c("regional", "value", "species"))

# Raw data ----
## Communities ----
ddata[, ':='(
   dataset_id = factor(data.table::fifelse(program == "RLS",
                                           paste(dataset_id, program, sep = "_"),
                                           paste(dataset_id, "ATRC-ParkVic-FRDC", sep = "_"))),

   local = as.factor(paste(site_code, block, sep = '_')),

   year = data.table::year(survey_date),
   month = data.table::month(survey_date),
   day = data.table::mday(survey_date),

   metric = 'abundance',
   unit = 'count'
)]

### pooling individual observations from the same species ----
ddata <- ddata[, .(value = sum(value)), by = .(dataset_id, regional, local,
                                               program,
                                               latitude, longitude,
                                               year, month, day, survey_date,
                                               species, metric, unit)]

## Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local,
                         year, month, day,
                         latitude, longitude)])
meta[, ":="(
   realm = "Marine",
   taxon = "Fish",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = 50L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "transect",
   alpha_grain_comment = "1m wide 50m long transects",

   comment = factor("Methods: 'This dataset contains records of cryptobenthic fishes collected by RLS and ATRC divers and partners along 50m transects on shallow rocky and coral reefs using standard methods. Abundance information is available for all species recorded within quantitative survey limits (50 x 1 m swathes either side of the transect line, each distinguished as a 'Block'), with divers searching the reef surface (including cracks) carefully for hidden fishes. These observations are recorded concurrently with the macroinvertebrate observations and together make up the 'Method 2' component of the surveys. For this method, typically one 'Block' is completed per 50 m transect for the program ATRC and 2 blocks are completed for RLS' "),
   comment_standardisation = "Only fish (Bony + cartilagenous), only method 2.
Abundances of individual observations of different sizes were pooled together by species.
local is built as site_code _ block",
doi = 'https://doi.org/10.1016/j.biocon.2020.108855 | https://doi.org/10.1017/S0376892912000185'
)]

ddata[, c("latitude", "longitude") := NULL]

## Saving raw data ----
data.table::setkey(ddata, dataset_id)
data.table::setkey(meta, dataset_id)
dataset_ids <- unique(meta$dataset_id)

for (dataset_id_i in dataset_ids) {
   dir.create(paste0("data/wrangled data/", dataset_id_i), showWarnings = FALSE)
   data.table::fwrite(
      x = ddata[dataset_id_i, !c("survey_date", "program")],
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
## standardisation ----
### Pooling blocks per transect in program RLS ----
ddata[, c("local", "block") := data.table::tstrsplit(local, "_")]

#### Excluding transects with only 1 block in RLS program ----
ddata <- ddata[
   !ddata[
      i = base::grepl("RLS", dataset_id),
      j = data.table::uniqueN(block) != 2L,
      by = .(regional, local, year, month, day)][(V1)],
   on = .(regional, local, year, month, day)]

#### Randomly excluding 1 block in transects with 2 blocks in ATRC ParkVic and FRDC program ----
set.seed(42)
ddata <- ddata[
   ddata[
      i = !base::grepl("RLS", dataset_id),
      j = .(block = sample(unique(block), 1L)),
      by = .(regional, local)],
   on = .(regional, local, block)]

#### Pooling abundances from both blocks in RLS program ----
ddata[base::grepl("RLS", dataset_id),
      value := sum(value),
      by = .(regional, local, year, month, day, species)]
ddata <- unique(ddata[, block := NULL])

### Excluding sites that were sampled by several programs ----
ddata[
   !ddata[, data.table::uniqueN(program), by = .(regional, local)][V1 != 1L],
   on = .(regional, local)]
ddata[, program := NULL]

### subsetting ----
### subsetting locations/regions with 4 sites/local scale samples or more.
ddata <- ddata[
   !ddata[, data.table::uniqueN(local) < 4L, by = .(dataset_id, regional, year)][(V1)],
   on = .(dataset_id, regional, year)]

# subsetting one sample per year from the most sampled months
month_order <- table(unique(ddata[,.(dataset_id, regional, local, year, month, survey_date)])$month)
ddata <- ddata[
   unique(ddata[, .(
      dataset_id, regional, local,
      year, month,
      month_order = order(month_order, decreasing = TRUE)[match(month, names(month_order))],
      survey_date)]
   )[order(month_order)
   ][, .SD[1L], by = .(dataset_id, regional, local, year) # first sampling from the most frequently sampled month
   ][, c('month_order', 'month') := NULL],
   on = .(dataset_id, regional, local, year, survey_date)
][, c("month", "day", 'survey_date') := NULL]

### Subsetting sites samples at least 10 years apart ----
ddata <- ddata[
   !ddata[, diff(range(year)) < 9L, by = .(dataset_id, regional, local)][(V1)],
   on = .(dataset_id, regional, local)]

## Metadata
meta[, local := data.table::tstrsplit(local, "_", keep = 1L)]
meta[, c("month", "day") := NULL]

meta <- unique(meta[
   unique(ddata[, .(regional, local, year)]),
   on = .(regional, local, year)])

meta[, ":="(
   alpha_grain = data.table::fifelse(base::grepl("RLS", dataset_id), 100L, 50L),

   effort = data.table::fifelse(base::grepl("RLS", dataset_id), 2L, 1L),

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "transect",
   gamma_sum_grains_comment = "alpha_grain * number of transects per year per region",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment_standardisation = "Only fish (Bony + cartilagenous), only method 2.
In RLS program, both sides of the transects, ie blocks, were pooled together.
In RLS program, transect with only one block sampled were excluded.
Transects that were sampled by several programs were excluded.
Only regions with at least 4 sites sampled at least 10 years appart.
Abundances of individual observations of different sizes were pooled together by species."
)][, ":="(gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6,
          gamma_sum_grains = sum(alpha_grain)),
   by = .(dataset_id, regional, year)]

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
