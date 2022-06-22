dataset_id <- "alves_2022"

ddata <- data.table::fread(
   file = "./data/cache/alves_2021_Long.Master.Species.Groups.csv",
   drop = c("V1","File.Name","Image.Code"),
   sep = ",", header = TRUE, colClasses = list(factor = c("Site", "ID"))
)
ddata <- ddata[ Cover != 0 ]
ddata <- ddata[ !General.Type %in% c("Substrate","Dead","Equipment","Fish","Rubble","Sand.sediment","Unknown","Water","N.c","CTB")][, ":="(Specific.Type = NULL, General.Type = NULL, Cover = NULL)]
ddata <- ddata[!ID %in% c("Calcareous", "Fleshy_Macroalgae", "Hydroid", "Macroalgae", "Mat.tunicate", "Soft.coral", "Sponge", "Zoanthid")]

data.table::setnames(ddata, c("year","local","transect","species"))

# Standardisation of effort ----
## removing campaigns with less than 6 transects ----
ddata <- ddata[ddata[, .(select = length(unique(transect)) >= 6L), by = .(local, year)][(select), .(local, year)], on = c("local","year")]

## subsampling 6 transects in all sites ----
### keeping transects that were sampled the most frequently: ordering them first ----
ddata[, sampling_frequency := length(unique(year)), by = .(local, transect)]
data.table::setorder(ddata, local, year, -sampling_frequency)
ddata <- ddata[
   unique(ddata[, .(year, local, transect)])[, .SD[1L:6L], by = .(local, year)],
   on = c("local", "year", "transect")
] # data.table style join
ddata[, sampling_frequency := NULL][, transect := NULL]

### pooling transects together ----
ddata <- unique(ddata)

# GIS Data ----
coords <- sf::st_read("./data/GIS data/alves_2022_site_coordinates.kml")
data.table::setDT(coords)
data.table::setnames(coords, "Name","local")
coords[, c("longitude", "latitude","z") := do.call(rbind.data.frame, geometry)]
coords[, c("geometry", "Description", "z") := NULL]


# community data ----
ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Belizean Barrier Reef",

   value = 1L,
   metric = "pa",
   unit = "pa"
)]

# metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta <- coords[meta, on = "local"]
meta[, ":="(
   taxon = "Invertebrates",
   realm = "Marine",

   effort = 6L,

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,
   sampling_years = NA,

   alpha_grain = 25L * 2L * 6L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "plot",
   alpha_grain_comment = "sum of the areas of 6 25m*2m transects",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of the areas of all transects of all sites on a given year",

   gamma_bounding_box = geosphere::areaPolygon(coords[grDevices::chull(coords$longitude, coords$latitude), c("longitude", "latitude")]) / 1000000,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",

   comment = "Data were downloaded from https://github.com/calves06/Belizean_Barrier_Reef_Change associated to the article: Alves C, Valdivia A, Aronson RB, Bood N, Castillo KD, et al. (2022) Twenty years of change in benthic communities across the Belizean Barrier Reef. PLOS ONE 17(1): e0249155. https://doi.org/10.1371/journal.pone.0249155. Authors measured cover of the substrate by recording images along transects.",
   comment_standardisation = "Items from the following types were excluded: Substrate, Dead, Equipment, Fish, Sponge, Rubble, Sand.sediment, Unknown, Water, N.c, CTB. Items from the following taxonomical groups were excluded: Calcareous, Fleshy_Macroalgae, Hydroid, Macroalgae, Mat.tunicate, Soft.coral, Sponge, Zoanthid. Campaigns with less than 6 transects were removed and only the 6 most frequently sampled transects from other sites were kept. Samples from these 6 transects were then pooled together"
)][, gamma_sum_grains := sum(alpha_grain), by = .(regional, year)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)
