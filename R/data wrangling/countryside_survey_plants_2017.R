# countryside_survey_plants
dataset_id <- "countryside_survey_plants_2017"

ddata <- base::readRDS("data/raw data/countryside_survey_plants_2017/rdata.rds")

#Raw Data ----
## Cleaning species names ----
ddata <- ddata[
   !species %in% c("Bare ground/litter/water/rock/mud", "Gaps", "Gaps (filled)", "Rock", "Unknown species") &
      !is.na(value) &
      !is.na(AMALG_PTYPE)]

## community data ----
ddata[, ":="(
   dataset_id = factor(paste(dataset_id,
                             c('200', '4', '4', '100', '100', '100', '100', '100', '100')[match(
                                AMALG_PTYPE, c('X', 'Y', 'U', 'H', 'RV', 'SW', 'B', 'D', 'M'))],
                             "sqm", sep = "_")),

   local = factor(paste(local, PLOT_ID, sep = "_")),

   metric = factor("cover"),
   unit = factor("percent")
)]
# ddata <- unique(ddata)
# ddata[, .N, by = .(dataset_id, regional, local, year, species)][N != 1]

## Excluding records from sites/years where duplicates were found.
ddata <- ddata[
   !ddata[, .N, by = .(dataset_id, regional, local, PLOT_ID, year, species)][N != 1L],
   on = .(dataset_id, regional, local, PLOT_ID, year)]

##Meta data ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, AMALG_PTYPE)])

meta[, ":="(
   taxon = "Plants",
   realm = "Terrestrial",

   study_type = "resurvey",

   data_pooled_by_authors = FALSE,

   latitude = c(52.3, 53, 57)[match(regional, c("Wales", "England", "Scotland"))],
   longitude = c(-3.6, -1, -4)[match(regional, c("Wales", "England", "Scotland"))],

   alpha_grain = c(200L, 4L, 4L, 100L, 100L, 100L, 100L, 100L, 100L)[match(
      AMALG_PTYPE, c('X', 'Y', 'U', 'H', 'RV', 'SW', 'B', 'D', 'M'))],
   alpha_grain_unit = "m2",
   alpha_grain_type = "plot",

   comment = factor("Extracted from 4 published Environmental Information Data Centre data sets, DOIs  https://doi.org/10.5285/67bbfabb-d981-4ced-b7e7-225205de9c96, https://doi.org/10.5285/26e79792-5ffc-4116-9ac7-72193dd7f191, https://doi.org/10.5285/07896bb2-7078-468c-b56d-fb8b41d47065, https://doi.org/10.5285/57f97915-8ff1-473b-8c77-2564cbd747bc . Authors sampled plants in plots located inside 1km2 grid cells in England, Scotland and Wales. "),
   comment_standardisation = factor('Groups  "Bare ground/litter/water/rock/mud", "Gaps", "Gaps (filled)", "Rock", and "Unknown species" were excluded.
There were redundant data: some species have several observations per site per year and cover can be higher than 100% indicating pooling in raw data.
Samples with redundant observations were removed.
dataset_id is built as countryside_survey_plants_2017_{quadrat area}_sqm.
regional is the country
local name is built as SQUARE_ID _ PLOT_ID _ AMALG_PTYPE.'),
   doi = factor('https://doi.org/10.5194/essd-9-445-2017'),
   AMALG_PTYPE = NULL
)]

ddata[, AMALG_PTYPE := NULL]

## Saving raw data ----
data.table::setkey(ddata, dataset_id)
data.table::setkey(meta, dataset_id)

for (dataset_id_i in unique(meta$dataset_id)) {
   dir.create(paste0("data/wrangled data/", dataset_id_i), showWarnings = FALSE)
   data.table::fwrite(
      x = ddata[dataset_id_i, !"PLOT_ID"],
      file = paste0("data/wrangled data/", dataset_id_i, "/", dataset_id_i, "_raw.csv"),
      row.names = FALSE, sep = ",", encoding = "UTF-8"
   )
   data.table::fwrite(
      x = meta[dataset_id_i],
      file = paste0("data/wrangled data/", dataset_id_i, "/", dataset_id_i, "_raw_metadata.csv"),
      row.names = FALSE, sep = ",", encoding = "UTF-8"
   )
}


# Standardised Data ----
ddata[, local := stringi::stri_extract_first_regex(local, "[A-Z]*(?=_)")]
data.table::setkey(ddata, dataset_id, regional, local, PLOT_ID, year)

## Selecting sites and years with at least 9 plots ----
ddata <- ddata[
   ddata[,
         .(nsite = data.table::uniqueN(PLOT_ID)),
         by = .(dataset_id, year, regional, local)][nsite >= 9L],
   on = .(dataset_id, year, regional, local)] # data.table style join

## Randomly selecting 9 plots among the available plots
set.seed(42L)
ddata <- ddata[
   ddata[,
         .(PLOT_ID = sample(unique(PLOT_ID), 9L)),
         by = .(dataset_id, year, regional, local)],
   on = .(dataset_id, year, regional, local, PLOT_ID)] # data.table style join

## Pooling plots within squares ----
# effort has to be constant 9L
# ddata[, effort := data.table::uniqueN(PLOT_ID), by = .(dataset_id, regional, local, year)]
ddata <- unique(ddata[, .(dataset_id, regional, local, year, species)])

## Cleaning species names----
ddata <- ddata[!species %in% c("Algae", "Total bryophyte", "Total lichen")]

## Community data ----
ddata[,":="(
   value = 1L,

   metric = "pa",
   unit = "pa"
)]

## Meta data ----
meta[, local := stringi::stri_extract_first_regex(local, "[A-Z]*(?=_)")]

meta <- unique(meta[unique(ddata[, .(dataset_id, regional, local, year)]),
             on = .(dataset_id, regional, local, year)])
meta[,":="(
   effort = 9L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "sum of the plots per year per region",

   gamma_bounding_box = c(20779L, 130279L, 77933L)[match(regional, c("Wales", "England", "Scotland"))],
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "administrative",
   gamma_bounding_box_comment = "ecological zone area is unknown so gamma has been set to the country",

   comment_standardisation = 'There were redundant data: some species have several observations per site per year and cover can be higher than 100% indicating pooling in raw data.
Samples with redundant observations were removed.
sample based rarefaction: To standardise effort through time and space, we selected sites/years where at least 9 plots were sampled and when more than 9 plots were sampled, 9 were randomly selected among them.
Then these 9 plots were pooled together and cover was turned into presence absence.
Groups  "Bare ground/litter/water/rock/mud", "Gaps", "Gaps (filled)", "Rock" and "Algae", "Total bryophyte", "Total lichen" were excluded.
dataset_id is built as countryside_survey_plants_2017_{quadrat area}_sqm.
regional is the country
local name is SQUARE_ID.'
)][, gamma_sum_grains := sum(alpha_grain), by = .(regional, year)]

## Saving standardised data ----
data.table::setkey(ddata, dataset_id)
data.table::setkey(meta, dataset_id)
dataset_ids <- unique(meta$dataset_id)

for (dataset_id in dataset_ids) {
   data.table::fwrite(
      x = ddata[dataset_id],
      file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised.csv"),
      row.names = FALSE, sep = ",", encoding = "UTF-8"
   )
   data.table::fwrite(
      x = meta[dataset_id],
      file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised_metadata.csv"),
      row.names = FALSE, sep = ",", encoding = "UTF-8"
   )
}
