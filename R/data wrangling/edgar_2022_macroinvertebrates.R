# edgar_2022_macroinvertebrates ----
dataset_id <- "edgar_2022_macroinvertebrates"
# reading the data ----
ddata <- base::readRDS("data/raw data/edgar_2022_macroinvertebrates/rdata.rds")

# Raw data ----
## Communities ----
### standardisation ----
#### Creating local at the block level
ddata[, local := as.factor(paste(site_code, block, sep = '_'))]
ddata[, ":="(
   year = data.table::year(survey_date),
   month = data.table::month(survey_date),
   day = data.table::mday(survey_date)
)]

#### pooling individual observations from the same species ----
ddata <- ddata[, .(value = sum(total)), by = .(regional = location, local,
                                               year, month, day,
                                               latitude, longitude,
                                               species = species_name)]

ddata[, ':='(
   dataset_id = dataset_id,

   metric = 'abundance',
   unit = 'count'
)][ species == "No species found", ":="(species = "NONE", value = 0L)]


## Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, month, day,
                         latitude, longitude)])
meta[, ":="(
   realm = "Marine",
   taxon = "Invertebrates",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = 50L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "transect",
   alpha_grain_comment = "1m wide 50m long transects",

   comment = "Methods: 'This dataset contains records of mobile macroinvertebrates collected by Reef Life Survey (RLS) and Australian Temperate Reef Collaboration (ATRC) divers and partners along 50m transects on shallow rocky and coral reefs using standard methods. Abundance information is available for all species recorded within quantitative survey limits (50 x 1 m swathes either side of the transect line, each distinguished as a 'Block'), with divers searching the reef surface (including cracks) carefully for hidden invertebrates such as sea stars, urchins, gastropods, lobsters, crabs etc. These observations are recorded concurrently with the cryptobenthic fish observations and together make up the 'Method 2' component of the surveys. For this method, typically one 'Block' is completed per 50 m transect for the program ATRC and 2 blocks are completed for RLS' ",
   comment_standardisation = "Abundances of individual observations of different sizes were pooled together by species.",
   doi = 'https://doi.org/10.1016/j.biocon.2020.108855 | https://doi.org/10.1017/S0376892912000185'
)]

ddata[, c("latitude", "longitude") := NULL]

## Saving raw data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8"
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8"
)

# standardised data ----
## Community data ----
ddata[, c("month", "day") := NULL]

### excluding sites with abnormal null values
ddata <- ddata[!ddata[value == 0L], on = .(regional, local, year)]

### excluding locations/regions with less than 4 sites/local scale samples ----
ddata <- ddata[
   !ddata[, data.table::uniqueN(local) < 4L, by = .(regional, year)][(V1)],
   on = .(regional, year)]

ddata <- ddata[, .(value = sum(value)), by = .(dataset_id, regional, local, year,
                                               species, metric, unit)]

#### Subsetting sites samples at least 10 years apart ----
ddata <- ddata[
   !ddata[, diff(range(year)) < 9L, by = local][(V1)],
   on = 'local']

## metadata ----
meta[, c("month", "day") := NULL]
meta <- unique(meta[
   unique(ddata[, .(regional, local, year)]),
   on = .(regional, local, year)])

meta[, ":="(
   effort = 1L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "transect",
   gamma_sum_grains_comment = "number of transects per year per region * 50m2",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment_standardisation = "Abundances of individual observations of different sizes were pooled together by species.
Samples containing abnormal values were excluded.
Only regions with at least 4 sites sampled at least 10 years appart."
)][, ":="(gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6,
          gamma_sum_grains = sum(alpha_grain)),
   by = .(regional, year)]

## Saving standardised data ----
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
