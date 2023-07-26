# edgar_2022_fish ----
dataset_id <- "edgar_2022_fish"

# reading the data ----
ddata <- base::readRDS(file =  "data/raw data/egar_2022_fish/rdata.rds")
data.table::setnames(x = ddata,
                     old = c("location", "site_code", "total", "species_name"),
                     new = c("regional", "local", "value", "species"))
# raw data ----
## Communities ----
ddata <- ddata[data.table::like(vector = class, pattern = "Actinopterygii|Elasmobranchii", fixed = FALSE) & method == 1L]

ddata[, ':='(
   dataset_id = dataset_id,

   year = data.table::year(survey_date),
   month = data.table::month(survey_date),
   day = data.table::mday(survey_date),

   metric = 'abundance',
   unit = 'count'
)]

### pooling individual observations from the same species ----
ddata <- ddata[, .(value = sum(value)), by = .(regional, local,
                                               latitude, longitude,
                                               year, month, day, survey_date,
                                               species)]

## Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, month, day, latitude, longitude)])
meta[, ":="(
   realm = "Marine",
   taxon = "Fish",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = 250L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "transect",
   alpha_grain_comment = "5m wide50m long transects",

   comment = "Methods: 'This dataset contains records of bony fishes and elasmobranchs collected by Reef Life Survey (RLS) and Australian Temperate Reef Collaboration (ATRC) divers and partners along 50m transects on shallow rocky and coral reefs using standard methods. Abundance information is available for all species recorded within quantitative survey limits (50 x 5 m swathes either side of the transect line, each distinguished as a 'Block'), with size and biomass data also included when available. These observations form the Method 1 component of the surveys' ",
   comment_standardisation = "Only fish (Bony + cartilagenous), only method 1. Abundances of individual observations of different sizes were pooled together by species.",
   doi = 'https://doi.org/10.1016/j.biocon.2020.108855 | https://doi.org/10.1017/S0376892912000185'
)]

ddata[, c("latitude", "longitude") := NULL]

## saving raw data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata[, !"survey_date"],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)


# Standardised data ----
## standardisation ----
### subsetting ----
### subsetting locations/regions with 4 sites/local scale samples or more.
ddata <- ddata[
   ddata[, data.table::uniqueN(local) >= 4L,
         by = regional][(V1)][, V1 := NULL],
   on = .(regional)
]

# subsetting one sample per year from the most sampled months
month_order <- table(unique(ddata[,.(regional, local, year, month, survey_date)])$month)
ddata <- ddata[
   unique(ddata[, .(
      regional, local,
      year, month,
      month_order = order(month_order, decreasing = TRUE)[match(month, names(month_order))],
      survey_date)]
   )[order(month_order)
   ][, .SD[1L], by = .(regional, local, year) # first sampling from the most frequently sampled month
   ][, c('month_order', 'month') := NULL],
   on = .(regional, local, year, survey_date)
][, c("month", "day", 'survey_date') := NULL]


## Metadata ----
meta[, c("month", "day") := NULL]
meta <- unique(meta[
   unique(ddata[, .(regional, local, year)]),
   on = .(regional, local, year)])

meta[, ":="(
   effort = 1L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "transect",
   gamma_sum_grains_comment = "number of transects per year per region * 250m2",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment_standardisation = "Only fish (Bony + cartilagenous), only method 1, only regions with at least 4 sites, when there are several samplings a year, only the first sample from the most frequently sampled month.
    Abundances of individual observations of different sizes were pooled together by species."
)][, ":="(gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6,
          gamma_sum_grains = sum(alpha_grain)),
   by = .(regional, year)]

## saving standardised data
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
