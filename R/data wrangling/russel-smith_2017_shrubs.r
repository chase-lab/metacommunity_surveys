# russel-smith_2017_shrubs
dataset_id <- "russell-smith_2017_shrubs"

ddata <- base::readRDS("data/raw data/russel-smith_2017_shrubs/rdata.rds")

## Summing abundances from different size class ----
ddata[, ":="(
   count_less_than_50cm = as.integer(count_less_than_50cm),
   `count_50cm-2m` = as.integer(`count_50cm-2m`),
   count_greater_than_2m = as.integer(count_greater_than_2m)
)]

ddata[, value := base::rowSums(.SD, na.rm = TRUE),
      .SDcols = c("count_less_than_50cm", "count_50cm-2m", "count_greater_than_2m")]

## remove absences
ddata <- ddata[value != 0L]

data.table::setnames(ddata,
                     old = c("park", "plot", "genus_species"),
                     new = c("regional", "local", "species"))

# Raw Data ----
## communities ----
ddata <- ddata[!is.na(date)]

ddata[, ":="(
   dataset_id = dataset_id,

   year = data.table::year(date),
   month = data.table::month(date),
   day = data.table::mday(date),

   metric = "abundance",
   unit = "count",

   visit = NULL,
   date = NULL,
   count_less_than_50cm = NULL,
   `count_50cm-2m` = NULL,
   count_greater_than_2m = NULL
)]

## cleaning: deleting samples with duplicated observations ----
ddata <- ddata[
   !unique(ddata[, .N, by = .(regional, local, year, month, day, species)][N != 1L]),
   on = c("regional", "local", "year", "month", "day")
   ]

## Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, latitude, longitude,
                         year, month, day)])

meta[, ":="(
   realm = "Terrestrial",
   taxon = "Plants",

   study_type = "ecological_sampling", #two possible values, or NA if not sure

   data_pooled_by_authors = FALSE,

   alpha_grain = 400L,  #area of individual plot
   alpha_grain_unit = "m2", #"acres", "ha", "km2", "m2", "cm2"
   alpha_grain_type = "plot",
   alpha_grain_comment = "all shrubs counted in 40m *10m plots",

   comment = factor("Data manually downloaded via https://datacommons.anu.edu.au/DataCommons/rest/records/anudc:5836/data/ with login for national university of australia website. Authors sampled shrubs from the inner 40m*10m plot of their fixed 40m*20m plots once a year. They measured the height of all shrubs and we kept only abundances."),
   comment_standardisation = factor("some visit numbers (T1, T2, ...) had no match (year) in the dates table so they were excluded.
Some species observations were duplicated so all results from these problematic plot/year samples were excluded."),
   doi = 'https://doi.org/10.25911/5c3d75bbca1c0'
)]

ddata[, c("latitude", "longitude") := NULL]

## save raw data ----
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

# standardised data ----
## Excluding sites that were not resampled at least 10 years apart ----
ddata <- ddata[
   !ddata[, .(diff(range(year)) < 9L), by = .(regional, local)][(V1)],
   on = .(regional, local)
]

## Only one sample per year
# ddata[, data.table::uniqueN(.SD), by = .(regional, local, year), .SDcols = c("month", "day")][, any(V1 != 1L)]
ddata[, c("month","day") := NULL]

## meta data ----
meta <- meta[unique(ddata[, .(regional, local, year)]),
             on = .(regional, local, year)]
meta[, ":="(
   month = NULL,
   day = NULL,

   effort = 1L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "area of the sampled plots per year multiplied by amount of plots per region",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "convex-hull over the coordinates of sample points",

   comment_standardisation = factor("some visit numbers (T1, T2, ...) had no match (year) in the dates table so they were excluded. Authors sampled shrubs from the smallest size class in subplots but since the size of subplot is constant, no standardisation is needed. Some rows were duplicated so all results from these 5 problematic plot/year subsets were excluded.
Sites that were not resampled at least 10 years apart were excluded.")
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
