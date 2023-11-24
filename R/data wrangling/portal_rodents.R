dataset_id = "portal_rodents"

ddata <- base::readRDS(file = "data/raw data/portal_traps/rdata.rds")

# Selecting rodent data ----
ddata <- ddata[i = is.na(taxon) | taxon == "Rodent", j = !"taxon"]

# Raw data ----
## Community data ----
### Building local name with plot, treatment, stake ----
ddata[j = ":="(
   dataset_id = dataset_id,

   regional = factor("Chihuahan Desert"),
   local = factor(paste0(
      plot, "_",
      treatment,
      data.table::fifelse(is.na(stake), "", paste0("_", stake))
   )),

   metric = "abundance",
   unit = "count",

   plot = NULL,
   stake = NULL,
   treatment = NULL
)]

## Metadata ----
meta <- unique(ddata[j = .(dataset_id, regional, local, longitude, latitude,
                           year, month, day)])
meta[j = ':='(
   taxon = "Mammals",
   realm = "Terrestrial",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = 1L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "sample",
   alpha_grain_comment = "pitfall trap",

   comment = factor("Extracted from Github repository S. K. Morgan Ernest, Glenda M. Yenni, Ginger Allington, Ellen K. Bledsoe, Erica M. Christensen, Renata Diaz, Keith Geluso, Jacob R. Goheen, Qinfeng Guo, Edward Heske, Douglas Kelt, Joan M. Meiners, Jim Munger, Carla Restrepo, Douglas A. Samson, Michele R. Schutzenhofer, Marian Skupski, Sarah R. Supp, Katherine M. Thibault, … Thomas J. Valone. (2023). weecology/PortalData: 5.20.0 (5.20.0) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.10092282 . Downloaded using the portalr package targetting version 5.20.0 (the latest at the time of writing).
METHODS: 'The data set includes continuing monthly rodent surveys. Each month rodents are trapped on all 24 experimental plots and information on each captured rodent is [Not] contained in this file.[Individual information is available in the original data but not included here.]Rodent access to plots is regulated using gates cut into the fencing. Large gates (3.7 x 5.7 cm) allow all small mammals to access plots. Small gates (1.9 x 1.9 cm) exclude kangaroo rats (*Dipodomys*) whose inflated auditory bullae make their skulls too large to pass through the gates. Rodent removal plots do not contain any gates and animals caught on those plots are removed and released outside the cattle exclosure fence.
From 1977-present, plots were trapped around each new moon, which occurs approximately once a month. The survey occurs as close to the new moon as possible to minimize external effects on trapping success which could be misconstrued as actual changes in populations. [...]During a survey (2 nights), each plot is trapped for one night, with treatments divided evenly between the 2 nights to eliminate differences between controls and treatments caused by environmental differences on different nights. When a plot is surveyed, all gates are closed to ensure that only resident individuals are captured. At each stake, one Sherman live-trap is placed and baited with millet seed. Traps are collected the next morning and individuals processed.'
local column is composed as plot_treatment_stake or plot_treatment when stake information is not available and community was pooled at the site level by the authors"),
    comment_standardisation = "abundances were obtained by counting all individuals of each species in a sample",
    doi = "https://doi.org/10.5281/zenodo.10092282"
)]

ddata[j = c("latitude","longitude") := NULL]

## saving raw data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata[, !c("effort", "sampled")],
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
ddata <- ddata[grepl("_control", local) &
                  !is.na(species) &
                  effort == 49L &
                  sampled == 1L]

### Pooling traps together at the site level per day ----
ddata[j = local := stringi::stri_extract_first_regex(local, "^[0-9]{1,2}(?=_)")]

ddata <- ddata[j = .(value = sum(value)),
               keyby = .(dataset_id, regional, local, year, month, day,
                         species, metric, unit)]

### Pooling several samples a year ----
# ddata[, j = data.table::uniqueN(.SD),
#       .SDcols = c("month", "day"),
#       keyby = .(local, year)][, table(V1)]
# ddata[, j = data.table::uniqueN(month),
#       keyby = .(local, year)][, table(V1)]
# ddata[, j = data.table::uniqueN(day),
#       keyby = .(local, year, month)][, table(V1)]


### When a site is sampled several times a year, selecting the 8 most frequently sampled months from the 10 most sampled months ----
month_order <- ddata[j = data.table::uniqueN(day),
                     keyby = .(dataset_id, month)
][j = sum(V1),
  keyby = month][order(-V1)][1L:10L, month]
ddata[j = month_order := (1L:10L)[match(month, month_order, nomatch = NULL)]]
data.table::setkey(ddata, month_order)

ddata <- ddata[!is.na(month_order)][j = nmonths := data.table::uniqueN(month),
                                    keyby = .(dataset_id, local, year)][nmonths >= 8L][, nmonths := NULL]

ddata <- ddata[
   unique(ddata[
      j = .(dataset_id, local, year, month)])[, .SD[1L:8L],
      keyby = .(dataset_id, local, year)],
   on = .(dataset_id, local, year, month), nomatch = NULL][, month_order := NULL]

### When a site is sampled twice a month, selecting the first visit ----
ddata <- ddata[
   i = unique(ddata[
      j = .(dataset_id, local, year, month, day)])[, .SD[1L],
      keyby = .(dataset_id, local, year, month)],
   on = .(dataset_id, local, year, month, day)
][, month := NULL][, day := NULL]

### Pooling all samples from a year together ----
ddata <- ddata[j = .(value = sum(value)),
               keyby = .(dataset_id, regional, local, year,
                         species, metric, unit)]

### Excluding sites that were not sampled at least twice 10 years apart ----
### Excluding years with less than.4 sampled sites
while (ddata[j = diff(range(year)) < 9L,
             by = .(regional, local)][, any(V1)] ||
       ddata[j = data.table::uniqueN(local) < 4L,
             by = .(regional, year)][, any(V1)]) {

   ddata <- ddata[
      i = !ddata[j = diff(range(year)) < 9L,
                 by = .(regional, local)][(V1)],
      on = .(regional, local)
   ]

   ddata <- ddata[
      i = !ddata[j = data.table::uniqueN(local) < 4L,
                 by = .(regional, year)][(V1)],
      on = .(regional, year)
   ]
}


## Metadata ----
meta[j = local := stringi::stri_extract_first_regex(local, "^[0-9]{1,2}(?=_)")]
meta[j = c("month","day") := NULL]
meta <- unique(meta[i = unique(ddata[, .(local, year)]),
                    on = .(local, year)])

meta[j = ":="(
   effort = 49L * 8L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "1sqm trap * 49 traps * 8 surveys per year",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment_standardisation = "Only control sites were kept.
When a site is sampled several times a year, selecting the 8 most frequently sampled months from the 10 most sampled months.
When a site is sampled twice a month, selecting the first visit.
Excluding sites that were not sampled at least twice 10 years apart
Excluding years with less than 4 sampled sites
"
)][j = ":="(
    gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6,
    gamma_sum_grains = sum(alpha_grain) * 49L * 8L),
   keyby = year]

## saving standardised data ----
data.table::fwrite(
   x = unique(ddata),
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised_metadata.csv"),
   row.names = FALSE
)
