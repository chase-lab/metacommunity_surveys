# Kolasa_2022
dataset_id <- 'kolasa_2022'

ddata <- base::readRDS(file = 'data/raw data/kolasa_2022/rdata.rds')
data.table::setnames(x = ddata,
                     old = c('pool_id', 'latin_name', 'otu_absolute_abundance'),
                     new = c('local', 'species', 'value'))

# Standardised data ----
## Communities ----
ddata[, ':='(
   dataset_id = dataset_id,

   regional = 'Discovery Bay, Jamaica',

   species = paste(species, otu_id),

   metric = 'abundance',
   unit = 'count',

   otu_id = NULL
)]

## Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, month)])

meta[, ':='(
   taxon = "Invertebrates",
   realm = "Marine",

   effort = 1L,

   longitude = mean(-77.415652, -77.415198),
   latitude = mean(18.469648, 18.468932),

   study_type = "ecological_sampling",
   data_pooled_by_authors = FALSE,

   alpha_grain = pi * (47 / 2)^2,
   alpha_grain_unit = "cm2",
   alpha_grain_type = "lake_pond",
   alpha_grain_comment = "mean area of the pools, mean diameter given by the authors",

   comment = 'Data extracted from:  Schenk, Siobhan, Lavender, Thomas Michael, and Kolasa, Jurek. 2023. "Long-Term Supratidal Rockpool Invertebrate Community, Discovery Bay, Jamaica." Ecology e4013. https://doi.org/10.1002/ecy.4013 . METHOD: "A sample of rockpool invertebrates is a collection of individuals of all species extracted from 500 mL of homogenized rockpool contents" Macro- and microinvertebrates were then counted in the lab.',
   comment_standardisation = 'Redundant rows were deleted.',
   doi = 'https://doi.org/10.1002/ecy.4013 | https://doi.org/10.5683/SP3/FNAU9L | https://esajournals.onlinelibrary.wiley.com/doi/full/10.1002/ecs2.3078'
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
## Selecting data ----
ddata <- ddata[
   ddata[month != 6L][, .(keep = length(unique(month)) == 1L, month = unique(month)), by = .(local, year)][(keep) | month == 1L][, keep := NULL],
   on = .(year, month, local)
][, month := NULL]

## Metadata ----
meta <- meta[unique(ddata[, .(local, year)]),
             on = .(local, year)]

meta[, ":="(

   effort = 1L,

   gamma_sum_grains_unit = "cm2",
   gamma_sum_grains_type = "lake_pond",
   gamma_sum_grains_comment = "sum of the sampled areas from all pools on a given year",

   gamma_bounding_box = 73L * 47L,
   gamma_bounding_box_unit = "m2",
   gamma_bounding_box_type = "box",
   gamma_bounding_box_comment = "box encompassing all pools, given by the authors",

   comment_standardisation = 'Redundant rows were deleted. June samples were excluded. When a pool was sampled twice during a year (January and December), only January was kept.',
   month = NULL
)][, gamma_sum_grains := sum(alpha_grain), by = year]

## Saving standardised data ----
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised.csv"),
   row.names = FALSE
)

data.table::fwrite(
   x = unique(meta),
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised_metadata.csv"),
   row.names = FALSE
)
