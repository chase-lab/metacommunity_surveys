dataset_id <- "reed_2022_fish"
datapath <- "data/raw data/reed_2022/rdata.rds"
ddata <- base::readRDS(datapath)

#spatial info

spatial <- data.table::data.table("SITE" = ddata[,unique(SITE)])
spatial[, ":="(
   latitude = parzer::parse_lat(c("34' 23.545' N","34' 25.340' N","34' 27.533' N","34' 23.660' N","34' 24.827' N","34' 24.170' N","34' 28.127' N","34' 24.007' N","34' 28.312' N", "34' 02.664' N","34' 03.518' N" )),
   longitude = parzer::parse_lon(c("119' 32.628' W","119' 57.176' W","120' 20.006' W","119' 43.800' W","119' 49.344' W","119' 51.472' W", "120' 07.285' W", "119' 44.663' W", "120' 08.663' W","119' 42.908' W","119' 45.458' W" ))
)]

#merge spatial to ddata
ddata <- ddata[spatial, on = "SITE"]

#sum percent_coverage, WM_GM2, DM_GM2, SFDM, AFDM and density measurement collecting all pa info
ddata[, value := sum(PERCENT_COVER, DENSITY, WM_GM2, DM_GM2, SFDM, AFDM,  na.rm = TRUE), by = c("SITE", "TRANSECT", "SP_CODE", "YEAR")]
ddata <- ddata[value > 0, value := 1L][value != 0]

#rename cols
data.table::setnames(ddata, c("YEAR", "SITE", "SCIENTIFIC_NAME"), c("year", "local", "species"))

#split dataset:
#group fish
ddata <- ddata[TAXON_CLASS == "Elasmobranchii" | TAXON_CLASS == "Actinopterygii"]

# community ----
ddata[, ":="(
   dataset_id = dataset_id,

   local = paste(local, TRANSECT, sep = "_"),

   metric = "pa",
   unit = "pa",

   regional = "Santa Barbara Channel",

   DATE = NULL,
   MONTH = NULL,
   TRANSECT = NULL,
   TAXON_KINGDOM = NULL,
   TAXON_PHYLUM = NULL,
   TAXON_CLASS = NULL,
   TAXON_ORDER = NULL,
   TAXON_FAMILY = NULL,
   TAXON_GENUS = NULL,
   COMMON_NAME = NULL,
   SP_CODE = NULL,
   PERCENT_COVER = NULL,
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

# meta ----
meta <- unique(ddata[, .(dataset_id, year, regional, local, latitude, longitude)])
meta[, ":="(

   realm = "Marine",
   taxon = "Fish",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   effort = 1L,

   alpha_grain = 40L*2L ,
   alpha_grain_unit = "m2",
   alpha_grain_type = "transect",
   alpha_grain_comment = " fixed plots i.e. 40 m x 2 m transects",

   gamma_bounding_box_unit = "m2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "area polygon of convex-hull",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "sampled area per year",

   comment = "These data are part of a larger collection of ongoing data sets that describe the temporal and spatial dynamics of kelp forest communities in the Santa Barbara Channel. Data on the abundance (density or percent cover) and size of ~250 species of reef associated macroalgae, invertebrates and fishes, substrate type and bottom topography are collected annually (one visit per year per transect between July and October) by divers in the summer within fixed plots (i.e. 40 m x 2 m transects) at 11 sites (n = 2 to 8 transects per site) that have historically supported giant kelp (Macrocystis pyrifera). Species-specific relationships between size (or percent cover) and mass developed for the region are used to covert abundance data to common metrics of mass (e.g., wet, dry, de-calcified dry) to facilitate analyses of community dynamics involving all species. Data collection began in 2000 and is ongoing.",
   comment_standardisation = "percent_coverage, WM_GM2, DM_GM2, SFDM, AFDM and density pooled together and translated to presence absence data. dataset split in different scripts by fish, invertebrate and algae. Fish defined as members of taxon_class = Elasmobranchii or Actinopterygii"
)]

meta[, ":="(
   gamma_sum_grains = sum(alpha_grain),
   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6
), by = year]

ddata[, c("longitude","latitude") := NULL]

# saving data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE)
