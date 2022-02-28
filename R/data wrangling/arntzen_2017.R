# arntzen_2017
dataset_id <- "arntzen_2017"

ddata <- base::readRDS(file = "./data/raw data/arntzen_2017/rdata.rds")
data.table::setnames(
  ddata,
  c(".id", "number", "of visits", "Longitude", "Latitude"),
  c("year", "local", "effort", "longitude", "latitude")
)

## filling in missing values in longitude and latitude
ddata[longitude == "as below", longitude := NA][, longitude := as.numeric(longitude)][, latitude := as.numeric(latitude)]

ddata[, ":="(
  longitude = data.table::nafill(longitude, type = "nocb"),
  latitude = data.table::nafill(latitude, type = "nocb")
)]

## correcting (removing the dot...) and converting coordinates
coords <- unique(ddata[, .(local, year, latitude, longitude)])
adding_zeroes <- function(x, full_length) {
   for (i in which(nchar(x) < full_length))   x[i] <- paste0(x[i], paste0(rep("0", times = full_length - nchar(x[i])), collapse = ""))
   return(as.numeric(x))
}
coords[, latitude := adding_zeroes(gsub("\\.", "", latitude), full_length = 7L)]
coords[, longitude := adding_zeroes(gsub("\\.", "", longitude), full_length = 6L)]
sp::coordinates(coords) <- ~longitude+latitude
sp::proj4string(coords) <- sp::CRS(SRS_string = 'EPSG:27571')
coords <- sp::spTransform(x = coords, CRSobj = sp::CRS(SRS_string = 'EPSG:4326'))
coords <- data.table::as.data.table(coords)


## deleting sites sampled only once
ddata[, local := gsub("[^0-9]", "", local)]
ddata <- ddata[unique(ddata[, .(year, local)])[, count := length(unique(year)), by = .(local)][count > 1L], on = c("year", "local")] # selection by data.table joint


## melting species
ddata <- data.table::melt(ddata,
  id.vars = c("year", "local", "effort", "longitude", "latitude"),
  measure.vars = 10L:23L,
  variable.name = "species",
  na.rm = TRUE
)

ddata <- ddata[value != 0 & species != "Lhv &"]

tax <- data.table::as.data.table(
  data.table::tstrsplit(
    x = data.table::tstrsplit(
      x = "Ao - Alytes obstetricans, Bb - Bufo bufo, Ec - Epidalea calamita, Ha - Hyla arborea, Ia - Ichthyosaura alpestris, Lh - Lissotriton helveticus, Lv - Lissotriton vulgaris, Pp - Pelodytes punctatus, Pe - Pelophylax kl. esculentus, Ra - Rana arvalis, Rt - Rana temporaria, Ss - Salamandra salamandra, Tc - Triturus cristatus",
      split = ", "
    ),
    split = " - "
  )
)

ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Western Pas de Calais, France",
  species = tax$V2[match(species, tax$V1)],

  metric = "pa",
  unit = "pa"
)]

# coords <- unique(ddata[, .(local, year, latitude, longitude)])
# sp::coordinates(coords) <- ~longitude+latitude
# # sp::proj4string(coords) <- sp::CRS(SRS_string = 'EPSG:27561') # deprecated, replaced by 27571
# sp::proj4string(coords) <- sp::CRS(SRS_string = 'EPSG:27571')
# coords <- sp::spTransform(x = coords, CRSobj = sp::CRS(SRS_string = 'EPSG:4326'))
# coords <- data.table::as.data.table(coords)



meta <- unique(ddata[, .(dataset_id, regional, local, year)])
# meta <- merge(meta, coords)
meta[, ":="(
  taxon = "Herpetofauna",
  realm = "Terrestrial",


  study_type = "resurvey",
  effort = 1L,

  data_pooled_by_authors = TRUE,
  data_pooled_by_authors_comment = "Sampling was repeated and pooled in the 1970s and 2010s. Number of visits per period per pound varies but the authors claim sample effort is ‘roughly’ equal in each period",
  sampling_years = c("1974, 1975", "1992", "2011, 2012")[match(year, c(1975, 1992, 2012))],

  latitude = 50.77,
  longitude = 1.946,

  alpha_grain = 100L,
  alpha_grain_unit = "m2",
  alpha_grain_type = "lake_pond",
  alpha_grain_comment = "maximal area estimated from pictures in Appendix 1",

  gamma_bounding_box = 300L,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "functional",
  gamma_bounding_box_comment = "given by the authors",

  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "lake_pond",
  gamma_sum_grains_comment = "sum of the areas of ponds sampled each year",

  comment = "Extracted from Arntzen, J.W., Abrahams, C., Meilink, W.R.M. et al. Amphibian decline, pond loss and reduced population connectivity under agricultural intensification over a 38 year period. Biodivers Conserv 26, 1411–1430 (2017). https://doi.org/10.1007/s10531-017-1307-y Appendix 2. Only sites sampled at least during 2 time periods were kept. In the 70s, sampling was repeated in 1974 and 1975, and in the 2010s, sampling was repeated in 2011 and 2012. Pelophylax kl. esculentus was only deteted in samples that we excluded. Species code 'Lhv &' not being clearly described as Lissotriton helveticus OR Lissotriton vulgaris, this taxa was excluded. The authors consider the effort to be comparable through time. Methods: 'A typical site visit to each pond included a search for amphibian eggs and embryos, dip netting for larvae and aquatic adults and a search of the terrestrial habitat in the vicinity. Evening and nightly visits were made to find amphibians by torching (mostly adults) and to detect anuran species from their mating call.[...]Single observations and count data in the field were recoded as presence/absence data for each pond.' ",
  comment_standardisation = "Undetermined taxon and sites sampled only once were excluded"
)][, gamma_sum_grains := 100L * length(unique(local)), by = year]

ddata[, effort := NULL]
ddata[, c("longitude", "latitude") := NULL]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
