dataset_id <- "magalhaes_2020"
ddata <- base::readRDS(file = "./data/raw data/magalhaes_2020/rdata.rds")

#Raw Data ----
##melting and splitting sites and years ----
data.table::setnames(ddata, 1L, "species")
ddata <- data.table::melt(ddata,
                          id.vars = "species",
                          variable.name = "local",
                          na.rm = TRUE
)

ddata[, c("local", "year") := data.table::tstrsplit(local, "_")]

##community data ----
ddata[, ":="(
  dataset_id = "magalhaes_2020",
  regional = "Muriae Ornamental Aquaculture Center",
  local = base::enc2utf8(tolower(local)),
  year = as.integer(gsub("s", "", year)),
  
  metric = "abundance",
  unit = "count"
)]

ddata[year == 2010L, year := 2015L]
ddata[year == 2000L, year := c(2003L, 2004L, 2005L, 2006L, 2006L)[match(local, c("boa vista", "pinheiros", "santo antônio", "chato", "gavião"))]]

##coordiantes ----
coords <- data.table::as.data.table(
  matrix(c(
    "Boa Vista", "21 01' 23'' S", "42 21' 45.7'' W",
    "Pinheiros", "20 53' 44.7'' S", "42 22' 03.5'' W",
    "Santo AntÔnio", "20 58' 18.7'' S", "42 19' 11.2'' W",
    "Chato", "20 57' 18.5'' S", "42 17' 25.1'' W",
    "GaviÃo", "20 57' 12.4'' S", "42 16' 52.4'' W"
  ),
  ncol = 3, dimnames = list(c(), c("local", "latitude", "longitude")), byrow = TRUE
  )
)
coords[, ":="(local = tolower(local), latitude = parzer::parse_lat(latitude), longitude = parzer::parse_lon(longitude))]

##meta data ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])

meta[, ":="(
  taxon = "Fish",
  realm = "Freshwater",
  
  latitude = coords$latitude[match(local, coords$local)],
  longitude = coords$longitude[match(local, coords$local)],
  
  study_type = "ecological_sampling",
  
  data_pooled_by_authors = FALSE,
  
  alpha_grain = 400L,
  alpha_grain_unit = "m2",
  alpha_grain_type = "sample",
  alpha_grain_comment = "estimated from the article '100-m long transects'",
  
  comment = base::enc2utf8("Extracted from supplementary 1 associated to article Magalhães, A.L.B., Daga, V.S., Bezerra, L.A.V. et al. All the colors of the world: biotic homogenization-differentiation dynamics of freshwater fish communities on demand of the Brazilian aquarium trade. Hydrobiologia 847, 3897–3915 (2020). https://doi.org/10.1007/s10750-020-04307-w. Methods: 'We sampled five headwater creeks (first- order streams, sensu Strahler, 1957), all belonging to the Paraíba do Sul River basin, an important Brazilian freshwater ecoregion.[...]Fish were collected with rectangular hand sieving (95 cm long, 25 cm high, and 0.3 mm mesh), along side the margins and channel beds, every 2 months (January to December), in each of the five headwater creeks located in the immediate vicinity of fish farms:[...], therefore totalizing five sampling units (creeks), in two treatments, five creeks sampled until 2006, and resampled in 2015. Two people sieved 50 times along 100-m long transects during a 2 h in period in daylight in each creek. The dataset was summarized according to the following decades: 2000s (i.e., corresponding to 2003, 2004, 2005 and 2006) and 2010s (i.e., corresponding to 2015).'"),
  comment_standardisation = "none needed"
)]

##save data ----

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
                   row.names = FALSE
)

#Standardized data ----

##meta data ----
meta[,":="(
  effort = 1L,
  
  gamma_sum_grains = 400L * 5L,
  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "sample",
  gamma_sum_grains_comment = "sum of the 5 sampled areas",
  
  gamma_bounding_box = geosphere::areaPolygon(coords[grDevices::chull(coords$longitude, coords$latitude), c("longitude", "latitude")]) / 1000000,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "convex-hull",
  gamma_bounding_box_comment = "convex hull covering the sampling sites"
)]

##save data ----

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standaradized_metadata.csv"),
                   row.names = FALSE
)

