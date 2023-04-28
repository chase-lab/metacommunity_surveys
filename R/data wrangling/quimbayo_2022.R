dataset_id <- "quimbayo_2022"

ddata <- base::readRDS("data/raw data/quimbayo_2022/rdata.rds")
data.table::setnames(ddata, c("ntransect", "location"), c("local", "regional"))

# Standardisation
# "transect_ids 2019_86 and 2019_91 were excluded over uncertainty whether data are duplicated or not."
ddata <- ddata[!transect_id %in% c("2019_86", "2019_91")]
# regions with less than 4 sampled locations per year are excluded (Campeche island2013 and 2017)
ddata <- ddata[ddata[, length(unique(local)), by = regional][V1 >= 4L][, V1 := NULL], on = .(regional)]

## community data ----

ddata[, ":="(
   dataset_id = dataset_id,

   metric = "abundance",
   unit = "count",

   site = NULL,
   transect_id = NULL
)]

## metadata ----

meta <- unique(ddata[, .(dataset_id, regional, local, year, latitude, longitude)])
meta[, ":="(
   realm = "Marine",
   taxon = "Fish",

   effort = 1L,

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = 40L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "transect",
   alpha_grain_comment = "given by authors",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "transect",
   gamma_sum_grains_comment = "number of transects per year per region * 40m2",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment = "Extracted from supplementary material associated to data paper https://doi.org/10.1002/ecy.3966. TimeFISH is a database of reef fish communities in Southwest Atlantic. Methods: 'A total of 202,965 individuals belonging to 163 reef fish species and 53 families were recorded across 1,857 [Under Water Visual Censuses]'. One 40m2 standard sample per year. Both 'scuba' and 'snorkel' samples were included. Authors provided three scales: location, site and transect ; here, location is regional, transect number is local and the site scale is ignored.",
   comment_standardisation = "transect_ids 2019_86 and 2019_91 were excluded over uncertainty whether data are duplicated or not.",
   doi = 'https://doi.org/10.1002/ecy.3966'
)
][, ":="(gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6,
         gamma_sum_grains = sum(alpha_grain)),
  by = .(regional, year)]

ddata[, c("latitude", "longitude") := NULL]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)
