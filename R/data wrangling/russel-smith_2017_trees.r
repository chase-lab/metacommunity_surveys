# russel-smith_2017_trees
dataset_id <- "russell-smith_2017_trees"

###Data manually downloaded from:
### https://datacommons.anu.edu.au/DataCommons/rest/records/anudc:5836/data/
###  Spacial data manually downloaded from:
###  https://datacommons.anu.edu.au/DataCommons/rest/records/anudc:5837/data/
###  Login for Australian National University needed. Data accessible after login without further requests.

# loading data ----
datafiles <- c(
  "./data/
  /tpsk_trees_1994+_p831t1066.csv",
  "./data/
  /tpsl_trees_1994+_p831t1124.csv",
  "./data/
  /tpsn_trees_1994+_p831t1129.csv"
)
datafiles_dates <- c(
  "./data/
  /tpsk_visit_date_1994+_p831t1067.csv",
  "./data/
  /tpsl_visit_date_1994+_p831t1125.csv",
  "./data/
  /tpsn_visit_date_1994+_p831t1153.csv"
)

datafiles_spacial <- c(
  "./data/raw data/russell-smith_2017/spacial/tpsk_plot_details_spatial_coordinates_p894t1154.csv",
  "./data/raw data/russell-smith_2017/spacial/tpsl_plot_details_spatial_coordinates_p894t1155.csv",
  "./data/raw data/russell-smith_2017/spacial/tpsn_plot_details_spatial_coordinates_p894t1156.csv"
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

spacial <- data.table::rbindlist(
  lapply(
    datafiles_spacial,
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


ddata[, ":="(
  dataset_id = dataset_id,
  year = format(date, "%Y"),
  visit = NULL,
  date = NULL
)]

#23 NA in years
ddata[, sum(is.na(year)) ]

meta <- unique(ddata[, .(dataset_id, year, regional, local)])
meta[, ":="(
  realm = "Terrestrial",
  taxon = "Vegetation",
  
  latitude = as.numeric(spacial[, .(x = mean(latitude))]),
  longitude = as.numeric(spacial[, .(x = mean(longitude))]),
  
  study_type = "ecological sampling", #two possible values, or NA if not sure
  
  data_pooled_by_authors = FALSE,
  data_pooled_by_authors_comment = NA,
  sampling_years = NA,
  
  effort = 24L, # Effort is the minimal number of sampling operations ie the number of pitfall traps * the number of dates per local per year
  
  alpha_grain = 90L,  #size/area of individual trap
  alpha_grain_unit = "cm2", #"acres", "ha", "km2", "m2", "cm2"
  alpha_grain_type = "trap",
  alpha_grain_comment = "15 cm2 diameter pitfall traps",
  
  gamma_bounding_box = 120L, #size of biggest common scale can be different values for different areas per region
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "box",
  gamma_bounding_box_comment = "complete area in which the 11 plots are located",
  
  gamma_sum_grains = 90L * 24L, #90 x effort
  gamma_sum_grains_unit = "cm2",
  gamma_sum_grains_type = "plot",
  gamma_sum_grains_comment = "Each grid consisted of 4 x 4 rows of traps spaced at 15 meter intervals",
  
  comment = "Data extracted from EDI repository https://portal.edirepository.org/nis/mapbrowse?scope=knb-lter-jrn&identifier=210007001&revision=38 . The authors captured, marked and recaptured lizards in 4 zones, 2 to 3 plots per zone and a 4*4 grid of pitfal traps. Data is provided at the individual level per pitfall trap and we applied standardisation(described in comment_standardisation). Effort is the minimal number of sampling operations ie the number of pitfall traps * the number of dates per local per year.",
  comment_standardisation = "data from 2005 and 2006 are excluded because empty pits are underestimated. only sites resampled in the 2000s are included. because effort varies: varying number of traps and varying number of sampling events per year, individuals are resampled down to the minimal number of captured individuals among the least intensively sampled years i.e. 12 individuals."
)]
