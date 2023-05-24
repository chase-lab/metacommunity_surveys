dataset_id <- 'macdonald_2023'

ddata <- base::readRDS('data/raw data/macdonald_2023/rdata.rds')

# melting species ----
ddata <- base::suppressWarnings(
   data.table::melt(
      data = ddata,
      id.vars = c('Site', 'Year_sampled','Q-2010','Q-1989','Q-1967'),
      variable.name = 'species', na.rm = TRUE)
)

data.table::setnames(x = ddata, c('Site','Q-1967','Year_sampled'), c('regional','local','year'))

# Standardising data ----
## in 1967, in the Athabasca site, 397 of the 400 quadrats were sampled so we kept only the same 397 quadrats in all sites and all years.
ddata <- ddata[ddata[regional == 'Athabasca' & year == 1967L, .(local = unique(local))], on = 'local']

# Community data ----
ddata[, ":="(
   dataset_id = dataset_id,

   metric = "abundance",
   unit = NA,

   `Q-1989` = NULL,
   `Q-2010` = NULL
)]

# metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
   taxon = "Plants",
   realm = "Terrestrial",

   effort = 1L,

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,
   sampling_years = NA,

   alpha_grain = 5L * 5L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "plot",
   alpha_grain_comment = "area of a 5m*5m plot",

   gamma_sum_grains = 5L * 5L * 397L,
   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "sum of the areas of all plots of all sites on a given year",
   gamma_bounding_box = 1L,
   gamma_bounding_box_unit = "ha",
   gamma_bounding_box_type = "plot",
   gamma_bounding_box_comment = "each region is a 1ha permanent plot split into 400 5*5m quadrats",

   comment = "Data were found in file Understory_data_raw_data.csv manually downloaded from the Borealis repository https://doi.org/10.5683/SP3/YAQCWD. The authors sampled trees and undestory vegetation from 1ha sites devided in 400 quadrats. Here we focus on understory vegetation only.",
   comment_standardisation = "cover of the following categories were excluded Dead_trees, Fine_DWD, Lich, Mineral, Trail, Pine_cones. in 1967, In the Athabasca site, 397 of the 400 quadrats were sampled so we kept only the same 397 quadrats in all sites, all years",
   doi = 'https://doi.org/10.5683/SP3/YAQCWD'
)]

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
