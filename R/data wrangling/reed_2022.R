dataset_id <- "reed_2022"
datapath <- "data/raw data/reed_2022/rdata.rds"

ddata <- base::readRDS(datapath)

ddata <- ddata[!is.na()]
ddata[, ":="( 
  dataset_id = dataset_id, 
  
  metric = "pa", 
  count = "pa",
  
  value = 1L, #transform to presence absence data 
  
)
  ]


# meta ----
meta <- unique(ddata[, .(dataset_id, year, regional, local)])
meta[, ":="(
  
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

  
  
  
  )]