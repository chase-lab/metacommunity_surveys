dataset_id <- "alston_2021a"
# trees
ddata <- base::readRDS(file = "./data/raw data/alston_2021a/rdata.rds")

# standardisation ----
## Excluding manipulated sites ----
ddata <- ddata[treatment == "OPEN"]
## Excluding 2019 for North site because only 2 plots were sampled instead of 3. ----
ddata <- ddata[!(site == "N" & year == 2019L)]
## Excluding empty plots ----
ddata <- ddata[species != "NONE"]

## Author warning: Euphorbia spp. were present but not recorded in 2009 -> we delete all records of Euphorbia plants
ddata <- ddata[!grepl(pattern = "Euphorbia_", x = species)]
## Author warning: In some sections in some years, two rows for the same species were inadvertently recorded with different numbers of trees. We recommend that data users average these entries to account for these data errors. -> we sum the abundances of the repeated rows.
ddata <- ddata[, .(value = as.integer(ceiling(mean(total))), latitude = unique(latitude), longitude = unique(longitude)), by = .(year, site, block, section, species)][value != 0L]

data.table::setnames(ddata, c("site","section"), c("regional","local"))

# Communities ----
ddata[, ":="(
   dataset_id = dataset_id,

   local = paste(regional, block, local, sep = "_"),

   metric = "abundance",
   unit = "count",

   block = NULL
)]

# Metadata ----

meta <- unique(ddata[, .(dataset_id, regional, local, year, latitude, longitude)])

meta[, ":="(
   taxon = "Plants",
   realm = "Terrestrial",

   study_type = "ecological_sampling",
   effort = 1L,

   data_pooled_by_authors = FALSE,
   data_pooled_by_authors_comment = NA,
   sampling_years = NA,

   alpha_grain = 10L * 10L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "quadrat",
   alpha_grain_comment = "10*10m quadrat",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "quadrat",
   gamma_sum_grains_comment = "sum of the quadrats sampled each year per region",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment = "Extracted from dryad repository Alston, Jesse et al. (2021), Ecological consequences of large herbivore exclusion in an African savanna: 12 years of data from the UHURU experiment, Dryad, Dataset, https://doi.org/10.5061/dryad.1g1jwstxw . In the UHURU experiment, 3 sites, North, Central and South are located on a 20km climatic gradient. Each site has 3 replicates/blocks in which several exclusion treatments are applied. We include only the OPEN treatment. In each treatment plot, 36 10*10m plots are surveyed: all trees measured. This data is provided by the authors in the table TREE_CENSUS_DETAILED_2009-2019.csv. The region is one of the 3 sites North, Central and South, and local scale is the section scale. Coordinates are provided by the authors in PLOT_COORDINATES.csv.",
   comment_standardisation = "Following author's recommendations found in the README file provided in the Dryad repository: Euphorbia species were excluded and when a species was recorded in two rows in a given section year, abundances were averaged."
)][, ":="(
   gamma_sum_grains = sum(alpha_grain),
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

