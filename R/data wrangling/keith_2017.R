#keith_2017
dataset_id <- "keith_2017"

###Data manually downloaded from:
### https://datacommons.anu.edu.au/DataCommons/rest/display/anudc:5778
###Login for Australian National University needed. Data accessible after login without further requests.

datapath <- "./data/raw data/keith_2017/kuhs_rnp_vegetation_floristics_1990-2014_p583t1043.csv"
ddata <- data.table::fread(datapath)

#delete species with abundance = 0 
ddata <- ddata[abundance != 0] 

#establish reginal, local scale
ddata[, regional := c("T1","T2","T3", "T4", "T5", "T6", "T7", "T8")[match(substr(trans_quad, 1, 2), c("T1","T2","T3","T4","T5","T6","T7", "T8"))]]
ddata[, local := c("1","2","3", "4", "5", "6", "7")[match(substr(trans_quad, 3, 4), c("Q1","Q2","Q3","Q4","Q5","Q6","Q7"))]]

# communities ----

ddata[, ":="(
  dataset_id = dataset_id,
  trans_quad = NULL,
  caps = NULL
)]

# meta ----
meta <- unique(ddata[, .(dataset_id, year, regional, local)])
meta[, ":="(
  realm = "Plants",
  taxon = "Vegetation",
  
  latitude = 34°05′46.00″ S,
  longitude = 151°09′02.73″ E,
  
  study_type = "ecological sampling", #two possible values, or NA if not sure
  
  data_pooled_by_authors = FALSE,
  data_pooled_by_authors_comment = NA,
  sampling_years = NA,
  
  effort = 1L, #sampled annually until 1994, subsequently in 1999, 2001, 2007, 2011 and 2014 -> data pooled?
  alpha_grain = 0.25L,  #area of individual plot
  alpha_grain_unit = "m2", #"acres", "ha", "km2", "m2", "cm2"
  alpha_grain_type = "plot",
  alpha_grain_comment = "permanent 0.5*0.5m plots were established ",
  
  gamma_bounding_box = 0L, #size of biggest common scale can be different values for different areas per region
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "convex-hull",
  gamma_bounding_box_comment = "convex-hull over the coordinates of sample points",
  
  gamma_sum_grains = 0L,
  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "transect",
  gamma_sum_grains_comment = "area of the sampled plots per year multiplied by amount of plots per region",
  
  comment = "Data manually downloaded via https://datacommons.anu.edu.au/DataCommons/rest/display/anudc:5778 with login for national university of australia website.",
  comment_standardisation = ""
)]

