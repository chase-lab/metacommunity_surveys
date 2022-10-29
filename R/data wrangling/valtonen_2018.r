dataset_id <- "valtonen_2018"

ddata <- base::readRDS(file = paste0("./data/raw data/", dataset_id, "/ddata.rds"))
data.table::setnames(ddata, c("Site", "Year"), c("local", "year"))

#Raw Data ----
## melting species ----
ddata <- data.table::melt(ddata,
                          id.vars = c("local", "year"),
                          variable.name = "species"
)
## delete value = 0 ----
ddata <- ddata[value > 0]

##community data ----
ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Hungary",
  
  metric = "abundance",
  unit = "count"
)]

##meta data ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  taxon = "Invertebrates",
  realm = "Terrestrial",
  
  latitude = 47L,
  longitude = 20L,
  
  study_type = "ecological_sampling",
  
  data_pooled_by_authors = FALSE,
  
  alpha_grain = 1L,
  alpha_grain_unit = "km2",
  alpha_grain_type = "sample",
  alpha_grain_comment = "area of the sampling sites",
  
  comment = 'Data extracted from the Dryad repository 10.5061/dryad.9m6vp. Compilation of butterflies trapped with light traps in Hungary. The data shared here were carefully curated to ensure the effort is constant as described in the article https://onlinelibrary.wiley.com/resolve/doi?DOI=10.1111/1365-2656.12687. "The traps were located in forests and forest  margins [...]. The traps were at the same locations (sites) throughout the study period, and they functioned generally throughout the annual active flight period of moths in the region." In each site there was one trap. alpha_grain is estimated as the area potentially sampled by a light-trap.',
  comment_standardisation = "none"
)]

##saving data tables ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
                   row.names = FALSE
)

#Standardized Data ----

##update meta ----
meta[, ":="(
  effort = 1L,
  
  gamma_sum_grains_unit = "km2",
  gamma_sum_grains_type = "sample",
  gamma_sum_grains_comment = "sum of the areas of the sampling sites for each year",
  
  gamma_bounding_box = 93030L,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "administrative",
  gamma_bounding_box_comment = "area of Hungary"
  
)][, gamma_sum_grains := length(unique(local)), by = year]


##saving data tables ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized_metadata.csv"),
                   row.names = FALSE
)