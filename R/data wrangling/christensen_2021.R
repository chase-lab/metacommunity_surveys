# christensen_2021
dataset_id <- "christensen_2021"
annual_species <- base::readRDS(file = "./data/raw data/christensen_2021/annual_species.rds")
perennial_species <- base::readRDS(file = "./data/raw data/christensen_2021/perennial_species.rds")
taxo <- base::readRDS(file = "./data/raw data/christensen_2021/taxo.rds")

data.table::setnames(annual_species, c("quadrat", "species_code", "count"), c("local", "species", "value"))
data.table::setnames(perennial_species, c("quadrat", "species_code"), c("local", "species"))


# standardisation ----
## keeping only stations sampled more than 1 year and only one month per year. If several samples, the one from the most often sampled month is kept.
annual_species[, order_month := order(table(month), decreasing = TRUE)[match(month, 1:12)]]
data.table::setorder(annual_species, local, year, order_month)
annual_species <- annual_species[unique(annual_species[, .(local, year, month)])[, .SD[1L], by = .(local, year)], on = .(local, year, month)] # (data.table style join)

perennial_species[, order_month := order(table(month), decreasing = TRUE)[match(month, 1:12)]]
data.table::setorder(perennial_species, local, year, order_month)
perennial_species <- perennial_species[unique(perennial_species[, .(local, year, month)])[, .SD[1L], by = .(local, year)], on = .(local, year, month)] # (data.table style join)

# merging annual and perennial species abundances ----
## intersecting
annual_species <- annual_species[unique(perennial_species[, .(local, year)]), on = .(local, year)]
perennial_species <- perennial_species[unique(annual_species[, .(local, year)]), on = .(local, year)]

## rbinding
ddata <- rbind(annual_species, perennial_species, fill = TRUE)

## deleting empty years
ddata <- ddata[!is.na(value)]

# taxonomy
taxo[, species := paste(genus, species)][species == " ", species := species_code]


# ddata ----
ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Jornada Experimental Range, USA",

   species = taxo$species[match(species, taxo$species_code)],

   metric = "abundance",
   unit = "count",



   month = NULL,
   project_year = NULL,
   notes = NULL,
   order_month = NULL
)]

# Metadata ----
coords <- data.frame(
   latitude = c(NW = 32.737108, NE = 32.737108, SE = 32.466879, SW = 32.466879),
   longitude = c(NW = -106.926435, NE = -106.528942, SE = -106.528942, SW = -106.926435)
)

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
   taxon = "Plants",
   realm = "Terrestrial",

   latitude = "32°37'N",
   longitude = "106°45'W",

   study_type = "ecological_sampling",
   effort = 1L,

   data_pooled_by_authors = FALSE,

   alpha_grain = 1L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "plot",
   alpha_grain_comment = "plot area",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of sampled areas per year",

   gamma_bounding_box = geosphere::areaPolygon(coords[, c("longitude", "latitude")]) / 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "box",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment = "Extracted from supplementary 2 associated to article Christensen, E., James, D., Maxwell, C., Slaughter, A., Adler, P.B., Havstad, K. and Bestelmeyer, B. (2021), Quadrat-based monitoring of desert grassland vegetation at the Jornada Experimental Range, New Mexico, 1915–2016. Ecology. Accepted Author Manuscript e03530. https://doi.org/10.1002/ecy.3530 . Methods: 'The data set includes 122 1 m by 1 m permanent quadrats, although not all quadrats were sampled in each year of the study and there is a gap in monitoring from 1980–1995'. Data from annual species counts and perennial species counts were included. Exact locations and gamma_bounding_box are unknown.",
   comment_standardisation = "keeping only stations sampled more than 1 year. When sampled several times a year, sample from the generally most sampled month kept"
)][, gamma_sum_grains := sum(alpha_grain), by = year]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)
