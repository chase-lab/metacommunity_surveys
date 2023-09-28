dataset_id <- "mushet_2017"

# Data preparation ----
##Extracting taxonomy from metadata ----
if (!file.exists("data/raw data/muschet_2017/CLSAInvertebrateCounts_metadata_taxonomy.csv")) {
   tax <- XML::xmlToList("data/raw data/muschet_2017/CLSAInvertebrateCounts_metadata.xml")

   codes <- unlist(sapply(tax$eainfo[[1]], function(element) element$attrlabl))
   lnames <- unlist(sapply(tax$eainfo[[1]], function(element) element$attrdef))
   lnames <- stringi::stri_extract_first_regex(str = lnames, pattern = "(?<=identified as? ).*(?= present)")

   write.table(
      x = na.omit(data.frame(codes = codes, long_names = lnames)),
      sep = ",", row.names = FALSE,
      file = "data/raw data/muschet_2017/CLSAInvertebrateCounts_metadata_taxonomy.csv"
   )
}
tax <- read.table(
   file = "data/raw data/muschet_2017/CLSAInvertebrateCounts_metadata_taxonomy.csv",
   sep = ",", header = TRUE)


## Coordinates
coords <- data.table::fread(file = "data/raw data/muschet_2017/site locations.csv", skip = 1)
coords[, Plot_name := data.table::fifelse(nchar(Plot_name) == 2L,
                                          paste0(substr(Plot_name, 1, 1), "0", substr(Plot_name, 2, 2)),
                                          Plot_name)]
data.table::setnames(coords, c("Latitude","Longitude"), c("latitude", "longitude"))

## Reading insect counts ----
ddata <- base::readRDS("data/raw data/muschet_2017/rdata.rds")

##melting species ----
ddata <- data.table::melt(ddata,
                          id.vars = c("YEAR", "WETLAND", "MONTH", "TRANSECT", "VEGZONE"),
                          variable.name = "species",
                          na.rm = TRUE
)

##exclude absences ----
ddata <- ddata[!value %in% c("0", "")]

data.table::setnames(ddata,
                     old = c("WETLAND","YEAR","MONTH"),
                     new = c("local", "year", "month"))

## Deleting samples with duplicated observations ----
# eg YEAR 2008 MONTH 3 WETLAND P01 TRANSECT E VEGZONE OW is twice with different species abundances
ddata <- ddata[
   !ddata[, .N, by = .(local, VEGZONE, TRANSECT, year, month, species)][N != 1L],
   on = .(local, VEGZONE, TRANSECT, year, month)]

#Raw Data ----
##community data ----

ddata[, ":="(
   dataset_id = dataset_id,

   regional = factor("Cottonwood Lake Study Area"),
   local = factor(paste(local, VEGZONE, TRANSECT, sep = "_")),

   species = factor(tax$long_names[match(species, tax$codes)]),

   metric = factor("abundance"),
   unit = factor("count")
)]

##meta data ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, month, Plot_name = sub("_.*$", "", local))])
meta[coords, ":="(latitude = i.latitude, longitude = i.longitude), on = "Plot_name"][, Plot_name := NULL]

meta[, ":="(
   taxon = "Invertebrates",
   realm = "Freshwater",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = 1L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "sample",
   alpha_grain_comment = "estimated",

   comment = "Extracted from Mushet, D.M., Euliss, N.H., Jr., and Solensky, M.J. 2017, Cottonwood Lake Study Area - Invertebrate Counts, U.S. Geological Survey data release, https://doi.org/10.5066/F7BK1B77. Authors provide data sampled in the Cottonwood Lake Study Area from 1992 to 2015. Methods: 'Aquatic macroinvertebrates were collected each month (April-September) from all wetlands at Cottonwood Lake Study Area containing water using vertically oriented funnel traps (Swanson 1978). Sampling was stratified to provide separate estimates of invertebrate biomass and abundance in all major vegetative zones of each wetland. Samples were collected at random locations along the 3 established transects in each wetland that were established earlier and used to collect other biotic and abiotic data (LaBaugh et al. 1987). The length of each vegetation zone as bisected by transects was measured and a computer-generated set of random numbers used to identify sample points for the collection of invertebrate samples in each vegetative zone. One sample was collected from each major vegetative zone from each transect. Data consist of counts by taxa.'  Taxonomic names were extracted from metadata file https://www.sciencebase.gov/catalog/item/get/599d9555e4b012c075b964a6",
   comment_standardisation = "Absences: 0 and NA were excluded but empty samples ('D') were kept.
Samples with duplicated observations were excluded.",
doi = 'https://doi.org/10.5066/F7BK1B77'
)]

## save raw data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata[, !c('TRANSECT','VEGZONE')],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)

# Standaridzed Data----
## Change of local name to remove the transect and vegzone names ----
ddata[, local := gsub("_.*$", "", local, perl = TRUE)]
meta[, local := gsub("_.*$", "", local, perl = TRUE)]

# selecting only months when all 3 transects were sampled ----
ddata[, full_sample_month := data.table::uniqueN(TRANSECT), by = .(local, year, month)]
ddata <- ddata[full_sample_month == 3L]
##selecting only wetlands/years where all 6 months were sampled ----
ddata[, nmonth := data.table::uniqueN(month), by = .(local, year)]
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

## exclude dry pond samples: value == D ----
ddata <- ddata[value != "D"][, value := as.numeric(value)]

## pooling all months, TRANSECTs and VEGZONEs together
ddata <- unique(ddata[, .(value = sum(value)),
                      by = .(dataset_id, regional, local, year, species, metric, unit)])

## Excluding sites that were not sampled at least twice 10 years apart ----
ddata <- ddata[!ddata[, diff(range(year)) < 9L, by = .(regional, local)][(V1)],
               on = .(regional, local)]

## meta data ----
meta[, month := NULL]
meta <- unique(meta[unique(ddata[, .(local, year)]),
                    on = .(local, year)])

meta[,":="(
   effort = 6L,

   gamma_sum_grains_type = "sample",
   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_comment = "estimated sampled area per year",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "area of the region computed as the convexhull covering the centres of all ponds",

   comment_standardisation = "Samples with duplicated observations were excluded.
To ensure standard effort, we kept only wetlands and years that were sampled in all 3 transects in each of the 6 months.
Then, samples from all transects and vegetative zones of a site, of all months of a year were pooled together.
Empty values: 0 and NA and values of D dry ponds were excluded.
Sites that were not sampled at least twice 10 years apart were excluded."
)][, ":="(
   gamma_sum_grains = sum(alpha_grain),
   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6),
   by = year]

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
