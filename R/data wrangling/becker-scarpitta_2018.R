## becker-scarpitta_2018
dataset_id <- "becker-scarpitta_2018"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata_historical.rds"))

data.table::setnames(
  ddata, c("Species"),
  c("species")
)

ddata <- data.table::melt(ddata,
  id.vars = c("species"),
  measure.vars = list(2:3, 4:5, 6:7),
  value.name = c("Forillon", "Mont-Megantic", "Gatineau"),
  variable.name = "period"
)

ddata <- data.table::melt(ddata,
  id.vars = c("species", "period"),
  variable.name = "local",
  value.name = "value"
)


ddata <- ddata[!is.na(value) & value > 0 & !is.na(species) & value != "-"]

ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Quebec",

  year = data.table::fifelse(
    period == 1,
    c(1972, 1970, 1973)[match(local, c("Forillon", "Mont-Megantic", "Gatineau"))],
    c(2015, 2012, 2016)[match(local, c("Forillon", "Mont-Megantic", "Gatineau"))]
  ),

  metric = "frequency",
  unit = "number of plots",
  period = NULL
)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
latitudes <- parzer::parse_lat(c("48°54`N", "45°27`N", "45°35`N"))
longitudes <- parzer::parse_lon(c("64°21`W", "71°9`W", "76°00`W"))

meta[, ":="(
  taxon = "Plants",
  realm = "Terrestrial",

  latitude = latitudes[match(local, c("Forillon", "Mont-Megantic", "Gatineau"))],
  longitude = longitudes[match(local, c("Forillon", "Mont-Megantic", "Gatineau"))],
  effort = c(49L, 48L, 28L)[match(local, c("Forillon", "Mont-Megantic", "Gatineau"))],
  data_pooled_by_authors = FALSE,


  study_type = "resurvey",

  alpha_grain = c(245L, 55L, 361L)[match(local, c("Forillon", "Mont-Megantic", "Gatineau"))],
  alpha_grain_unit = "km2",
  alpha_grain_type = "ecosystem",
  alpha_grain_comment = "area of the 3 national parks inside which samples were made",

  gamma_sum_grains = sum(245L, 55L, 361L),
  gamma_sum_grains_unit = "km2",
  gamma_sum_grains_type = "ecosystem",
  gamma_sum_grains_comment = "sum of the areas of the three parks",

  # gamma_bounding_box = 1365128L,
  # gamma_bounding_box_unit = 'km2',
  # gamma_bounding_box_type = "administrative",
  # gamma_bounding_box_comment = "area of the province of Quebec",

  gamma_bounding_box = geosphere::areaPolygon(data.frame(longitudes, latitudes)[grDevices::chull(longitudes, latitudes), ]) / 10^6,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "convex-hull",

  comment = "Extracted from Becker-Scarpitta et al 2018 Supplementary. Regional is Quebec, local are parks along a warming gradient (weak, medium and strong warming in Forillon, Mont-Megantic and Gatineau respectively. Effort = Numbers of plots which varies between parks but is the same in time within a park. Area of individual plots also varies between parks (90 to 800m2) but is the same within park and over time. The plots were never staked to make them permanent but different cues were used to resurvey the same area as accurately as possible making the plots semi-permanent. Only plots sufficiently accurately characterised were resurveyed. 'Taxonomical reference for vascular plants was the Taxonomic Name Resolution Service v4.0 (assessed in Feb 2017: http://tnrs.iplantcollaborative.org).'",
  comment_standardisation = "none needed"
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)

