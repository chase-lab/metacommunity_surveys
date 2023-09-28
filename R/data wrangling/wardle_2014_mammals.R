#wardle_2014_mammals
dataset_id <- "wardle_2014_mammals"

###Data manually downloaded from:
###https://datacommons.anu.edu.au/DataCommons/rest/display/anudc:5751
###Login for national university of australia needed. Data accessible after login without further requests.

ddata <- data.table::fread(
   file = "data/raw data/wardle_2014_mammal/derg_small_mammal_trapping_data_1990+_p901t1206.csv",
   sep = ',', header = TRUE, stringsAsFactors = TRUE,
   drop = c("site_code", "trip_no",
            "nights", "no_traps", "recapt_same_trip", "family"))

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
][, month_year := NULL
][, month := (1L:12L)[data.table::chmatch(month, c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"))]]

##community data ----
ddata[, species := as.character(species)][, ":="(
   dataset_id = dataset_id,

   regional = "Simpson Desert",
   local = factor(paste(site_name, local, sep = "_")),

   species = data.table::fifelse(species == "No captures", "Empty traps", species),

   metric = "density",
   unit = "cpue",

   site_name = NULL
)]

## meta ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, month)])
meta[, ":="(
   realm = "Terrestrial",
   taxon = "Mammals",

   latitude =  "23°35'59.388″ S",
   longitude = "138°14'7.818″ E",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain =  1L,
   alpha_grain_unit = "ha",
   alpha_grain_type = "plot",
   alpha_grain_comment = "1 ha trapping grids with 36 traps per grid",

   comment = "Data manually downloaded via https://datacommons.anu.edu.au/DataCommons/rest/display/anudc:5751 for national university of australia. The authors estimated percent coverage in an area occupying 2.5 m radius around six traps on each plot and have been aggregated to plot level data. Regional in this dataset is defined as the Simpson desert where the whole experiment is located and local is defined as site_name _ grid_name.",
   comment_standardisation = "Standartisation to achieve same Effort was given by the authors, already present in raw data: value =  unitnumbercaptures_100tn. Captures standardised for unequal trapping effort. captures/100 trap nights = captures/(number pitfalls (usually 36)*nights opened (usually 3))*100.",
   doi = 'http://doi.org/10.25911/5c13171d944fe'
)]

## saving raw data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata[, !c("total_trap_nights", "captures")],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)

# Standardised Data ----
## standardising effort ----
### When a site is sampled several times a year, selecting the 1 most frequently sampled months from the 6 most sampled months ----
month_order <- ddata[, data.table::uniqueN(.SD), by = .(regional, local, year, month), .SDcols = c("year", "month")][, sum(V1), by = month][order(-V1)][1L:6L, month]
ddata[, month_order := (1L:6L)[match(month, month_order, nomatch = NULL)]]
data.table::setkey(ddata, month_order)

ddata <- ddata[!base::is.na(month_order)]

ddata <- ddata[
   unique(ddata[, .(regional, local, year, month)]
   )[, .SD[1L], by = .(regional, local, year)],
   on = .(regional, local, year, month)
][, month_order := NULL]

## Resampling ----
ddata[, value := captures][, captures := NULL]

### computing min total abundance for the local/year where the effort is the smallest ----
ddata[, sample_size := sum(value), by = .(local, year)]
ddata <- ddata[sample_size >= 10L]
min_sample_size <- ddata[total_trap_nights == min(total_trap_nights), min(sample_size)]

### resampling abundances down to the minimal total abundance observed among the surveys with the minimal effort ----
ddata <- ddata[species != "Empty traps" & species != "Rodent" & value != 0]
source("R/functions/resampling.r")
ddata <- ddata[species != ""]

set.seed(42)
ddata[sample_size > min_sample_size,
      value := resampling(species, value, min_sample_size),
      by = .(year, regional, local)]
ddata <- ddata[, c("sample_size", "total_trap_nights", "month") := NULL][!is.na(value)]

## Excluding sites that were not sampled at least twice 10 years apart ----
ddata <- ddata[!ddata[, diff(range(year)) < 9L, by = .(regional, local)][(V1)],
               on = .(regional, local)]

## Metadata ----
meta[, month := NULL]
meta <- unique(meta)
meta <- meta[
   unique(ddata[, .(local, year)]),
   on = .(local, year)]

meta[, ":="(
   effort = 72L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "sampled area per year",

   gamma_bounding_box = geosphere::areaPolygon(coords) / 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "box",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment_standardisation = "Samples with duplicated observations were removed..
Standartisation to achieve same Effort:
One month per year was selected.
Samples with less than 10 individuals were excluded.
All samples were resampled down to the number of individuals found in the sample with the lowest effort: 72 trap nights, 11 individuals.
Sites that were not sampled at least twice 10 years apart were excluded."
)][, gamma_sum_grains := sum(alpha_grain), by = year]

## save data
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
