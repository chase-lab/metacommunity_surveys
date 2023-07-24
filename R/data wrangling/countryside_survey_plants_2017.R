# countryside_survey_plants
dataset_id <- "countryside_survey_plants_2017"

#Raw Data ----
ddata <- data.table::rbindlist(list(
  `1978` = data.table::fread(file = "./data/raw data/countryside_survey_plants_2017/67bbfabb-d981-4ced-b7e7-225205de9c96/data/Vegetation Plot - Species List 1978.csv"),
  `1990` = data.table::fread(file = "./data/raw data/countryside_survey_plants_2017/26e79792-5ffc-4116-9ac7-72193dd7f191/data/Vegetation Plot - Species List 1990.csv"),
  `1998` = data.table::fread(file = "./data/raw data/countryside_survey_plants_2017/07896bb2-7078-468c-b56d-fb8b41d47065/data/Vegetation Plot - Species List 1998.csv"),
  `2007` = data.table::fread(file = "./data/raw data/countryside_survey_plants_2017/57f97915-8ff1-473b-8c77-2564cbd747bc/data/Vegetation Plot - Species List 2007.csv")
),
fill = TRUE, use.names = TRUE, idcol = FALSE
)
data.table::setnames(ddata, c("YEAR", "SQUARE_ID", "BRC_NAMES"), c("year", "local", "species"))

env <- data.table::rbindlist(list(
  `1978` = data.table::fread(file = "./data/raw data/countryside_survey_plants_2017/67bbfabb-d981-4ced-b7e7-225205de9c96/data/Vegetation Plot - Plot Information 1978.csv"),
  `1990` = data.table::fread(file = "./data/raw data/countryside_survey_plants_2017/26e79792-5ffc-4116-9ac7-72193dd7f191/data/Vegetation Plot - Plot Information 1990.csv"),
  `1998` = data.table::fread(file = "./data/raw data/countryside_survey_plants_2017/07896bb2-7078-468c-b56d-fb8b41d47065/data/Vegetation Plot - Plot Information 1998.csv"),
  `2007` = data.table::fread(file = "./data/raw data/countryside_survey_plants_2017/57f97915-8ff1-473b-8c77-2564cbd747bc/data/Vegetation Plot - Plot Information 2007.csv")
),
fill = TRUE, use.names = TRUE, idcol = FALSE
)
data.table::setnames(env, "SQUARE_ID", "local")


##Cleaning species names ----
ddata <- ddata[!species %in% c("Bare ground/litter/water/rock/mud", "Gaps", "Gaps (filled)", "Rock")]

##community data ----
ddata[, ":="(
  dataset_id = dataset_id,
  regional = stringi::stri_extract_first_regex(
    str = env$EZ_DESC_07[match(local, env$local)],
    pattern = "(?<=\\().*(?=\\))"
  ),
  
  metric = "coverage",
  unit = "percent",
  value = TOTAL_COVER
)]

##Meta data ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])

meta[, ":="(
  taxon = "Plants",
  realm = "Terrestrial",
  
  study_type = "resurvey",
  
  data_pooled_by_authors = FALSE,
  
  latitude = c(52.3, 53, 57)[match(regional, c("Wales", "England", "Scotland"))],
  longitude = c(-3.6, -1, -4)[match(regional, c("Wales", "England", "Scotland"))],
  
  alpha_grain = 1L,
  alpha_grain_unit = "km2",
  alpha_grain_type = "plot",
  
  comment = "Extracted from 4 published Environmental Information Data Centre data sets, DOIs  https://doi.org/10.5285/67bbfabb-d981-4ced-b7e7-225205de9c96, https://doi.org/10.5285/26e79792-5ffc-4116-9ac7-72193dd7f191, https://doi.org/10.5285/07896bb2-7078-468c-b56d-fb8b41d47065, https://doi.org/10.5285/57f97915-8ff1-473b-8c77-2564cbd747bc . Authors sampled plants in plots located inside 1km2 grid cells in England, Scotland and Wales. ",
  comment_standardisation = "None needed",
  doi = 'https://doi.org/10.5194/essd-9-445-2017'
)]

##save data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
                   row.names = FALSE
)

#Standardized Data ----

data.table::setkey(ddata, local, year)
## Selecting sites and years with at least 9 plots ----
ddata <- ddata[ddata[, .(nsite = length(unique(PLOT_ID))), by = .(year, local)][nsite >= 9L], on = .(local, year)] # data.table style join
## Randomly selecting 9 plots among the available plots
set.seed(42L)
ddata <- ddata[ddata[, .(PLOT_ID = unique(PLOT_ID)[sample(1:length(unique(PLOT_ID)), 9L)]), by = .(local, year)], on = .(year, local, PLOT_ID)] # data.table style join
## Pooling plots within squares ----
ddata[, effort := length(unique(PLOT_ID)), by = .(local, year)]
ddata <- unique(ddata[, .(local, year, effort, species)])

##Cleaning species names----
ddata <- ddata[!species %in% c("Algae", "Bare ground/litter/water/rock/mud", "Gaps", "Gaps (filled)", "Rock", "Total bryophyte", "Total lichen")]

##community data ----
ddata[,":="(
  metric = "pa",
  count = "pa"
)]

##meta data ----
meta <- meta[unique(ddata[, .(dataset_id, local, regional, year, effort)]),
             on = .(local, regional, year)]
meta[,":="(
  gamma_sum_grains_unit = "km2",
  gamma_sum_grains_type = "plot",
  gamma_sum_grains_comment = "sum of the plots per year per region",
  
  gamma_bounding_box = c(20779L, 130279L, 77933L)[match(regional, c("Wales", "England", "Scotland"))],
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "administrative",
  gamma_bounding_box_comment = "ecological zone area is unknown so gamma has been set to the country",
  
  comment_standardisation = "sample based rarefaction: To standardise effort through time and space, we selected sites/years where at least 9 plots were sampled and when more than 9 plots were sampled, 9 were randomly selected among them. Then these 9 plots were pooled together and cover was turned into presence absence."
)][, gamma_sum_grains := length(unique(local)), by = .(regional, year)]

ddata[, effort := NULL]

##save data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
  x = ddata,
  file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized.csv"),
  row.names = FALSE
)
data.table::fwrite(
  x = meta,
  file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized_metadata.csv"),
  row.names = FALSE
)
