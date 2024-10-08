dataset_id <- 'macdonald_2023_understory'

ddata <- base::readRDS('data/raw data/macdonald_2023_understory/rdata.rds')

# Data preparation ----
## Spatial data ----
coords <- data.frame(matrix(ncol = 3, byrow = TRUE, data = c(
   'Athabasca',   -117.9696549,  52.75510395,
   'Hector',      -116.2567177,  51.50370852,
   'Spray River', -115.39626631, 50.90481182,
   'Sunwapta',    -117.70472626, 52.5624097,
   'Whirlpool',   -117.92613834, 52.71421711),
   dimnames = list(c(), c('regional', 'longitude', 'latitude'))
))

## melting species ----
ddata <- base::suppressWarnings(
   data.table::melt(
      data = ddata,
      id.vars = c('Site', 'Year_sampled', 'Q-2010', 'Q-1989', 'Q-1967'),
      variable.name = 'species', na.rm = TRUE)
)

data.table::setnames(x = ddata,
                     old = c('Site','Q-1967','Year_sampled'),
                     new = c('regional','local','year'))

# Raw data ----
## Community data ----
ddata[, ":="(
   dataset_id = dataset_id,

   metric = "cover",
   unit = 'percent',

   `Q-1989` = NULL,
   `Q-2010` = NULL
)]

## metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[coords,
     ":="(latitude = i.latitude, longitude = i.longitude),
     on = 'regional']

meta[, ":="(
   taxon = "Plants",
   realm = "Terrestrial",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = 5L * 5L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "quadrat",
   alpha_grain_comment = "area of a 5m*5m plot",

   comment = "Data were found in file Understory_data_raw_data.csv manually downloaded from the Borealis repository https://doi.org/10.5683/SP3/YAQCWD. The authors sampled trees and undestory vegetation from 1ha sites devided in 400 quadrats. Here we focus on understory vegetation only. Site coordinates given in 1b_ReadMe_Summary.txt",
   comment_standardisation = "Cover of the following categories were excluded Dead_trees, Fine_DWD, Lich, Mineral, Trail, Pine_cones.",
   doi = 'https://doi.org/10.5683/SP3/YAQCWD'
)]


## Saving raw data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)


# Standardised data ----
## Community data ----
ddata[, ":="(
   value = 1L,
   metric = "pa",
   unit = 'pa'
)]
## Metadata ----
meta[, ":="(
   effort = 1L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "quadrat",
   gamma_sum_grains_comment = "sum of the areas of all plots of all sites on a given year",

   gamma_bounding_box = 1L,
   gamma_bounding_box_unit = "ha",
   gamma_bounding_box_type = "ecosystem",
   gamma_bounding_box_comment = "each region is a 1ha permanent plot split into 400 5*5m quadrats",
   comment_standardisation = "percent cover provided by the authors turned into presence absence. Cover of the following categories were excluded Dead_trees, Fine_DWD, Lich, Mineral, Trail, Pine_cones."
)][, gamma_sum_grains := sum(alpha_grain), by = .(regional, year)]

## Saving standardised data ----
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised_metadata.csv"),
   row.names = FALSE
)
