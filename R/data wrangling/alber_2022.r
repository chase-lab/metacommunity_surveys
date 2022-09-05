dataset_id <- "alber_2022"
ddata <- base::readRDS("./data/raw data/alber_2022/rdata.rds")

if (FALSE) {
   table(ddata[, length(unique(Date)), by = .(Year, Site, Zone, Plot)]$V1)
   table(ddata[, length(unique(Zone)), by = .(Year, Site)]$V1)
   table(ddata[, length(unique(Plot)), by = .(Year, Site, Zone)]$V1)
   table(ddata[, length(unique(Plot)), by = .(Year, Site)]$V1)
   ddata[, length(unique(Plot)), by = .(Year, Site)]

   # Site is regional and plot is local
   ddata[, .(diff(range(Year)), diff(range(Quadrat_Area))), by = .(Site, Plot)]
   ddata[, .(diff(range(Year)), diff(range(Quadrat_Area))), by = .(Site, Plot)][ V1 >= 10L & V2 == 0]

   ddata[Quadrat_Area == 0.5, diff(range(Year)), by = .(Site, Plot)][V1 >= 10L]
   ddata[ddata[Quadrat_Area == 0.5, diff(range(Year)), by = .(Site, Plot)][V1 >= 10L], on = c("Site","Plot")][, length(unique(Plot)), by = .(Year, Site)][V1 >= 4]
}

# Raw data ----
data.table::setnames(ddata,
                     c("Year", "Site_Name", "Location", "Longitude", "Latitude", "Species", "Mollusc_Count", "Quadrat_Area"),
                     c("year", "regional", "local", "longitude", "latitude", "species", "value", "alpha_grain")
)
ddata[regional == "", regional := paste0("GCE", Site)]

## communities ----
ddata[, ":="(
   dataset_id = dataset_id,

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
   alpha_grain_comment = "area of a a single quadrat",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of the areas of all quadrats of all sites on a given year",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment = "Data were downloaded from DOI:10.6073/pasta/651d603e2930d7ff608d7325230418e8 . METHODS: 'This data set includes long-term observational data on mollusc species abundance and size distribution at 10 Georgia Coastal Ecosystems marsh sites used for annual plant and invertebrate population monitoring. Infaunal and epifaunal molluscs were hand-collected from within quadrats of known area in mid-marsh and creekbank zones (n = 4 quadrats per zone) at all sites annually in October' also see: https://gce-lter.marsci.uga.edu/public/app/dataset_details.asp?accession=INV-GCES-1610",
   comment_standardisation = "none needed"
)]

meta_0.25 <- meta[alpha_grain == 0.25]
meta_0.5 <- meta[alpha_grain == 0.5]

meta_0.25[, ":="(
   gamma_sum_grains = sum(alpha_grain),
   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6),
   by = .(regional, year)]
meta_0.5[, ":="(
   gamma_sum_grains = sum(alpha_grain),
   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6),
   by = .(regional, year)]

ddata[, c("latitude","longitude") := NULL]

## splitting and saving into 2 studies because 2 sampling gears were used ----
drop_col <-  "alpha_grain"
### 0.25 m2
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata[alpha_grain == 0.25, !..drop_col],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_0.25_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta_0.25,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_0.25_raw_metadata.csv"),
   row.names = FALSE
)
### 0.5 m2
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata[alpha_grain == 0.5, !..drop_col],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_0.5_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta_0.5,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_0.5_raw_metadata.csv"),
   row.names = FALSE
)


# Standardised data ----
## data selection ----
ddata <- ddata[alpha_grain == 0.5]
## excluding empty sites ----
ddata <- ddata[value != 0L]

## excluding regions/years with less than 4 locations with observed mollusks. data.table style join ----
ddata <- ddata[ddata[, .(n_locations = length(unique(local))), by = .(year, regional)][n_locations >= 4L], on = c("year", "regional")]

## metadata ----
### subsetting original meta with standardised ddata ----
meta <- meta[ddata[,.(regional, local, year)], on = .(regional, local, year)]
### updating extent values ----
meta[, ":="(
   comment_standardisation = "Only quadrats of 0.5m2 were kept. We excluded regions/years with less than 4 locations with observed molluscs."
)][, ":="(
   gamma_sum_grains = sum(alpha_grain),
   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6),
   by = .(regional, year)]

## saving standardised data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standadised.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standadised_metadata.csv"),
   row.names = FALSE
)
