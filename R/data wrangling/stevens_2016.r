# stevens_2016


dataset_id <- "stevens_2016"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))
data.table::setnames(ddata, new = c("local", "species", "1968", "2013"))
ddata[local == "", local := NA_character_][, local := zoo::na.locf(local)]

ddata <- data.table::melt(ddata,
  measure.vars = c("1968", "2013"),
  value.name = "value",
  variable.name = "year"
)

ddata <- ddata[value > 0]

ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Sheffield",

  metric = "frequency",
  unit = "frequency"
)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(

  realm = "Terrestrial",
  taxon = "Plants",

  latitude = '53° 23` 0" N',
  longitude = '1° 28` 0" W',

  effort = c(196L, 259L)[match(local, c("Acid", "Calcareous"))],
  study_type = "resurvey",

  data_pooled_by_authors = TRUE,
  data_pooled_by_authors_comment = "one sampling per site per sampling period",
  sampling_years = c("1965-1968", "2012-2013")[match(year, c(1968, 2013))],

  alpha_grain_unit = "m2",
  alpha_grain_type = "quadrat",
  alpha_grain_comment = "sum of 1m2 quadrats sampled per habitat type",

  gamma_sum_grains = 196L + 259L,
  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "quadrat",

  gamma_bounding_box = 2400L,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "ecosystem",
  gamma_bounding_box_comment = "The survey focused on a 2400 km2 area around Sheffield encompassing a large part of the Peak District National Park.",

  comment = "Extracted from stevens et al 2016, data extracted from supplementary excel file ( https://doi.org/10.1111/avsc.12206). Authors resurveyed the exact same sites as Lloyd in 1965-68 to analyse structuring factors of plant communities. Regional is the area covering all sampling sites, given by the authors, local are two habitat types sampled in many locations throughout the regional area. The number of quadrats per habitat is given as effort.",
  comment_standardisation = "All quadrats were pooled together by period and habitat type"
)][, alpha_grain := effort]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)

data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
