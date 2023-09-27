# christensen_2021
dataset_id <- "christensen_2021"

annual_species <- base::readRDS(file = "data/raw data/christensen_2021/annual_species.rds")
perennial_species <- base::readRDS(file = "data/raw data/christensen_2021/perennial_species.rds")
taxo <- base::readRDS(file = "data/raw data/christensen_2021/taxo.rds")

#Raw data ----
data.table::setnames(
   annual_species,
   old = c("quadrat", "species_code", "count"),
   new = c("local", "species", "value"))
data.table::setnames(
   perennial_species,
   old = c("quadrat", "species_code"),
   new = c("local", "species"))

##merging annual and perennial species abundances ----
###intersecting ----
annual_species <- annual_species[unique(perennial_species[, .(local, year)]), on = .(local, year)]
perennial_species <- perennial_species[unique(annual_species[, .(local, year)]), on = .(local, year)]

### rbinding ----
ddata <- rbind(annual_species, perennial_species, fill = TRUE)

## taxonomy ----
taxo[, species := data.table::fifelse(species == "", species_code, paste(genus, species))]
ddata <- ddata[!is.na(species) & !is.na(project_year) & !is.na(value)]

## community data ----
ddata[, ":="(
   dataset_id = dataset_id,

   regional = "Jornada Experimental Range, USA",

   species = taxo$species[data.table::chmatch(species, taxo$species_code)],

   metric = "abundance",
   unit = "count",

   project_year = NULL,
   notes = NULL
)]

## meta data ----
coords <- data.frame(
   latitude = c(NW = 32.737108, NE = 32.737108, SE = 32.466879, SW = 32.466879),
   longitude = c(NW = -106.926435, NE = -106.528942, SE = -106.528942, SW = -106.926435)
)

meta <- unique(ddata[, .(dataset_id, regional, local, year, month)])
meta[, ":="(
   taxon = "Plants",
   realm = "Terrestrial",

   latitude = "32°37'N",
   longitude = "106°45'W",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = 1L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "plot",
   alpha_grain_comment = "plot area",

   comment = "Extracted from supplementary 2 associated to article Christensen, E., James, D., Maxwell, C., Slaughter, A., Adler, P.B., Havstad, K. and Bestelmeyer, B. (2021), Quadrat-based monitoring of desert grassland vegetation at the Jornada Experimental Range, New Mexico, 1915–2016. Ecology. Accepted Author Manuscript e03530. https://doi.org/10.1002/ecy.3530 . Methods: 'The data set includes 122 1 m by 1 m permanent quadrats, although not all quadrats were sampled in each year of the study and there is a gap in monitoring from 1980–1995'. Data from annual species counts and perennial species counts were included. Exact locations are unknown.",
   comment_standardisation = "Rows with NA `species`, `year`, `value` values were excluded.",
   doi = 'https://doi.org/10.1002/ecy.3530'
)]

##save data -----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8"
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8"
)

#standardised data ----
## Excluding sites that were not resampled at least 10 years appart
ddata <- ddata[
   !ddata[, .(diff(range(year)) < 9L), by = .(regional, local)][(V1)],
   on = .(regional, local)
]

## When a site is sampled several times a year, selecting the most frequently sampled month from the 6 most sampled months ----
month_order <- ddata[, data.table::uniqueN(.SD), by = .(local, year, month), .SDcols = c("year", "month")][, sum(V1), by = month][order(-V1)]
ddata[, month_order := (1L:6L)[match(month, month_order, nomatch = NULL)]]

ddata <- ddata[
   unique(ddata[, .(local, year, month)])[, .SD[1L], by = .(local, year)],
   on = .(local, year, month)][, month_order := NULL][, month := NULL]

## meta data ----
meta[, month := NULL]
meta <- unique(meta)
meta <- meta[unique(ddata[, .(local, year)]),
             on = .(local, year)]

meta[, ":="(
   effort = 1L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of sampled areas per year",

   gamma_bounding_box = geosphere::areaPolygon(coords[, c("longitude", "latitude")]) / 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "box",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment_standardisation = "Only sites sampled at least twice at 10 years apart are kept.
When sampled several times a year, sample from the generally most sampled month kept"
)][, gamma_sum_grains := sum(alpha_grain), by = year]

##save data ----
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8"
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised_metadata.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8"
)
