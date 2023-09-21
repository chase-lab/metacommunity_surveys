# dugan_2021e marine mammals
dataset_id <- "dugan_2021b"

ddata <- base::readRDS("data/raw data/dugan_2021/rdata.rds")

# Data preparation ----
data.table::setnames(
   ddata,
   old = c("DATE", "MONTH", "YEAR", "SITE", "TOTAL"),
   new = c("date", "month", "year", "local", "value"))
ddata[, date := data.table::as.IDate(date, format = "%Y-%m-%d")]

## delete absences  ----
ddata <- ddata[value != 0]


# Raw data ----
## community data ----

ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Santa Barbara Coastal LTER",

   day = data.table::mday(date),

   species = paste(TAXON_GENUS, TAXON_SPECIES),

   metric = "abundance",
   unit = "count",

   TAXON_CLASS = NULL,
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
meta <- unique(ddata[, .(dataset_id, regional, local, year, month, day)])

meta[, ":="(
   realm = "Terrestrial",
   taxon = "Mammals",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   latitude = c(34.40305, mean(34.39452, 34.391151), 34.40928, 34.470467, 34.410767, 34.408533)[match(local, c("ABB", "CSB-CCB", "IVWB", "AQB", "EUCB", "SCLB"))],
   longitude = c(-119.74375, mean(-119.52699, -119.521236), -119.87385, -120.118617, -119.842017, -119.551583)[match(local, c("ABB", "CSB-CCB", "IVWB", "AQB", "EUCB", "SCLB"))],

   alpha_grain = 100000L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "transect",
   alpha_grain_comment = "1000m long transect along the beach estimated to be 100m wide",

   comment = "Extracted from EDI repository knb-lter-sbc.51.10 https://pasta.lternet.edu/package/eml/knb-lter-sbc/51/10 . Authors counted birds, marine mammals, dogs and humans on 1km transects of 6 coastal sites of the Santa Barbara Coastal LTER. Only living mammals were included in this data set. Coordinates are from the Santa Barbara Coastal LTER website https://sbclter.msi.ucsb.edu/data/catalog/package/?package=knb-lter-sbc.51",
   comment_standardisation = "none needed",
   doi = 'https://doi.org/10.6073/pasta/06c6b9983a5f0a44349e027a002f5040'
)]

##save data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata[,!c("TAXON_FAMILY", "date")],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)

# Standardised Data ----

# ddata <- ddata[!is.na(TAXON_FAMILY) & !TAXON_FAMILY %in% c("Delphinidae","Canidae","Hominidae")]
ddata <- ddata[
   TAXON_FAMILY %in% c("Otariidae", "Phocidae")][
      !ddata[,
             .(nmonth = data.table::uniqueN(month), nweek = data.table::uniqueN(date)),
             by = .(local, year)][nmonth != 12L & nweek != 12L],
      on = .(local, year)]

ddata <- ddata[, .(value = sum(value)), by = .(dataset_id, regional, local, year,
                                               species, metric, unit)]

## Excluding regions years with less than 4 sites ----
ddata <- ddata[!ddata[, data.table::uniqueN(local) < 4L, by = .(regional, year)][(V1)],
               on = .(regional, year)]

## Excluding sites that were not sampled at least twice 10 years apart ----
ddata <- ddata[!ddata[, diff(range(year)) < 9L, by = local][(V1)],
               on = "local"]

if (nrow(ddata) != 0L) {
   ##community data ----
   ddata[,":="(
      value = 1L,
      metric = "pa",
      unit = "pa"
   )]

   ##meta data ----
   meta[, c("month", "day") := NULL]
   meta <- unique(meta[ddata[, .(regional, local, year)], on = .(regional, local, year)])

   meta[,":="(
      effort = 12L,

      gamma_sum_grains_unit = "m2",
      gamma_sum_grains_type = "plot",
      gamma_sum_grains_comment = "number of sites per year * 1200m2",

      gamma_bounding_box = 6L,
      gamma_bounding_box_unit = "km2",
      gamma_bounding_box_type = "ecosystem",
      gamma_bounding_box_comment = "60km long coastline between the most distant sites (measured on Google Earth) * 100m wide beach (estimated)",

      comment_standardisation = "Only taxa from Otariidae and Phocidae families were kept.
Only sites actually sampled 12 times every year were included.
Regions years with less than 4 sits were excluded.
Sites that were not sampled at least twice 10 years apart were excluded."
   )][, gamma_sum_grains := data.table::uniqueN(local) * 10000L, by = year]

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
}
