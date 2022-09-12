dataset_id <- "reed_2022"
dataset_id_fish <- "reed_2022_fish"
dataset_id_macroalgae <- "reed_2022_macroalgae"
dataset_id_invertebrate <- "reed_2022_invertebrate"

datapath <- "data/raw data/reed_2022/rdata.rds"
if (FALSE) {
   ddata <- base::readRDS(datapath)

   #sum percent_coverage and density measurement collecting all pa info
   ddata[, value := sum(PERCENT_COVER, DENSITY, na.rm = TRUE), by = c("SITE", "TRANSECT", "SP_CODE", "DATE")]
   ddata <- ddata[value > 0, value := 1L][value != 0]

   #rename cols
   data.table::setnames(ddata, c("YEAR", "MONTH", "SITE", "TRANSECT", "SCIENTIFIC_NAME"), c("year", "month", "local", "transect", "species"))

   #split dataset:
   #group fish
   ddata_fish <- ddata[TAXON_CLASS == "Elasmobranchii" | TAXON_CLASS == "Actinopterygii"]

   #group invertebrates
   ddata_invertebrate <- ddata[TAXON_KINGDOM == "Animalia" & TAXON_PHYLUM != "Chordata"]

   #group macroalgae
   ddata_macroalgae <- ddata[TAXON_KINGDOM == "Plantae"]
   #set levels new?


   ddata_invertebrate[, ":="(
      dataset_id = dataset_id_invertebrate,

      metric = "pa",
      count = "pa",

      regional = "Santa Barbara Channel",

      DATE = NULL,
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
      COARSE_GROUPING = NULL,
      value = NULL
   )]

   ddata_fish[, ":="(
      dataset_id = dataset_id_fish,

      metric = "pa",
      count = "pa",

      regional = "Santa Barbara Channel",

      DATE = NULL,
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
      COARSE_GROUPING = NULL,
      value = NULL
   )]

   #duplicates! WHY THOUGH
   ddata_macroalgae[, ":="(
      dataset_id = dataset_id_macroalgae,

      metric = "pa",
      count = "pa",

      regional = "Santa Barbara Channel",

      DATE = NULL,
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
      COARSE_GROUPING = NULL,
      value = NULL
   )
   ]

   #difficult aka different coordinates for different local scales

   meta_fish <- unique(ddata_fish[, .(dataset_id_fish, year, regional, local)])
   meta_fish[, ":="(

      realm = "Aquatic",
      taxon = "Algea, Fish, Invertebrates", # make several datasets of one to only look at one species?

      #different lat lon for different study sites aka regional?
      #Study Sites: Nine of the 11 study sites occur along the mainland coast of the Channel (Arroyo Burro 340 24.007' N 1190 44.663' W; Arroyo Hondo 340 28.312' N, 1200 08.663' W; Arroyo Quemado 340 28.127' N, 1200 07.285' W; Bulito 340 27.533' N, 1200 20.006' W; Carpinteria 340 23.545' N, 1190 32.628' W; Goleta Bay 340 24.827' N, 1190 49.344' W; Isla Vista 340 24.170' N 1190 51.472' W; Naples 340 25.340' N 1190 57.176' W; Mohawk 340 23.660' N, 1190 43.800' W) and two occur on the northern coast of Santa Cruz Island (Diablo 340 03.518' N, 1190 45.458' W; Twin Harbors West 340 02.664' N, 1190 42.908' W).

      latitude =  "",
      longitude = "",

      study_type = "ecological_sampling", #two possible values, or NA if not sure

      data_pooled_by_authors = FALSE,

      effort = 1L,


      alpha_grain = 40*2L ,
      alpha_grain_unit = "m2",
      alpha_grain_type = "transect",
      alpha_grain_comment = " fixed plots i.e. 40 m x 2 m transects",

      #
      gamma_bounding_box = ,
      gamma_bounding_box_unit = "ha",
      gamma_bounding_box_type = "box",
      gamma_bounding_box_comment = "",

      gamma_sum_grains_unit = "m2",
      gamma_sum_grains_type = "plot",
      gamma_sum_grains_comment = "sampled area per year",

      comment = "",
      comment_standardisation = ""
   )]

   meta_fish[, ":="(
      gamma_sum_grains = sum(alpha_grain)
   ),
   by = .(regional, year)
   ]


   meta_invertebrate <- unique(ddata_invertebrate[, .(dataset_id_invertebrate, year, regional, local)])
   meta_invertebrate[, ":="(

      realm = "Aquatic",
      taxon = "Algea, Fish, Invertebrates", # make several datasets of one to only look at one species?

      #different lat lon for different study sites aka regional?
      #Study Sites: Nine of the 11 study sites occur along the mainland coast of the Channel (Arroyo Burro 340 24.007' N 1190 44.663' W; Arroyo Hondo 340 28.312' N, 1200 08.663' W; Arroyo Quemado 340 28.127' N, 1200 07.285' W; Bulito 340 27.533' N, 1200 20.006' W; Carpinteria 340 23.545' N, 1190 32.628' W; Goleta Bay 340 24.827' N, 1190 49.344' W; Isla Vista 340 24.170' N 1190 51.472' W; Naples 340 25.340' N 1190 57.176' W; Mohawk 340 23.660' N, 1190 43.800' W) and two occur on the northern coast of Santa Cruz Island (Diablo 340 03.518' N, 1190 45.458' W; Twin Harbors West 340 02.664' N, 1190 42.908' W).

      latitude =  "",
      longitude = "",

      study_type = "ecological_sampling", #two possible values, or NA if not sure

      data_pooled_by_authors = FALSE,

      effort = 1L,


      alpha_grain = 40*2L ,
      alpha_grain_unit = "m2",
      alpha_grain_type = "transect",
      alpha_grain_comment = " fixed plots i.e. 40 m x 2 m transects",

      #
      gamma_bounding_box = ,
      gamma_bounding_box_unit = "ha",
      gamma_bounding_box_type = "box",
      gamma_bounding_box_comment = "",

      gamma_sum_grains_unit = "m2",
      gamma_sum_grains_type = "plot",
      gamma_sum_grains_comment = "sampled area per year",

      comment = "",
      comment_standardisation = ""
   )]

   meta_invertebrate[, ":="(
      gamma_sum_grains = sum(alpha_grain)
   ),
   by = .(regional, year)
   ]


   meta_macroalgae <- unique(ddata_macroalgae[, .(dataset_id_macroalgae, year, regional, local)])
   meta_macroalgae[, ":="(

      realm = "Aquatic",
      taxon = "Algea, Fish, Invertebrates", # make several datasets of one to only look at one species?

      #different lat lon for different study sites aka regional?
      #Study Sites: Nine of the 11 study sites occur along the mainland coast of the Channel (Arroyo Burro 340 24.007' N 1190 44.663' W; Arroyo Hondo 340 28.312' N, 1200 08.663' W; Arroyo Quemado 340 28.127' N, 1200 07.285' W; Bulito 340 27.533' N, 1200 20.006' W; Carpinteria 340 23.545' N, 1190 32.628' W; Goleta Bay 340 24.827' N, 1190 49.344' W; Isla Vista 340 24.170' N 1190 51.472' W; Naples 340 25.340' N 1190 57.176' W; Mohawk 340 23.660' N, 1190 43.800' W) and two occur on the northern coast of Santa Cruz Island (Diablo 340 03.518' N, 1190 45.458' W; Twin Harbors West 340 02.664' N, 1190 42.908' W).

      latitude =  "",
      longitude = "",

      study_type = "ecological_sampling", #two possible values, or NA if not sure

      data_pooled_by_authors = FALSE,

      effort = 1L,


      alpha_grain = 40*2L ,
      alpha_grain_unit = "m2",
      alpha_grain_type = "transect",
      alpha_grain_comment = " fixed plots i.e. 40 m x 2 m transects",

      #
      gamma_bounding_box = ,
      gamma_bounding_box_unit = "ha",
      gamma_bounding_box_type = "box",
      gamma_bounding_box_comment = "",

      gamma_sum_grains_unit = "m2",
      gamma_sum_grains_type = "plot",
      gamma_sum_grains_comment = "sampled area per year",

      comment = "",
      comment_standardisation = ""
   )]

   meta_macroalgae[, ":="(
      gamma_sum_grains = sum(alpha_grain)
   ),
   by = .(regional, year)
   ]




   dir.create(paste0("data/wrangled data/", dataset_id_fish), showWarnings = FALSE)
   dir.create(paste0("data/wrangled data/", dataset_id_invertebrate), showWarnings = FALSE)
   dir.create(paste0("data/wrangled data/",dataset_id_macroalgae), showWarnings = FALSE)


   data.table::fwrite(ddata_fish, paste0("data/wrangled data/", dataset_id_fish, "/", dataset_id_fish, ".csv"),
                      row.names = FALSE
   )
   data.table::fwrite(meta_fish, paste0("data/wrangled data/", dataset_id_fish, "/", dataset_id_fish, "_metadata.csv"),
                      row.names = FALSE
   )
   data.table::fwrite(ddata_invertebrate, paste0("data/wrangled data/", dataset_id_invertebrate, "/", dataset_id_invertebrate, ".csv"),
                      row.names = FALSE
   )
   data.table::fwrite(meta_invertebrate, paste0("data/wrangled data/", dataset_id_invertebrate, "/", dataset_id_invertebrate, "_metadata.csv"),
                      row.names = FALSE
   )
   data.table::fwrite(ddata_macroalgae, paste0("data/wrangled data/", dataset_id_macroalgae, "/", dataset_id_macroalgae, ".csv"),
                      row.names = FALSE
   )
   data.table::fwrite(meta_macroalgae, paste0("data/wrangled data/", dataset_id_macroalgae, "/", dataset_id_macroalgae, "_metadata.csv"),
                      row.names = FALSE
   )
}
