dataset_id <- "warren_2022"
datapath <- "data/raw data/warren_2022/rdata1.rds"
spatialpath <- "data/raw data/warren_2022/rdata2.rds"

ddata <- base::readRDS(datapath)
spatial <- base::readRDS(spatialpath)

#remove duplicated entries in ddata - why there are duplicates?
ddata <- unique(ddata)
#unique site-code entries in spatial data
spatial <- unique(spatial, by = "site_code")
#combine spatial and observational data
ddata <- ddata[spatial, on = "site_code"]

#renaming
ddata[, year := format(ddata$survey_date, "%Y")]
ddata[, month := format(ddata$survey_date, "%m")]
ddata[, day := format(ddata$survey_date, "%d")]
data.table::setnames(ddata, c("location_type", "site_code", "common_name", "lat", "long", "bird_count"), c("regional", "local", "species", "latitude", "longitude", "value"))
ddata[, latitude := mean(latitude), by = .(regional, local)]
ddata[, longitude := mean(longitude), by = .(regional, local)]

## community ----
#many duplicated rows after deletion of columns due to identifiing information in deleted columns
#in standardized data the sum is build of duplicated rows for summing values for different distance, direction and  detection  method and 
ddata <- ddata[, ":="(
   dataset_id = dataset_id,
   
   metric = "abundance",
   unit = "count",
   
   survey_id = NULL, 
   survey_date = NULL, 
   time_start = NULL, 
   time_end = NULL, 
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
   end_date_year = NULL
)]


## meta ----
meta <- unique(ddata[, .(dataset_id, year, regional, local)])
meta[, ":="(
   taxon = "Birds",
   
   latitude = ddata[,mean(latitude)],
   longitude = ddata[,mean(longitude)], 
   realm = "Terrestrial",
   
   study_type = "ecological_sampling", #two possible values, or NA if not sure
   
   data_pooled_by_authors = FALSE,
   
   effort = NA,
   
   alpha_grain = 1L ,
   alpha_grain_unit = "m2",
   alpha_grain_type = "radius",
   alpha_grain_comment = "Open Radius sampling of birds seen or heard",
   
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "box",
   gamma_bounding_box_comment = "",
   
   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "sampled area per year",
   
   comment = "",
   comment_standardisation = ""
)]

meta[, ":="(
   gamma_sum_grains = sum(alpha_grain),
   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6
),
by = .(year, regional)
] 

## saving data ----

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata[,!"observer"], paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
                   row.names = FALSE
)

# Standardised Data ----
## effort standardisation ----
### remove duplicated entries in raw ddata ----
### ddata <- unique(ddata) # better not rather sum rows of seen, heard, distance

### selecting one sampling month from one season: 01,12 or 10 per local per year ----
ddata <- ddata[month %in% c(01,12,10)]
ddata <- ddata[!ddata[(regional == "ESCA"| regional == "riparian") & month == "12" & year == "2003"], on = c("year", "regional", "local")]

### selecting one observer per local per year: ----
set.seed(42)
ddata <- ddata[ddata[,.(observer = observer[sample(x = 1:.N, size = 1L)]),
                     by = local],on = c("local", "observer")]

# sum bird count over direction, seen, heard, distance ----
ddata[, value := sum(value), by = .(local, year, species)]

# remove duplicates, keep summed bird count ----
ddata <- ddata[!duplicated(ddata), ]

# meta ----

meta <- meta[unique(ddata[,.(dataset_id,regional, local, year)]), on = .(regional, local, year)]
meta[,":="(
   comment_standardisation = "reducing dataset to one sampling event per year in same season. reducing to one observer per sampling event per year. removing NA in bird_count. Summing bird_counts for different direction, condition and distance to one abundance measure",
   effort = 1L
)][, ":="(
   gamma_sum_grains = sum(alpha_grain),
   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6
),
by = .(year, regional)
] 



dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata[,!"observer" ], paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised_metadata.csv"),
                   row.names = FALSE
)
