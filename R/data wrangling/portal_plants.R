dataset_id = "portal_plants"

ddata <- base::readRDS(file = "data/raw data/portal_plants/rdata.rds")

# Raw data ----
## Community data ----
### Building local name with plot, treatment, quadrat ----
ddata[j = ":="(
   dataset_id = factor(paste(dataset_id, season, sep = "_")),

   regional = factor("Chihuahan Desert"),
   local = factor(paste(plot, treatment, quadrat, sep = "_")),

   metric = "abundance",
   unit = "count",

   season = NULL,
   plot = NULL,
   quadrat = NULL,
   treatment = NULL
)]
data.table::setnames(x = ddata, old = "abundance", new = "value")

### Removing one sample with duplicated observations of Chenopodium fremontii ----
ddata <- ddata[
   i = !ddata[, .N, by = .(dataset_id, local, year, species)][N != 1L],
   on = .(dataset_id, local, year)]

## Metadata ----
meta <- unique(ddata[j = .(dataset_id, regional, local,
                           alpha_grain, longitude, latitude,
                           year)])
meta[, ':='(
   taxon = "Plants",
   realm = "Terrestrial",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain_unit = "m2",
   alpha_grain_type = "quadrat",

   comment = factor("Extracted from Github repository S. K. Morgan Ernest, Glenda M. Yenni, Ginger Allington, Ellen K. Bledsoe, Erica M. Christensen, Renata Diaz, Keith Geluso, Jacob R. Goheen, Qinfeng Guo, Edward Heske, Douglas Kelt, Joan M. Meiners, Jim Munger, Carla Restrepo, Douglas A. Samson, Michele R. Schutzenhofer, Marian Skupski, Sarah R. Supp, Katherine M. Thibault, … Thomas J. Valone. (2023). weecology/PortalData: 5.20.0 (5.20.0) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.10092282 . Downloaded using the portalr package targetting version 5.20.0 (the latest at the time of writing).
METHODS: 'The entire study area is approximately 20 ha and within this area there are 24 experimental plots'. This data sets include 'data collected by counting all individuals on a 0.5 m x 0.5 m quadrat at each of 16 permanent locations on each plot. `species` and `abundance` are recorded.[...]Since January 1988 there have been no direct manipulations of the plant community. From July 1985 to December 1987, annuals were “removed” by applying an herbicide (brand: Roundup), but this removal was not considered successful and was discontinued (Brown 1998).'
local column is composed as plot_treatment_quadrat"),
    comment_standardisation = "none needed",
    doi = "https://doi.org/10.5281/zenodo.10092282"
)]

ddata[j = c("latitude", "longitude", "alpha_grain") := NULL]

## Saving raw data ----
data.table::setkey(ddata, dataset_id)
data.table::setkey(meta, dataset_id)
dataset_ids <- unique(meta$dataset_id)

for (dataset_id_i in dataset_ids) {
   dir.create(paste0("data/wrangled data/", dataset_id_i), showWarnings = FALSE)
   data.table::fwrite(
      x = ddata[dataset_id_i, !"sampled"],
      file = paste0("data/wrangled data/", dataset_id_i, "/", dataset_id_i, "_raw.csv"),
      row.names = FALSE
   )
   data.table::fwrite(
      x = meta[dataset_id_i],
      file = paste0("data/wrangled data/", dataset_id_i, "/", dataset_id_i, "_raw_metadata.csv"),
      row.names = FALSE
   )
}

# Standardised data ----
## Standardisation ----
### Subsetting control and fully sampled samples
ddata <- ddata[grepl("control", local) & sampled == 1L]

# ddata[, j = data.table::uniqueN(local),
#       keyby = .(dataset_id,
#                 stringi::stri_extract_first_regex(local, "^[0-9]{1,2}(?=_)"),
#                 year)][, table(V1)]

### Individual base resampling ----
ddata[j = site := stringi::stri_extract_first_regex(local, "^[0-9]{1,2}(?=_)")]
ddata[j = effort := data.table::uniqueN(local),
      keyby = .(dataset_id, year, site)][, local := NULL]
data.table::setnames(x = ddata, old = "site", new = "local")

### Pooling all quadrats from a year ----
ddata <- ddata[i = effort >= 8L,
               j = .(value = sum(value)),
               keyby = .(dataset_id, regional, local, year,
                         species, metric, unit, effort)]

#### computing min total abundance for the local/year where the effort is the smallest ----
ddata[j = sample_size := sum(value),
      keyby = .(dataset_id, year, local)]
#### excluding samples with less than 10 individuals ----
if (any(ddata$sample_size < 10L)) ddata <- ddata[sample_size >= 10L]
min_sample_size <- ddata[effort == min(effort), min(sample_size)]

#### resampling abundances down to the minimal total abundance observed among the surveys with the minimal effort ----
source("R/functions/resampling.r")
set.seed(42)
ddata[i = sample_size > min_sample_size,
      j = value := resampling(species, value,
                              min_sample_size, replace = FALSE),
      by = .(dataset_id, year, local)]

ddata[i = sample_size < min_sample_size,
      j = value := resampling(species, value,
                              min_sample_size, replace = TRUE),
      by = .(dataset_id, year, local)]

ddata[, c("effort", "sample_size") := NULL]
ddata <- ddata[!is.na(value)]

### Excluding sites that were not sampled at least twice 10 years apart ----
### Excluding years with less than.4 sampled sites
while (ddata[j = diff(range(year)) < 9L,
             keyby = .(dataset_id, local)][, any(V1)]
       ||
       ddata[j = data.table::uniqueN(local) < 4L,
             keyby = .(dataset_id, year)][, any(V1)]) {

   ddata <- ddata[
      i = !ddata[j = diff(range(year)) < 9L,
                 keyby = .(dataset_id, local)][(V1)],
      on = .(dataset_id, local)
   ]

   ddata <- ddata[
      i = !ddata[j = data.table::uniqueN(local) < 4L,
                 keyby = .(dataset_id, year)][(V1)],
      on = .(dataset_id, year)
   ]
}


## Metadata ----
meta[j = local := stringi::stri_extract_first_regex(local, "^[0-9]{1,2}(?=_)")]
meta <- unique(meta[i = unique(ddata[, .(dataset_id, local, year)]),
                    on = .(dataset_id, local, year)])

meta[j = ":="(
   effort = 8L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "0.25sqm quadrats",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment_standardisation = "Only control sites were kept.
When a site is sampled several times a year, selecting the 8 most frequently sampled months from the 10 most sampled months.
When a site is sampled twice a month, selecting the first visit.
Excluding sites that were not sampled at least twice 10 years apart
Excluding years with less than 4 sampled sites"
)][j = ":="(
   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6,
   gamma_sum_grains = sum(alpha_grain) * 8),
   keyby = year]

## Saving standardised data ----
data.table::setkey(ddata, dataset_id)
data.table::setkey(meta, dataset_id)
dataset_ids <- unique(meta$dataset_id)

for (dataset_id_i in dataset_ids) {
   data.table::fwrite(
      x = ddata[dataset_id_i],
      file = paste0("data/wrangled data/", dataset_id_i, "/", dataset_id_i, "_standardised.csv"),
      row.names = FALSE
   )
   data.table::fwrite(
      x = meta[dataset_id_i],
      file = paste0("data/wrangled data/", dataset_id_i, "/", dataset_id_i, "_standardised_metadata.csv"),
      row.names = FALSE
   )
}
