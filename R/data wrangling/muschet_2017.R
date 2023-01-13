dataset_id <- "mushet_2017"

#Raw Data ----

##Extracting taxonomy from metadata ----
if (!file.exists("./data/raw data/muschet_2017/CLSAInvertebrateCounts_metadata_taxonomy.csv")) {
  tax <- XML::xmlToList("./data/raw data/muschet_2017/CLSAInvertebrateCounts_metadata.xml")
  
  codes <- unlist(sapply(tax$eainfo[[1]], function(element) element$attrlabl))
  lnames <- unlist(sapply(tax$eainfo[[1]], function(element) element$attrdef))
  lnames <- stringi::stri_extract_first_regex(str = lnames, pattern = "(?<=identified as? ).*(?= present)")
  
  write.table(
    x = na.omit(data.frame(codes = codes, long_names = lnames)),
    sep = ",", row.names = FALSE,
    file = "./data/raw data/muschet_2017/CLSAInvertebrateCounts_metadata_taxonomy.csv"
  )
}
tax <- read.table("./data/raw data/muschet_2017/CLSAInvertebrateCounts_metadata_taxonomy.csv", sep = ",", header = TRUE)


##Coordinates
coords <- read.csv("./data/raw data/muschet_2017/site locations.csv", skip = 1)
coords$Plot_name <- ifelse(nchar(coords$Plot_name) == 2, paste0(substr(coords$Plot_name, 1, 1), "0", substr(coords$Plot_name, 2, 2)), coords$Plot_name)

##Reading insect counts ----
ddata <- base::readRDS("./data/raw data/muschet_2017/rdata.rds")

##melting species ----
ddata <- data.table::melt(ddata,
                          id.vars = 1:5,
                          variable.name = "species",
                          na.rm = TRUE
)

##exclude empty values ----
ddata <- ddata[!value %in% c("0", "D", "")]


##community data ----
data.table::setnames(ddata, c("WETLAND","YEAR","MONTH"), c("local", "year", "month"))
ddata[, ":="(
  dataset_id = dataset_id,
  local = paste(local, sep="_", VEGZONE),
  regional = "Cottonwood Lake Study Area",
  
  species = tax$long_names[match(species, tax$codes)],
  
  metric = "abundance",
  unit = "count"
)]

##meta data ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  taxon = "Invertebrates",
  realm = "Freshwater",
  
  latitude = coords$Latitude[match(local, coords$Plot_name)],
  longitude = coords$Longitude[match(local, coords$Plot_name)],
  
  study_type = "ecological_sampling",
  
  data_pooled_by_authors = FALSE,
  
  alpha_grain = NA,
  alpha_grain_unit = NA,
  alpha_grain_type = "functional",
  alpha_grain_comment = "wetland area unknown",
  
  comment = "Extracted from Mushet, D.M., Euliss, N.H., Jr., and Solensky, M.J. 2017, Cottonwood Lake Study Area - Invertebrate Counts, U.S. Geological Survey data release, https://doi.org/10.5066/F7BK1B77. Authors provide data sampled in the Cottonwood Lake Study Area from 1992 to 2015. Methods: 'Aquatic macroinvertebrates were collected each month (April-September) from all wetlands at Cottonwood Lake Study Area containing water using vertically oriented funnel traps (Swanson 1978). Sampling was stratified to provide separate estimates of invertebrate biomass and abundance in all major vegetative zones of each wetland. Samples were collected at random locations along the 3 established transects in each wetland that were established earlier and used to collect other biotic and abiotic data (LaBaugh et al. 1987). The length of each vegetation zone as bisected by transects was measured and a computer-generated set of random numbers used to identify sample points for the collection of invertebrate samples in each vegetative zone. One sample was collected from each major vegetative zone from each transect. Data consist of counts by taxa.'  Taxonomic names were extracted from metadata file https://www.sciencebase.gov/catalog/item/get/599d9555e4b012c075b964a6",
  comment_standardisation = "empty values: 0 and NA were excluded"
)]

##save data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata[,!c("TRANSECT","VEGZONE")], paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
                   row.names = FALSE
)

#Standaridzed Data----

##selecting only months when all 3 transects were sampled ----
ddata[, full_sample_month := length(unique(TRANSECT)), by = .(local, year, month)]
ddata <- ddata[full_sample_month == 3L]
##selecting only wetlands/years where all 6 months were sampled ----
ddata[, nmonth := length(unique(month)), by = .(local, year)]
ddata <- ddata[nmonth == 6L]

# # selecting the first two months for each local//year
# seldata <- unique(ddata[, .(local, year, month)])
# seldata[, month_priority_order := c(2L, 1L, 3L, 4L)[match(month, c(5, 6, 7, 8))]]
# data.table::setorder(seldata, local, year, month_priority_order)
# seldata <- seldata[, .SD[1:2,], by = .(local, year)]
# # subsetting by using a data.table join
# ddata <- ddata[seldata, on = c('local','year','month')]
#
# ddata[, .N / sum(grepl("\\.", value)), by = .(year, local, TRANSECT, VEGZONE)]

## pooling all months, TRANSECTs and VEGZONEs together
ddata <- unique(ddata[, .(value = sum(as.numeric(value))), by = .(local, year, species)])

##exclude dry pond samples: value == D ----
ddata <- ddata[!value %in% c("D")]

##meta data ----

meta <- meta[unique(ddata[, .(dataset_id, local, regional, year)]),
             on = .(local, regional, year)]

meta[,":="(
  effort = 6L,
  
  gamma_sum_grains = NA,
  gamma_sum_grains_type = "sample",
  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_comment = "unknown number of trap per transect.",
  
  gamma_bounding_box = geosphere::areaPolygon(coords[grDevices::chull(coords$Longitude, coords$Latitude), c("Longitude", "Latitude")]) / 1000000,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "convex-hull",
  gamma_bounding_box_comment = "area of the region computed as the convexhull covering the centres of all ponds",
  
  comment_standardisation = "To ensure standard effort, we kept only wetlands and years that were sampled in all 3 transects in each of the 6 months. Then, samples from all transects and vegetative zones of a site, of all months of a year were pooled together.Empty values: 0 and NA and values of D resembling dry ponds were excluded"
  
)]

##save data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized_metadata.csv"),
                   row.names = FALSE
)

