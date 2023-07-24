dataset_id <- "alston_2021b"
# small mammals
ddata <- readRDS("./data/raw data/alston_2021b/rdata.rds") # SMALL_MAMMALS_2009-2019.csv

# How are individuals that are captured twice in the same trap or twice in the same grid during the same campaign counted? They are kept because maybe this happens in other sampling designs without it being recorded

# Raw data ----
data.table::setnames(ddata, c("site", "plot"), c("regional", "local"))
ddata <- ddata[!is.na(rebar) & !is.na(species)]
ddata <- ddata[, .(value = .N), by = .(year, date, regional, local, rebar, species, longitude, latitude)]

## communities ----
ddata[, ":="(
   dataset_id = dataset_id,
   local = paste(sep = "_", local, rebar),

   date = as.POSIXct(x = date, format = "%d-%b-%y"),

   metric = "abundance",
   unit = "count"
)][, ":="(
   month = format(date, "%m"),
   day = format(date, "%d")
)]

## metadata ----
meta <- unique(ddata[, .(dataset_id, year, month, day, regional, local, latitude, longitude)])
meta[, ":="(
   taxon = "Mammals",
   realm = "Terrestrial",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,
   data_pooled_by_authors_comment = NA,
   sampling_years = NA,

   alpha_grain = NA_real_,
   alpha_grain_unit = "cm2",
   alpha_grain_type = "trap",
   alpha_grain_comment = "traps",

   comment = "Extracted from dryad repository Alston, Jesse et al. (2021), Ecological consequences of large herbivore exclusion in an African savanna: 12 years of data from the UHURU experiment, Dryad, Dataset, https://doi.org/10.5061/dryad.1g1jwstxw . In the UHURU experiment, 3 sites, North, Central and South are located on a 20km climatic gradient. Each site has 3 replicates/blocks in which several exclusion treatments are applied. In each treatment plot, small mammals were captures every other month with 49 cage traps placed at fixed locations marked by a rebar stuck in the ground regularly placed on a 60m*60m grid. They stay open overnight and are used several times a year. This data is provided by the authors in the table SMALL_MAMMALS_2009-2019.csv. The region is one of the 3 sites North, Central and South, and local scale is a plot: one of the 3 replicates found in a site. Coordinates are provided by the authors in PLOT_COORDINATES.csv. Additional sampling information found in previous study: https://www.esapubs.org/archive/ecol/E095/064/metadata.php : 'Small mammals were live trapped at two-month intervals in total-exclusion and open plots using Sherman live-traps (Goheen et al. 2013). In each trapping session, and for four consecutive days, a single trap was set at each of the 49 grid stakes in the center of each plot, opened in the late afternoon, and checked and closed in the early morning.' ",
   comment_standardisation = "empty traps were excluded"
)]

ddata[, c("latitude", "longitude", "rebar") := NULL]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
drop_col <-  "date"
data.table::fwrite(
   ddata[, !..drop_col],
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
ddata <- ddata[grepl(pattern = "OPEN", x = local)]
## standardising effort ----
### changing local to be one level up: we pool all rebars from a plot together
ddata[, local := gsub(pattern = "_.*$", replacement = "", x = local)]

### effort: the total number of sampling nights per plot per year ----
ddata[, effort := length(unique(date)), by = .(year, regional, local)]

### pooling abundances of all traps/rebars of a plot for each year ----
ddata <- ddata[, .(value = .N, effort = unique(effort)), by = .(regional, local, year, species)]

### computing min total abundance for the local/year where the effort is the smallest ----
ddata[, sample_size := sum(value), by = .(year, regional, local)]
### deleting samples with less than 10 individuals
ddata <- ddata[sample_size >= 10L]
min_sample_size <- ddata[effort == min(effort), min(sample_size)]

## resampling abundances down to the minimal total abundance observed among the surveys with the minimal effort
source("./R/functions/resampling.r")
set.seed(42)
ddata[sample_size > min_sample_size, value := resampling(species, value, min_sample_size), by = .(year, regional, local)]
ddata[sample_size < min_sample_size, value := resampling(species, value, min_sample_size, replace = TRUE), by = .(year, regional, local)]
ddata <- ddata[!is.na(value)]


## communities ----
ddata[, ":="(
   sample_size = NULL
)]


## metadata ----
### subsetting original meta with standardised ddata ----
meta[, local := gsub(pattern = "_.*$", replacement = "", x = local)][, c("month", "day") := NULL]
meta <- unique(unique(meta)[ddata[,.(regional, local, year, effort)], on = .(regional, local, year)])

### updating grain and extent values ----
meta[, ":="(
   alpha_grain = 0.36,
   alpha_grain_unit = "ha",
   alpha_grain_type = "plot",

   effort = 1L,

   gamma_sum_grains_unit = "ha",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "sum of the PLOT areas sampled each year per region",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment_standardisation = "Following author's informations: all empty traps are recorded with a NA in the species field, the number of nights a trap is left open is stored in the night field. Only OPEN treatment plots were used. 
   Because effort varies: varying number of traps and varying number of sampling events per year, individuals are resampled down to the minimal number of captured individuals among the least intensively sampled years i.e. 10 individuals.",
   doi = 'https://doi.org/10.5061/dryad.1g1jwstxw | https://doi.org/10.1002/ecy.3649'
)][, ":="(
   gamma_sum_grains = 0.36 * length(unique(local)),
   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6
), by = .(year, regional)
]

ddata[, effort := NULL]

### saving standardised data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
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
