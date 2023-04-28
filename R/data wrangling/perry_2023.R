# perry_2023
dataset_id <- 'perry_2023'

ddata <- base::readRDS('data/raw data/perry_2023/rdata.rds')
data.table::setnames(ddata, tolower(colnames(ddata)))


# subsetting data for equal number of visits per year + good quality ----
ddata[, year := base::format(sampledate, '%Y')][, month := base::format(sampledate, '%m')]
## When there are 2 dates per month, select one ----
# data.table style join
ddata <- ddata[
   ddata[qualitycheck == 'Good'][, .(sampledate = sampledate[1L]), by = .(lab, year, month, stationcode)],
   on = .(lab, year, month, stationcode, sampledate)
]

## selecting 10 samples in sites/years with 11 or 12 samples ----
ddata[, order_month := order(table(month), decreasing = TRUE)[base::match(month, 1L:12L)]]
data.table::setorder(ddata, lab, stationcode, year, order_month)
ddata <- ddata[
   unique(ddata[, .(lab, stationcode, year, month)])[, .SD[1L:10L], by = .(lab, stationcode, year)],
   on = .(lab, stationcode, year, month)
] # (data.table style join)

# Pooling monthly samples together ----
ddata <- ddata[,.(value = mean(organisms_per_ml), latitude = unique(latitude), longitude = unique(longitude)),
               by = .(year, regional = lab, local = stationcode, species = name)][!is.na(species)]


# communities ----
ddata[, ":="(
   dataset_id = dataset_id,
   regional = as.factor(paste('Sacramento-San Joaquin Bay-Delta', regional, sep = '_ ')),

   metric = "density",
   unit = "individuals per mL"
)]

# metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, latitude, longitude)])

meta[, ":="(
   taxon = "Invertebrates", # Phytoplankton
   realm = "Freshwater",

   study_type = "ecological_sampling",
   effort = 10L,

   data_pooled_by_authors = FALSE,
   data_pooled_by_authors_comment = NA,
   sampling_years = NA,

   alpha_grain = NA_integer_,
   alpha_grain_unit = NA_character_,
   alpha_grain_type = NA_character_,
   alpha_grain_comment = NA_character_,

   gamma_sum_grains_unit = NA_character_,
   gamma_sum_grains_type = NA_character_,
   gamma_sum_grains_comment = NA_character_,

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment = "Extracted from Perry, S.E., T. Brown, and V. Klotz. 2023. Interagency Ecological Program: Phytoplankton monitoring in the Sacramento-San Joaquin Bay-Delta, collected by the Environmental Monitoring Program, 2008-2021 ver 1. Environmental Data Initiative. https://doi.org/10.6073/pasta/389ea091f8af4597e365d8b8a4ff2a5a (Accessed 2023-02-23). METHODS: 'Phytoplankton samples are collected with a submersible pump or a Van Dorn sampler from a water depth of one meter (approximately three feet) below the water surface.' density vlues were retrieved from column 'organisms_per_mL' LOCAL is a stationcode and REGIONAL is the whole Sacramento-San Joaquin Bay-Delta with a split depending on the lab in charge of identifying algae organisms.",
   comment_standardisation = "Only samples rated as 'Good' are kept. Only sites/years with at least 10 months sampled are kept. When more than 10 months are sampled, the 10 most frequently sampled months (overall) are kept.",
   doi = 'https://doi.org/10.6073/pasta/389ea091f8af4597e365d8b8a4ff2a5a'
)][, ":="(
   gamma_sum_grains = sum(alpha_grain),
   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6
),
by = year
]

ddata[, c('latitude','longitude') := NULL]

base::dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)
