## cazelles_2019

dataset_id <- "cazelles_2019"

# GIS
# Ontario boundaries
load("./data/raw data/cazelles_2019/McCannLab-HomogenFishOntario-b08469d/data/sf_bsm_ahi.rda")
bsm <- sf::as_Spatial(sf_bsm_ahi)

ddata <- data.table::as.data.table(sf_bsm_ahi)
data.table::setnames(
  ddata, c("idLake"),
  c("local")
)

ddata <- data.table::melt(ddata,
  measure.vars = grep("PA", colnames(ddata)),
  variable.name = "species",
  value.name = "value"
)
ddata <- ddata[value > 0, .(local, species, value)]

# species names
load("./data/raw data/cazelles_2019/McCannLab-HomogenFishOntario-b08469d/data/df_species_info.rda")

ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Ontario",
  year = data.table::fifelse(grepl("AHI", species), 1982L, 2012L),

  species = gsub("PA_|_AHI", "", species),
  metric = "pa",
  unit = "pa"
)][species %in% df_species_info$idOnt, species := df_species_info$rfbName[match(species, df_species_info$idOnt)]]


ddata <- unique(ddata)

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  realm = "Freshwater",
  taxon = "Fish",

  latitude = "49°15'00'N",
  longitude = "84°30'00'W",

  effort = 1L,

  study_type = "resurvey",

  data_pooled_by_authors = FALSE,
  data_pooled_by_authors_comment = "each lake was only sampled twice, once per period but sampling year is unknown (1965-1982, 2008-2012)",
  sampling_years = c("1965-1982", "2008-2012")[match(year, c(1982L, 2012L))],

  alpha_grain = bsm$Area_km2_[match(local, bsm$idLake)], # lake area given by the authors
  alpha_grain_unit = "km2",
  alpha_grain_type = "lake_pond",
  alpha_grain_comment = "lake area given by the authors",

  gamma_sum_grains = sum(bsm$Area_km2_[bsm$idLake %in% local]),
  gamma_sum_grains_unit = "km2",
  gamma_sum_grains_type = "lake_pond",
  gamma_sum_grains_comment = "sum of the sampled lakes",

  gamma_bounding_box = 1076395L,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "administrative",
  gamma_bounding_box_comment = "area of Ontario province",

  comment = "Extracted from Cazelles et al zenodo repo. 'We constructed a dataset of 524 natural lakes that were each surveyed twice, once historically between 1965 and 1982 during the Aquatic Habitat Inventory (hereafter AHI [...]) and again between 2008 and 2012 by the Ontario Broad-scale Fish Community Monitoring Program (hereafter BsM [...]). Both AHI and BsM surveys assess the fish species composition across a wide range of habitats in lakes. For both surveys, we used the presence/absence data obtained based on gill nets that were set in the lakes for 12 hr and use a very similar range of mesh sizes (25–127 mm for both; see Dodge et al., 1987 for details about AHI, and Sandstrom et al., 2013 for more details about BsM).' Authors were not allowed to disclose lake coordinates. ",
  comment_standardisation = "none needed"

)]


dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
