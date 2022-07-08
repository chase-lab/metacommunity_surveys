# szydlowski_2022_molluscs
dataset_id = "szydlowski_2022_snails"
source("./R/functions/resampling.r")

ddata <- base::readRDS(file = "./data/raw data/szydlowski_2022_snails/rdata.rds")

# Melting species ----
species_list <- grep(pattern = "^[A-Z][a-z]*_[a-z]*$", x = colnames(ddata), value = TRUE)
ddata[, (species_list) := lapply(.SD, function(column) replace(column, column == 0, NA_real_)), .SDcols = species_list] # replace all 0 values by NA
ddata <- data.table::melt(ddata,
                          id.vars = c("year","lake","sector","lat","long","gear"),
                          measure.vars = species_list,
                          variable.name = "species",
                          value.name = "value",
                          na.rm = TRUE
)
data.table::setnames(ddata, c("lake","lat","long"), c("local","latitude","longitude"))

# standardising effort ----
## computing alpha_grain as the total sampled area ----
ddata[, gear := c(0.01824, 0.01824, 0.5)[match(gear, c("OC", "VC", "LR"))]]

## deleting undersampled lakes/years ----
ddata <- ddata[, effort := length(unique(sector)), by = .(local, year)][effort >= 5]

## resampling based on the smallest sample size from the sites with the smallest number of sectors ----
ddata[, sample_size := as.integer(sum(value)), by = .(local, year)]
min_sample_size <- as.integer(ddata[effort == min(effort), min(sample_size)])
ddata[, ":="(latitude = mean(latitude), longitude = mean(longitude), gear = sum(gear)), by = .(local, year)]

ddata <- ddata[, .(
   value = as.integer(sum(value)),
   latitude = unique(latitude), longitude = unique(longitude),
   alpha_grain = unique(gear), sample_size = unique(sample_size)
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

   metric = "density",
   unit = "individuals per square meter",

   sample_size = NULL
)]

# Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, latitude, longitude, alpha_grain)])
meta[, ":="(
   taxon = "Invertebrates",
   realm = "Freshwater",

   effort = 5L,

   alpha_grain_unit = "m2",
   alpha_grain_type = "sample",
   alpha_grain_comment = "sample of the area of the gear used per sampling. Unknown but comparable in 1987 and 2002",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of the sampled areas from all lakes on a given year",

   gamma_bounding_box = 2640L,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "administrative",
   gamma_bounding_box_comment = "area of Vilas County, Wisconsin",

   comment = "Extracted from EDI repository - Aquatic snail and macrophyte abundance and richness data for ten lakes in Vilas County, WI, USA, 1987-2020 - https://doi.org/10.6073/pasta/29733b5269efe990c3d2d916453fe4dd and associated article . Authors sampled snails from the bottom substrate using different samplers following the lakes invasion by a crayfish. Sampling happened in 1987, 2002, 2011 and 2020. Ideally alpha_grain would be the size of the lakes but that information was not found.",
   comment_standardisation = "All abundances per m2 were turned into integers to allow resampling process. Sites with less than 5 sampling points were excluded. Abundances were resampled based on the minimal abundance found in lakes with only 5 sampling points. METHOD: 'Gear information for 2002 and 1987 is not available, though a combination of the same gears was still used'"
)][, gamma_sum_grains := sum(alpha_grain) * length(unique(local)), by = year]

ddata[, c("latitude", "longitude", "alpha_grain") := NULL]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)

data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)


