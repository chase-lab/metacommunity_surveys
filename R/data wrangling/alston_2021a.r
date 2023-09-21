dataset_id <- "alston_2021a"
# trees
ddata <- base::readRDS(file = "data/raw data/alston_2021a/rdata.rds")

# Raw data ----
data.table::setnames(
   x = ddata,
   old = c("site","section","total"),
   new = c("regional","local","value"))

## Communities ----
## Author warning: In some sections in some years, two rows for the same species were inadvertently recorded with different numbers of trees. We recommend that data users average these entries to account for these data errors. -> we average the abundances of the repeated rows.
ddata <- ddata[, .(value = as.integer(ceiling(mean(value)))), by = .(year, regional, local, block, treatment, latitude, longitude, species)]

#
ddata[, ":="(
   dataset_id = dataset_id,

   local = paste(block, treatment, local, sep = "_"),

   metric = "abundance",
   unit = "count",

   block = NULL,
   treatment = NULL
)]


## Metadata ----

meta <- unique(ddata[, .(dataset_id, regional, local, year, latitude, longitude)])

meta[, ":="(
   taxon = "Plants",
   realm = "Terrestrial",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,
   data_pooled_by_authors_comment = NA,
   sampling_years = NA,

   alpha_grain = 10L * 10L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "quadrat",
   alpha_grain_comment = "10*10m quadrat",

   comment = "Extracted from dryad repository Alston, Jesse et al. (2021), Ecological consequences of large herbivore exclusion in an African savanna: 12 years of data from the UHURU experiment, Dryad, Dataset, https://doi.org/10.5061/dryad.1g1jwstxw . In the UHURU experiment, 3 sites, North, Central and South are located on a 20km climatic gradient. Each site has 3 replicates/blocks in which several exclusion treatments are applied. We include only the OPEN treatment. In each treatment plot, 36 10*10m plots are surveyed: all trees measured. This data is provided by the authors in the table TREE_CENSUS_DETAILED_2009-2019.csv. The region is one of the 3 sites North, Central and South, and local scale is the section scale. Coordinates are provided by the authors in PLOT_COORDINATES.csv.",
   comment_standardisation = "Following author's recommendations found in the README file provided in the Dryad repository: when a species was recorded in two rows in a given section year, abundances were averaged. However, the authors also warned that Euphorbia species were no consistently counted but this is not corrected here.",
   doi = 'https://doi.org/10.5061/dryad.1g1jwstxw | https://doi.org/10.1002/ecy.3649'
)]

ddata[, c("latitude","longitude") := NULL]

## Saving raw data ----
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
## Excluding manipulated sites ----
ddata <- ddata[grepl(pattern = "OPEN", x = local)]
## Excluding 2019 for North site because only 2 plots were sampled instead of 3. ----
ddata <- ddata[!(regional == "NORTH" & year == 2019L)]
## Excluding empty plots ----
ddata <- ddata[species != "NONE" & value != 0L]

## Author warning: Euphorbia spp. were present but not recorded in 2009 -> we delete all records of Euphorbia plants
ddata <- ddata[!grepl(pattern = "Euphorbia_", x = species)]

## Excluding sites that were not sampled at least twice 10 years apart.
ddata <- ddata[!ddata[, diff(range(year)) < 9L, by = .(regional, local)][(V1)],
               on = .(regional, local)]

## Metadata ----
### subsetting original meta with standardised ddata ----
meta <- unique(meta[ddata[,.(regional, local, year)], on = .(regional, local, year)])

### updating extent values ----
meta[, ":="(
   effort = 1L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "quadrat",
   gamma_sum_grains_comment = "sum of the quadrats sampled each year per region",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment = "Extracted from dryad repository Alston, Jesse et al. (2021), Ecological consequences of large herbivore exclusion in an African savanna: 12 years of data from the UHURU experiment, Dryad, Dataset, https://doi.org/10.5061/dryad.1g1jwstxw . In the UHURU experiment, 3 sites, North, Central and South are located on a 20km climatic gradient. Each site has 3 replicates/blocks in which several exclusion treatments are applied. We include only the OPEN treatment. In each treatment plot, 36 10*10m plots are surveyed: all trees measured. This data is provided by the authors in the table TREE_CENSUS_DETAILED_2009-2019.csv. The region is one of the 3 sites North, Central and South, and local scale is the section scale. Coordinates are provided by the authors in PLOT_COORDINATES.csv.",
   comment_standardisation = "Following author's recommendations found in the README file provided in the Dryad repository: Euphorbia species were excluded and when a species was recorded in two rows in a given section year, abundances were averaged.
Excluding sites that were not sampled at least twice 10 years apart."
)][, ":="(
   gamma_sum_grains = sum(alpha_grain),
   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6
), by = .(year, regional)]

## saving standardised data ----
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
