dataset_id <- "mendieta-leiva_2021"

ddata <- readRDS("data/raw data/mendieta-leiva_2021/rdata.rds")
ddata[, ":="(
   .id = c(2000L, 2012L)[match(.id, c(1, 2))],
   V1 = NULL,
   tsppc = NULL
)]

# Raw data ----
## community data ----

data.table::setnames(ddata, c("year", "local", "species", "value", "alpha_grain"))


ddata[, ":="(
   dataset_id = dataset_id,
   regional = "San Lorenzo crane plot",

   metric = "abundance",
   unit = "count"
)]

## meta data ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, alpha_grain)])
meta[, ":="(
   taxon = "Plants",
   realm = "Terrestrial",

   latitude = 9.2815,
   longitude = -79.974,

   study_type = "resurvey",

   data_pooled_by_authors = FALSE,
   sampling_years = c("1998-2000", "2010-2012")[match(year, c(2000L, 2012L))],

   alpha_grain_unit = "m2",
   alpha_grain_type = "functional",
   alpha_grain_comment = "1 tree on which epiphytes were observed. Grain = average crown area from the literature",

   comment = "Extracted from Zenodo repository from mendieta-leiva_2021. They sampled epiphytes on 200+ trees of the San Lorenzo crane plot in 1998-2000 and again in 2010-2012. Trees are considered local scale and the regional scale is the San Lorenzo crane plot which is a 140*140m plot inside the San Lorenzo National Park, Panama. Average crown area/ alpha grain was computed from Martinez Cano, Isabel et al. (2019), Data from: Tropical tree height and crown allometries for the Barro Colorado Nature Monument, Panama: a comparison of alternative hierarchical models incorporating interspecific variation in relation to life history traits, Dryad, Dataset, https://doi.org/10.5061/dryad.85k53v8",
   comment_standardisation = "none needed",
   doi = 'https://doi.org/10.5281/zenodo.5645774 | https://doi.org/10.1111/1365-2745.13817'
)]

ddata[, alpha_grain := NULL]

## save raw data ----

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
## Selecting only tree communities that were sampled twice using a data.table joint
ddata <- ddata[ ddata[, .(selec = length(unique(year)) == 2L), by = local][(selec), .(local)], on = "local"]

## Meta data ----

meta <- meta[unique(ddata[, .(local, year)]),
             on = .(local, year)]

meta[, ":="(
   effort = 1L,

   gamma_bounding_box = 140L * 140L,
   gamma_bounding_box_unit = "m2",
   gamma_bounding_box_type = "administrative",
   gamma_bounding_box_comment = "area of the San Lorenzo crane plot",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "functional",
   gamma_sum_grains_comment = "sum of the sampled areas of 13 pools",

   comment_standardisation = "we kept only trees that were sampled twice"
)
][,
  gamma_sum_grains := sum(alpha_grain), by = year
]


## save standardised data ----
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

