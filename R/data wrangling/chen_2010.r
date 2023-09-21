dataset_id <- "chen_2010"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))

#Raw Data ----
data.table::setnames(
   ddata, c("Species", "Taxonomic group", "Historical sites", "Modern sites"),
   c("species", "taxon", "hsites", "msites")
)

ddata[, paste0("historical", 1:8) := data.table::tstrsplit(hsites, ",", fixed = TRUE)]
ddata[, paste0("modern", 1:7) := data.table::tstrsplit(msites, ",", fixed = TRUE)]

ddata <- data.table::melt(ddata,
                          id.vars = c("species"),
                          measure.vars = c(paste0("historical", 1:8), paste0("modern", 1:7)),
                          variable.name = "period",
                          value.name = "local",
                          na.rm = TRUE
)

##GIS coordinates ----
coords <- base::readRDS(file = paste("data/raw data", dataset_id, "coords.rds", sep = "/"))
data.table::setnames(coords, c("Locality", "Code", "Longitude", "Latitude", "Dates"), c("regional", "local", "longitude", "latitude", "year"))
coords_temp <- coords[grDevices::chull(coords$longitude, coords$latitude), c("longitude", "latitude")]
coords[, gamma_bounding_box := geosphere::areaPolygon(coords_temp) / 10^6]

coords[, local := as.character(local)]

ddata <- merge(ddata, coords[, .(regional, local, year)])

##community data ----
ddata[, ":="(
   dataset_id = dataset_id,

   year = data.table::fifelse(grepl("historical", period), substr(year, 1, 4), substr(year, 7, 10)),

   value = 1L,
   metric = "pa",
   unit = "pa",

   period = NULL
)]

##meta data----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta <- merge(meta, coords[, .(local, latitude, longitude, gamma_bounding_box)])

meta[, ":="(
   realm = "Terrestrial",
   taxon = "Invertebrates",

   study_type = "resurvey",

   data_pooled_by_authors = FALSE,
   data_pooled_by_authors_comment = NA,
   sampling_years = NA,

   alpha_grain = pi * (15^2),
   alpha_grain_unit = "m2",
   alpha_grain_type = "sample",
   alpha_grain_comment = "30m radius sampling area of a light trap",

   comment = "chen et al. 2010 resurvey on moths in Malaysia. Data obtained through Roman-Palacios & Wiens 2020 Dryad repository. The authors sampled using light traps at the same locations and season in 1965 and 2007.",
   comment_standardisation = "none needed",
   doi = 'https://doi.org/10.1111/j.1466-8238.2010.00594.x'
)]

##save data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta[,!c("gamma_bounding_box")],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)

#standardised Data ----

##meta data ----
meta[,":="(
   effort = 1L,

   gamma_sum_grains = pi * (.0015^2) * 10,
   gamma_sum_grains_unit = "km2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of the sampled areas",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "Area of the convex hulls covering the sites. Computed in R with the coordinates found in pnas.1913007117.sd02.xlsx"
)]

##save data ----
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
