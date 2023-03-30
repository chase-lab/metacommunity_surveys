# szydlowski_2022_snails
dataset_id = "szydlowski_2022_snails"

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
## backtransforming abundances ----
ddata[, value := value * 0.01824]

## selecting comparable samples ----
min_sample_number <- 6L
ddata <- ddata[gear == "OC", effort := length(unique(sector)), by = .(local, year)][effort >= min_sample_number]
set.seed(42)
ddata <- ddata[ddata[, .(sector = sample(sector, min_sample_number, replace = FALSE)), by = .(local, year)], on = .(local, year, sector)]

## pooling sectors together
ddata <- ddata[, .(value = sum(value), latitude = mean(latitude), longitude = mean(longitude)), by = .(local, year, species)]

## excluding lakes with less than 20 individuals total abundance per year ----
ddata <- ddata[ddata[, .(rich = sum(value) >= 20L), by = .(local, year)][(rich), .(local, year)], on = .(local, year)]

## keeping only lakes available for 2 years ----
ddata <- ddata[ddata[, length(unique(year)) >= 2L, by = local][(V1), .(local)], on = "local"]

# Community data ----
lake_names <- c("Allequash Lake" = "AL", "High Lake" = "HI", "Little John Lake" = "LJ", "Little Star Lake" = "LS", "Papoose Lake" = "PA", "Plum Lake" = "PL", "Presque Isle Lake" = "PI", "Spider Lake" = "SP", "Squirrel Lake" = "SQ", "Wild Rice Lake" = "WR")

ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Vilas County, Wisconsin",
   local = names(lake_names)[match(local, lake_names)],

   metric = "abundance",
   unit = "count"
)]

# Metadata ----
meta <- unique(ddata[, .(latitude = mean(latitude), longitude = mean(longitude)), by = .(dataset_id, regional, year, local)])
meta[, ":="(
   taxon = "Invertebrates",
   realm = "Freshwater",

   effort = min_sample_number,

   study_type = "ecological_sampling",
   data_pooled_by_authors = FALSE,

   alpha_grain = 0.01824 * min_sample_number,
   alpha_grain_unit = "m2",
   alpha_grain_type = "sample",
   alpha_grain_comment = "area of the open core * the number of cores per lake",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of the sampled areas from all lakes on a given year",

   # gamma_bounding_box = 2640L,
   gamma_bounding_box =  geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",

   comment = "Extracted from EDI repository - Aquatic snail and macrophyte abundance and richness data for ten lakes in Vilas County, WI, USA, 1987-2020 - https://doi.org/10.6073/pasta/29733b5269efe990c3d2d916453fe4dd and associated article . Authors sampled snails from the bottom substrate using different samplers following the lakes invasion by a crayfish. Sampling happened in 1987, 2002, 2011 and 2020. ",
   comment_standardisation = "All abundances per m2 were back-transformed into integers using the Open Core sample area. To obtain a representative and standardised communities, we focused on years where sampling gear is known (2011 and 2020) and used only Open Cores. To get a comparable effort between years and lakes, we randomly selected 6 sectors (ie samples) from each lake/year. The number of 6 samples is a trade-off between excluding the fewest lakes with insufficient effort and getting as many individuals as possible."
)][, gamma_sum_grains := sum(alpha_grain), by = year]

ddata[, c("latitude", "longitude") := NULL]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)

data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)
