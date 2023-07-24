dataset_id <- "alston_2021c"
# understory plants - UNDERSTORY_LGQUAD_2008-2019.csv
ddata <- base::readRDS("./data/raw data/alston_2021c/rdata.rds")

# Raw data ----
## melting species ----
species_list <- grep("[A-Z][a-z]+(_[a-z]+)?|unknown", colnames(ddata), value = TRUE)
ddata[, (species_list) := lapply(.SD, function(column) replace(as.integer(column), column == 0, NA)), .SDcols = species_list] # replace all 0 values by NA

ddata <- data.table::melt(
   data = ddata,
   id.vars = c("date", "site", "plot", "rebar", "latitude", "longitude"),
   measure.vars = species_list,
   variable.name = "species",
   na.rm = TRUE)

## communities ----
data.table::setnames(ddata, c("site", "rebar"), c("regional", "local"))

ddata[, c("month", "year") := data.table::tstrsplit(date, split = "_")]

ddata[, ":="(
   dataset_id = dataset_id,
   local = paste0(plot, local),

   month = c(2L, 2L, 3L, 4L, 9L, 10L, 11L)[data.table::chmatch(month, c("February", "february", "March" , "April", "September", "October", "November"))],

   value = 1L,
   metric = "pa",
   unit = "pa",

   plot = NULL,
   date = NULL
)]

## metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, month, latitude, longitude)])

meta[, ":="(
   taxon = "Plants",
   realm = "Terrestrial",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,
   sampling_years = NA,

   alpha_grain = 1L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "quadrat",
   alpha_grain_comment = "49 quadrats per block, 3 blocks per region",

   comment = "Extracted from dryad data set 'Ecological consequences of large herbivore exclusion in an African savanna: 12 years of data from the UHURU experiment' https://doi.org/10.5061/dryad.1g1jwstxw. Tables PLOT_COORDINATES.csv and UNDERSTORY_LGQUAD_2008-2019.csv METHODS: 'Understory Monitoring: Grasses and forbs were surveyed biannually in February/March (dry season) and October (short rains). A 1-m2 quadrat was placed immediately to the north of each of the 49 stakes demarcating the 0.36-ha center grid in each plot, and a 0.25-m2 quadrat was placed within the larger quadrat. Species presence/absence was recorded within both quadrats. A 10-pinpoint frame was then positioned within the smaller quadrat, and the total number of vegetation pin hits was recorded for each species and/or the presence of bare soil. Individuals were identified to species (or to genus and morphospecies) using field guides and published species lists (Bogdan 1976, Blundell 1982, van Oudtshoorn 2009).' (https://www.esapubs.org/archive/ecol/E095/064/metadata.php) ",
   comment_standardisation = "Cover turned into presence absence",
   doi = 'https://doi.org/10.5061/dryad.1g1jwstxw | https://doi.org/10.1002/ecy.3649'
)]

ddata[, c("latitude", "longitude") := NULL]

## saving raw data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   ddata,
   paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   meta,
   paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)

# Standardised data ----
## Excluding manipulated sites ----
ddata <- ddata[grepl("OPEN", local)]
## standardising effort ----
# all 49 quadrats per plot sampled every year and every sampling event.
# some sites are sampled once a year, others, twice.

# 2009 was sampled in both spring and autumn, 2019 was sampled in spring only so we keep only spring surveys for all sites
ddata <- ddata[month %in% c(2L, 3L, 4L)]

## cleaning species lists ----
## Authors' warning: delete trees (e.g., Acacia spp. and Boscia angustifolia) and other overstory species (e.g., Opuntia stricta and Euphorbia sp.)
species_list <- grep(x = species_list, pattern = "Acacia|Boscia_angustifolia|Euphorbia|Opuntia_stricta|Unknown|unknown", value = TRUE, invert = TRUE)
ddata <- ddata[species %in% species_list]

## Metadata ----
meta <- unique(meta[ddata[, .(dataset_id, regional, local, year)], on = .(regional, local, year)])

meta[, ":="(
   effort = 1L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of sampled areas per year",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment_standardisation = "only open plots i.e. control treatment are included here. Only spring surveys are included here because 2009 and 2019 have spring in common. Tree species are excluded as recommended by the authors. Cover turned into presence absence"
)][, ":="(
   gamma_sum_grains = sum(alpha_grain),
   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6
   ), by = .(year, regional)
]

## saving standardised data ----
data.table::fwrite(
   ddata,
   paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised.csv"),
   row.names = FALSE
)
data.table::fwrite(
   meta,
   paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised_metadata.csv"),
   row.names = FALSE
)
