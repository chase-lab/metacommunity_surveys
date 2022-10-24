dataset_id <- "wardle_2014_plants"

###Data manually downloaded from:
### https://datacommons.anu.edu.au/DataCommons/rest/display/anudc:5755?layout=def:display
###Login for national university of australia needed. Data accessible after login without further requests.


datapath <- "./data/raw data/wardle_2014_vegetation/derg_vegetation_1993+_p903t1208.csv"

# Raw Data ----

ddata <- unique(data.table::fread(file = datapath))


#coordinates:
coords <- data.frame(longitude = c(137.86511, 138.6059, 137.86511, 138.6059),
                     latitude = c(-23.20549, -23.20549, -23.99417, -23.99417))

data.table::setnames(ddata, c("site_grid","avg_of_cover"), c("local", "value"))

#extract month
ddata[,month := unlist(stringi::stri_extract_all_regex(str = month_year, pattern = "[A-Z][a-z]{1,3}"))]


## community ----
ddata[, ":="(
   
   dataset_id = dataset_id,
   
   regional = "Simpson Desert",
   
   metric = "cover", 
   unit = "percent",
   
   site_name = NULL,
   month_year = NULL,
   trip_no = NULL,
   avg_of_fl = NULL,
   avg_of_seed = NULL
)]

## meta ----
meta <- unique(ddata[, .(dataset_id, year, regional, local)])
meta[, ":="(
   realm = "Terrestrial",
   taxon = "Plants",
   
   latitude =  "23°35'59.388″ S",
   longitude = "138°14'7.818″ E", #coordinates from download page
   
   study_type = "ecological_sampling", #two possible values, or NA if not sure
   
   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "spatial pooling: percent of coverage in an area occupying 2.5 m radius around six traps on each trapping grid and have been aggregated to grid level data",
   sampling_years = year,
   
   
   alpha_grain = 6 * pi * 2.5^2,
   alpha_grain_unit = "m2", #"acres", "ha", "km2", "m2", "cm2"
   alpha_grain_type = "plot",
   alpha_grain_comment = "percent of coverage in an area occupying 2.5 m radius around six traps on each trapping grid and have been aggregated to grid level data",
   
   
   comment = "Data manually downloaded via https://datacommons.anu.edu.au/DataCommons/rest/display/anudc:5755 for national university of australia. The authors estimated percent coverage in an area occupying 2.5 m radius around six traps on each plot and have been aggregated to plot level data. Regional in this dataset is defined as Site, local is defined as Plot "
)]

meta[, gamma_sum_grains := sum(alpha_grain), by = year]

# save data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata[,!"dead_alive"], paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
                   row.names = FALSE
)

# Standardised Data ----
## exclude rows with NA in Column percent coverage ----
ddata <- na.omit(ddata, on = "value")
## exclude rows with percent coverage of dead plants ----
ddata <- ddata[dead_alive == "Alive"]

# update meta ----
meta <- meta[unique(ddata[,.(dataset_id, regional, local, year)]), on = .(regional, local, year)]
meta[, ":=" (
   effort = 6L, #sampled annualy every April-May - constant? different amount of local per regional over time
   
   comment_standardisation = "Converted percent of cover into presence absence. Exclude rows with NA values for perent coverage. Exclude percent coverage of dead plants",
   
   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "sampled area per year",
   
   gamma_bounding_box = geosphere::areaPolygon(coords) / 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "box",
   gamma_bounding_box_comment = "coordinates provided by the authors"
   
)][, gamma_sum_grains := sum(alpha_grain), by = .(regional, year)]

# save data -----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata[,!"dead_alive"], paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
                   row.names = FALSE
)
