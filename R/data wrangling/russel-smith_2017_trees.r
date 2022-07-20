# russel-smith_2017_trees
dataset_id <- "russell-smith_2017_trees"

###Data manually downloaded from:
### https://datacommons.anu.edu.au/DataCommons/rest/records/anudc:5836/data/
###  Spacial data manually downloaded from:
###  https://datacommons.anu.edu.au/russell-smith_2017/dataCommons/rest/records/anudc:5837/data/
###  Login for Australian National University needed. Data accessible after login without further requests.

# loading data ----
datafiles <- c(
  "./data/raw data/russell-smith_2017/data/tpsk_trees_1994+_p831t1066.csv",
  "./data/raw data/russell-smith_2017/data/tpsl_trees_1994+_p831t1124.csv",
  "./data/raw data/russell-smith_2017/data/tpsn_trees_1994+_p831t1129.csv"
)
datafiles_dates <- c(
  "./data/raw data/russell-smith_2017/data/tpsk_visit_date_1994+_p831t1067.csv",
  "./data/raw data/russell-smith_2017/data/tpsl_visit_date_1994+_p831t1125.csv",
  "./data/raw data/russell-smith_2017/data/tpsn_visit_date_1994+_p831t1153.csv"
)

datafiles_spatial <- c(
  "./data/raw data/russell-smith_2017/spatial/tpsk_plot_details_spatial_coordinates_p894t1154.csv",
  "./data/raw data/russell-smith_2017/spatial/tpsl_plot_details_spatial_coordinates_p894t1155.csv",
  "./data/raw data/russell-smith_2017/spatial/tpsn_plot_details_spatial_coordinates_p894t1156.csv"
)



ddata <- data.table::rbindlist( fill = TRUE,
  lapply(
    datafiles,
    FUN = function(x)
      data.table::fread(file = x)
  ),
  use.names = TRUE, idcol = FALSE
)

dates <- data.table::rbindlist(
  lapply(
    datafiles_dates,
    FUN = function(x)
      data.table::fread(file = x)
  ),
  use.names = TRUE, idcol = FALSE
)

spatial <- data.table::rbindlist(
  lapply(
    datafiles_spatial,
    FUN = function(x)
      data.table::fread(file = x)
  ), 
  use.names = TRUE, idcol = FALSE, fill = TRUE
)

####Trees are defined as any woody species with diameter at breast height (DBH) > 5cm.

#merge data and dates
ddata <- dates[ddata, on = c("park", "plot", "visit")]
ddata <- ddata[,.N, by = .(park, plot, visit, genus_species, date)]

data.table::setnames(ddata, c("park", "plot","genus_species", "N"), c("regional","local","species", "value"))

#format spatial data to have common identifier with ddata
spatial[, regional := c("Kakadu","Litchfield","Nitmiluk")[match(substr(plot, 1, 3), c("KAK","LIT","NIT"))]]
spatial[, local := stringi::stri_extract_all_regex(str = plot, pattern = "[0-9]{2,3}")
][, local := as.integer(sub("^0+(?=[1-9])", "", local, perl = TRUE))]


ddata[, ":="(
  dataset_id = dataset_id,
  year = format(date, "%Y"),
  visit = NULL,
  date = NULL
)]

#remove NA values in year
ddata <- na.omit(ddata, cols = "year")

meta <- unique(ddata[, .(dataset_id, year, regional, local)])
meta <- meta[spatial[, .(local, regional, latitude, longitude)], on = c("local", "regional")]
meta[, ":="(
  realm = "Terrestrial",
  taxon = "Trees",
  
  latitude = as.numeric(spatial[, .(x = mean(latitude))]),
  longitude = as.numeric(spatial[, .(x = mean(longitude))]),
  
  study_type = "ecological sampling", #two possible values, or NA if not sure
  
  data_pooled_by_authors = FALSE,
  data_pooled_by_authors_comment = NA,
  sampling_years = NA,
  
  effort = 1L, # Effort is the minimal number of sampling operations
  
  alpha_grain = 800L,  #area of individual plot
  alpha_grain_unit = "m2", #"acres", "ha", "km2", "m2", "cm2"
  alpha_grain_type = "plot",
  alpha_grain_comment = "all trees defined as wooden species with diameter at breast hight > 5cm are counted in 40*20m plot ",
  
  gamma_bounding_box = 0L, #size of biggest common scale can be different values for different areas per region
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "convex-hull",
  gamma_bounding_box_comment = "convex-hull over the coordinates of the plots",
  
  gamma_sum_grains = 0L,
  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "plot",
  gamma_sum_grains_comment = "area of the sampled plots per year multiplied by amount of plots per region",
  
  comment = "Data manually downloaded via https://datacommons.anu.edu.au/DataCommons/rest/records/anudc:5836/data/ with login for national university of australia webpage.",
  comment_standardisation = ""
)]


meta[, ":="(
  gamma_bounding_box = geosphere::areaPolygon(meta[grDevices::chull(meta[, .(longitude, latitude)]), .(longitude, latitude)]) / 10^6,
  gamma_sum_grains = alpha_grain * length(unique(local))), 
  
  by = .(regional, year)]
