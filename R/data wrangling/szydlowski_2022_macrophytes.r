# szydlowski_2022_macrophytes
dataset_id = "szydlowski_2022_macrophytes"
source("./R/functions/resampling.r")

ddata <- base::readRDS(file = "./data/raw data/szydlowski_2022_macrophytes/rdata.rds")

# Melting species ----
ddata[, Uknown_macroalgae := NULL]
species_list <- grep(pattern = "^[A-Z][a-z]*_[a-z]*$", x = colnames(ddata), value = TRUE)
ddata[, (species_list) := lapply(.SD, function(column) replace(column, column == 0, NA_real_)), .SDcols = species_list] # replace all 0 values by NA
ddata[, effort := length(unique(sector)), by = .(year, lake)]
ddata <- data.table::melt(ddata,
                          id.vars = c("year","lake","sector","lat","long","effort"),
                          measure.vars = species_list,
                          variable.name = "species",
                          value.name = "value",
                          na.rm = TRUE
)
data.table::setnames(ddata, c("lake","lat","long"), c("local","latitude","longitude"))

# standardising effort ----

## resampling based on the smallest sample size from the sites with the smallest number of sectors ----
ddata[, sample_size := as.integer(sum(value)), by = .(local, year)]
min_sample_size <- as.integer(ddata[effort == min(effort), min(sample_size)])

ddata[, ":="(latitude = mean(latitude), longitude = mean(longitude)), by = .(local, year)]

ddata <- ddata[, .(
   value = as.integer(sum(value)),
   latitude = unique(latitude), longitude = unique(longitude),
   effort = unique(effort), sample_size = unique(sample_size)
), by = .(local, year, species)
]
ddata[, species := as.character(species)]
data.table::setkey(ddata, species)

set.seed(42)
ddata[sample_size > min_sample_size, value := resampling(species, value, min_sample_size), by = .(local, year)]
ddata[sample_size < min_sample_size, value := resampling(species, value, min_sample_size, replace = TRUE), by = .(local, year)]
ddata <- ddata[!is.na(value)]

# Community data ----
lake_names <- c("Allequash Lake" = "AL", "High Lake" = "HI", "Little John Lake" = "LJ", "Little Star Lake" = "LS", "Papoose Lake" = "PA", "Plum Lake" = "PL", "Presque Isle Lake" = "PI", "Spider Lake" = "SP", "Squirrel Lake" = "SQ", "Wild Rice Lake" = "WR")

ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Vilas County, Wisconsin",
   local = names(lake_names)[match(local, lake_names)],

   metric = "abundance",
   unit = "individuals per transect",

   sample_size = NULL,
   effort = NULL
)]

# Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, latitude, longitude)])
meta[, ":="(
   taxon = "Plants",
   realm = "Freshwater",

   effort = 6L,

   study_type = "ecological_sampling",
   data_pooled_by_authors = FALSE,

   alpha_grain = 10L * 75L * 26L * 6L,
   alpha_grain_unit = "cm2",
   alpha_grain_type = "sample",
   alpha_grain_comment = "area of the sampled vertical plan, 10cm wide and 75cm deep, times 26 panes per transect, times the standardised number of transects",

   gamma_sum_grains_unit = "cm2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of the sampled areas from all lakes on a given year",

   gamma_bounding_box = 2640L,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "administrative",
   gamma_bounding_box_comment = "area of Vilas County, Wisconsin",

   comment = "Extracted from EDI repository - Aquatic snail and macrophyte abundance and richness data for ten lakes in Vilas County, WI, USA, 1987-2020 - https://doi.org/10.6073/pasta/29733b5269efe990c3d2d916453fe4dd and associated article . Authors sampled counted macrophytes intersecting 10cm wide panes going from the substrate to the surface (75cm in most cases) every meter of a 25m long transect, 6 to 14 transects per lake per year. Sampling happened in 1987, 2002, 2011 and 2020 following the lakes invasion by a crayfish. Ideally alpha_grain would be the size of the lakes but that information was not found.",
   comment_standardisation = "Abundances were resampled based on the minimal abundance found in lakes with only 6 transects."
)][, gamma_sum_grains := sum(alpha_grain), by = year]

ddata[, c("latitude","longitude") := NULL]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)

data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)
