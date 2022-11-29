## myers-smith_2019

dataset_id <- "myers-smith_2019"
ddata <- base::readRDS(file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
data.table::setnames(ddata, c("regional", "latitude", "longitude", "year", "local", "species", "value"))

#Raw data ----

##communtiy data ----
ddata[, ":="(
  dataset_id = dataset_id,
  regional = c("Komakuk", "Herschel")[match(substr(regional, 5, 6), c("KO", "HE"))],

  metric = "count",
  unit = "frequency",
  
  species = trimws(species)
)]

##exclude unknown  species ----
ddata <- ddata[!grepl("XXX", species, ignore.case = TRUE)]

##meta data ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, latitude, longitude)])

meta[, ":="(
  taxon = "Plants",
  realm = "Terrestrial",
  
  study_type = "ecological_sampling",

  data_pooled_by_authors = FALSE,

  latitude = gsub(",", ".", latitude, fixed = TRUE),
  longitude = -as.numeric(gsub(",", ".", longitude, fixed = TRUE)),

  alpha_grain = 1L,
  alpha_grain_unit = "m2",
  alpha_grain_type = "plot",
  alpha_grain_comment = "ITEX grid plot with 100 points",

  comment = "Extracted from Zenodo repository Isla H. Myers-Smith. (2018). ShrubHub/QikiqtarukHub: QikiqtarukHub_v1.0 (v1.0). Zenodo. https://doi.org/10.5281/zenodo.2397996. Effort is standardised. Herschel and Komakuk vegetain type areas are considered distinct regions. Methods: 'Community composition was measured in two vegetation communities (Fig. 1): the Herschel vegetation type and the Komakuk vegetation type. Community composition was assessed using point-framing methods following the ITEX protocols (Molau and Mølgaard 1996). Twelve plots of 1m2 (six per vegetation type) were established in 1999 and resurveyed in 2004, 2009, and 2013–2017. A grid with 100 points at 10-cm spacing was placed over each plot at a height of approximately 50 cm. A metal pin was dropped vertically at each of the 100 grid points; all plant parts that touched the pin were recorded",
  comment_standardisation = "none"
)]

ddata[, c("longitude", "latitude") := NULL]


#Standardized data ----
##transform value to pa ----
ddata <- unique(ddata[, value := 1L])

ddata[, ":="(
  metric = "pa",
  unit = "pa"
)]
##meta data ----
meta[,":="(
  
  gamma_sum_grains = 6L,
  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "sample",
  gamma_sum_grains_comment = "sum of the areas of 6 quadrats",
  
  gamma_bounding_box = 2500L,
  gamma_bounding_box_unit = "m2",
  gamma_bounding_box_type = "functional",
  gamma_bounding_box_comment = "estimated area of the sampling zone",
  
  effort = 1L,
  
  comment_standardisation = "frequency values transformed to presence absence values"
)]

##save data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized_metadata.csv"),
                   row.names = FALSE
)

