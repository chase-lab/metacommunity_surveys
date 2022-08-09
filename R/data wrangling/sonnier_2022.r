dataset_id <- "sonnier_2022"

datapath <- "./data/raw data/sonnier_2022/rdata.rds"

ddata <- base::readRDS(datapath)

data.table::setnames(
   x = ddata,
   old = c("wetland_ID", "scientific_name", "incidence"),
   new = c("local", "species", "value")
)

#drop NA for year
ddata <- na.omit(ddata, cols = c("year", "species"))

ddata <- ddata[!grepl("Unknown", species)]

ddata[, ":="(
   dataset_id = dataset_id,

   regional = "Buck Island Ranch",

   metric = "abundance",
   unit = "count",

   species_ID = NULL
)]


# meta ----
meta <- unique(ddata[, .(dataset_id, year, regional, local)])
meta[, ":="(
   realm = "Terrestrial",
   taxon = "Plants",

   latitude =  "27°09′ N",
   longitude = "81°11′ W", #coordinates from paper

   study_type = "ecological sampling", #two possible values, or NA if not sure

   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "1 m2 circular quadrats at 15 random points in one 1ha plot",
   sampling_years = NA,

   effort = 1L, #one observation per year

   alpha_grain =  15L,
   alpha_grain_unit = "m2", #"acres", "ha", "km2", "m2", "cm2"
   alpha_grain_type = "ecosystem", #wetland
   alpha_grain_comment = "1 m2 circular quadrats at 15 random points in one wetland-plot",

   gamma_bounding_box = 4170L,
   gamma_bounding_box_unit = "ha",
   gamma_bounding_box_type = "functional",
   gamma_bounding_box_comment = "Buck Island Ranch,a 4170-ha commercial cattle ranch with over 600 isolated, seasonal wetlands",

   gamma_sum_grains_unit = "ha",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "sampled area per year",

   comment = "The authors sampled vegetation in 40 randomly selected wetlands on commercial cattle ranch with over 6000 isolated seasonal wetlands. THey sampled wetland vegetation at the end of the wet season during October–November. They counted species occurence in 1 m2 circular quadrats at 15 random points per wetlandstratified into five zones: the wetland centre, and its north-east, north-west, south-east and south-west quadrants.",
   comment_standardisation = "none needed"
)]

meta[, ":="(
   gamma_sum_grains = sum(alpha_grain)
),
by = .(regional, year)
]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)

