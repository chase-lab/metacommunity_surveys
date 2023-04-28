dataset_id <- "mushet_2018"

# Loading coordinates
coords <- read.csv("./data/raw data/muschet_2017/site locations.csv", skip = 1)
coords$Plot_name <- ifelse(nchar(coords$Plot_name) == 2, paste0(substr(coords$Plot_name, 1, 1), "0", substr(coords$Plot_name, 2, 2)), coords$Plot_name)


ddata <- data.table::fread("./data/raw data/muschet_2018/muschet_2018-CLSAamphibiansCounts_v2.csv")
data.table::setnames(ddata, tolower(colnames(ddata)))
data.table::setnames(ddata, "wetland", "local")

# standardising ----
# selecting only sampling surveys that lasted the whole 4 days
ddata <- ddata[ddata[, .(N = length(unique(day))), by = .(local, transect, year, month)][N == 4], on = c("local", "transect", "year", "month")]

# selecting only months when all 3 transects were sampled.
ddata[, date := paste0(day, month, year)]
ddata[, full_sample_month := length(unique(transect)), by = .(local, year, month)]
# ddata <- ddata[!(full_sample_month > 3L & !transect %in% c('A', 'C', 'E'))] # excluding 3 locals that were over sampled
ddata <- ddata[full_sample_month == 3L]

# selecting two out of the three most common months for each local//YEAR
seldata <- unique(ddata[, .(local, transect, year, month)])
seldata <- seldata[month %in% 5:7]
# excluding locals / transects / years with only 2 month sampled
seldata <- seldata[seldata[, .N, by = .(local, transect, year)][N >= 2L], on = c("local", "transect", "year")]
seldata[, month_priority_order := c(3L, 2L, 1L)[match(month, c(5L, 6L, 7L))]]
data.table::setorder(seldata, local, transect, year, month_priority_order)
seldata <- seldata[, .SD[1:2, ], by = .(local, transect, year)]
# subsetting by using a data.table join
ddata <- ddata[seldata, on = c("local", "transect", "year", "month")]

# selecting only 2 surveys per transect per local per month per year
# selsample <- unique(ddata[, .(local, transect, year, month, day)])
# # excluding locals / transects / years / months with only 1 day sampled
# selsample <- selsample[selsample[, .N, by = .(local, transect, year, month)][N >= 2L], on = c('local','transect','year','month')]
# data.table::setorder(selsample)
# selsample <- selsample[, .SD[1:2,], by = .(local, transect, year, month)]
# # subsetting by using a data.table join
# ddata <- ddata[selsample, on = c('local','transect','year','month','day')]


# pooling all days, MONTHs, TRANSECTs, development stages and sex together
ddata <- unique(ddata[, .(value = sum(as.numeric(count))), by = .(local, year, species)])
ddata <- ddata[species != "NONE" & value > 0L]

# ddata wrangling ----
ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Cottonwood Lake Study Area",

  species = c(
    "Ambystoma mavortium", "Chrysemys picta", "Lithobates tadpole",
    "Pseudacris maculata", "Lithobates pipiens", "Lithobates sylvaticus",
    "Thamnophis radix"
  )[match(species, c("AMMA", "CHPI", "FROTAD", "PSMA", "RAPI", "RASY", "THRA"))],

  metric = "abundance",
  unit = "count"
)]

# metadta ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  taxon = "Herpetofauna",
  realm = "Freshwater",

  latitude = coords$Latitude[match(local, coords$Plot_name)],
  longitude = coords$Longitude[match(local, coords$Plot_name)],

  effort = 1L,
  study_type = "ecological_sampling",

  data_pooled_by_authors = FALSE,

  alpha_grain = pi * 0.05^2,
  alpha_grain_unit = "m2",
  alpha_grain_type = "sample",
  alpha_grain_comment = "5cm wide aperture of the funnel opening",

  gamma_sum_grains = NA,
  gamma_sum_grains_type = "sample",
  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_comment = "unknown number of trap per transect.",

  gamma_bounding_box = geosphere::areaPolygon(coords[grDevices::chull(coords$Longitude, coords$Latitude), c("Longitude", "Latitude")]) / 1000000,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "convex-hull",
  gamma_bounding_box_comment = "area of the region computed as the convexhull covering the centres of all ponds",

  comment = "Extracted from Mushet, D.M., and Solensky, M.J., 2022, Cottonwood Lake Study Area - Amphibians (ver. 2.0): U.S. Geological Survey data release, https://doi.org/10.5066/P9G8TM2S. Authors provide data sampled in the Cottonwood Lake Study Area from 1992 to 2021. METHODS: 'Amphibians and reptiles were captured over one week in May-September from 1992-2017 using amphibian funnel traps (Mushet et al. 1997). Traps were placed along three existing transects within the central vegetation zone of each CLSA wetland. Funnel traps were constructed of 1/8 inch galvanized hardware cloth and had a 5-cm aperture at the funnel opening. The funnel traps designed for use in this study have been shown to minimize injury rates (Mushet et al. 1997) and provide captured animals access to the surface. Additionally, traps were checked daily to minimize the time captured animals spent in traps. Funnel traps were set on the morning of day one and checked each morning over four subsequent days. Adult amphibians and reptiles were identified to species, and tadpoles were identified to genus.'  Taxonomic names were extracted from metadata file https://www.sciencebase.gov/catalog/item/get/599d9555e4b012c075b964a6",
  comment_standardisation = "To ensure standard effort, we kept only wetlands and years that were sampled in all 3 transects during 2 months in May, June or July. Then, samples from all transects and vegetative zones of a site, of all selected months of a year were pooled together.",
  doi = 'https://doi.org/10.5066/F7X9297Q'
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
