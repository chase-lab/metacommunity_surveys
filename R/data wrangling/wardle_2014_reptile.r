dataset_id <- "wardle_2014_reptile"
datapath <- "data/raw data/wardle_2014_reptile/derg_reptile_data_1990+_p902t1207.csv"

###Data manually downloaded from:
###https://datacommons.anu.edu.au/DataCommons/rest/display/anudc:5753
###Login for national university of australia needed. Data accessible after login without further requests.

# Raw Data ----
ddata <- unique(data.table::fread(file = datapath))


coords <- data.frame(longitude = c(137.86511, 138.6059, 137.86511, 138.6059),
                     latitude = c(-23.20549, -23.20549, -23.99417, -23.99417))


data.table::setnames(
   x = ddata,
   old = c( "site_grid", "captures_100tn"),
   new = c("local", "value"))

#extract month
ddata[,month := stringi::stri_extract_first_regex(str = month_year, pattern = "[A-Z][a-z]{1,3}")]


## community ----
ddata[, ":="(
   dataset_id = dataset_id,
   
   regional = "Simpson Desert",
   
   metric = "abundance",
   unit = "count",
   
   site_name = NULL,
   trip_no = NULL,
   nights = NULL,
   no_traps = NULL,
   total_trap_nights = NULL,
   recap_this_trip = NULL,
   captures = NULL,
   family = NULL,
   month_year = NULL
)]

## meta ----
meta <- unique(ddata[, .(dataset_id, year, month, regional, local)])
meta[, ":="(
   realm = "Terrestrial",
   taxon = "Mammals",
   
   latitude =  "23°35'59.388″ S",
   longitude = "138°14'7.818″ E", #coordinates from download page
   
   study_type = "ecological_sampling", #two possible values, or NA if not sure
   
   data_pooled_by_authors = FALSE,
   data_pooled_by_authors_comment = "",
   sampling_years = NA,
   
   alpha_grain =  1L,
   alpha_grain_unit = "ha", #"acres", "ha", "km2", "m2", "cm2"
   alpha_grain_type = "plot",
   alpha_grain_comment = "1 ha trapping grids with 36 traps per grid",
   
   comment = "Data manually downloaded via https://datacommons.anu.edu.au/DataCommons/rest/display/anudc:5753 for national university of australia. The authors estimated percent coverage in an area occupying 2.5 m radius around six traps on each plot and have been aggregated to plot level data. Regional in this dataset is defined as Site, local is defined as Plot ",
   comment_standardisation = "Standartisation to achieve same Effort was given by the authors, already present in raw data: value =  unitnumbercaptures_100tn. Captures standardised for unequal trapping effort. captures/100 trap nights = captures/(number pitfalls (usually 36)*nights opened (usually 3))*100"
)]

## saving raw data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
                   row.names = FALSE
)

# Standardized Data ----
## standardising effort ----
### Selecting one Sampling month sampled every year, every site:
ddata <- ddata[month == "Apr" | month == "may"]
# excluding rows with value = 0
ddata <- ddata[value != 0]


## meta ----
meta <- meta[unique(ddata[,.(dataset_id, regional, local, year)]), on = .(regional, local, year)]
meta[, ":="(
   effort = 36*100L, #6 lines of 6 traps per plot open for 100 nights by raw data  standartisation
   
   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "sampled area per year",
   
   gamma_bounding_box = geosphere::areaPolygon(coords) / 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "box",
   gamma_bounding_box_comment = "coordinates provided by the authors",
   
   comment_standardisation = "Duplicated rows in row data were excluded. Standartisation to achieve same Effort was given by the authors, already present in raw data: unitnumbercaptures_100tn. Captures standardised for unequal trapping effort. captures/100 trap nights = captures/(number pitfalls (usually 36)*nights opened (usually 3))*100. Only sample months april and may were kept as there was an uneven sampling effort per year, per site. Months april and may have been sampled every year at every site. "
)][, gamma_sum_grains := sum(alpha_grain), by = .(regional, year)]

## saving standardised data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standaradised.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised_metadata.csv"),
                   row.names = FALSE
)
