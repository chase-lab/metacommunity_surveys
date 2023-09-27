dataset_id <- "santana_2017"
ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))

# Raw Data ----
data.table::setnames(ddata,
                     old = c("Year", "Transect", "Date"), new = c("year", "local", "date"))

ddata <- data.table::melt(
   ddata,
   id.vars = c("year", "local", "Rowname", "Farmland_area", "date", "Recorder"),
   variable.name = "species",
   value.name = "value"
)

ddata <- ddata[value > 0]

## community data ----
ddata[date == "April 1996", date := "13 April 1996"][, date := data.table::as.IDate(date, format = "%d %B %Y")]
ddata[, ":="(
   dataset_id = dataset_id,

   regional = paste("SPA Castro Verde", Farmland_area),

   month = data.table::month(date),
   day = data.table::mday(date),

   metric = "abundance",
   unit = "count",

   date = NULL,
   Rowname = NULL,
   Recorder = NULL,
   Farmland_area = NULL
)]

## meta data ----

meta <- unique(ddata[, .(dataset_id, regional, local, year, month, day)])
meta[, ":="(
   realm = "Terrestrial",
   taxon = "Birds",

   latitude = data.table::fifelse(grepl("High-intensity", regional), "38°03'N", "37°41N"),
   longitude = data.table::fifelse(grepl("High-intensity", regional), "8°06'W", "8°00'W"),

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = 32.12,
   alpha_grain_unit = "ha",
   alpha_grain_type = "sample",
   alpha_grain_comment = "transect 250m buffer",

   comment = "Extracted from Santana et al 2017 Dryad repo (https://datadryad.org/stash/dataset/doi:10.5061/dryad.kp3fv). Authors sampled birds in two rural areas of Portugal. Both areas differ by the agriculture intensity. No standardisation needed, one sampling per year during 6 years, values are numbers of individual per transect. Each local is a buffer of 250 m along a transect (71 transects).",
   comment_standardisation = "none needed",
   doi = 'https://doi.org/10.5061/dryad.kp3fv | https://doi.org/10.1111/1365-2664.12898'
)]

## save data ----
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

# Standardised Data ----
ddata[, c("month","day") := NULL]
meta[, c("month","day") := NULL]

## meta data ----
meta <- meta[unique(ddata[, .(local, regional, year)]),
             on = .(local, regional, year)]
meta[, ":="(
   effort = 1L,

   gamma_sum_grains_unit = "ha",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of the sampled transect areas per region per year",

   gamma_bounding_box = data.table::fifelse(grepl("High-intensity", regional), 423.92, 456.08),
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "ecosystem",
   gamma_bounding_box_comment = "areas of the high and low intensity areas estimated from figure 1",

   comment_standardisation = "none needed"
)][, gamma_sum_grains := 32.12 * length(unique(local)), by = .(regional, year)]

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
