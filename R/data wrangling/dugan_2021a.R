# dugan_2021a birds
dataset_id <- "dugan_2021a"

ddata <- base::readRDS("./data/raw data/dugan_2021/rdata.rds")

#Raw Data ----

data.table::setnames(ddata, c("MONTH", "YEAR", "SITE", "TOTAL"), c("month", "year", "local", "value"))

##delete absences for removing unneccessary duplicates ---- 
ddata <- ddata[value != 0,]

## community data ----
ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Santa Barbara Coastal LTER",
  
  species = paste(TAXON_GENUS, TAXON_SPECIES),
  
  metric = "abundance",
  unit = "count",
  TAXON_FAMILY = NULL, 
  TAXON_GENUS = NULL,
  TAXON_GROUP = NULL,
  TAXON_KINGDOM = NULL,
  TAXON_PHYLUM = NULL,
  TAXON_SPECIES = NULL,
  TAXON_ORDER = NULL,
  SURVEY = NULL,
  COMMON_NAME = NULL
)]

## metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])

meta[, ":="(
  realm = "Terrestrial",
  taxon = "Birds",
  
  study_type = "ecological_sampling",
  
  data_pooled_by_authors = FALSE,
  
  latitude = c(34.40305, mean(34.39452, 34.391151), 34.40928, 34.470467, 34.410767, 34.408533)[match(local, c("ABB", "CSB-CCB", "IVWB", "AQB", "EUCB", "SCLB"))],
  longitude = c(-119.74375, mean(-119.52699, -119.521236), -119.87385, -120.118617, -119.842017, -119.551583)[match(local, c("ABB", "CSB-CCB", "IVWB", "AQB", "EUCB", "SCLB"))],
  
  alpha_grain = 100000L,
  alpha_grain_unit = "m2",
  alpha_grain_type = "transect",
  alpha_grain_comment = "1000m long transect along the beach estimated to be 100m wide",
  
  comment = "Extracted from EDI repository knb-lter-sbc.51.10 https://pasta.lternet.edu/package/eml/knb-lter-sbc/51/10 . Authors counted birds, marine mammals, dogs and humans on 1km transects of 6 coastal sites of the Santa Barbara Coastal LTER. Only birds were included in this data set. Coordinates are from the Santa Barbara Coastal LTER website https://sbclter.msi.ucsb.edu/data/catalog/package/?package=knb-lter-sbc.51"
)]


##save data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata[,!c("TAXON_CLASS", "DATE")], paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
                   row.names = FALSE
)

#Standardized Data ----
ddata <- ddata[TAXON_CLASS == "Aves"][ddata[, .(nmonth = length(unique(month)), nweek = length(unique(DATE))), by = .(local, year)][nmonth == 12L & nweek == 12L], on = .(local, year)]

##community data ----
ddata[,":="(
  value = 1L,
  metric = "pa",
  unit = "pa"
)]

##meta data ----
meta[,":="(
  effort = 12L,
  
  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "plot",
  gamma_sum_grains_comment = "number of sites per year * 1200m2",
  
  gamma_bounding_box = 6L,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "functional",
  gamma_bounding_box_comment = "60km long coastline between the most distant sites (measured on Google Earth) * 100m wide beach (estimated)",
  
  comment_standardisation = "Only sites actually sampled 12 times every year were included"
)][, gamma_sum_grains := length(unique(local)) * 10000L, by = year]

##save data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized_metadata.csv"),
                   row.names = FALSE
)

