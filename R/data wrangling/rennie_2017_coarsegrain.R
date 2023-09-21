dataset_id <- 'rennie_2017_coarsegrain'

ddata <- base::readRDS(file = "data/raw data/rennie_2017_coarsegrain/rdata.rds")
data.table::setnames(ddata, c('regional','year','plot','local','species'))

# Standardisation ----
ddata <- ddata[species != 'Litter']
ddata <- ddata[
   ddata[, diff(range(year)) >= 9L, by = .(regional, local)][(V1)][, V1 := NULL],
   on = .(regional, local)]

# Raw data ----
## Community data ----
ddata[, ':='(
   dataset_id = dataset_id,

   local = as.factor(paste(plot, local, sep = '_')),

   value = 1L,
   metric = 'pa',
   unit = 'pa'
)]

# Coordinates ----
coords <- data.table::as.data.table(matrix(
   dimnames = list(c(), c("regional", "regional_name", "latitude", "longitude")),
   byrow = TRUE, ncol = 4L, data = c(
      "T01", "Drayton", "52°11`37.95'N","1°45`51.95'W",
      "T02", "Glensaugh", "56°54`33.36'N", "2°33`12.14'W",
      "T03", "Hillsborough", "54°27`12.24'N", "6° 4`41.26'W",
      "T04", "Moor House – Upper Teesdale", "54°41`42.15'N", "2°23`16.26'W",
      "T05", "North Wyke", "50°46`54.96'N", "3°55`4.10'W",
      "T06", "Rothamsted", "51°48`12.33'N", "0°22`21.66'W",
      "T07", "Sourhope", "55°29`23.47'N", "2°12`43.32'W",
      "T08", "Wytham", "51°46`52.86'N", "1°20`9.81'W",
      "T09", "Alice Holt", "51° 9`16.46'N", "0°51`47.58'W",
      "T10", "Porton Down", "51° 7`37.83'N", "1°38`23.46'W",
      "T11", "Y Wyddfa – Snowdon", "53° 4`28.38'N", "4° 2`0.64'W",
      "T12", "Cairngorms", "57° 6`58.84'N", "3°49`46.98'W")
))

# Metadata data ----
meta <- unique(ddata[, .(dataset_id, regional, plot, local, year)])
meta[coords,
     ":="(latitude = i.latitude, longitude = i.longitude),
     on = 'regional']

meta[, ":="(
   taxon = "Plants",
   realm = "Terrestrial",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = 40L * 40L,
   alpha_grain_unit = "cm2",
   alpha_grain_type = "quadrat",
   alpha_grain_comment = "area of a cell",

   comment = "Data were downloaded from https://doi.org/10.5285/d349babc-329a-4d6e-9eca-92e630e1be3f. Authors measured plant species presence in 12 sites, each sampled 50 2*2m plots, each sampled in at least 2 40*40cm cells. The local scale is the cell and its name is constituted as plot_cell. Site coordinates were extracted from VC_DATA_STRUCTURE.rtf found in the Supporting documentation.",
   comment_standardisation = "Records for `Litter` were removed.",
   doi = 'https://doi.org/10.5285/d349babc-329a-4d6e-9eca-92e630e1be3f'
)]

## Saving raw data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata[value != 0L, !"plot"],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta[unique(ddata[value != 0L, .(regional, local, year)]), on = .(regional, local, year), !"plot"],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)

# Standardised data ----
## Keeping only sites sampled at least twice 10 years apart ----
ddata <- ddata[
   !ddata[, diff(range(year)), by = .(regional, local)][(V1 < 9L)],
   on = .(regional, local)
]


## Metadata ----
meta <- meta[
   unique(ddata[, .(regional, local, year)]),
   on = .(regional, local, year)]

meta[, ":="(
   effort = 1L,

   gamma_sum_grains_unit = "cm2",
   gamma_sum_grains_type = "quadrat",
   gamma_sum_grains_comment = "sum of the areas of all cells of a site on a given year",

   gamma_bounding_box_unit = "m2",
   gamma_bounding_box_type = "ecosystem",
   gamma_bounding_box_comment = "sum of the area of the plot of a site on a given year",

   comment_standardisation = "Records for `Litter` were removed. Cells/local samples that were not sampled at least 10 years appart were removed."
)][, ":="(
   gamma_sum_grains = sum(alpha_grain),
   gamma_bounding_box = data.table::uniqueN(plot) * 2L * 2L),
   by = .(regional, year)]

## Saving standardised data ----
data.table::fwrite(
   x = ddata[, !"plot"],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta[, !"plot"],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised_metadata.csv"),
   row.names = FALSE
)
