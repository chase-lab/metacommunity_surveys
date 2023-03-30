dataset_id <- "wardle_2014_reptile"
datapath <- "data/raw data/wardle_2014_reptile/derg_reptile_data_1990+_p902t1207.csv"

###Data manually downloaded from:
###https://datacommons.anu.edu.au/DataCommons/rest/display/anudc:5753
###Login for national university of australia needed. Data accessible after login without further requests.

ddata <- unique(data.table::fread(file = datapath))


coords <- data.frame(longitude = c(137.86511, 138.6059, 137.86511, 138.6059),
                     latitude = c(-23.20549, -23.20549, -23.99417, -23.99417))


#capture data for a specified duration of trapping nights (usually 3 night session) in the Simpson Desert
#Captured mammal fauna were identified and recaptures during the same session were removed (i.e. individuals were only counted once)
#core of 12 sites which are sampled every April-May.
#each regional has 2 locals 1-ha trapping grids/plots - per grid: 36 traps
#Traps on each grid were opened for 3 nights once per year and checked in the mornings and sometimes afternoon
#in 2012 there was not a complete survey, and so there are only 2 (Field River South and Main Camp) sites represented in this table.
#unitnumbercaptures_100tn
#definition	Captures standardised for unequal trapping effort. captures/100 trap nights = captures/(number pitfalls (usually 36)*nights opened (usually 3))*100

data.table::setnames(
   x = ddata,
   old = c( "site_grid", "captures_100tn"),
   new = c("local", "value"))

#extract month
ddata[,month := stringi::stri_extract_first_regex(str = month_year, pattern = "[A-Z][a-z]{1,3}")]
#standardization
#only data from Apr and March were sampled every year at every site
ddata <- ddata[month == "Apr" | month == "May"]
ddata <- ddata[value != 0]


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
   month_year = NULL,
   month = NULL
)]



# meta ----
meta <- unique(ddata[, .(dataset_id, year, regional, local)])
meta[, ":="(
   realm = "Terrestrial",
   taxon = "Mammals",

   latitude =  "23°35'59.388″ S",
   longitude = "138°14'7.818″ E", #coordinates from download page

   study_type = "ecological_sampling", #two possible values, or NA if not sure

   data_pooled_by_authors = FALSE,
   data_pooled_by_authors_comment = "",
   sampling_years = NA,

   effort = 36*100L, #6 lines of 6 traps per plot open for 100 nights by standartisation

   alpha_grain =  1L,
   alpha_grain_unit = "ha", #"acres", "ha", "km2", "m2", "cm2"
   alpha_grain_type = "plot",
   alpha_grain_comment = "1 ha trapping grids with 36 traps per grid",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "sampled area per year",

   gamma_bounding_box = geosphere::areaPolygon(coords) / 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "box",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment = "Data manually downloaded via https://datacommons.anu.edu.au/DataCommons/rest/display/anudc:5753 for national university of australia. The authors estimated percent coverage in an area occupying 2.5 m radius around six traps on each plot and have been aggregated to plot level data. Regional in this dataset is defined as Site, local is defined as Plot ",
   comment_standardisation = "Dulpicated rows in row data were excluded. Standartisation to achieve same Effort was given by the authors, already present in raw data: unitnumbercaptures_100tn. Captures standardised for unequal trapping effort. captures/100 trap nights = captures/(number pitfalls (usually 36)*nights opened (usually 3))*100. Only sample months april and may were kept as there was an uneven sampling effort per year, per site. Months april and may have been sampled every year at every site. "
)]

meta[, gamma_sum_grains := sum(alpha_grain), by = year]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)
