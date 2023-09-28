dataset_id <- "lelli_2020"

coordinates <- base::readRDS("data/raw data/lelli_2020/coordinates.rds")
historical <- data.table::fread(
   file = paste0("data/raw data/", dataset_id, "/historical.csv"),
   sep = ",", header = TRUE)
resurvey <- data.table::fread(
   file = paste0("data/raw data/", dataset_id, "/resurvey.csv"),
   sep = ",", header = TRUE)

#Raw Data ----
##melting sites ----
historical <- data.table::melt(historical,
                               id.vars = "species",
                               variable.name = "local"
)
historical <- historical[value != ""]
historical[, period := "historical"]

resurvey <- data.table::melt(resurvey,
                             id.vars = "species",
                             variable.name = "local"
)
resurvey <- resurvey[value != ""]

##pooling resurvey subplots ----
resurvey[, period := "recent"]

##community data ----
ddata <- rbind(historical, resurvey)
ddata[, ":="(
   dataset_id = dataset_id,

   regional = "Northern Apennines",

   year = c(1960L, 2018L)[data.table::chmatch(period, c("historical", "recent"))],

   metric = "abundance score",
   unit = "score",

   period = NULL
)]

##meta data ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])

meta[, ":="(
   taxon = "Plants",
   realm = "Terrestrial",

   study_type = "resurvey",

   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "plots were sampled once sometime between 1934 and 1960",
   sampling_years = c("1934-1960", "2018")[match(year, c(1960L, 2018L))],

   latitude = coordinates$latitude[data.table::chmatch(sub("[ABC]", "", local), coordinates$local)],
   longitude = coordinates$longitude[data.table::chmatch(sub("[ABC]", "", local), coordinates$local)],

   alpha_grain = 40L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "plot",

   comment = "Extracted from Lelli et all 2020 appendices 6 and 7. 23 plots in Central Italy sampled for plants between 1934 and 1960 (historical record) and 2018. Methods: '22 historical plots were localized with a high confidence level and three replicates were performed for each historical record, with a final dataset of 88 plots (22 original plots and 66 resampled plots).[...]We carried out the field work from May to July 2018. We recorded the species composition following a protocol similar to that of the original surveyor and in the same period of the year (Chytrý et al., 2014; Becker, Spanka, Schröder, and Leuschner, 2017; Giarrizzo et al., 2017). We adopted the same plot size as indicated in the original data (Hédl, 2004; Förster, Becker, Gerlach, Meesenburg, and Leuschner, 2017), ranging from 40 m2 to 100 m2, in the form of squared plots placed in the direction of the maximum slope.' ",
   comment_standardisation = "Subplots sampled during the resurvey were pooled together",
   doi = 'https://doi.org/10.1111/jvs.12939'
)]

##save data ----
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

#standardised Data----
ddata[, ":="(
   local = sub("[ABC]", "", local),

   value = 1L,
   metric = "pa",
   unit = "pa"
)]

## Pooling subplots in recent ----
ddata <- unique(ddata)

##meta data ----
meta[, local := sub("[ABC]", "", local)]
meta <- unique(meta)

meta[,":="(
   effort = 1L,

   gamma_sum_grains = 40L * 22L,
   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "minimal quadrat size * number of sites",

   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors"
)]

##save data ----
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
