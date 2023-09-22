dataset_id <- "vojik_2018"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))
data.table::setnames(ddata, 1, "section")

#Raw Data ----
##melting, splitting and melting period and site ----
ddata <- data.table::melt(ddata,
                          id.vars = c("section", "species", "layer")
)
ddata[, c("period", "site") := data.table::tstrsplit(variable, " ")]

## Excluding absences ----
ddata <- ddata[!(is.na(value) | value == ".")]

##community data ----
ddata[, ":="(
   dataset_id = dataset_id,

   regional = "Klinec forest",
   local = paste0("s", site, "_", layer),

   year = c(1957L, 2015L, 2015L)[data.table::chmatch(period, c("historical", "modern", "modern\n"))],

   metric = "Braun-Blanquet scale",
   unit = "score",

   section = NULL,
   layer = NULL,
   period = NULL,
   variable = NULL
)]

##meta data ----

meta <- unique(ddata[, .(dataset_id, regional, site, local, year)])
meta[, ":="(
   realm = "Terrestrial",
   taxon = "Plants",

   latitude = "49.9008N",
   longitude = "14.3426E",

   study_type = "resurvey",

   data_pooled_by_authors = FALSE,

   alpha_grain = 500L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "sample",

   comment = "Extracted from supplementary material Table 1 in Vojik and Boublik 2018 (https://doi.org/10.1007/s11258-018-0831-5). Historical vegetation records of the Klinec forest, Czech Republic, were made in 1957. In 2015, M Vojik resampled the same 29 plots of 500m2 each using the same methodology.",
   comment_standardisation = "Local is here a description of site, tree level and section ",
   doi = 'https://doi.org/10.1007/s11258-018-0831-5'
)]

##saving data tables ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata[, !"site"],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)

data.table::fwrite(
   x = meta[, !"site"],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)

#Standaradized Data ----

## pooling values of different layers and turning cover into presence absence ----
ddata <- ddata[, .(species = unique(species), value = 1L),
               by = .(dataset_id, regional, local = site, year, metric, unit)]

##meta data ----
meta[, local := site][, site := NULL]
meta <- unique(meta)[unique(ddata[, .(local, year)]),
                     on = .(local, year)]

meta[, ":="(
   effort = 1L,

   gamma_sum_grains = 500L * 29L,
   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "29 plots of 500m2",

   gamma_bounding_box = 1000L,
   gamma_bounding_box_unit = "ha",
   gamma_bounding_box_type = "ecosystem",
   gamma_bounding_box_comment = "area provided by the authors",

   comment = "Extracted from supplementary material Table 1 in Vojik and Boublik 2018 (https://doi.org/10.1007/s11258-018-0831-5). Historical vegetation records of the Klinec forest, Czech Republic, were made in 1957. In 2015, M Vojik resampled the same 29 plots of 500m2 each using the same methodology.",
   comment_standardisation = "Braun-Blanquet ccover turned into rpesence absence
tree, shrub and herb layers pooled together"
)]

##saving data tables ----
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
