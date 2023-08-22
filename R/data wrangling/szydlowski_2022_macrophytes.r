dataset_id <- "szydlowski_2022_macrophytes"
source("R/functions/resampling.r")

ddata <- base::readRDS(file = "./data/raw data/szydlowski_2022_macrophytes/rdata.rds")

# Raw Data ----
## Melting species ----
species_list <- grep(pattern = "^[A-Z][a-z]*_[a-z]*$", x = colnames(ddata), value = TRUE)

ddata[, (species_list) := lapply(.SD, function(column) replace(column, column == 0, NA_real_)),
      .SDcols = species_list] # replace all 0 values by NA
ddata <- data.table::melt(ddata,
                          id.vars = c("year","date","lake","sector","lat","long"),
                          measure.vars = species_list,
                          variable.name = "species",
                          value.name = "value",
                          na.rm = TRUE
)

data.table::setnames(
   ddata,
   old = c("lake", "lat", "long"),
   new = c("local", "latitude", "longitude"))

#
# ddata <- ddata[, .(
#    value = as.integer(sum(value)),
#    latitude = unique(latitude),
#    longitude = unique(longitude),
#    sample_size = unique(sample_size),
#    effort = unique(effort)
# ), by = .(local, year, species)]
#
# ddata[, species := as.character(species)]

##community data ----
lake_names <- c("Allequash Lake" = "AL", "High Lake" = "HI", "Little John Lake" = "LJ",
                "Little Star Lake" = "LS", "Papoose Lake" = "PA", "Plum Lake" = "PL",
                "Presque Isle Lake" = "PI", "Spider Lake" = "SP", "Squirrel Lake" = "SQ",
                "Wild Rice Lake" = "WR")

ddata[, ":="(
   dataset_id = dataset_id,

   date = data.table::as.IDate(date),

   regional = "Vilas County, Wisconsin",
   local = paste(names(lake_names)[match(local, lake_names)], sector, sep = "_"),

   metric = "abundance",
   unit = "count"
)][, ":="(
   month = data.table::month(date),
   day = data.table::mday(date),
   date = NULL
)]

##metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, month, day, latitude, longitude)])
meta[, ":="(
   taxon = "Plants",
   realm = "Freshwater",

   study_type = "ecological_sampling",
   data_pooled_by_authors = FALSE,

   alpha_grain = 10L * 75L * 26L * 6L,
   alpha_grain_unit = "cm2",
   alpha_grain_type = "sample",
   alpha_grain_comment = "area of the sampled vertical plan, 10cm wide and 75cm deep, times 26 panes per transect, times the number of transects",

   comment = factor("Extracted from EDI repository - Aquatic snail and macrophyte abundance and richness data for ten lakes in Vilas County, WI, USA, 1987-2020 - https://doi.org/10.6073/pasta/29733b5269efe990c3d2d916453fe4dd and associated article . Authors sampled counted macrophytes intersecting 10cm wide panes going from the substrate to the surface (75cm in most cases) every meter of a 25m long transect, 6 to 14 transects per lake per year. Sampling happened in 1987, 2002, 2011 and 2020 following the lakes invasion by a crayfish. Ideally alpha_grain would be the size of the lakes but that information was not found."),
   comment_standardisation = "None needed",
   doi = 'https://doi.org/10.6073/pasta/29733b5269efe990c3d2d916453fe4dd'
)]

##save data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata[, !c("sector","latitude","longitude")],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)

# Standardised data ----
ddata[, c("month","day") := NULL]

## Removing sector name from local column ----
ddata[, local := gsub("_.*$", "", local, FALSE, TRUE)]
meta[, local := gsub("_.*$", "", local, FALSE, TRUE)]

## define latitude longitude values ----
ddata[, ":="(latitude = mean(latitude), longitude = mean(longitude)),
      by = .(local, year)]

## standardising effort ----
## selecting samples with comparable effort ----
min_sample_number <- 4L
ddata <- ddata[, effort := data.table::uniqueN(sector),
                             by = .(local, year)][effort >= min_sample_number]
set.seed(42)
ddata <- ddata[
   ddata[, .(sector = sample(sector, min_sample_number, replace = FALSE)),
         by = .(local, year)],
   on = .(local, year, sector)]

## pooling sectors together ----
ddata <- ddata[, .(value = sum(value), latitude = mean(latitude),
                   longitude = mean(longitude)),
               by = .(dataset_id, regional, local, year, species, metric, unit)]

##meta ----
meta[, c("month","day","latitude","longitude") := NULL]
meta <- unique(meta)
meta <- meta[unique(ddata[, .(local, latitude, longitude, year)]),
             on = .(local, year)]

meta[, ":="(
   effort = 4L,

   alpha_grain = 10L * 75L * 26L * 4L,

   gamma_sum_grains_unit = "cm2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of the sampled areas from all lakes on a given year",

   gamma_bounding_box = 2640L,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "administrative",
   gamma_bounding_box_comment = "area of Vilas County, Wisconsin",

   comment_standardisation = "To get a comparable effort between years and lakes, we randomly selected 4 sectors (ie samples) from each lake/year. The number of 4 samples is a trade-off between excluding the fewest lakes with insufficient effort and getting as many individuals as possible.
When some of these sectors were sampled twice a year, we selected the first date."
)][, gamma_sum_grains := sum(alpha_grain), by = year]

ddata[, c("latitude", "longitude") := NULL]

##save data ----
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
