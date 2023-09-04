dataset_id <- "wardle_2014_plants"

###Data manually downloaded from:
### https://datacommons.anu.edu.au/DataCommons/rest/display/anudc:5755?layout=def:display
###Login for national university of australia needed. Data accessible after login without further requests.

# Raw Data ----

ddata <- unique(data.table::fread(
   file = "data/raw data/wardle_2014_vegetation/derg_vegetation_1993+_p903t1208.csv",
   sep = ',', header = TRUE, stringsAsFactors = TRUE,
   drop = c("trip_no", "avg_of_fl", "avg_of_seed")))


#coordinates:
coords <- data.frame(longitude = c(137.86511, 138.6059, 137.86511, 138.6059),
                     latitude = c(-23.20549, -23.20549, -23.99417, -23.99417))

data.table::setnames(ddata,
                     old = c("site_grid", "avg_of_cover"),
                     new = c("local", "value"))

#extract month
ddata[, month := stringi::stri_extract_first_regex(
   str = month_year,
   pattern = "[A-Z][a-z]{1,3}")
][, month_year := NULL
][, month := (2L:12L)[data.table::chmatch(month, c("Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"))]]


## community ----
ddata[, ":="(
   dataset_id = dataset_id,

   regional = "Simpson Desert",
   local = factor(paste(site_name, local, sep = "_")),

   metric = "cover",
   unit = "percent",

   site_name = NULL
)]

## Deleting samples with redundant observations ----
data.table::setkey(ddata, regional, local, year, month)
ddata <- ddata[!ddata[, .N, by = .(regional, local, year, month, species)][N != 1L]]

## meta ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, month)])
meta[, ":="(
   realm = "Terrestrial",
   taxon = "Plants",

   latitude =  "23°35'59.388″ S",
   longitude = "138°14'7.818″ E", #coordinates from download page

   study_type = "ecological_sampling",

   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "spatial pooling: percent of coverage in an area occupying 2.5 m radius around six traps on each trapping grid and have been aggregated to grid level data",

   alpha_grain = 6 * pi * 2.5^2,
   alpha_grain_unit = "m2",
   alpha_grain_type = "plot",
   alpha_grain_comment = "percent of coverage in an area occupying 2.5 m radius around six traps on each trapping grid and have been aggregated to grid level data",

   comment = "Data manually downloaded via https://datacommons.anu.edu.au/DataCommons/rest/display/anudc:5755 for national university of australia. The authors estimated percent coverage in an area occupying 2.5 m radius around six traps on each plot and have been aggregated to plot level data. Regional in this dataset is defined as the Simpson desert where the whole experiment is located and local is defined as grid_name",
   comment_standardisation = "Samples with duplicated observations were removed.",
   doi = 'http://doi.org/10.25911/5c13171d944fe'
)]

# save data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata[, !"dead_alive"],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)

# Standardised Data ----
## exclude rows with NA in Column percent coverage ----
## exclude rows with percent coverage of dead plants ----
ddata <- ddata[!is.na(value) & dead_alive == "Alive"][, dead_alive := NULL]

### When a site is sampled several times a year, selecting the 1 most frequently sampled months from the 6 most sampled months ----
month_order <- ddata[, data.table::uniqueN(.SD), by = .(regional, local, year, month), .SDcols = c("year","month")][, sum(V1), by = month][order(-V1)][1L:6L, month]
ddata[, month_order := (1L:6L)[match(month, month_order, nomatch = NULL)]]
data.table::setkey(ddata, month_order)

ddata <- ddata[!base::is.na(month_order)]

ddata <- ddata[
   unique(ddata[,
                .(regional, local, year, month)])[, .SD[1L],
                                                  by = .(regional, local, year)],
   on = .(regional, local, year, month)
][, month_order := NULL]

## Pooling all samples from a year together ----
ddata <- ddata[, .(species = unique(species)), by = .(dataset_id, regional, local, year, metric, unit)]

ddata[, ":="(
   value = 1L,
   metric = "pa",
   unit = "pa",

   month = NULL
)]

# update meta ----
meta[, "month" := NULL]
meta <- unique(meta)
meta <- meta[unique(ddata[, .(local, year)]),
             on = .(local, year)]

meta[, ":="(
   effort = 1L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "sampled area per year",

   gamma_bounding_box = geosphere::areaPolygon(coords) / 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "box",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment_standardisation = "Samples with duplicated observations were removed.
Converted percent of cover into presence absence.
Exclude rows with NA values for percent coverage.
Exclude percent coverage of dead plants.
When a site is sampled several times a year, selecting the 1 most frequently sampled months from the 6 most sampled months."
)][, gamma_sum_grains := sum(alpha_grain), by = .(regional, year)]

# save data -----
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
