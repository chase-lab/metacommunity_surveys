## larkin_2015
dataset_id <- "larkin_2015"

ddata <- base::readRDS(file = "./data/raw data/larkin_2015/ddata.rds")

data.table::setnames(
  ddata, c("Year", "Site", "Plot"),
  c("year", "local", "block")
)

taxonomy <- base::readRDS(file = "./data/raw data/larkin_2015/taxonomy.rds")

# subsetting: We keep only the first 19 plots of each site (19 is the minimal number of plots across sites).
ddata <- ddata[, .SD[1:19], by = .(year, local)]

# pooling
ddata <- ddata[, block := NULL][, lapply(.SD, sum), by = .(year, local)]

ddata <- data.table::melt(ddata,
  id.vars = c("year", "local"),
  variable.name = "species",
  value.name = "value"
)
ddata <- unique(ddata[value != 0][, value := 1L]) # replacing all > 1 values

# community data ----
ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Illinois",

  metric = "pa",
  unit = "pa"

)]

# taxonomy cleaning
ddata <- ddata[!species %in% c("dicot", "unkforb", "grass1", "grass3", "grasssp")]
taxonomy[Code == "polveriso", species := "Polygala verticillata iso"]
ddata[species == "thadashyp", species := "Thalictrum dasycarpum hyp"]
ddata[species == "astsp1", species := "Aster sp.1"]
ddata[species == "astsp2", species := "Aster sp.2"]
ddata[species %in% taxonomy$Code, species := taxonomy$Species[match(species, taxonomy$Code)]]


# metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(

  realm = "Terrestrial",
  taxon = "Plants",

  latitude = 41.5,
  longitude = -88.5,

  effort = 1L,
  study_type = "resurvey",

  data_pooled_by_authors = FALSE,

  alpha_grain = 4.75,
  alpha_grain_unit = "m2",
  alpha_grain_type = "plot",
  alpha_grain_comment = "19 0.25m2 circular quadrats per site",

  gamma_sum_grains = 4.75 * 41,
  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "plot",
  gamma_sum_grains_comment = " 19 0.25m5 quadrats per site * number of sites",

  gamma_bounding_box = 37499.25,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "administrative",
  gamma_bounding_box_comment = "area of Illinois/4 because sites are located in 'north-eastern Illinois'",

  comment = "Extracted from Larkin et al 2015 Dryad repo (https://datadryad.org/stash/dataset/doi:10.5061/dryad.763v6). Resurvey of plant communities of 41 sites in Illinois originally sampled in 1976 and resampled in 2001. Coordinates of the centre of Nort East Illinois.",
  comment_standardisation = "Original sampling was standardised: 20 to 30 0.25m2 circular quadrats along a transect, per site BUT We keep only the first 19 plots of each site (19 is the minimal number of plots across sites). Then we pooled together species detected in the 19 quadrats of a site in a given year."
)]


dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
