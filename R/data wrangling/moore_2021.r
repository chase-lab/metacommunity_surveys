dataset_id <- "moore_2022"

ddata <- readRDS("./data/raw data/moore_2022/rdata.rds")
coords <- readRDS("./data/raw data/moore_2022/coords.rds")

# counting individuals
ddata <- ddata[, .(value = .N), by = .(year = Year, regional = Site, local = Quadrat, species)]

# all quadrats have been sampled at least twice

ddata[, ":="(
   dataset_id = dataset_id,

   metric = "abundance",
   unit = "count"
)]


meta <- unique(ddata[, .(dataset_id, regional, local, year)])

meta[, ":="(
   taxon = "Plants",
   realm = "Terrestrial",

   study_type = "ecological sampling",
   effort = 1L,

   data_pooled_by_authors = FALSE,
   data_pooled_by_authors_comment = NA,
   sampling_years = year,

   latitude = coords$Latitude_NAD_1983[match(local, coords$Quadrat)],
   longitude = coords$Longitude_NAD_1983[match(local, coords$Quadrat)],

   alpha_grain = 1L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "quadrat",
   alpha_grain_comment = "1*1m quadrat",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "quadrat",
   gamma_sum_grains_comment = "sum of the quadrats sampled each year",

   comment = "Extracted from Moore, Margaret M.; Jenness, Jeffrey S.; Laughlin, Daniel C.; Strahan, Robert T.; Bakker, Jonathan D.; Dowling, Helen E.; Springer, Judith D. 2021. Cover and density data of southwestern ponderosa pine understory plants in permanent chart quadrats (2002-2020+). Fort Collins, CO: Forest Service Research Data Archive. Updated 30 March 2022. https://doi.org/10.2737/RDS-2021-0092. METHODS: 'This data publication includes cover and density data collected on 101 permanent 1 meter (m) x 1 m (1-m²) quadrats located within southwestern ponderosa pine ecosystems near Flagstaff, Arizona, USA. Individual plants in these quadrats were identified and mapped annually for 19 years (2002-2021)[...]' Abundances were retrieved from table 6 ('(6) tabular representation of point locations for plant species mapped as points') LOCAL is a quadrat and regional is a site."
)][, ":="(
   gamma_sum_grains = length(unique(local)),
   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 1000000
),
by = .(year, regional)
]



dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)
