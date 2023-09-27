# dustan-halas_1987
dataset_id <- "dustan-halas_1987"

ddata <- data.table::fread(
   file = paste0("data/raw data/", dataset_id, "/rdata.csv"),
   skip = 1L, header = TRUE)

#Raw Data ----
ddata <- data.table::melt(ddata,
                          id.vars = "species",
                          value.name = "tmp",
                          variable.name = "local"
)

##transforming time period codes in values ----
ddata[, tmp := c("historical", "modern", "historical+modern")[match(tmp, c("x", "o", "."))]]

ddata[, c("tmp1", "tmp2") := data.table::tstrsplit(tmp, "\\+")]
ddata <- data.table::melt(ddata,
                          id.vars = c("species", "local"),
                          measure.vars = c("tmp1", "tmp2"),
                          value.name = "period"
)

##excluding NA species and NA time periods ----
ddata <- ddata[!is.na(period) & !is.na(species)]

ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Carysfort reef",

   year = c(1975L, 1983L)[data.table::chmatch(period, c("historical", "modern"))],

   value = 1L,
   metric = "pa",
   unit = "pa",

   period = NULL,
   variable = NULL
)]

##meta data ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(

   realm = "Marine",
   taxon = "Invertebrates",

   latitude = "25`13`N",
   longitude = "80`13`W",

   study_type = "resurvey",

   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "'Carysfort Reef was surveyed in 1975 (Dustan 1985) and resurveyed in the summers of 1982 and 1983; it took two field sessions to find and resample all the transects'",
   sampling_years = c("1975", "1982-1983")[match(year, c(1975L, 1983L))],

   alpha_grain = 5L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "sample",
   alpha_grain_comment = "25m long transect, 0.2m width",

   comment = "Extracted from dustan-halas 1987 table 3 (table extraction with tabula). Regional is the area covering all 21 25m long transects, local are transects. 'Carysfort Reef was surveyed in 1975 (Dustan 1985) and resurveyed in the summers of 1982 and 1983; it took two field sessions to find and resample all the transects. Transects 1-10 were surveyed in 1982 and 11-21 in 1983.' The observer then used the transect line to measure contact length with coral colonies hence the estimated 20cm width of sampling. 'The length of line crossing over coral colonies and the space between them was measured to the nearest 0.5 cm'. ",
   comment_standardisation = "none needed",
   doi = 'https://doi.org/10.1007/BF00301378'
)]

##save raw data ----

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8"
)

data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8"
)

# standardised Data ----
## Excluding sites that were not sampled at least twice 10 years apart ----
ddata <- ddata[!ddata[, diff(range(year)) < 9L, by = local][(V1)],
               on = "local"]

##meta data ----
meta[,":="(
   effort = 1L,

   gamma_sum_grains = 5L * 25L,
   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "number of transects * 5m2",

   gamma_bounding_box = 7500L,
   gamma_bounding_box_unit = "m2",
   gamma_bounding_box_type = "ecosystem",
   gamma_bounding_box_comment = "area covering all transects (25m * 300m)",

   comment_standardisation = "Sites that were not sampled at least twice 10 years apart were excluded."
)]

## save standardised data ----
if (nrow(ddata != 0L)) {
   data.table::fwrite(
      x = ddata,
      file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised.csv"),
      row.names = FALSE, sep = ",", encoding = "UTF-8"
   )

   data.table::fwrite(
      x = meta,
      file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised_metadata.csv"),
      row.names = FALSE, sep = ",", encoding = "UTF-8"
   )
}
