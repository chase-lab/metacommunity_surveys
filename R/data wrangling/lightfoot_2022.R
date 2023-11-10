dataset_id <- "lightfoot_2022"

#data extraction
ddata <- base::readRDS("data/raw data/lightfoot_2022/rdata.rds")

# Fix any interval or ratio columns mistakenly read in as nominal and nominal columns read as numeric or dates read as strings
# attempting to convert ddata$date dateTime string to R date structure (date or POSIXct)
tmp1date <- data.table::as.IDate(ddata$date, format = "%Y-%m-%d")
# Keep the new dates only if they all converted correctly
if (length(tmp1date) == length(tmp1date[!is.na(tmp1date)])) {ddata$date <- tmp1date } else {print("Date conversion failed for ddata$date. Please inspect the data and do the date conversion yourself.")}

if (class(ddata$zone) != "factor") ddata$zone <- as.factor(ddata$zone)
if (class(ddata$site) != "factor") ddata$site <- as.factor(ddata$site)
if (class(ddata$plot) != "factor") ddata$plot <- as.factor(ddata$plot)
if (class(ddata$pit) != "factor") ddata$pit <- as.factor(ddata$pit)
if (class(ddata$spp) != "character") ddata$spp <- as.character(ddata$spp)

##Convert Missing Values to NA for non-dates ----
ddata$plot <- as.factor(ifelse((trimws(as.character(ddata$plot)) == trimws("NA")), NA, as.character(ddata$plot)))
ddata$pit <- ifelse((trimws(as.character(ddata$pit)) == trimws("NA")), NA, ddata$pit)
suppressWarnings(ddata$pit <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(ddata$pit)) == as.character(as.numeric("NA"))), NA, ddata$pit))

#Raw Data ----

data.table::setnames(ddata, old = c("zone", "spp"), new = c("local", "species"))
ddata[, local := paste0(local, "_", site, "_", plot,
                        data.table::fifelse(is.na(pit), "", paste0("_", pit))
)][, ":="(
   year = data.table::year(date),
   month = data.table::month(date),
   day = data.table::mday(date))]

## Community data ----
### Pooling individuals together ----
ddata <- ddata[, .(value = .N), keyby = .(local, site, plot, pit,
                                          year, month, day, date, species)]

ddata[, ":="(
   dataset_id = dataset_id,

   regional = "Jornada Basin",

   metric = "abundance",
   unit = "count"
)][species == "NONE", species := NA_character_]

# metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, month, day)])
meta[, ":="(
   realm = "Terrestrial",
   taxon = "Herpetofauna",

   latitude = '32°40`08.4000"N',
   longitude = '106°51`54.0000"W',

   study_type = "ecological_sampling", #two possible values, or NA if not sure

   data_pooled_by_authors = FALSE,

   alpha_grain = pi*(15/2)^2,  #size/area of individual trap
   alpha_grain_unit = "cm2", #"acres", "ha", "km2", "m2", "cm2"
   alpha_grain_type = "trap",
   alpha_grain_comment = "15 cm2 diameter pitfall traps",

   comment = "Data extracted from EDI repository https://portal.edirepository.org/nis/mapbrowse?scope=knb-lter-jrn&identifier=210007001&revision=38 . The authors captured, marked and recaptured lizards in 4 zones, 2 to 3 plots per zone and a 4*4 grid of pitfal traps. Data is provided at the individual level per pitfall trap.",
   comment_standardisation = "Individual level data (morpho, sex). Individuals counted to obtain abundances.",
   doi = 'https://doi.org/10.6073/pasta/51814fa39f87aea44629a5be8602ec49'
)]

##save data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata[, !c("date","site", "plot", "pit")],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8"
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE, sep = ",", encoding = "UTF-8"
)

#standardised Data ----
## Removing pit number from local name ----
ddata[, local := sub("_[0-9]{1,2}$", "", local)]

