dataset_id <-  "tanner_2022"
ddata <- base::readRDS(file = "data/raw data/tanner_2022/rdata.rds")
data.table::setnames(ddata, c("local","year","species"))

# Community data ----
ddata[, ":="(
   dataset_id = dataset_id,
   regional = "North Crest, Heron Island",

   metric = "pa",
   unit = "pa",
   value = 1L
)]

# Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
   taxon = "Invertebrates",
   realm = "Marine",

   effort = 1L,

   latitude = -23.43425,
   longitude = 151.92731,

   study_type = "ecological_sampling",
   data_pooled_by_authors = FALSE,

   alpha_grain = 1L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "quadrat",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of the sampled areas from all lakes on a given year",

   gamma_bounding_box = pi * (326 / 2)^2,
   gamma_bounding_box_unit = "m2",
   gamma_bounding_box_type = "box",
   gamma_bounding_box_comment = "area of circle covering all quadrats",

   comment = "Extracted from figshare repository - Aquatic snail and macrophyte abundance and richness data for ten lakes in Vilas County, WI, USA, 1987-2020 - https://doi.org/10.6073/pasta/29733b5269efe990c3d2d916453fe4dd and associated article . Authors sampled snails from the bottom substrate using different samplers following the lakes invasion by a crayfish. Sampling happened in 1987, 2002, 2011 and 2020. Ideally alpha_grain would be the size of the lakes but that information was not found.",
   comment_standardisation = "none needed"
)][, gamma_sum_grains := sum(alpha_grain), by = year]
meta[local == "NCNR", ":="(latitude = -23.43453, longitude = 151.92436)]


dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)

data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)

