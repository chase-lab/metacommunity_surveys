dataset_id <- 'bowman_2021'

ddata <- base::readRDS('data/raw data/bowman_2021/rdata.rds')
data.table::setnames(ddata, tolower(colnames(ddata)))

# Standardisation ----
ddata <- unique(ddata[trt == 0 & hits != 0][, c('trt', 'plottype', 'hits','taxonid') := NULL])
data.table::setnames(ddata, c('regional','year','local','species'))

# Communities ----
ddata[, ':='(
   dataset_id = dataset_id,

   value = 1L,
   metric = 'pa',
   unit = 'pa'
)]

# Coordinates
coords <- data.frame(longitude = c(-105.5828, -105.5828, -105.5835, -105.5835), latitude = c(40.0528, 40.05336, 40.05336, 40.0528))

# Metadata ----
meta <- unique(ddata[, .(regional, local, year)])
meta[, ':='(
   taxon = "Plants",
   realm = "Terrestrial",

   study_type = "ecological_sampling",
   effort = 1L,

   data_pooled_by_authors = FALSE,
   sampling_years = NA,

   latitude = mean(coords$latitude),
   longitude = mean(coords$longitude),

   alpha_grain = 1L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "quadrat",
   alpha_grain_comment = "",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of sampled areas per year",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "box",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment = "Extracted from EDI repository Bowman, W. 2021. N fertilization and recovery experiment (2-4-6) plant species composition data for East of Tvan from 1997 to 2017, yearly ver 2. Environmental Data Initiative. https://doi.org/10.6073/pasta/e1a9391a826475a853c623a31348baec . METHODS: 'The treatments were applied to 5 replicate 1 m x 1.5 m plots for each treatment for a total of 20 plots, arranged in 5 replicate blocks. A 1 m x 0.5 m portion of the plot was reserved for destructive soil sampling, while the remainder was used for monitoring vegetation change.  The plots were established in 1997, and the treatments were applied each year. At the start of the field season in 2009 the plots were split in half (0.5 m x1.5 m), with one side randomly assigned as a recovery plot, receiving no further treatment solution, and the other side continuing to receive the treatment.

The composition of vascular plant species within the subplots plots was measured each year (except 2001) using a point-intercept method with a 5 x 10 grid of 50 points in each subplot.  Species nomenclature follows USDA PLANTS Database. Species that occurred within a plot but not recorded at one of the points were given a projected cover value of 0.5. Because the leaf area index was sometimes greater than 1, more than 100 points were recorded in some plots.' ",
   comment_standardisation = "Only control sites were kept. Hits were turned into presence absence",
   doi = 'https://doi.org/10.6073/pasta/e1a9391a826475a853c623a31348baec'
)][, gamma_sum_grains := sum(alpha_grain), by = .(year, regional)
][, gamma_bounding_box := geosphere::areaPolygon(coords[grDevices::chull(coords$longitude, coords$latitude), ]) / 10^6]


dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)
