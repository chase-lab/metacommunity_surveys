dataset_id <- "starko_2019"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata_historical.rds"))

#Raw Data ----
data.table::setnames(
  x = ddata,
  old = c("Site Num", "Year2"),
  new = c("local", "year"))

##melting species columns -----
ddata <- data.table::melt(ddata,
                          id.vars = c("local", "year"),
                          measure.vars = 5:(ncol(ddata) - 1),
                          measure.name = "value",
                          variable.name = "species",
                          na.rm = TRUE
)
##excluding absence data ----
ddata <- ddata[value > 0]

##GIS ----
coords <- base::readRDS(file = paste("data/raw data", dataset_id, "coords.rds", sep = "/"))
data.table::setnames(coords, c("Site", "Longitude", "Latitude"), c("local", "longitude", "latitude"))
vertices <- coords[grDevices::chull(x = coords$longitude, y = coords$latitude), c("longitude", "latitude")]

##community data ----
ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Barkley Sound",
  
  metric = "coverage",
  unit = "levels"
)]

##meta data ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  taxon = "Marine plants",
  realm = "Marine",
  
  study_type = "resurvey",
  
  data_pooled_by_authors = FALSE,
  
  latitude = coords$latitude[match(local, coords$local)],
  longitude = coords$longitude[match(local, coords$local)],
  
  alpha_grain = 40L,
  alpha_grain_unit = "m2",
  alpha_grain_type = "sample",
  alpha_grain_comment = "stretches 20-50 meters long covering the tidal zones were investigated",
  
  comment = "Extracted from Starko et al 2019 Supplementary. Authors resurveyed kelp from the intertidal zone of rocky shores of 4 islands. Effort and methodology is comparable between historical and recent surveys. 'Surveys were conducted following the methods of the original surveyors and were mostly restricted to species in the order Laminariales'. Regional is the Barkley Sound study area west Vancouver Island, local are beaches. Sampling was made along 20 to 50 m long transects considered to be 2 m wide hence the estimated minimal grain of 40 m2. Presence and absence of all kelp species were determined for the entire survey area by carefully identifying all kelp species present by morphology. Kelps are large, seasonally persistent and are easy to distinguish based on conspicuous morphological features [39]. Thus, both our surveys and those done by the original surveyors were likely to result in unbiased, reproducible data. In order to quantify abundance, the intertidal was blocked into four zones: high intertidal (approx. > 2.5 m), mid intertidal (approx. 1.2–2.5 m), low intertidal (approx. 0.2–1.2 m) and shallow subtidal (0–0.2 m). Abundance of each species, in each zone, was then quantified based on visual estimation of percentage cover categories:  rare (≤ 5%) = 1, common (6–20%) = 2and (21–100%) = 3. A species’ assigned abundance was then taken from the zone of its greatest abundance.",
  comment_standardisation = "none needed",
  doi = 'https://doi.org/10.1371/journal.pone.0213191'
)]

## save data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
  x = ddata[, !c("taxon")],
  file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
  row.names = FALSE
)
data.table::fwrite(
  x = meta,
  file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
  row.names = FALSE
)

#Standardized Data ----
##transforming average abundance levels to presence absence data ----
ddata[value > 0, value := 1]

ddata[, ":="(
  metric = "pa",
  unit = "pa"
)]

##meta data ----
meta <- meta[unique(ddata[, .(dataset_id, local, regional, year)]),
             on = .(local, regional, year)]

meta[, ":="(
  effort = 1L,
  
  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "quadrat",
  gamma_sum_grains_comment = "sum of the area of 46-49 transects sampled per year",
  
  gamma_bounding_box = geosphere::areaPolygon(vertices) / 10^6,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "convex-hull",
  gamma_bounding_box_comment = "convex-hull area of the sampling points given in journal.pone.0213191.s001.csv",

  comment_standardisation = "cover category turned into presence absence"
)][, gamma_sum_grains := 40L * length(unique(local)), by = year]

##save data ----
data.table::fwrite(
  x = ddata[, !c("taxon")],
  file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized.csv"),
  row.names = FALSE
)
data.table::fwrite(
  x = meta,
  file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized_metadata.csv"), 
  row.names = FALSE
)
