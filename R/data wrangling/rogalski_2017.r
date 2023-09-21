# rogalski_2017
dataset_id <- "rogalski_2017"

ddata <- base::readRDS(paste0("data/raw data/", dataset_id, "/ddata.rds"))

data.table::setnames(ddata, old = 1L, new = "local")

#Raw Data ----
##melting species ----
ddata <- data.table::melt(ddata,
                          id.vars = c("local", "year"),
                          variable.name = "species",
                          na.rm = TRUE
)

ddata <- ddata[value > 0]

## community data ----
ddata[, ":="(
   dataset_id = dataset_id,

   regional = "Connecticut",

   year = trunc(year),

   value = 1L,
   metric = "pa",
   unit = "pa"
)]

## coordinates ----
coords <- data.frame(
   latitude = c(41.528562, 41.86038014288051, 41.9506421, 41.3209),
   longitude = c(-72.740850, -71.90013328247834, -71.9513725, -72.7796)
)

## meta data ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
   taxon = "Invertebrates",
   realm = "Freshwater",

   latitude = coords$latitude[data.table::chmatch(local, c("Black", "Alexander", "Roseland", "Cedar"))],
   longitude = coords$longitude[data.table::chmatch(local, c("Black", "Alexander", "Roseland", "Cedar"))],

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = pi * (0.125^2),
   alpha_grain_unit = "m2",
   alpha_grain_type = "sample",
   alpha_grain_comment = "sample/alpha_grain is one single sediment core per lake (local).",

   comment = "Data were extracted from the Dryad repository https://doi.org/10.5061/dryad.2vh5c. Authors made sediment samples in 3 lakes and counted Daphnia eggs at different depths to reconstruct past communities.  The authors consider the Ceriodaphnia_eggs_dryg-1 morphospecies as a species (not a group of species that they cannot differentiate). Lake areas were extracted from supp1 associated to the article https://dx.doi.org/10.6084/m9. Coordinates were looked for on various local (Connecticut) websites.",
   comment_standardisation = "Absence values excluded",
   doi = 'https://doi.org/10.5061/dryad.2vh5c | https://doi.org/10.1098/rspb.2017.0865'
)]

## save raw data ----
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
ddata <- ddata[species != "Unknown_eggs_dryg-1"]

## meta data ----
meta <- meta[unique(ddata[, .(local, year)]),
             on = .(local, year)]
meta[, ":="(
   effort = 1L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sample/alpha_grain is one single sediment core per lake (local). gamma_sum_grains is the sum of sediment core 'slices' per year",

   gamma_bounding_box = geosphere::areaPolygon(coords[grDevices::chull(coords$longitude, coords$latitude), c("longitude", "latitude")]) / 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "area covering the 4 lakes",

   comment_standardisation = "Taxa that were not identified (ie 'unknown') were excluded."
)][, gamma_sum_grains := pi * (0.125^2) * length(unique(local)), by = .(regional, year)]


## save standardised data ----
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
