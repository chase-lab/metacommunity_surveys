dataset_id <-  "tanner_2022"
ddata <- base::readRDS(file = "data/raw data/tanner_2022/rdata.rds")

#Raw Data ----
data.table::setnames(ddata, c("local", "year", "species"))

## Community data ----
ddata[, ":="(
   dataset_id = dataset_id,
   regional = "North Crest, Heron Island",
   
   metric = "pa",
   unit = "pa",
   value = 1L
)]

## Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
   taxon = "Invertebrates",
   realm = "Marine",
   
   latitude = -23.43425,
   longitude = 151.92731,
   
   study_type = "ecological_sampling",
   data_pooled_by_authors = FALSE,
   
   alpha_grain = 1L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "quadrat",
   
   comment = "Extracted from figshare repository Tanner, Jason E.; Connell, Joseph H. (2022): Heron Island exposed (north) crest coral community data. figshare. Dataset. https://doi.org/10.6084/m9.figshare.21114061.v1 . Coral communities in fixed quadrats followed over years.",
   comment_standardisation = "none needed",
   doi = 'https://doi.org/10.6084/m9.figshare.21114061.v1'
)]
meta[local == "NCNR", ":="(latitude = -23.43453, longitude = 151.92436)]

##saving data tables ----
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

#standardised Data ----

##Metadata ----
meta[, ":="(
   effort = 1L,
   
   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of the sampled areas from all sites on a given year",
   
   gamma_bounding_box = pi * (326 / 2)^2,
   gamma_bounding_box_unit = "m2",
   gamma_bounding_box_type = "box",
   gamma_bounding_box_comment = "area of circle covering all quadrats"
   
)][, gamma_sum_grains := sum(alpha_grain), by = year]

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
