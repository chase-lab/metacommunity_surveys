dataset_id <- "sonnier_2022"

datapath <- "./data/raw data/sonnier_2022/rdata.rds"

ddata <- base::readRDS(datapath)

data.table::setnames(
   x = ddata,
   old = c("wetland_ID", "scientific_name"),
   new = c("local", "species")
)

#Raw Data----

#drop NA for year
ddata <- ddata[!grepl("Unknown", species) & !is.na(year) & !is.na(species)]
ddata_raw <- data.table::copy(ddata)

ddata_raw[, ":="(
   dataset_id = dataset_id,
   
   regional = "Buck Island Ranch",

   metric = "incidence",
   unit = "count",

   species_ID = NULL
)]


##meta data ----
meta <- unique(ddata_raw[, .(dataset_id, year, regional, local)])
meta[, ":="(
   realm = "Terrestrial",
   taxon = "Plants",
   
   latitude =  "27°09′ N",
   longitude = "81°11′ W", #coordinates from paper
   
   study_type = "ecological_sampling", #two possible values, or NA if not sure
   
   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "spatial pooling: 1 m2 circular quadrats at 15 random points in one 1ha plot",
   sampling_years = year,
   
   alpha_grain =  15L,
   alpha_grain_unit = "m2", #"acres", "ha", "km2", "m2", "cm2"
   alpha_grain_type = "functional", #wetland
   alpha_grain_comment = "1 m2 circular quadrats at 15 random points in one wetland-plot",
   
   comment = "The authors sampled vegetation in 40 randomly selected wetlands on commercial cattle ranch with over 6000 isolated seasonal wetlands. THey sampled wetland vegetation at the end of the wet season during October–November. They counted species occurence in 1 m2 circular quadrats at 15 random points per wetland stratified into five zones: the wetland centre, and its north-east, north-west, south-east and south-west quadrants.",
   comment_standardisation = "rows with year = NA and Unknown species were excluded."
   doi = 'https://doi.org/10.6073/pasta/f20622c01b40e1e08e72f01e29f59302'
)]

##save data ----

base::dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata_raw,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized_metadata.csv"),
   row.names = FALSE
)

#Standardized Data ----
##exclude unknown species ----
ddata <- ddata[, ":="(
   metric = "pa",
   unit = "pa",
   value = 1L,

   species_ID = NULL
)]

##meta data ----
meta <- meta[unique(ddata[, .(dataset_id, local, regional, year)]),
             on = .(local, regional, year)]

meta[,":="(
   effort = 1L, #one observation per year
   
   gamma_bounding_box = 4170L,
   gamma_bounding_box_unit = "ha",
   gamma_bounding_box_type = "administrative",
   gamma_bounding_box_comment = "Buck Island Ranch,a 4170-ha commercial cattle ranch with over 600 isolated, seasonal wetlands",
   
   gamma_sum_grains_unit = "ha",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "sampled area per year",

   comment_standardisation = "Unidentified species were excluded. Incidence (ie nb of quadrats in which a given species is detected) turned into presence-absence"
)][, gamma_sum_grains := sum(alpha_grain), by = year]

##save data ---
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized_metadata.csv"),
   row.names = FALSE
)
