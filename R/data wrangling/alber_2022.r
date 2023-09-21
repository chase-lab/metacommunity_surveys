dataset_id <- "alber_2022"
ddata <- base::readRDS("data/raw data/alber_2022/rdata.rds")

if (FALSE) {
   table(ddata[, length(unique(Date)), by = .(Year, Site, Zone, Plot)]$V1)
   table(ddata[, length(unique(Zone)), by = .(Year, Site)]$V1)
   table(ddata[, length(unique(Plot)), by = .(Year, Site, Zone)]$V1)
   table(ddata[, length(unique(Plot)), by = .(Year, Site)]$V1)
   ddata[, length(unique(Plot)), by = .(Year, Site)]

   # Site is regional and plot is local
   ddata[, .(diff(range(Year)), diff(range(Quadrat_Area))), by = .(Site, Plot)]
   ddata[, .(diff(range(Year)), diff(range(Quadrat_Area))), by = .(Site, Plot)][ V1 >= 9L & V2 == 0]

   ddata[Quadrat_Area == 0.5, diff(range(Year)), by = .(Site, Plot)][V1 >= 9L]
   ddata[ddata[Quadrat_Area == 0.5, diff(range(Year)), by = .(Site, Plot)][V1 >= 9L], on = c("Site","Plot")][, length(unique(Plot)), by = .(Year, Site)][V1 >= 4]
}

# Raw data ----
data.table::setnames(
   x = ddata,
   old = c("Year", "Site_Name", "Location", "Longitude", "Latitude", "Species",
           "Mollusc_Count", "Quadrat_Area"),
   new = c("year", "regional", "local", "longitude", "latitude", "species",
           "value", "alpha_grain")
)
ddata[regional == "", regional := paste0("GCE", Site)]

ddata <- ddata[!is.na(alpha_grain)]

## communities ----
ddata[, ":="(
   dataset_id = factor(paste(dataset_id, "grain", alpha_grain, "m2", sep = "_")),

   metric = "abundance",
   unit = "count",

   Date = NULL,
   Site = NULL,
   Zone = NULL,
   Plot = NULL,
   Flag_Location = NULL,
   Flag_Longitude = NULL,
   Flag_Latitude = NULL,
   Location_Notes = NULL,
   Mollusc_Density = NULL,
   Notes = NULL
)]

## metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, latitude, longitude, alpha_grain)])
meta[, ":="(
   taxon = "Invertebrates",
   realm = "Terrestrial",

   effort = 1L,

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,
   sampling_years = NA,

   alpha_grain_unit = "m2",
   alpha_grain_type = "quadrat",
   alpha_grain_comment = "area of a single quadrat",

   comment = "Data were downloaded from DOI:10.6073/pasta/651d603e2930d7ff608d7325230418e8 . METHODS: 'This data set includes long-term observational data on mollusc species abundance and size distribution at 10 Georgia Coastal Ecosystems marsh sites used for annual plant and invertebrate population monitoring. Infaunal and epifaunal molluscs were hand-collected from within quadrats of known area in mid-marsh and creekbank zones (n = 4 quadrats per zone) at all sites annually in October' also see: https://gce-lter.marsci.uga.edu/public/app/dataset_details.asp?accession=INV-GCES-1610",
   comment_standardisation = "Rows with quadrat_area = NA or quadrat_area having a very rare value were excluded.",
   doi = 'https://doi.org/10.6073/pasta/651d603e2930d7ff608d7325230418e8'
)]

ddata[, c("latitude","longitude") := NULL]

## splitting and saving into several studies because several sampling gears were used ----
data.table::setkey(ddata, dataset_id)
data.table::setkey(meta, dataset_id)
dataset_ids <- unique(meta$dataset_id)

for (dataset_id_i in dataset_ids) {
   dir.create(paste0("data/wrangled data/", dataset_id_i), showWarnings = FALSE)
   data.table::fwrite(
      x = ddata[dataset_id_i, !"alpha_grain"],
      file = paste0("data/wrangled data/", dataset_id_i, "/", dataset_id_i, "_raw.csv"),
      row.names = FALSE
   )
   data.table::fwrite(
      x = meta[dataset_id_i, !"effort"],
      file = paste0("data/wrangled data/", dataset_id_i, "/", dataset_id_i, "_raw_metadata.csv"),
      row.names = FALSE
   )
}

# Standardised data ----
## data selection ----
ddata <- ddata[alpha_grain == 0.5][, alpha_grain := NULL]
## excluding empty sites ----
ddata <- ddata[value != 0L]

## excluding regions/years with less than 4 locations with observed mollusks. ----
ddata <- ddata[
   !ddata[, .(n_locations = data.table::uniqueN(local)),
          by = .(dataset_id, regional, year)][n_locations < 4L],
   on = .(dataset_id, regional, year)]

## Excluding sites that were not sampled at least twice 10 years apart.
ddata <- ddata[
   !ddata[, diff(range(year)) < 9L,
          by = .(dataset_id, regional, local)][(V1)],
   on = .(dataset_id, regional, local)]

## metadata ----
### subsetting original meta with standardised ddata ----
meta <- unique(meta[
   ddata[,.(dataset_id, regional, local, year)],
   on = .(dataset_id, regional, local, year)])

### updating extent values ----
meta[, ":="(
   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of the areas of all quadrats of all sites on a given year",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment_standardisation = "We excluded regions/years with less than 4 locations with observed molluscs.
We excluded sites that were not sampled twice at least 10 years apart."
)][, ":="(
   gamma_sum_grains = sum(alpha_grain),
   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6),
   by = .(dataset_id, regional, year)]

## saving standardised data ----
data.table::setkey(ddata, dataset_id)
data.table::setkey(meta, dataset_id)
dataset_ids <- unique(meta$dataset_id)

for (dataset_id_i in dataset_ids) {
   data.table::fwrite(
      x = ddata[dataset_id_i],
      file = paste0("data/wrangled data/", dataset_id_i, "/", dataset_id_i, "_standardised.csv"),
      row.names = FALSE
   )
   data.table::fwrite(
      x = meta[dataset_id_i],
      file = paste0("data/wrangled data/", dataset_id_i, "/", dataset_id_i, "_standardised_metadata.csv"),
      row.names = FALSE
   )
}

