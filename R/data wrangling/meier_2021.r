# Meier_2021
dataset_id <- 'meier_2021'

ddata <- base::readRDS(file = "./data/raw data/meier_2021/rdata.rds")
data.table::setnames(x = ddata, c('Year', 'Plot size [m2]','Relevé.number'), c('year', 'alpha_grain', 'local'))

# Data selection -----
ddata <- ddata[alpha_grain != '20']

# Communities ----
ddata[, ':='(
   dataset_id = 'meier_2021',

   regional = base::paste('grain', alpha_grain, 'm2', sep = '_'),
   year = base::as.integer(year),

   value = 1L,
   metric = 'pa',
   unit = 'pa',

   `Relevé number` = NULL
)]

# Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, coordinates, alpha_grain)])

meta[, c('latitude','longitude') := data.table::tstrsplit(coordinates, '; ')][, coordinates := NULL]

meta[, ':='(
   taxon = "Plants",
   realm = "Terrestrial",

   effort = 1L,

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,
   sampling_years = NA,

   latitude = parzer::parse_lat(latitude),
   longitude = parzer::parse_lon(longitude),

   alpha_grain = as.numeric(alpha_grain),
   alpha_grain_unit = "m2",
   alpha_grain_type = "plot",
   alpha_grain_comment = "area of the sampling points",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of the sampled areas of all sites on a given year",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment = "Data extracted from the pdf found here: https://www.tuexenia.de/publications/tuexenia/Tuexenia_2021_NS_041_0203-0226.pdf . Original data are Relevés from dry or semi dry grasslands of Germany. METHODS: Seven study areas were selected from two regions in Central Germany that have pronounced occurrences of xerothermic grasslands: (1) Saaletal northwest of Halle (Saale) and (2) Kyffhäuser [...] The previous plots were identified using location sketches or vegetation maps prepared by the authors of the studies (SCHNEIDER 1996, RICHTER 2002). Using GoogleEarth (image overlay), the position for each plot could be relocated and its GPS coordinate specified, while GPS coordinates were already available in PUSCH & BARTHEL (2003). The new vegetation relevés were carried out using the same methodology as that adopted in the original study (including area size, recording time, cover-abundance values).",
   comment_standardisation = "plots of different sizes were grouped in different regions",
   doi = 'https://doi.org/10.14471/2021.41.009'
)][, ":="(
   gamma_bounding_box = geosphere::areaPolygon(data.frame(na.omit(longitude), na.omit(latitude))[grDevices::chull(na.omit(longitude), na.omit(latitude)), ]) / 10^6,
   gamma_sum_grains = sum(alpha_grain)
), by = .(regional, year)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
   row.names = FALSE
)
