# russel-smith_2017_shrubs
dataset_id <- "russell-smith_2017_shrubs"

###Data manually downloaded from:
### https://datacommons.anu.edu.au/DataCommons/rest/records/anudc:5836/data/
###  Spatial data manually downloaded from:
###  https://datacommons.anu.edu.au/DataCommons/rest/records/anudc:5837/data/
###  Login for Australian National University needed. Data accessible after login without further requests.

# loading data ----
datafiles <- c(
   "./data/raw data/russell-smith_2017/data/tpsk_shrubs_1994+_p831t1065.csv",
   "./data/raw data/russell-smith_2017/data/tpsl_shrubs_1994+_p831t1123.csv",
   "./data/raw data/russell-smith_2017/data/tpsn_shrubs_1994+_p831t1128.csv"
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


ddata <- data.table::rbindlist(
   lapply(
      datafiles,
      FUN = function(x)
         data.table::fread(file = x, na.strings = "NA")
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
#Raw Data ----
## cleaning: deleting duplicated rows ----
duplicated_subsets <- unique(ddata[duplicated(ddata), .(park, plot, visit)])
ddata <- ddata[!duplicated_subsets, on = c("park","plot","visit")]

## merging data.table style ----
ddata <- dates[ddata, on = c("park","plot","visit")]
# unique(ddata[is.na(as.integer(`count_50cm-2m`))]$`count_50cm-2m`)
# unique(ddata[is.na(as.integer(count_less_than_50cm))]$count_less_than_50cm)
# unique(ddata[is.na(as.integer(count_greater_than_2m))]$count_greater_than_2m)

## Summing abundances from different size class ----
ddata[, ":="(
   count_less_than_50cm = as.integer(count_less_than_50cm),
   `count_50cm-2m` = as.integer(`count_50cm-2m`),
   count_greater_than_2m = as.integer(count_greater_than_2m)
)]

ddata[, value := apply(ddata[, .(count_less_than_50cm, `count_50cm-2m`, count_greater_than_2m)], 1, sum, na.rm = TRUE)]
## remove absences
ddata <- ddata[value != 0L]

data.table::setnames(ddata, c("park", "plot","genus_species"), c("regional","local","species"))

#format spatial data to have common identifier with ddata
spatial[, regional := c("Kakadu","Litchfield","Nitmiluk")[match(substr(plot, 1, 3), c("KAK","LIT","NIT"))]]
spatial[, local := stringi::stri_extract_all_regex(str = plot, pattern = "[0-9]{2,3}")][, local := as.integer(sub("^0+(?=[1-9])", "", local, perl = TRUE))]


# communities ----

ddata[, ":="(
   dataset_id = dataset_id,
   
   year = format(date, "%Y"),
   
   metric = "abundance",
   unit = "count",
   
   visit = NULL,
   date = NULL,
   comments = NULL,
   count_less_than_50cm = NULL,
   `count_50cm-2m` = NULL,
   count_greater_than_2m = NULL
)]

##remove NA values in year because of missing dates in original data ----
ddata <- ddata[!is.na(year)]


meta <- unique(ddata[, .(dataset_id, year, regional, local)])
meta <- spatial[, .(local, regional, latitude, longitude)][meta, on = c("local", "regional")]
meta[, ":="(
   realm = "Terrestrial",
   taxon = "Plants",
   
   study_type = "ecological_sampling", #two possible values, or NA if not sure
   
   data_pooled_by_authors = FALSE,
   data_pooled_by_authors_comment = NA,
   sampling_years = NA,
   
   alpha_grain = 400L,  #area of individual plot
   alpha_grain_unit = "m2", #"acres", "ha", "km2", "m2", "cm2"
   alpha_grain_type = "plot",
   alpha_grain_comment = "all shrubs counted in 40m *10m plots",
   
   comment = "Data manually downloaded via https://datacommons.anu.edu.au/DataCommons/rest/records/anudc:5836/data/ with login for national university of australia website. Authors sampled shrubs from the inner 40m*10m plot of their fixed 40m*20m plots once a year. They measured the height of all shrubs and we kept only abundances.",
   comment_standardisation = "some visit numbers (T1, T2, ...) had no match (year) in the dates table so they were excluded. Authors sampled shrubs from the smallest size class in subplots but since the size of subplot is constant, no standardisation is needed. Some rows were duplicated so all results from these 5 problematic plot/year subsets were excluded. Sites sampled only one year were excluded."
)]


##save data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
                   row.names = FALSE
)

#Standardization ----
## deleting site sampled only once with a data.table style join ----
ddata <- ddata[ ddata[, .(n_years = length(unique(year))), by = .(regional, local)][n_years > 1L][, .(regional, local)], on = .(regional, local)]

##meta data ----
meta <- meta[unique(ddata[, .(dataset_id, local, regional, year)]),
             on = .(local, regional, year)]
meta[,":="(
   effort = 1L,
   
   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "area of the sampled plots per year multiplied by amount of plots per region",
   
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "convex-hull over the coordinates of sample points",
   
   comment_standardisation = "some visit numbers (T1, T2, ...) had no match (year) in the dates table so they were excluded. Authors sampled shrubs from the smallest size class in subplots but since the size of subplot is constant, no standardisation is needed. Some rows were duplicated so all results from these 5 problematic plot/year subsets were excluded. Sites sampled only one year were excluded."
)]

meta[, ":="(
   gamma_bounding_box = geosphere::areaPolygon(data.frame(na.omit(longitude), na.omit(latitude))[grDevices::chull(na.omit(longitude), na.omit(latitude)), ]) / 10^6,
   gamma_sum_grains = sum(alpha_grain)
),
by = .(regional, year)
]

##save data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized_metadata.csv"),
                   row.names = FALSE
)
