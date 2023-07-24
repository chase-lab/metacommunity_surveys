dataset_id <- "swenson_2020"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))

#Raw Data ----

##melting species ----
ddata <- data.table::melt(ddata,
                          id.vars = c("local", "period"),
                          variable.name = "species",
                          na.rm = TRUE
)

##exclude absences ----
ddata <- ddata[value != 0]

##community data
ddata[, ":="(
  dataset_id = dataset_id,
  regional = "SEFDP",
  
  year = c(1976L, 1996L, 2007L)[match(period, 1:3)],
  
  metric = "abundance",
  unit = "count",
  period = NULL
)]

##meta data ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  taxon = "Plants",
  realm = "Terrestrial",
  
  latitude = 10.8394,
  longitude = -85.61862,
  
  study_type = "resurvey",
  
  data_pooled_by_authors = TRUE,
  data_pooled_by_authors_comment = "one sampling per site per sampling period",
  sampling_years = c("1976", "1996", "2006-2007")[match(year, c(1976L, 1996L, 2007L))],
  
  alpha_grain = 20L * 20L,
  alpha_grain_unit = "m2",
  alpha_grain_type = "sample",
  alpha_grain_comment = "386 plots on a matrix",
  
  comment = "Extracted from Swenson et al 2020 Dryad repository (https://doi.org/10.5061/dryad.h44j0zpg3). 'The SEFDP was originally censused in 1976 by George Stevens and Stephen Hubbell, where all woody stems greater than or equal to 3 cm diameter at 1.3 m off the ground including lianas had their diameter measured and their spatial location in the plot recorded'. A second and a third surveys were made in 1996 and 2006-2007. Regional is the SEFDP, local is a 20*20 square meter plot where all trees > 3cm diameter DBH were sampled. Coordinates are approximative: research centre in the Santa Rosa Sector of the Santa Rosa National Park.",
  comment_standardisation = "none needed",
  doi = 'https://doi.org/10.5061/dryad.h44j0zpg3'
)]

##save data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
  x = ddata[, !c("taxon")],
  file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
  row.names = FALSE
)
data.table::fwrite(
  x = meta,
  file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
  row.names = FALSE
)

#Standardized Data ----
##meta data ----
meta <- meta[unique(ddata[, .(dataset_id, local, regional, year)]),
             on = .(local, regional, year)]

meta[,":="(
  effort = 1L,
  
  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "plot",
  gamma_sum_grains_comment = "sum of the area of the sampled plots per year",
  
  gamma_bounding_box = 240L * 680L,
  gamma_bounding_box_unit = "m2",
  gamma_bounding_box_type = "ecosystem",
  gamma_bounding_box_comment = "area of the SEFDP"
)][, gamma_sum_grains := alpha_grain * length(unique(local)), by = year]


##save data ----
data.table::fwrite(
  x = ddata[, !c("taxon")],
  file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized.csv"),
  row.names = FALSE
)
data.table::fwrite(
  x = meta,
  file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized_metadata.csv"), 
  row.names = FALSE
)
