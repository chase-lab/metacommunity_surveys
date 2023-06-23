# edgar_2022_fish ----
dataset_id <- "edgar_2022_fish"
# reading the data ----
## Data were downloaded by hand from the online repository
ddata <- data.table::fread(
   file = "data/cache/edgar_2022_fish/IMOS_-_National_Reef_Monitoring_Network_Sub-Facility_-_Global_reef_fish_abundance_and_biomass.csv",
   skip = 69, header = TRUE, sep = ",",
   stringsAsFactors = TRUE,
   select = c("class","location","survey_date","site_code","latitude","longitude","method","species_name","total")
)

# Communities ----
## standardisation ----
### subsetting ----
### subsetting fish
### subsetting standardised method 1
### subsetting locations/regions with 4 sites/local scale samples or more.
ddata <- ddata[data.table::like(vector = class, pattern = "Actinopterygii|Elasmobranchii", fixed = FALSE) & method == 1L][
   ddata[,
         length(unique(site_code)),
         by = location][V1 >= 4L][, V1 := NULL],
   on = .(location)
][, c("class", "method") := NULL]

# subsetting one sample per year from the most sampled months
ddata[, ':='(year = as.integer(format(survey_date, "%Y")), month = format(survey_date, "%m"))]
month_order <- table(unique(ddata[,.(location, site_code, year, month, survey_date)])$month)
ddata <- ddata[
   unique(ddata[, .(
      location, site_code,
      year, month,
      month_order = order(month_order, decreasing = TRUE)[data.table::chmatch(month, names(month_order))],
      survey_date)]
      )[order(month_order)
        ][, .SD[1L], by = .(location, site_code, year) # first sampling from the most frequently sampled month
          ][, c('month_order', 'month') := NULL],
   on = .(location, site_code, survey_date)
]

### pooling species ----
ddata <- ddata[, .(value = sum(total)), by = .(regional = location, local = site_code, year, latitude, longitude, species = species_name)]

## ddata format ----
ddata[, ':='(
   dataset_id = dataset_id,
   metric = 'abundance',
   unit = 'count')]


# Metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, latitude, longitude)])
meta[, ":="(
   realm = "Marine",
   taxon = "Fish",

   effort = 1L,

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = 250L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "transect",
   alpha_grain_comment = "5m wide50m long transects",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "transect",
   gamma_sum_grains_comment = "number of transects per year per region * 250m2",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment = "Methods: 'This dataset contains records of bony fishes and elasmobranchs collected by Reef Life Survey (RLS) and Australian Temperate Reef Collaboration (ATRC) divers and partners along 50m transects on shallow rocky and coral reefs using standard methods. Abundance information is available for all species recorded within quantitative survey limits (50 x 5 m swathes either side of the transect line, each distinguished as a 'Block'), with size and biomass data also included when available. These observations form the Method 1 component of the surveys' ",
   comment_standardisation = "Only fish (Bony + cartilagenous), only method 1, only regions with at least 4 sites, when there are several samplings a year, only the first sample from the most frequently sampled month.",
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
