#keith_2017
dataset_id <- "keith_2017"

###Data manually downloaded from:
### https://datacommons.anu.edu.au/DataCommons/rest/display/anudc:5778
###Login for Australian National University needed. Data accessible after login without further requests.

datapath <- "./data/raw data/keith_2017/kuhs_rnp_vegetation_floristics_1990-2014_p583t1043.csv"
ddata <- data.table::fread(datapath)

#delete species with abundance = 0
ddata <- ddata[abundance != 0]
data.table::setnames(ddata, c("trans_quad","abundance"), c("local","value"))

# communities ----

ddata[, ":="(
  dataset_id = dataset_id,
   regional = "Royal National Park",

  caps = NULL
)]

# meta ----
meta <- unique(ddata[, .(dataset_id, year, regional, local)])
meta[, ":="(
  realm = "Plants",
  taxon = "Vegetation",

  latitude = "34°05′46.00″ S",
  longitude = "151°09′02.73″ E",

  study_type = "ecological sampling", #two possible values, or NA if not sure

  data_pooled_by_authors = FALSE,
  data_pooled_by_authors_comment = NA,
  sampling_years = NA,

  effort = 1L, #sampled annually until 1994, subsequently in 1999, 2001, 2007, 2011 and 2014 -> data pooled?
  alpha_grain = 0.25,  #area of individual plot
  alpha_grain_unit = "m2", #"acres", "ha", "km2", "m2", "cm2"
  alpha_grain_type = "plot",
  alpha_grain_comment = "permanent 0.5*0.5m plots were established ",

  gamma_bounding_box = 151L, #size of biggest common scale can be different values for different areas per region
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "administrative",
  gamma_bounding_box_comment = "area of the Royal National park",

  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "transect",
  gamma_sum_grains_comment = "area of the sampled plots per year multiplied by amount of plots per region",

  comment = "Data manually downloaded via https://datacommons.anu.edu.au/DataCommons/rest/display/anudc:5778 with login for national university of australia website. The authors sampled plants from fixed quadrats in the Royal National Park, Australia. Plots are organised along 8 transects, 7 plots per transect. Plot is the alpha scale and the park is gamma scale.",
  comment_standardisation = "none needed"
)][,
   gamma_sum_grains := sum(alpha_grain), by = year
]

