dataset_id <- "alston_2021b"
# small mammals
ddata <- readRDS("./data/raw data/alston_2021b/rdata.rds") # SMALL_MAMMALS_2009-2019.csv

# How are individuals that are captured twice in the same trap or twice in the same grid during the same campaign counted? They are kept because maybe this happens in other sampling designs without it to be recorded

# standardising effort ----
data.table::setnames(ddata, c("site","plot"), c("regional","local"))
## effort: the total number of sampling nights per plot per year ----
ddata[, effort := sum(night), by = .(year, regional, local)]
ddata <- ddata[!is.na(rebar) & !is.na(species)]

## pooling abundances at the local/year level ----
ddata <- ddata[, .(value = .N, effort = unique(effort), latitude = unique(latitude), longitude = unique(longitude)), by = .(year, regional, local, species)]

## computing min total abundance for the local/year where the effort is the smallest ----
ddata[, sample_size := sum(value), by = .(year, regional, local)]
min_sample_size <- ddata[effort == min(effort), min(sample_size)]

## resampling abundances down to the minimal total abundance observed among the surveys with the minimal effort
source("./R/functions/resampling.r")
set.seed(42)
ddata[sample_size > min_sample_size, value := resampling(species, value, min_sample_size), by = .(year, regional, local)]
ddata[sample_size < min_sample_size, value := resampling(species, value, min_sample_size, replace = TRUE), by = .(year, regional, local)]
ddata <- ddata[!is.na(value)]

# keep only one date
# pool rebars at the block level
# keep abundances including recaptures


# communities ----
ddata[, ":="(
   dataset_id = dataset_id,

   metric = "abundance",
   unit = "count",

   sample_size = NULL,
   effort = NULL
)]


# metadata ----
meta <- unique(ddata[, .(dataset_id, year, regional, local, latitude, longitude)])
meta[, ":="(
   taxon = "Mammals",
   realm = "Terrestrial",

   study_type = "ecological_sampling",
   effort = 18L,  # Effort is the minimal number of sampling nights per local per year (all traps together)

   data_pooled_by_authors = FALSE,
   data_pooled_by_authors_comment = NA,
   sampling_years = NA,

   alpha_grain = 0.36,
   alpha_grain_unit = "ha",
   alpha_grain_type = "sample",
   alpha_grain_comment = "60m*60m grid of traps",

   gamma_sum_grains_unit = "ha",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of the grids sampled each year per region",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment = "Extracted from dryad repository Alston, Jesse et al. (2021), Ecological consequences of large herbivore exclusion in an African savanna: 12 years of data from the UHURU experiment, Dryad, Dataset, https://doi.org/10.5061/dryad.1g1jwstxw . In the UHURU experiment, 3 sites, North, Central and South are located on a 20km climatic gradient. Each site has 3 replicates/blocks in which several exclusion treatments are applied. We include only the OPEN treatment. In each treatment plot, small mammals were captures every other month with 49 cage traps placed at fixed locations marked by a rebar stuck in the ground regularly placed on a 60m*60m grid. They stay open overnight and are used several times a year. This data is provided by the authors in the table SMALL_MAMMALS_2009-2019.csv. The region is one of the 3 sites North, Central and South, and local scale is a plot: one of the 3 replicates found in a site. Coordinates are provided by the authors in PLOT_COORDINATES.csv. Additional sampling information found in previous study: https://www.esapubs.org/archive/ecol/E095/064/metadata.php : 'Small mammals were live trapped at two-month intervals in total-exclusion and open plots using Sherman live-traps (Goheen et al. 2013). In each trapping session, and for four consecutive days, a single trap was set at each of the 49 grid stakes in the center of each plot, opened in the late afternoon, and checked and closed in the early morning.' ",
   comment_standardisation = "Following author's informations: all empty traps are recorded with a NA in the species field, the number of nights a trap is left open is stored in the night field. Only OPEN treatment plots were used. because effort varies: varying number of traps and varying number of sampling events per year, individuals are resampled down to the minimal number of captured individuals among the least intensively sampled years i.e. 7 individuals.",
   doi = 'https://doi.org/10.5061/dryad.1g1jwstxw | https://doi.org/10.1002/ecy.3649'
)][, ":="(
   gamma_sum_grains = 0.36 * length(unique(local)),
   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 1000000
),
by = .(year, regional)
]

ddata[, c("latitude","longitude") := NULL]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)
