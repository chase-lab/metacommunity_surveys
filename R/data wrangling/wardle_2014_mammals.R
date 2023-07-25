#wardle_2014_mammals
dataset_id <- "wardle_2014_mammals"

###Data manually downloaded from:
###https://datacommons.anu.edu.au/DataCommons/rest/display/anudc:5751
###Login for national university of australia needed. Data accessible after login without further requests.

datapath <- "data/raw data/wardle_2014_mammal/derg_small_mammal_trapping_data_1990+_p901t1206.csv"

ddata <- data.table::fread(file = datapath, sep = ',', header = TRUE,
   drop = c("site_name", "site_code", "site_name", "trip_no",
      "nights", "no_traps", "total_trap_nights", "recapt_same_trip",
      "captures", "family", "month_year"), stringsAsFactors = TRUE)

# Raw Data ----
coords <- data.frame(longitude = c(137.86511, 138.6059, 137.86511, 138.6059),
                     latitude = c(-23.20549, -23.20549, -23.99417, -23.99417))

data.table::setnames(
   x = ddata,
   old = c("site_grid", "captures_100tn"),
   new = c("local", "value")
)

#extract month
ddata[, month := stringi::stri_extract_first_regex(
   str = month_year,
   pattern = "[A-Z][a-z]{1,3}")
   ]

##community data ----

ddata[, ":="(
   dataset_id = dataset_id,
   
   regional = "Simpson Desert",
   
   metric = "abundance",
   unit = "count"
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
   
   comment = "Data manually downloaded via https://datacommons.anu.edu.au/DataCommons/rest/display/anudc:5751 for national university of australia. The authors estimated percent coverage in an area occupying 2.5 m radius around six traps on each plot and have been aggregated to plot level data. Regional in this dataset is defined as Site, local is defined as Plot ",
   comment_standardisation = "Standartisation to achieve same Effort was given by the authors, already present in raw data: value =  unitnumbercaptures_100tn. Captures standardised for unequal trapping effort. captures/100 trap nights = captures/(number pitfalls (usually 36)*nights opened (usually 3))*100.",
   doi = 'http://doi.org/10.25911/5c13171d944fe'
)]

meta[, gamma_sum_grains := sum(alpha_grain), by = year]

## saving raw data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)

# Standardised Data ----
## Selecting one sampling month sampled every year, every site: ----
ddata <- ddata[month == "Apr" | month == "may"][, month := NULL]

## meta ----
meta <- meta[
   unique(ddata[, .(dataset_id, regional, local, year)]),
   on = .(regional, local, year)]

meta[, ":="(
   effort = 36*100L, #6 lines of 6 traps per plot open for 100 nights by standartisation
   
   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "sampled area per year",
   
   gamma_bounding_box = geosphere::areaPolygon(coords) / 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "box",
   gamma_bounding_box_comment = "coordinates provided by the authors",
   
   comment_standardisation = "Standartisation to achieve same Effort was given by the authors, already present in raw data: unitnumbercaptures_100tn. Captures standardised for unequal trapping effort. captures/100 trap nights = captures/(number pitfalls (usually 36)*nights opened (usually 3))*100. Only sample months april and may were kept as there was an uneven sampling effort per year, per site. Months april and may have been sampled every year at every site. "
)][, gamma_sum_grains := sum(alpha_grain), by = .(regional, year)]

## save data
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized_metadata.csv"),
   row.names = FALSE
)
