# edgar_2022_macroinvertebrates ----
dataset_id <- "edgar_2022_macroinvertebrates"
# reading the data ----
## Data were downloaded by hand from the online repository
ddata <- data.table::fread(
   file = "data/cache/edgar_2022_macroinvertebrates/IMOS_-_National_Reef_Monitoring_Network_Sub-Facility_-_Global_mobile_macroinvertebrate_abundance.csv",
   skip = 69, header = TRUE, sep = ",",
   stringsAsFactors = TRUE,
   select = c("country","area","ecoregion","location","site_code","block","latitude","longitude","survey_date","program","species_name","total")
)

# Communities ----
## standardisation ----
### subsetting ----
### Creating local at the block level
ddata[, local := as.factor(paste(site_code, block, sep = '_'))]
### Subsetting sites samples at least 10 years appart
ddata[, year := data.table::year(survey_date)]
ddata <- ddata[ddata[, diff(range(year)) >= 9L, by = local][(V1)][, local], on = 'local']
### subsetting locations/regions with 4 sites/local scale samples or more.
ddata <- ddata[ddata[, data.table::uniqueN(local) >= 4L, by = .(location)][(V1)][, location], on = 'location']

### pooling species ----
ddata <- ddata[, .(value = sum(total)), by = .(regional = location, local, year, latitude, longitude, species = species_name)]

## ddata format ----
ddata[, ':='(
   dataset_id = dataset_id,
   metric = 'abundance',
   unit = 'count')]


# Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, latitude, longitude)])
meta[, ":="(
   realm = "Marine",
   taxon = "Invertebrates",

   effort = 1L,

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = 50L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "transect",
   alpha_grain_comment = "1m wide 50m long transects",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "transect",
   gamma_sum_grains_comment = "number of transects per year per region * 50m2",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment = "Methods: 'This dataset contains records of mobile macroinvertebrates collected by Reef Life Survey (RLS) and Australian Temperate Reef Collaboration (ATRC) divers and partners along 50m transects on shallow rocky and coral reefs using standard methods. Abundance information is available for all species recorded within quantitative survey limits (50 x 1 m swathes either side of the transect line, each distinguished as a 'Block'), with divers searching the reef surface (including cracks) carefully for hidden invertebrates such as sea stars, urchins, gastropods, lobsters, crabs etc. These observations are recorded concurrently with the cryptobenthic fish observations and together make up the 'Method 2' component of the surveys. For this method, typically one 'Block' is completed per 50 m transect for the program ATRC and 2 blocks are completed for RLS' ",
   comment_standardisation = "Only regions with at least 4 sites sampled at least 10 years appart.",
   doi = 'https://doi.org/10.1016/j.biocon.2020.108855 | https://doi.org/10.1017/S0376892912000185'
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
