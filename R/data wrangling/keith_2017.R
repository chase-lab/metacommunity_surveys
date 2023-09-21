#keith_2017
dataset_id <- "keith_2017"

###Data manually downloaded from:
### https://datacommons.anu.edu.au/DataCommons/rest/display/anudc:5778
###Login for Australian National University needed. Data accessible after login without further requests.
ddata <- data.table::fread(
   file = "data/raw data/keith_2017/kuhs_rnp_vegetation_floristics_1990-2014_p583t1043.csv",
   header = TRUE, sep = ",")

#Raw Data----
##delete species with abundance = 0 ----
ddata <- ddata[abundance != 0]

data.table::setnames(ddata, c("trans_quad","abundance"), c("local","value"))

##community data ----

ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Royal National Park",

   metric = "abundance",
   unit = "count",

   caps = NULL
)]

##meta data----
meta <- unique(ddata[, .(dataset_id, year, regional, local)])
meta[, ":="(
   realm = "Terrestrial",
   taxon = "Plants",

   latitude = "34°05′46.00″ S",
   longitude = "151°09′02.73″ E",

   study_type = "ecological_sampling", #two possible values, or NA if not sure

   data_pooled_by_authors = FALSE,
   data_pooled_by_authors_comment = NA,
   sampling_years = NA,

   alpha_grain = 0.25,  #area of individual plot
   alpha_grain_unit = "m2", #"acres", "ha", "km2", "m2", "cm2"
   alpha_grain_type = "plot",
   alpha_grain_comment = "permanent 0.5*0.5m plots were established ",

   comment = "Data manually downloaded via https://datacommons.anu.edu.au/DataCommons/rest/display/anudc:5778 with login for national university of australia website. The authors sampled plants from fixed quadrats in the Royal National Park, Australia. Plots are organised along 8 transects, 7 plots per transect. Plot is the alpha scale and the park is gamma scale.",
   comment_standardisation = "none needed",
   doi = "https://doi.org/10.25911/5c130ca59c5a8"
)]

##save data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x= meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)

#standardised Data----

##meta data----
meta[,":="(
   effort = 1L, #sampled annually until 1994, subsequently in 1999, 2001, 2007, 2011 and 2014 -> data pooled?

   gamma_bounding_box = 151L, #size of biggest common scale can be different values for different areas per region
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "administrative",
   gamma_bounding_box_comment = "area of the Royal National park",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "transect",
   gamma_sum_grains_comment = "area of the sampled plots per year multiplied by amount of plots per region"
)][,
   gamma_sum_grains := sum(alpha_grain), by = year
]

##save data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised_metadata.csv"),
   row.names = FALSE
)
