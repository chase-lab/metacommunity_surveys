dataset_id <- "warren_2022"
datapath <- "data/raw data/warren_2022/rdata1.rds"
spatialpath <- "data/raw data/warren_2022/rdata2.rds"

ddata <- base::readRDS(datapath1)
spatial <- base::readRDS(datapath2)

#remove duplicated entries in ddata - why there are duplicates?
ddata <- unique(ddata)
#unique site-code entries in spatial data
spatial <- unique(spatial, by = "site_code" )
#combine spatial and observational data
ddata <- ddata[spatial, on = "site_code"]

ddata[, year := format(ddata$survey_date, "%Y")]
ddata[, month := format(ddata$survey_date, "%m")]
data.table::setnames(ddata, c("location_type", "site_code", "common_name", "lat", "long"), c("regional", "local", "species", "latutide", "longitude"))
ddata[, latitude := mean(latitude), by = .(regional, local)]
ddata[, longitude := mean(longitude), by = .(regional, local)]

ddata[, ":="(
  dataset_id = dataset_id,
  
  metric = "abundance",
  unit = "count",
  
  survey_id = NULL, 
  survey_date = NULL, 
  time_start = NULL, 
  time_end = NULL, 
  observer = NULL, 
  code = NULL, 
  distance = NULL, 
  observation_notes = NULL, 
  seen = NULL, 
  heard = NULL, 
  direction = NULL, 
  qccomment = NULL, 
  begin_date = NULL, 
  begin_date_month = NULL, 
  begin_date_year = NULL, 
  end_date = NULL, 
  end_date_month = NULL, 
  end_date_year = NULL, 
)]


# meta ----
meta <- unique(ddata[, .(dataset_id, year, regional, local)])
meta[, ":="(
  realm = "Terrestrial",
  taxon = "Birds",
  
  
  longitude = "from ddata", #average
  
  study_type = "ecological_sampling", #two possible values, or NA if not sure
  
  data_pooled_by_authors = FALSE,
  
  #unclear, depends whether regional stays regional - then there are years in which there was only one month sampled -> effort = 1?
  effort = 1L,
  
  alpha_grain = 1L ,
  alpha_grain_unit = "m2",
  alpha_grain_type = "radius",
  alpha_grain_comment = "Open Radius sampling of birds seen or heard",
  

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
[, ":="(
  gamma_sum_grains = sum(alpha_grain),
  gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6
),
  by = .(year, regional)
] 

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