## in 2005 and 2006, all empty pits were coded as pit 0, even if several pits were empty? this would lead to a significant underestimation of effort and we decide to exclude 2005 and 2006 entirely. ----
ddata <- ddata[!year %in% 2005L:2006L]
## exclude subsampled sites ----
ddata <- ddata[!is.na(plot)] #remove NA, I6-unknown location in site M-RABB
ddata <- ddata[!(site == 'SAND' & plot == 'C') &
                  !(site == 'RABB' & plot == 'C') &
                  !(site == 'IBPE' & plot == 'C')] # remove plots incomplete in time - reduce to 1 plot

## resample individuals, based on the total abundance in the smallest sampling effort ----
### computing effort ----
ddata[, pit_ID := .GRP, keyby = .(local, pit)
][, effort := data.table::uniqueN(date), keyby = .(year, local, pit_ID)
][, effort := sum(effort), keyby = .(year, local)] # Effort is the minimal
# number of sampling operations ie the number of pitfall traps * the number of
# dates per local per year.

### pooling pits and dates ----
ddata <- ddata[, .(value = .N, effort = unique(effort)),
               keyby = .(dataset_id, regional, local, year, species, metric, unit)]

### excluding more empty traps
ddata <- ddata[species != "NONE"]

### computing min total abundance for the local/year where the effort is the smallest ----
ddata[, sample_size := sum(value), keyby = .(local, year)]
min_sample_size <- ddata[effort == min(effort), min(sample_size)]
ddata[, effort := NULL]

### resampling ----
ddata <- ddata[sample_size >= 10L]
source("R/functions/resampling.r")
set.seed(42)
ddata[
   i = sample_size > min_sample_size,
   j = value := resampling(species, value, min_sample_size),
   by = .(local, year)]
ddata[
   i = sample_size < min_sample_size,
   j = value := resampling(species, value, min_sample_size, replace = TRUE),
   by = .(local, year)]

ddata <- ddata[!is.na(value)][, sample_size := NULL]

while (ddata[, diff(range(year)) < 9L, by = .(regional, local)][, any(V1)] ||
       ddata[, data.table::uniqueN(local) < 4L, by = .(regional, year)][, any(V1)]) {
   ddata <- ddata[
      i = !ddata[, diff(range(year)) < 9L, by = .(regional, local)][(V1)],
      on = .(regional, local)
   ]
   ddata <- ddata[
      i = !ddata[, data.table::uniqueN(local) < 4L, by = .(regional, year)][(V1)],
      on = .(regional, year)
   ]
}
if (nrow(ddata) != 0L) {
   ##meta data ----
   ## Removing pit number from local name ----
   ddata[, local := sub("_[0-9]{1,2}$", "", local)]

   meta[, c("month", "day") := NULL]
   meta <- unique(meta[i = unique(ddata[, .(local, year)]),
                       on = .(local, year)])

   meta[, ":="(
      effort = 14L, # Effort is the minimal number of sampling operations ie the number of pitfall traps * the number of dates per local per year

      gamma_bounding_box = 120L, #size of biggest common scale can be different values for different areas per region
      gamma_bounding_box_unit = "km2",
      gamma_bounding_box_type = "box",
      gamma_bounding_box_comment = "complete area in which the 11 plots are located",

      gamma_sum_grains_unit = "cm2",
      gamma_sum_grains_type = "plot",
      gamma_sum_grains_comment = "Each grid consisted of 4 x 4 rows of traps spaced at 15 meter intervals",

      comment_standardisation = "data from 2005 and 2006 are excluded because empty pits are underestimated.
Only sites resampled in the 2000s are included.
Because effort varies: varying number of traps and varying number of sampling events per year,
individuals are resampled down to the minimal number of captured individuals among
the least intensively sampled years i.e. 10 individuals.
Samples with less than 10 individuals were excluded,
Effort is the minimal number of sampling operations ie the number of pitfall traps * the number of dates per local per year."
   )][, gamma_sum_grains := alpha_grain * effort, keyby = year]

   ##save standardiseddata ----
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
}
