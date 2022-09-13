datapath <- "./data/raw data/wardle_2014_vegetation/derg_vegetation_1993+_p903t1208.csv"

# Raw Data ----

ddata <- unique(data.table::fread(file = datapath))


#coordinates:
coords <- data.frame(longitude = c(137.86511, 138.6059, 137.86511, 138.6059),
                     latitude = c(-23.20549, -23.20549, -23.99417, -23.99417))

data.table::setnames(ddata, c("site_grid", "avg_of_fl"), c( "local", "value"))

#extract month
ddata[,month := unlist(stringi::stri_extract_all_regex(str = month_year, pattern = "[A-Z][a-z]{1,3}"))]

## remove duplicated rows ----
ddata <- ddata[,unique(ddata)]

## exclude rows with NA in Column percent coverage ----
ddata <- na.omit(ddata, on = "value")

#copy for downstream standartisation
raw <- data.table::copy(ddata)

## community ----
ddata[, ":="(
   dataset_id = dataset_id,
   
   regional = "Simpson Desert",
   
   metric = "cover",
   unit = "percentage",
   
   avg_of_cover = NULL,
   month_year = NULL,
   trip_no = NULL,
   avg_of_seed = NULL,
   dead_alive = NULL,
   site_name = NULL, 
   
   day = NA
)]

## meta ----
meta <- unique(ddata[, .(dataset_id, year, local)])
meta[, ":="(
   realm = "Terrestrial",
   taxon = "Plants",
   
   latitude =  "23°35'59.388″ S",
   longitude = "138°14'7.818″ E", #coordinates from download page
   
   study_type = "ecological_sampling", #two possible values, or NA if not sure
   
   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "spatial pooling: percent of coverage in an area occupying 2.5 m radius around six traps on each trapping grid and have been aggregated to grid level data",
   sampling_years = year,
   
   effort = 6L, #sampled annualy every April-May - constant? different amount of local per regional over time
   
   alpha_grain = 6 * pi * 2.5^2,
   alpha_grain_unit = "m2", #"acres", "ha", "km2", "m2", "cm2"
   alpha_grain_type = "plot",
   alpha_grain_comment = "percent of coverage in an area occupying 2.5 m radius around six traps on each trapping grid and have been aggregated to grid level data",
   
   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "sampled area per year",
   
   gamma_bounding_box = geosphere::areaPolygon(coords) / 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "box",
   gamma_bounding_box_comment = "coordinates provided by the authors",
   
   comment = "Data manually downloaded via https://datacommons.anu.edu.au/DataCommons/rest/display/anudc:5755 for national university of australia. The authors estimated percent coverage in an area occupying 2.5 m radius around six traps on each plot and have been aggregated to plot level data. Regional in this dataset is defined as Site, local is defined as Plot ",
   comment_standardisation = "Converted percent of cover into presence absence"
)]

meta[, gamma_sum_grains := sum(alpha_grain), by = .( year)]

# save data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
                   row.names = FALSE
)

# Standardised Data ----

## exclude rows with percent coverage of dead plants ----
raw <- raw[dead_alive == "Alive"]
# update community ----
common <- intersect(colnames(raw), colnames(ddata))
ddata <- merge(raw[, c("species", "local", "value", "year", "month")], ddata, by = common, all.x = TRUE)

# update meta ----
meta <- meta[unique(ddata[,.(dataset_id, local, year)]), on = .( local, year)]
meta[, ":=" (
   comment_standardisation = "Converted percent of cover into presence absence. Exclude rows with NA values for perent coverage. Exclude percent coverage of dead plants"
)][, gamma_sum_grains := sum(alpha_grain), by = .( year)]

# save data -----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
                   row.names = FALSE
)

