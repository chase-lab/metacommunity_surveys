dataset_id <- "moore_2022"

ddata <- base::readRDS("data/raw data/moore_2022/rdata.rds")
coords <- base::readRDS("data/raw data/moore_2022/coords.rds")

#Raw Data ----
##counting individuals ----
ddata <- ddata[, .(value = .N), by = .(year = Year, regional = Site, local = Quadrat, species)]

##community data ----
ddata[, ":="(
   dataset_id = dataset_id,

   metric = "abundance",
   unit = "count"
)]

##meta data----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])

meta[, ":="(
   taxon = "Plants",
   realm = "Terrestrial",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,
   data_pooled_by_authors_comment = NA,
   sampling_years = NA,

   latitude = coords$Latitude_NAD_1983[match(local, coords$Quadrat)],
   longitude = coords$Longitude_NAD_1983[match(local, coords$Quadrat)],

   alpha_grain = 1L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "quadrat",
   alpha_grain_comment = "1*1m quadrat",

   comment = "Extracted from Moore, Margaret M.; Jenness, Jeffrey S.; Laughlin, Daniel C.; Strahan, Robert T.; Bakker, Jonathan D.; Dowling, Helen E.; Springer, Judith D. 2021. Cover and density data of southwestern ponderosa pine understory plants in permanent chart quadrats (2002-2020+). Fort Collins, CO: Forest Service Research Data Archive. Updated 30 March 2022. https://doi.org/10.2737/RDS-2021-0092. METHODS: 'This data publication includes cover and density data collected on 101 permanent 1 meter (m) x 1 m (1-m2) quadrats located within southwestern ponderosa pine ecosystems near Flagstaff, Arizona, USA. Individual plants in these quadrats were identified and mapped annually for 19 years (2002-2021)[...]' Abundances were retrieved from table 6 ('(6) tabular representation of point locations for plant species mapped as points') LOCAL is a quadrat and regional is a site.",
   comment_standardisation = "none needed",
   doi = 'http://dx.doi.org/10.1002/ecy.3661'
)]

##save data ----
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

#standardised data ----
## Community data ----
## Excluding sites that were not sampled at least twice 10 years apart ----
ddata <- ddata[!ddata[, diff(range(year)) < 9L, by = .(regional, local)][(V1)],
               on = .(regional, local)]

## Metadata ----
meta <- meta[unique(ddata[, .(regional, local, year)]),
             on = .(regional, local, year)]
meta[,":="(
   effort = 1L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "quadrat",
   gamma_sum_grains_comment = "sum of the quadrats sampled each year",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment_standardisation = "Sites that were not sampled at least twice 10 years apart were excluded."

)][, ":="(
   gamma_sum_grains = length(unique(local)),
   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6
),
by = .(year, regional)
]

##save data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
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
