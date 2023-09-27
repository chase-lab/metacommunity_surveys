dataset_id <- "maleki_2021"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))

# Raw Data ----
## aggregating at the species level ----
ddata <- ddata[, .(value = .N, lat = lat[1], long = long[1]),
               by = .(plot_id, year, species_name, status_id)]
data.table::setnames(ddata,
                     old = c("plot_id", "species_name", "lat", "long"),
                     new = c("local", "species", "latitude", "longitude"))

## make copy for standardisation including life stage info, status_id: ----
ddatax <- data.table::copy(ddata)

## pooling life stages aka status_id:  ----
ddata <- ddata[, status_id := NULL][, lapply(.SD, sum), by = .(year, local, latitude, longitude, species)]

## community data ----
ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Lake Duparquet Research and Teaching Forest in western Quebec",

   metric = "abundance",
   unit = "count"
)]

## meta data ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, latitude, longitude)])
meta[, ":="(
   taxon = "Plants",
   realm = "Terrestrial",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = 1L,
   alpha_grain_unit = "ha",
   alpha_grain_type = "sample",
   alpha_grain_comment = "6 1ha permanent plots - given by the authors",

   comment = "Extracted from Maleki et al dryad repository (https://doi.org/10.5061/dryad.tqjq2bvwz). Tree community assessment between 1994 and 2019. Regional is the Lake Duparquet Research and Teaching Forest reserve, local are 6 1ha permanent plots. The name of the plots refer to the year when they were burnt. 'Each plot was divided into 100-m2 subplots, on which all living and dead trees (standing and fallen) with DBH greater than 5 cm were measured, mapped and identified to species level.' ",
   comment_standardisation = "None needed",
   doi = 'https://doi.org/10.5061/dryad.tqjq2bvwz'
)]

ddata[, ":="(
   latitude = NULL,
   longitude = NULL
)]

## save raw data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8"
)

data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8"
)

# Standardised Data ----
## alive trees only ----
ddata <- ddatax[!grepl(pattern = "A", x = status_id, fixed = TRUE)][, status_id := NULL]
ddata[, ":="(
   latitude = NULL,
   longitude = NULL
)]

ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Lake Duparquet Research and Teaching Forest in western Quebec",

   metric = "abundance",
   unit = "count"
)]

## pooling together all alive trees ----
ddata <- ddata[, .(value = sum(value)), by = .(dataset_id, regional, local, year,
                                              species, metric, unit)]

## meta data ----
meta <- meta[unique(ddata[, .(local, year)]),
             on = .(local, year)]

meta[,":="(
   effort = 1L,

   gamma_sum_grains = 6L,
   gamma_sum_grains_unit = "ha",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of the areas of the 6 1ha plots",

   gamma_bounding_box = 8045L,
   gamma_bounding_box_unit = "ha",
   gamma_bounding_box_type = "functional",
   gamma_bounding_box_comment = "area of the LDRTF",

   comment_standardisation = "Dead trees were excluded but fallen alive trees were kept."
)]

## save standardised data ----
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8"
)

data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised_metadata.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8"
)
