dataset_id <- "reed_2022_macroalgae"

ddata <- base::readRDS("data/raw data/reed_2022/rdata.rds")

#Raw data ----
##spatial info ----
spatial <- data.table::data.table("SITE" = unique(ddata$SITE))
spatial[, ":="(
   latitude = parzer::parse_lat(c(
      "34' 23.545' N", "34' 25.340' N", "34' 27.533' N", "34' 23.660' N",
      "34' 24.827' N", "34' 24.170' N", "34' 28.127' N", "34' 24.007' N",
      "34' 28.312' N", "34' 02.664' N", "34' 03.518' N")),
   longitude = parzer::parse_lon(c(
      "119' 32.628' W", "119' 57.176' W", "120' 20.006' W", "119' 43.800' W",
      "119' 49.344' W", "119' 51.472' W", "120' 07.285' W", "119' 44.663' W",
      "120' 08.663' W", "119' 42.908' W", "119' 45.458' W"))
)]

##merge spatial to ddata ----
ddata <- ddata[spatial, on = "SITE"]

## converting date ----
ddata[, DATE := data.table::as.IDate(DATE, format = "%Y-%m-%d")][, day := data.table::mday(DATE)]

##split dataset: ----
#group macroalgae
ddata <- ddata[TAXON_KINGDOM == "Plantae"]

##rename cols ----
data.table::setnames(
   x = ddata,
   old = c("YEAR", "MONTH", "SITE", "SCIENTIFIC_NAME", "PERCENT_COVER"),
   new = c("year", "month", "local", "species", "value"))

##community data ----
ddata <- ddata[value != 0]
ddata[, ":="(
   dataset_id = dataset_id,

   regional = "Santa Barbara Channel",
   local = paste(local, TRANSECT, sep = "_"),

   metric = "cover",
   unit = "percent",

   DATE = NULL,
   TRANSECT = NULL,
   TAXON_KINGDOM = NULL,
   TAXON_PHYLUM = NULL,
   TAXON_CLASS = NULL,
   TAXON_ORDER = NULL,
   TAXON_FAMILY = NULL,
   TAXON_GENUS = NULL,
   COMMON_NAME = NULL,
   SP_CODE = NULL,
   DENSITY = NULL,
   WM_GM2 = NULL,
   DM_GM2 = NULL,
   SFDM = NULL,
   AFDM = NULL,
   GROUP = NULL,
   MOBILITY = NULL,
   GROWTH_MORPH = NULL,
   COARSE_GROUPING = NULL
)]

##meta data ----
meta <- unique(ddata[, .(dataset_id, year, regional, local,
                         latitude, longitude,
                         month, day)])
meta[, ":="(
   realm = "Marine",
   taxon = "Marine plants",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain_unit = "m2",

   alpha_grain = 40L * 2L,
   alpha_grain_type = "transect",
   alpha_grain_comment = " fixed plots i.e. 40 m x 2 m transects",

   comment = "These data are part of a larger collection of ongoing data sets that describe the temporal and spatial dynamics of kelp forest communities in the Santa Barbara Channel. Dataset split in different scripts by fish, invertebrate and macroalgae. Macroalgae defined as members of taxon_kingdom = plantae.
   Data on the abundance (density or percent cover) and size of ~250 species of reef associated macroalgae, invertebrates and fishes, substrate type and bottom topography are collected annually (one visit per year per transect between July and October) by divers in the summer within fixed plots (i.e. 40 m x 2 m transects) at 11 sites (n = 2 to 8 transects per site) that have historically supported giant kelp (Macrocystis pyrifera). Species-specific relationships between size (or percent cover) and mass developed for the region are used to covert abundance data to common metrics of mass (e.g., wet, dry, de-calcified dry) to facilitate analyses of community dynamics involving all species. Data collection began in 2000 and is ongoing.",
   comment_standardisation = "none needed",
   doi = 'https://doi.org/10.6073/pasta/f2d0beb83ce7ed6949364ac28df790ea'
)]

ddata[, c("longitude", "latitude") := NULL]

## save data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8")
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8")

#standardised data ----
ddata[, c("month", "day") := NULL]
meta[, c("month", "day") := NULL]

##meta data ----
meta[, ":="(
   effort = 1L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "sampled area per year",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "area polygon of convex-hull",

   comment_standardisation = "percent_coverage translated to presence absence data."
)][, ":="(
   gamma_sum_grains = sum(alpha_grain),
   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6
), keyby = year]


##save data ----
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8")
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised_metadata.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8")
