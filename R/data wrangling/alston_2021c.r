dataset_id <- "alston_2021c"
# understory plants - UNDERSTORY_LGQUAD_2008-2019.csv
ddata <- base::readRDS("./data/raw data/alston_2021c/rdata.rds")

# standardising effort ----
ddata[, c("month","year") := data.table::tstrsplit(date, split = "_")]

ddata[, length(unique(rebar)), by = .(year, date, plot)][order(year, plot)]  # all 49 quadrats per plot sampled every year and every sampling event.
ddata[, length(unique(date)), by = .(year, plot, rebar)][order(year, plot)]  # some sites are sampled once a year, others, twice.

# 2009 was sampled in both spring and autumn, 2019 was sampled in spring only so we keep only spring surveys for all sites
ddata <- ddata[month %in% c("february","February","March","April")]

# cleaning species lists ----
species_list <- grep("[A-Z][a-z]+(_[a-z]+)?", colnames(ddata), value = TRUE)
## Authors' warning: delete trees (e.g., Acacia spp. and Boscia angustifolia) and other overstory species (e.g., Opuntia stricta and Euphorbia sp.)
species_list <- grep(x = species_list, pattern = "Acacia|Boscia_angustifolia|Euphorbia|Opuntia_stricta|Unknown", value = TRUE, invert = TRUE)

# melting species ----
ddata[, (species_list) := lapply(.SD, function(column) replace(as.integer(column), column == 0, NA)), .SDcols = species_list] # replace all 0 values by NA

ddata <- data.table::melt(ddata,
                 id.vars = c("year","site","plot","rebar","latitude","longitude"),
                 measure.vars = species_list,
                 variable.name = "species",
                 na.rm = TRUE)


# ddata ----
data.table::setnames(ddata, c("site", "rebar"), c("regional","local"))

ddata[, ":="(
   dataset_id = dataset_id,
   local = paste0(plot, local),

   value = 1L,
   metric = "ap",
   unit = "ap",

   plot = NULL
)]

# Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, latitude, longitude)])

meta[, ":="(
   taxon = "Plants",
   realm = "Terrestrial",

   study_type = "ecological_sampling",
   effort = 1L,

   data_pooled_by_authors = FALSE,
   sampling_years = NA,

   alpha_grain = 1L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "quadrat",
   alpha_grain_comment = "49 quadrats per block, 3 blocks per region",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of sampled areas per year",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex hull",

   comment = "Extracted from dryad data set 'Ecological consequences of large herbivore exclusion in an African savanna: 12 years of data from the UHURU experiment' https://doi.org/10.5061/dryad.1g1jwstxw. Tables PLOT_COORDINATES.csv and UNDERSTORY_LGQUAD_2008-2019.csv METHODS: 'Understory Monitoring: Grasses and forbs were surveyed biannually in February/March (dry season) and October (short rains). A 1-m2 quadrat was placed immediately to the north of each of the 49 stakes demarcating the 0.36-ha center grid in each plot, and a 0.25-m2 quadrat was placed within the larger quadrat. Species presence/absence was recorded within both quadrats. A 10-pinpoint frame was then positioned within the smaller quadrat, and the total number of vegetation pin hits was recorded for each species and/or the presence of bare soil. Individuals were identified to species (or to genus and morphospecies) using field guides and published species lists (Bogdan 1976, Blundell 1982, van Oudtshoorn 2009).' (https://www.esapubs.org/archive/ecol/E095/064/metadata.php) ",
   comment_standardisation = "only open plots i.e. control treatment are included here. Only spring surveys are included here because 2009 and 2019 have spring in common. Tree species are excluded as recommended by the authors. Cover turned into presence absence"
)][, gamma_sum_grains := sum(alpha_grain), by = .(year, regional)
   ][, gamma_bounding_box := geosphere::areaPolygon(coords[grDevices::chull(coords$longitude, coords$latitude), c("longitude","latitude")]) / 1000000]

ddata[, c("latitude","longitude") := NULL]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)
