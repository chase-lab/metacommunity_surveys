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

# data selection and cleaning ----
ddata <- ddata[Quadrat_Area == 0.5]
## excluding empty sites ----
ddata <- ddata[Mollusc_Count != 0L]

ddata[Site_Name == "", Site_Name := paste0("GCE", Site)]
ddata[,]
data.table::setnames(ddata,
                     c("Year", "Site_Name", "Location", "Longitude", "Latitude", "Species", "Mollusc_Count", "Quadrat_Area"),
                     c("year", "regional", "local", "longitude", "latitude", "species", "value", "alpha_grain")
)
## excluding regions/years with less than 4 locations with observed mollusks. data.table style join ----
ddata <- ddata[ddata[, .(n_locations = length(unique(local))), by = .(year, regional)][n_locations >= 4L], on = c("year", "regional")]
## averaging coordinates per location ----
# ddata[, ":="(
#    latitude = mean(latitude),
#    longitude = mean(longitude)
# ), by = .(regional, local)]

# communities ----
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
   Notes = NULL,
   n_locations = NULL
)]


# metadata ----
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

   comment = "Data were downloaded from DOI:10.6073/pasta/651d603e2930d7ff608d7325230418e8 . METHODS: 'This data set includes long-term observational data on mollusc species abundance and size distribution at 10 Georgia Coastal Ecosystems marsh sites used for annual plant and invertebrate population monitoring. Infaunal and epifaunal molluscs were hand-collected from within quadrats of known area in mid-marsh and creekbank zones (n = 4 quadrats per zone) at all sites annually in October'",
   comment_standardisation = "Only quadrats of 0.5m2 were kept. We excluded regions/years with less than 4 locations with observed molluscs."
)][, ":="(
   gamma_sum_grains = sum(alpha_grain),
   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6),
   by = .(regional, year)]

ddata[, c("latitude","longitude","alpha_grain") := NULL]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
   row.names = FALSE
)
