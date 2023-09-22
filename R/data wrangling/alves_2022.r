dataset_id <- "alves_2022"

ddata <- base::readRDS(file = "data/raw data/alves_2022/rdata.rds")

# Raw data ----
ddata <- unique(ddata[ !General.Type %in% c("Substrate", "Dead", "Equipment",
                                            "Fish", "Rubble", "Sand.sediment",
                                            "Unknown", "Water", "N.c", "CTB")
][, Specific.Type := NULL])

data.table::setnames(ddata,
                     old = c("Year", "Image.Code", "ID", "Cover"),
                     new = c("year", "local", "species", "value"))

## communities ----
ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Belizean Barrier Reef",

   species = sub(pattern = ".", replacement = " ", x = species, fixed = TRUE),

   metric = "cover",
   unit = "percent"
)]

## coordinates ----
coords <- sf::st_read("data/GIS data/alves_2022_site_coordinates.kml")
data.table::setDT(coords)
coords[, c("longitude", "latitude", "z") := do.call(rbind.data.frame, geometry)]

## metadata ----
meta <- unique(ddata[, .(dataset_id, regional, Site, Transect, local, year,
                         Name = sub(pattern = "-.*$", replacement = "", x = local))])
meta[coords, ":="(
   latitude = i.latitude,
   longitude = i.longitude),
   on = "Name"]

meta[, ":="(
   taxon = "Invertebrates",
   realm = "Marine",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = 25L * 2L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "plot",
   alpha_grain_comment = "area of a 25m*2m transect",

   comment = "Data were downloaded from https://github.com/calves06/Belizean_Barrier_Reef_Change associated to the article: Alves C, Valdivia A, Aronson RB, Bood N, Castillo KD, et al. (2022) Twenty years of change in benthic communities across the Belizean Barrier Reef. PLOS ONE 17(1): e0249155. https://doi.org/10.1371/journal.pone.0249155. Authors measured cover of the substrate by recording images along transects. Site coordinates were looked for on maps",
   comment_standardisation = "Items from the following types were excluded: Substrate, Dead, Equipment, Fish, Rubble, Sand.sediment, Unknown, Water, N.c, CTB.",
   doi = 'https://doi.org/10.1371/journal.pone.0249155',

   Name = NULL
)]

## Saving raw data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata[value != 0, !c("Site", "Transect", "General.Type")],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = unique(meta[ddata[value != 0 ], on = .(local, year), !c("Site", "Transect")]),
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)

# Standardised data ----
## Standardisation of effort ----
### Sample based standardisation ----
# Resampling 14 pictures in all transects
ddata <- ddata[
   ddata[, .(local = sample(unique(local), 14L, replace = FALSE)), by = .(Site, Transect, year)],
   on = .(Site, Transect, year, local)][value != 0L]

ddata[, regional := Site][, Site := NULL]
ddata[, local := Transect][, Transect := NULL]

ddata[, ":="(
   value = 1L,
   metric = "pa",
   unit = "pa"
)]

ddata <- unique(ddata[General.Type == "Coral"][, General.Type := NULL])

## Excluding region-years with less than 4 transects/local ----
ddata <- ddata[
   !ddata[, data.table::uniqueN(local) < 4L, by = .(regional, year)][(V1)],
   on = .(regional, year)]

## Excluding sites that were not sampled at least twice 10 years apart.
ddata <- ddata[
   !ddata[, diff(range(year)) < 9L, by = .(regional, local)][(V1)],
   on = .(regional, local)]

## metadata ----
meta[, regional := Site][, Site := NULL]
meta[, local := Transect][, Transect := NULL]
meta <- unique(unique(meta)[ddata[, .(regional, local, year)],
                            on = .(regional, local, year)])

meta[, ":="(
   effort = 1L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of the areas of all transects of a site/region on a given year",

   gamma_bounding_box = NA,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "sites located by hand on maps",

   comment_standardisation = "Items from the following types were excluded: Substrate, Dead, Equipment, Fish, Rubble, Sand.sediment, Unknown, Water, N.c, CTB.
Only Coral is kept.
Regional is an island/site.
local is a transect.
Transects that had 15 pictures taken where resampled down to 14 pictures.
Transects that were not sampled at least twice at least 10 years apart were excluded."
)][, gamma_sum_grains := sum(alpha_grain), by = .(regional, year)]

## Saving standardised data ----
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
