# russel-smith_2017_trees
dataset_id <- "russell-smith_2017_trees"

ddata <- base::readRDS(file = "data/raw data/russel-smith_2017_trees/rdata.rds")

## data preparation ----
### remove NA values in year because of missing dates in original data ----
ddata <- na.omit(ddata, cols = "date")

ddata_standardised <- data.table::copy(ddata)

# Raw Data ----
### Sum individual observations to get species abundances ----
ddata <- ddata[, .N, by = .(park, plot, visit, genus_species, date, latitude, longitude)]

data.table::setnames(ddata,
                     old = c("park", "plot","genus_species", "N"),
                     new = c("regional","local","species", "value"))

### excluding unknown species ----
ddata <- ddata[species != ""]

## community data ----
ddata[, ":="(
   dataset_id = dataset_id,

   year = data.table::year(date),
   month = data.table::month(date),
   day = data.table::mday(date),

   metric = "abundance",
   unit = "count",

   visit = NULL,
   date = NULL
)][species %in% c("NO TREES",""), ":="(species = "NONE", value = 0L)]

## cleaning: deleting samples with duplicated rows ----
ddata <- ddata[
   !ddata[, .N, by = .(regional, local, year, month, day, species)][N != 1L],
   on = c("regional", "local", "year", "month", "day")
]

meta <- unique(ddata[, .(dataset_id, regional, local, latitude, longitude,
                         year, month, day)])

meta[, ":="(
   realm = "Terrestrial",
   taxon = "Plants",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = 800L,  #area of individual plot
   alpha_grain_unit = "m2", #"acres", "ha", "km2", "m2", "cm2"
   alpha_grain_type = "plot",
   alpha_grain_comment = "all trees defined as wooden species with diameter at breast hight > 5cm are counted in 40*20m plot ",

   comment = factor("Data manually downloaded via https://datacommons.anu.edu.au/DataCommons/rest/records/anudc:5836/data/ with login for national university of australia webpage. Authors sampled trees with DBH (diameter at breast hight) > 5cm in fixed 40m*20m plots once a year."),
   comment_standardisation = "some visit numbers (T1, T2,...) have no match (year) in the dates table so they were excluded.
Some rows were duplicated so all results from these problematic plot/year subsets were excluded.
Dead trees were kept.
Empty samples with species == NO TREES were given a value of 0 instead of 1 and name was replaced with NONE",
   doi = 'https://doi.org/10.25911/5c3d75bbca1c0'
)]

ddata[, c("latitude", "longitude") := NULL]

## save data ----
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

# standardised Data -----
### Sum individual observations to get species abundances ----
ddata <- ddata_standardised[!(is_the_tree_dead)]
ddata <- ddata[, .N, by = .(park, plot, visit, genus_species, date)]

data.table::setnames(ddata,
                     old = c("park", "plot","genus_species", "N"),
                     new = c("regional","local","species", "value"))

### excluding unknown species ----
ddata <- ddata[species != "NONE"]

## community data ----
ddata[, ":="(
   dataset_id = dataset_id,

   year = data.table::year(date),
   month = data.table::month(date),
   day = data.table::mday(date),

   metric = "abundance",
   unit = "count",

   visit = NULL,
   date = NULL
)]

## cleaning: deleting samples with duplicated rows ----
ddata <- ddata[
   !ddata[, .N, by = .(regional, local, year, month, day, species)][N != 1L],
   on = c("regional", "local", "year", "month", "day")
]

## Excluding sites that were not resampled at least 10 years apart
ddata <- ddata[
   !ddata[, .(diff(range(year)) < 9L), by = .(regional, local)][(V1)],
   on = .(regional, local)
]

ddata[, c("month","day") := NULL]

## meta data ----
meta[, c("month", "day") := NULL]
meta <- meta[unique(ddata[, .(regional, local, year)]),
             on = .(regional, local, year)]

meta[, ":="(
   effort = 1L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "area of the sampled plots per year multiplied by amount of plots per region",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "convex-hull over the coordinates of sample points",

   comment_standardisation = "some visit numbers (T1, T2,...) have no match (year) in the dates table so they were excluded.
Some rows were duplicated so all results from these problematic plot/year subsets were excluded.
Sites that were not resampled at least 10 years apart were excluded.
Dead trees were excluded"
)][, ":="(
   gamma_bounding_box = geosphere::areaPolygon(data.frame(na.omit(longitude), na.omit(latitude))[grDevices::chull(na.omit(longitude), na.omit(latitude)), ]) / 10^6,
   gamma_sum_grains = sum(alpha_grain)
), by = .(regional, year)]

## save standardised data ----
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
