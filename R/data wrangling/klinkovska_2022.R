dataset_id = 'klinkovska_2022'

ddata <- base::readRDS(file = 'data/raw data/klinkovska_2022/rdata.rds')
data.table::setnames(x = ddata,
                     old = c('Rs_plot', 'deg_lat', 'deg_lon', 'Date..year.month.day.', 'Releve.area..m2.'),
                     new = c('local','latitude','longitude','date','alpha_grain'))
# Raw data ----
## melting species ----
species_list <- base::grep('_[0-9]$', colnames(ddata), value = TRUE, perl = TRUE)
ddata[, (species_list) := lapply(.SD,
                                 function(column) replace(column, column == 0, NA_real_)),
      .SDcols = species_list] # replace all 0 values by NA

ddata <- data.table::melt(
   data = ddata,
   id.vars = c('local','latitude','longitude','date','alpha_grain'),
   measure.vars = species_list,
   variable.name = 'species',
   na.rm = TRUE)

## preparing data ----
## Communities ----
ddata[, date := data.table::as.IDate(base::strptime(date, "%Y%m%d"))][, ":="(
   dataset_id = factor(paste(dataset_id, "grain", alpha_grain, sep = "_")),

   regional = factor("Jeseniky, CZ"),
   local = factor(base::substr(local, 9L, 11L)),

   year = data.table::year(date),
   month = data.table::month(date),
   day = data.table::mday(date),

   metric = 'cover',
   unit = 'percent',

   species = base::gsub("_[0-9]$", '', species, perl = TRUE),

   date = NULL
)]

ddata <- ddata[alpha_grain != 0L]

## Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, month, day,
                         latitude, longitude, alpha_grain)])
meta[, ':='(
   taxon = "Plants",
   realm = "Terrestrial",

   study_type = "resurvey",
   data_pooled_by_authors = FALSE,

   alpha_grain_unit = "m2",
   alpha_grain_type = "plot",
   alpha_grain_comment = "given by the authors",

   comment = "Extracted from Zenodo respository https://doi.org/10.5281/zenodo.7338814 . 'The data contain plant species composition from vegetation plots repeatedly surveyed in the Hrubý Jeseník Mountains (Eastern Sudetes, Czech Republic). Vegetation plots surveyed by Leoš Bureš and Zuzana Burešová in 1973–1978 were resurveyed in 2004–2010 by Martin Kočí and Leo Bureš and resurveyed again in 2021 by the authors of this dataset. Several new plots were also surveyed in 2004–2010 and resurveyed in 2021'. METHOD: 'Plot size and shape varied by vegetation type. Repeated sampling always used the same plot size as the previous sampling. Most plots were squares of 100 m2 in woodlands and 16 m2 in grasslands or rectangles of 10 m2 in springs. The size/type of plot is given in the alpha_grain column. All species of vascular plants were recorded in each plot'. ",
   comment_standardisation = "none needed",
   doi = 'https://doi.org/10.1111/avsc.12711'
)]

ddata[, c("latitude", "longitude") := NULL]

## splitting and saving into several studies because several sampling gears were used ----
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
## Communities ----

### Data selection ----
#### years with less than 4 localities sampled were excluded ----
ddata <- ddata[
   !ddata[, data.table::uniqueN(local), by = .(dataset_id, year)][(V1 < 4L)],
   on = .(dataset_id, year)]

#### focusing on sites resurveyed at least 10 years apart ----
ddata <- ddata[
   !ddata[, diff(range(year)), by = .(dataset_id, regional, local)][V1 < 9L],
   on = .(dataset_id, regional, local)]

ddata[, ":="(
   value = 1L,
   metric = 'pa',
   unit = 'pa',

   alpha_grain = NULL,
   month = NULL,
   day = NULL
)]

## Metadata ----
meta[, c("month","day") := NULL]
meta <- meta[unique(ddata[, .(dataset_id, regional, local, year)]),
             on = .(dataset_id, regional, local, year)]

meta[, ":="(
   effort = 1L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "sum of the sampled areas from all sites on a given year",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment_standardisation = "The data set was split depending on plot size.
Percentage cover was converted into presence absence.
Years with less than 4 sites sampled were excluded.
Only sites sampled at least 10 years apart were kept."
)][, ":="(
   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6,
   gamma_sum_grains = sum(alpha_grain)),
   by = .(dataset_id, regional, year)]

## saving standardised data ----
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
