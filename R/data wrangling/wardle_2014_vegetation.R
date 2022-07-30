#wardle_2014
dataset_id <- "wardle_2014"

###Data manually downloaded from:
### https://datacommons.anu.edu.au/DataCommons/rest/display/anudc:5755?layout=def:display
###Login for national university of australia needed. Data accessible after login without further requests.


datapath <- "./data/raw data/wardle_2014/derg_vegetation_1993+_p903t1208.csv"

ddata <- data.table::fread(datapath)

# program uses a core of 12 sites which are spaced at least 15 km apart, each comprising two 1-ha trapping grids program uses a core of 12 sites which are spaced at least 15 km apart, each comprising two 1-ha trapping grids - Vegetation attribute are recorded in a 2.5 m radius around six pitfall traps on each vertebrate trapping grid. have been aggregated to grid level data

data.table::setnames(ddata, c("site_name", "site_grid"), c("regional", "local"))

#remove NAs in Column percent coverage
ddata <- na.omit(ddata, on = "avg_of_cover")

ddata[, ":="(
  dataset_id = dataset_id,
  
  metric = "coverage",
  unit = "percent",
  
  month_year = NULL,
  trip_no = NULL,
  avg_of_fl = NULL,
  avg_of_seed = NULL,
  dead_alive = NULL
)]


# meta ----
meta <- unique(ddata[, .(dataset_id, Year, Regional, Local)])
meta[, ":="(
  realm = "Terrestrial",
  taxon = "Plants",
  
  latitude =  "23°35'59.388″ S",
  longitude = "138°14'7.818″ E", #coordinates from download page
  
  study_type = "ecological sampling", #two possible values, or NA if not sure
  
  data_pooled_by_authors = TRUE,
  data_pooled_by_authors_comment = "percent of coverage in an area occupying 2.5 m radius around six traps on each trapping grid and have been aggregated to grid level data",
  sampling_years = NA,
  
  effort = 6L, #sampled annualy every April-May - constant? different amount of local per regional over time
  
  
  alpha_grain = 6 * pi* 2.5^2,
  alpha_grain_unit = "m2", #"acres", "ha", "km2", "m2", "cm2"
  alpha_grain_type = "plot",
  alpha_grain_comment = "percent of coverage in an area occupying 2.5 m radius around six traps on each trapping grid and have been aggregated to grid level data",
  
  gamma_bounding_box = 176.5,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "box",
  gamma_bounding_box_comment = "",
  
  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "plot",
  gamma_sum_grains_comment = "sampled area per year",
  
  comment = "Data manually downloaded via https://datacommons.anu.edu.au/DataCommons/rest/display/anudc:5755?layout=def:display for national university of australia. The authors estimated percent coverage in an area occupying 2.5 m radius around six traps on each plot and have been aggregated to plot level data. Regional in this dataset is defined as Site, local is defined as Plot ",
  comment_standardisation = "Converted percent of cover into presencce absence. Exclude rows with NA values for perent coverage. Exclude percent coverage of dead plants"
)][,
  gamma_sum_grains := sum(alpha_grain), by = .(year, regional)
]


dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)


#check continious effort: -------- local varies for regional scales
d <- ddata[, length(unique(local)), by = c("regional","year")]
d <- d[order(d$regional), ]

