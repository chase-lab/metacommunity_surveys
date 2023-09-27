dataset_id <- "mushet_2018"

# Loading coordinates
coords <- data.table::fread(file = "data/raw data/muschet_2017/site locations.csv", skip = 1)
coords[, Plot_name := data.table::fifelse(nchar(Plot_name) == 2L,
                                          sub("(^[PT])([0-9]{1}$)", "\\10\\2", Plot_name, perl = TRUE),
                                          Plot_name)]
data.table::setnames(coords, c("Latitude","Longitude"), c("latitude", "longitude"))

ddata <- data.table::fread(
   file = "data/raw data/muschet_2018/muschet_2018-CLSAamphibiansCounts_v2.csv",
   sep = ",", header = TRUE)

# Raw data ----
data.table::setnames(ddata, tolower(colnames(ddata)))
data.table::setnames(ddata, old = "wetland", new = "local")

## pooling all development stages and sex together ----
ddata <- unique(ddata[, .(value = sum(count)),
                      by = .(local, year, species, transect, month, day)])

## excluding absences but keeping empty samples----
ddata <- ddata[!(value == 0L & species != "NONE")]

## community data ----
ddata[, ":="(
   dataset_id = dataset_id,

   regional = "Cottonwood Lake Study Area",
   local = paste(local, transect, sep = "_"),

   species = c(
      "Ambystoma mavortium", "Chrysemys picta", "Lithobates tadpole",
      "Pseudacris maculata", "Lithobates pipiens", "Lithobates sylvaticus",
      "Thamnophis radix"
   )[data.table::chmatch(species, c("AMMA", "CHPI", "FROTAD", "PSMA", "RAPI", "RASY", "THRA"))],

   metric = "abundance",
   unit = "count"
)]

## meta data ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, month, day, Plot_name = sub("_.*$", "", local))])
meta[coords, ":="(latitude = i.latitude, longitude = i.longitude), on = "Plot_name"][, Plot_name := NULL]

meta[, ":="(
   taxon = "Herpetofauna",
   realm = "Freshwater",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = pi * 0.05^2,
   alpha_grain_unit = "m2",
   alpha_grain_type = "sample",
   alpha_grain_comment = "5cm wide aperture of the funnel opening",

   comment = "Extracted from Mushet, D.M., and Solensky, M.J., 2022, Cottonwood Lake Study Area - Amphibians (ver. 2.0): U.S. Geological Survey data release, https://doi.org/10.5066/P9G8TM2S. Authors provide data sampled in the Cottonwood Lake Study Area from 1992 to 2021. METHODS: 'Amphibians and reptiles were captured over one week in May-September from 1992-2017 using amphibian funnel traps (Mushet et al. 1997). Traps were placed along three existing transects within the central vegetation zone of each CLSA wetland. Funnel traps were constructed of 1/8 inch galvanized hardware cloth and had a 5-cm aperture at the funnel opening. The funnel traps designed for use in this study have been shown to minimize injury rates (Mushet et al. 1997) and provide captured animals access to the surface. Additionally, traps were checked daily to minimize the time captured animals spent in traps. Funnel traps were set on the morning of day one and checked each morning over four subsequent days. Adult amphibians and reptiles were identified to species, and tadpoles were identified to genus.'  Taxonomic names were extracted from metadata file https://www.sciencebase.gov/catalog/item/get/599d9555e4b012c075b964a6",
   comment_standardisation = "Absences excluded but empty sites kept (species == NONE)",
   doi = 'https://doi.org/10.5066/F7X9297Q'
)]

## Save raw data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata[, !"transect"],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8"
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8"
)

# standardised data ----
## local name back to the wetland level ----
ddata[, local := gsub("_.$", "", local, perl = TRUE)]
meta[, local := gsub("_.$", "", local, perl = TRUE)]

## selecting only sampling surveys that lasted the whole 4 days ----
ddata <- ddata[ddata[, .(N = data.table::uniqueN(day)), by = .(local, transect, year, month)][N == 4], on = c("local", "transect", "year", "month")]

## selecting only months when all 3 transects were sampled.----
ddata[, full_sample_month := data.table::uniqueN(transect) == 3L, by = .(local, year, month)]
ddata <- ddata[(full_sample_month)]

## selecting two out of the three most common months for each local//YEAR ----
seldata <- unique(ddata[, .(local, transect, year, month)])
seldata <- seldata[month %in% 5:7]

## excluding locals / transects / years with less than 2 months sampled ----
seldata <- seldata[seldata[, .N, by = .(local, transect, year)][N >= 2L], on = c("local", "transect", "year")]
seldata[, month_priority_order := c(3L, 2L, 1L)[match(month, c(5L, 6L, 7L))]]
data.table::setorder(seldata, local, transect, year, month_priority_order)
seldata <- seldata[, .SD[1:2, ], by = .(local, transect, year)]
# subsetting by using a data.table join
ddata <- ddata[seldata, on = c("local", "transect", "year", "month")]

## delete absence values ----
ddata <- ddata[species != "NONE"]

## pooling all days, months and transects together ----
ddata <- unique(ddata[, .(value = sum(value)),
                      by = .(dataset_id, regional, local, year, species, unit, metric)])

## meta data ----
meta[, c("month","day") := NULL]
meta <- unique(meta)
meta <- meta[unique(ddata[, .(local, year)]),
             on = .(local, year)]

meta[, ":="(
   effort = 6L,

   gamma_sum_grains_type = "sample",
   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_comment = "area of a trap * 3 transects per wetland * 2 months",

   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "area of the region computed as the convexhull covering the centres of all ponds",

   comment_standardisation = "To ensure standard effort, we kept only wetlands and years that were sampled in all 3 transects during 2 months in May, June or July. Then, samples from all transects and vegetative zones of a site, of all selected months of a year were pooled together."
)][, gamma_sum_grains := sum(alpha_grain) * 3 * 2, by = year]

## save standardised data ----
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8"
)

data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised_metadata.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8"
)
