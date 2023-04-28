# wright_2021
dataset_id <- "wright_2021"

ddata <- data.table::fread(
  file = "./data/raw data/wright_2021/SEVBeeData2002-2019.csv", sep = ",", quote = '"',
  drop = c("month", "start_date", "end_date", "direction", "color")
)
taxo <- data.table::fread(
  file = "./data/raw data/wright_2021/SEVBeeSpeciesList2002-2019.csv", sep = ",", quote = '"',
  select = c("code", "genus", "species", "author")
)
taxo[grepl("[0-9]", species), species := paste("sp.", species)][, species := paste(genus, species, author)]

# melting species
variable_list <- c("year", "complete_sampling_year", "complete_sampling_month", "ecosystem", "transect")
species_list <- colnames(ddata)[!names(ddata) %in% variable_list]
ddata[, (species_list) := lapply(.SD, function(column) replace(column, column == 0L, NA_integer_)), .SDcols = species_list] # replace all 0 values by NA

ddata <- data.table::melt(
  ddata,
  id.vars = variable_list,
  measure.vars = species_list,
  variable.name = "species",
  na.rm = TRUE
)

# standardisation ----
ddata <- ddata[complete_sampling_year == 1L & complete_sampling_month == 1L, .(value = sum(value), regional = unique(ecosystem)), by = .(year, local = transect, species)]

# Ddata ----
ddata[, ":="(
  dataset_id = dataset_id,

  regional = c("plains grasslands", "desert shrubland", "desert grassland")[match(regional, c("B", "C", "G"))],

  species = taxo$species[match(species, taxo$code)],

  metric = "abundance",
  unit = "count"
)]

# Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  taxon = "Invertebrates",
  realm = "Terrestrial",

  effort = 2L,

  study_type = "ecological_sampling",

  data_pooled_by_authors = FALSE,

  latitude = c(34.3364, 34.3329, 34.3362)[match(regional, c("plains grasslands", "desert shrubland", "desert grassland"))],
  longitude = c(-106.6345, -106.7358, -106.7212)[match(regional, c("plains grasslands", "desert shrubland", "desert grassland"))],

  alpha_grain = pi * (1.4 / 2)^2,
  alpha_grain_unit = "m2",
  alpha_grain_type = "trap",
  alpha_grain_comment = "area of funnel trap opening. 2 traps per transect.",

  gamma_sum_grains = (pi * (1.4 / 2)^2) * 2 * 5,
  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "sample",
  gamma_sum_grains_comment = "sum of trap areas per site",

  gamma_bounding_box = c(800L * 800L, 1400L * 400L, 1000L * 600L)[match(regional, c("plains grasslands", "desert shrubland", "desert grassland"))],
  # gamma_bounding_box = 930, # 230 000 acres area of the Sevilleta National Wildlife Refuge
  gamma_bounding_box_unit = "m2",
  gamma_bounding_box_type = "box",
  gamma_bounding_box_comment = "coarse box measured on figS1 from https://doi.org/10.1038/s41598-020-57553-2",

  comment = "Extracted from Wright et al EDI repository 	knb-lter-sev.321.2 doi:10.6073/pasta/cbe04a94b5f6f3859a3d9c98f5be0fc8 . Bee abundances were summed per year per transect. Methods: 'We focused on three major ecosystem types: Chihuahuan Desert shrubland, which is dominated by creosote bush (Larrea tridentata), Chihuahuan Desert grassland, which is dominated by black grama grass (Bouteloua eriopoda (Torr.) Torr.), and Plains grassland, which is dominated by blue grama grass (Bouteloua gracilis (Willd. Ex Kunth) Lag. Ex Griffiths). In our study, the two Chihuahuan Desert sites were separated by ~2 km; the Plains grassland site was ~10 km from the Chihuahuan Desert sites.[...] Bees were sampled along five transects located within each of the three focal ecosystem types. To sample bees, we installed one passive funnel trap at each end of five 200 m transects/site. Each trap consisted of a 946 mL paint can filled with ~275 mL of propylene glycol and topped with a plastic automotive funnel with the narrow part of the funnel sawed off (funnel height = 10 cm, top diameter = 14 cm, bottom diameter = 2.5 cm. The funnels’ interiors were painted with either blue or yellow fluorescent paint (Krylon, Cleveland, OH or Ace Hardware, Oak Brook, IL). On each transect, we randomly assigned one trap to be blue and the other to be yellow (total across the three sites: N = 30 traps, with 15 traps/color). Each trap was placed on a 45 cm high platform that was surrounded by a 60 cm high chicken wire cage to prevent wildlife and wind disturbance. Funnel traps provide a measure of bee activity, not a measure of presence, and may be biased by bee taxon and sociality. From 2002 to 2014, bees were sampled each month from March through October' IMPORTANT the authors warn that the abundance values they report should be considered as proxies of bee activity, not relative importance.",
  comment_standardisation = "only samples considered complete by the authors were kept. Pooling of species abundances at the transect level.",
  doi = 'https://doi.org/10.6073/pasta/cbe04a94b5f6f3859a3d9c98f5be0fc8'
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
