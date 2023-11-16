dataset_id = "portal_shrubs_old"

ddata <- base::readRDS(file = "data/raw data/portal_shrubs_old/rdata.rds")

# Raw data ----
## Community data ----
### Building local name with plot, treatment, transect ----
ddata[j = ":="(
   dataset_id = factor(dataset_id),

   regional = factor("Chihuahan Desert"),
   local = factor(paste(plot, treatment, transect, sep = "_")),

   metric = "abundance",
   unit = "count",

   plot = NULL,
   transect = NULL,
   treatment = NULL
)]

## Metadata ----
meta <- unique(ddata[j = .(dataset_id, regional, local,
                           longitude, latitude, year)])
meta[, ':='(
   taxon = "Plants",
   realm = "Terrestrial",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = 0.2 * 25,
   alpha_grain_unit = "m2",
   alpha_grain_type = "transect",
   alpha_grain_comment = "25m long, estimated 20cm wide point contact transect",

   comment = factor("Extracted from Github repository S. K. Morgan Ernest, Glenda M. Yenni, Ginger Allington, Ellen K. Bledsoe, Erica M. Christensen, Renata Diaz, Keith Geluso, Jacob R. Goheen, Qinfeng Guo, Edward Heske, Douglas Kelt, Joan M. Meiners, Jim Munger, Carla Restrepo, Douglas A. Samson, Michele R. Schutzenhofer, Marian Skupski, Sarah R. Supp, Katherine M. Thibault, … Thomas J. Valone. (2023). weecology/PortalData: 5.20.0 (5.20.0) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.10092282 . Downloaded using the portalr package targetting version 5.20.0 (the latest at the time of writing).
METHODS: 'Transect data were [...] collected in a point-intercept-transect (PIT) method. In each plot, four transects of 25 m each were made. Each transect was placed diagonally from a corner of the plot to the center (approximately; transects did not reach either to a corner or the center in fact). They are numbered on the data sheets as follows: A (NW corner), B (NE corner), C (SE corner), D (SW corner). The plant species (or lack of plants) was recorded every 1 decimeter (10 cm) along the 25 m, for a total of 250 data points per transect.'
local column is composed as plot_treatment_transect"),
comment_standardisation = "none needed",
doi = "https://doi.org/10.5281/zenodo.10092282"
)]

ddata[j = c("latitude", "longitude") := NULL]

## save raw data ----
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

# Standardised data ----
## Standardisation ----
### Subsetting control and fully sampled samples
ddata <- ddata[grepl("control", local, fixed = TRUE)]

# ddata[, j = data.table::uniqueN(local),
#       keyby = .(dataset_id,
#                 stringi::stri_extract_first_regex(local, "^[0-9]{1,2}(?=_)"),
#                 year)][, table(V1)]

ddata[j = regional := stringi::stri_extract_first_regex(local, "^[0-9]{1,2}(?=_)")]

## Metadata ----
meta[j = regional := stringi::stri_extract_first_regex(local, "^[0-9]{1,2}(?=_)")]
meta <- unique(meta[i = unique(ddata[, .(dataset_id, local, year)]),
                    on = .(dataset_id, local, year)])

meta[j = ":="(
   effort = 4L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors for the entire Chihuahan study site encompassing 24 plots",

   comment_standardisation = "Only control sites were kept."
)][j = gamma_bounding_box := geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6, by = year
   ][j = gamma_sum_grains := sum(alpha_grain),
   keyby = .(regional, year)]

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
