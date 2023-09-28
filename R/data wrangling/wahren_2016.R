dataset_id <- "wahren_2016"

ddata <- data.table::fread(
   file = "data/raw data/wahren_2016/vltm_vegetation_monitoring_1947-2013_p821t990.csv")

#Raw Data ----
ddata[, species := paste(genus, species)]

##exclude: unknown lichen, moss, liverwort, rock, bare ground, no data, litter ----
ddata <- ddata[!grepl(pattern = "rock| litter|ground", x = species, ignore.case = TRUE)]
ddata_standardised <- data.table::copy(ddata)

## Pool alive and dead individuals ----
ddata <- ddata[, .(species = unique(species)), by = .(site, tr, point, year, date)]

## community data ----
ddata[, ":="(
   dataset_id = dataset_id,

   regional = "Pretty Valley",
   local = factor(paste(site, tr, point, sep = "_")),

   month = data.table::month(date),
   day = data.table::mday(date),

   value = 1L,
   metric = "pa",
   unit = "pa"
)][, c("site", "tr", "point", "date") := NULL]

## metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, month, day)])

meta[, ":="(
   realm = "Terrestrial",
   taxon = "Plants",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   latitude = "36°54'S",
   longitude =  "147°18'E",

   alpha_grain = pi * (.4 / 2) ^ 2,
   alpha_grain_unit = "cm2",
   alpha_grain_type = "plot",
   alpha_grain_comment = "Area of 1 4mm diameter steel nail used per point",

   comment = "Extracted from: https://datacommons.anu.edu.au/DataCommons/rest/display/anudc:5886?layout=def:display, data saved at raw data/wahren_2016, data download only possible with login, download not scripted",
   comment_standardisation = "Local is built as site _ transect _ point
Observations of dead and alive individuals are kept without differenciation. This informtion is given in the raw data.",
   doi = 'https://doi.org/10.25911/5c3ff778936da'
)]

##saving raw data tables ----
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

#Standardised Data ----
ddata <- ddata_standardised[grepl("OUT", site) & status == "L"][, status := NULL]

##exclude: unknown lichen, moss, liverwort, rock, bare ground, no data, litter ----
ddata <- ddata[!grepl(pattern = "no data|unknown", x = species, ignore.case = TRUE)]

## community data ----
data.table::setnames(ddata, old = c("site", "tr"), new = c("regional", "local"))
ddata[, ":="(
   dataset_id = dataset_id,

   value = 1L,

   metric = "pa",
   unit = "pa",

   date = NULL
)]

## Sample base standardisation ----
### Excluding transect-years with less than 10 points ----
ddata <- ddata[!ddata[, data.table::uniqueN(point) < 10L, by = .(year, regional, local)][(V1)],
               on = .(year, regional, local)]

### For transect-years with more than 10 points, random selection of 10 points ----
set.seed(42)
ddata <- ddata[
   ddata[, .(point = sample(unique(point), 10L, replace = FALSE)),
         by = .(year, regional, local)],
   on = .(year, regional, local, point)]
### Pooling ----
ddata <- ddata[, .(species = unique(species)), by = .(dataset_id, year,
                                                      regional, local,
                                                      value, metric, unit)]

### Excluding regions years with less than 4 sites ----
ddata <- ddata[
   !ddata[, data.table::uniqueN(local) < 4L, by = .(regional, year)][(V1)],
   on = .(regional, year)]

### Excluding sites that were not sampled at least twice 10 years apart ----
ddata <- ddata[
   !ddata[, diff(range(year)) < 9L, by = local][(V1)],
   on = .(local)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])

meta[, ":="(
   realm = "Terrestrial",
   taxon = "Plants",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   latitude = "36°54'S",
   longitude =  "147°18'E",

   effort = 10L,

   alpha_grain = 10L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "transect",
   alpha_grain_comment = "Approximate area of Pretty Valley transects as given by the authors",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "Sum area of the transects per year",

   gamma_bounding_box = 900L,
   gamma_bounding_box_unit = "m2",
   gamma_bounding_box_type = "ecosystem",
   gamma_bounding_box_comment = "plot area provided by the authors",

   comment = "Extracted from: https://datacommons.anu.edu.au/DataCommons/rest/display/anudc:5886?layout=def:display, data saved at raw data/wahren_2016, data download only possible with login, download not scripted",
   comment_standardisation = "Unidentified species and rock covers were excluded.
PV_IN_G the site inside the enclosure was not kept.
Transect-years with less than 10 points were excluded.
Transect-years with more than 10 points, random selection of 10 points.",
   doi = 'https://doi.org/10.25911/5c3ff778936da'
)][, gamma_sum_grains := sum(alpha_grain), by = .(regional, year)]

##saving standardised data tables ----
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
