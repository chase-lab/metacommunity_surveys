## gibb_2019
dataset_id <- "gibb_2019"


ddata <- base::readRDS(paste0("./data/raw data/", dataset_id, "/ddata.rds"))
env <- base::readRDS(paste0("./data/raw data/", dataset_id, "/env.rds"))


# standardisation: 1) deleting winter samples and 2) selecting only surveys where all pitfall traps were recovered.
env[season == "Spring" & no.traps == 6, both_grids := .N, by = .(year, site)]
env <- env[both_grids == 2]

# melting species
ddata <- data.table::melt(ddata, id.vars = "code", variable.name = "species")
ddata <- ddata[value > 0]

# merging ddata and env
ddata <- merge(ddata, env[, .(code, site, position, year)], all.y = TRUE)


# data
ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Main Camp area of the Ethabuka Reserve",
  local = paste(site, position, sep = "_"),

  

  metric = "abundance",
  unit = "count",

  code = NULL,
  site = NULL,
  position = NULL
)]


meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  taxon = "Invertebrates",
  realm = "Terrestrial",

  latitude = "23°46'S",
  longitude = "138°28'E",

  effort = 1L,
  
  study_type = "ecological_sampling",

  data_pooled_by_authors = FALSE,

  alpha_grain = pi * (5^2),
  alpha_grain_unit = "cm2",
  alpha_grain_type = "sample",
  alpha_grain_comment = "area of a single pitfall trap",

  gamma_sum_grains = pi * (0.05^2) * 6,
  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "sample",
  gamma_sum_grains_comment = "sum of the area of the 6 pitfall traps per grid",

  gamma_bounding_box = pi * (10^2),
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "functional",
  gamma_bounding_box_comment = "'five sites within 10 km of 'Main Camp'",


  comment = "Data extracted fro dryad repo 10.5061/dryad.vc80r13. On each 1ha site, 2 invertebrate trap grids with 6 pitfall traps were set, one at the top and one at the bottom of the dune. In some site-year, two samplings occurred each year, one in spring, one in winter. Only spring samples were kept. In some cases pitfall traps were lost. Only site-year surveys where all pitfall traps were recovered were kept. The authors do not make clear that pitfall grids are accurately placed at the same spot over the years and sampling was annual or seasonal hence the 'ecological_sampling' categorisation. IMPORTANT in each 1ha site, each grid is considered separately: each local value is a grid meaning that independence between grids belonging to the same site should be taken into account.",
  comment_standardisation = "1) deleting winter samples and 2) selecting only surveys where all pitfall traps were recovered."
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
