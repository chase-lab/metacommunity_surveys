dataset_id <- "warren_2022"
datapath <- "data/raw data/warren_2022/rdata1.rds"
spatialpath <- "data/raw data/warren_2022/rdata2.rds"

ddata <- base::readRDS(datapath)
spatial <- base::readRDS(spatialpath)
# Raw Data ----

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

#copy for later standartisation
raw <- data.table::copy(ddata)

## community ----
ddata <- ddata[, ":="(
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
  end_date_year = NULL
)]

## meta ----
meta <- unique(ddata[, .(dataset_id, year, regional, local)])
meta[, ":="(
  realm = "Terrestrial",
  taxon = "Birds",
  
  latitude = ddata[,mean(latitude)],
  longitude = ddata[,mean(longitude)], 
  
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
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
                   row.names = FALSE
)

# Standardised Data ----
## effort standardisation ----
### remove duplicated entries in raw ddata ----
raw <- unique(raw)

### Selecting one sampling month from one season: 01,12 or 10 per local per year ----
raw <- raw[month %in% c(01,12,10)]
raw <- raw[!raw[(regional == "ESCA"| regional == "riparian") & month == "12" & year == "2003"], on = c("year", "regional", "local")]

### selecting one observer per local per year: ----
set.seed(42)
raw <- raw[raw[,.(observer = observer[sample(x = 1:.N, size = 1L)]),
                     by = local],on = c("local", "observer")]


## sum bird count over direction, seen, heard, distance ----
raw[, value := sum(value), by = .(local, year, species)]

## remove duplicates, keep summed bird count ----
raw <- raw[!duplicated(raw), ]

## update community ----
final <- ddata[unique(raw[,.(local, regional, species, value, latitude, longitude, year, month, day)]), on = .(regional, local, species, value, latitude, longitude, year, month, day)]

common <- intersect(colnames(raw), colnames(ddata))
final <- merge(raw[,c("local","species","value","regional","latitude","longitude","year","month","day")], ddata, by = common, all.x = TRUE, all.y = FALSE)

final <- final[!duplicated(final),]
## meta ----

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
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised_metadata.csv"),
                   row.names = FALSE

)

