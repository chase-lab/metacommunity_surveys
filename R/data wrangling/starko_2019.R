## starko_2019

dataset_id <- "starko_2019"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata_historical.rds"))

data.table::setnames(ddata, c("Site Num", "Year2"), c("local", "year"))

# melting species columns
ddata <- data.table::melt(ddata,
  id.vars = c("local", "year"),
  measure.vars = 5:(ncol(ddata) - 1),
  measure.name = "value",
  variable.name = "species",
  na.rm = TRUE
)

ddata <- ddata[value > 0]
ddata[value > 0, value := 1]

# GIS
coords <- base::readRDS(file = paste("data/raw data", dataset_id, "coords.rds", sep = "/"))
data.table::setnames(coords, c("Site", "Longitude", "Latitude"), c("local", "longitude", "latitude"))
vertices <- coords[grDevices::chull(x = coords$longitude, y = coords$latitude), c("longitude", "latitude")]

ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Barkley Sound",

  metric = "pa",
  unit = "pa"

)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  taxon = "Marine plants",
  realm = "Marine",

  effort = 1L,
  study_type = "resurvey",

  data_pooled_by_authors = FALSE,

  latitude = coords$latitude[match(local, coords$local)],
  longitude = coords$longitude[match(local, coords$local)],

  alpha_grain = 40L,
  alpha_grain_unit = "m2",
  alpha_grain_type = "sample",
  alpha_grain_comment = "stretches 20-50 meters long covering the tidal zones were investigated",

  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "quadrat",
  gamma_sum_grains_comment = "sum of the area of 46-49 transects sampled per year",

  gamma_bounding_box = geosphere::areaPolygon(vertices) / 10^6,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "convex-hull",
  gamma_bounding_box_comment = "convex-hull area of the sampling points given in journal.pone.0213191.s001.csv",

  comment = "Extracted from Starko et al 2019 Supplementary. Authors resurveyed kelp from the intertidal zone of rocky shores of 4 islands. Effort and methodology is comparable between historical and recent surveys. 'Surveys were conducted following the methods of the original surveyors and were mostly restricted to species in the order Laminariales'. Regional is the Barkley Sound study area west Vancouver Island, local are beaches. Sampling was made along 20 to 50 m long transects considered to be 2 m wide hence the estimated minimal grain of 40 m2.",
  comment_standardisation = "none needed",
  doi = 'https://doi.org/10.1371/journal.pone.0213191'
)][, gamma_sum_grains := 40L * length(unique(local)), by = year]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
