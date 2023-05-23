## lightfoot_2022
dataset_id <- "lightfoot_2022"

ddata <- base::readRDS("data/raw data/lightfoot_2022/rdata.rds")
#data extraction
# Fix any interval or ratio columns mistakenly read in as nominal and nominal columns read as numeric or dates read as strings
# attempting to convert ddata$date dateTime string to R date structure (date or POSIXct)
tmpDateFormat <- "%Y-%m-%d"
tmp1date <- as.Date(ddata$date,format = tmpDateFormat)
# Keep the new dates only if they all converted correctly
if (length(tmp1date) == length(tmp1date[!is.na(tmp1date)])) {ddata$date <- tmp1date } else {print("Date conversion failed for ddata$date. Please inspect the data and do the date conversion yourself.")}
rm(tmpDateFormat,tmp1date)
if (class(ddata$zone) != "factor") ddata$zone <- as.factor(ddata$zone)
if (class(ddata$site) != "factor") ddata$site <- as.factor(ddata$site)
if (class(ddata$plot) != "factor") ddata$plot <- as.factor(ddata$plot)
if (class(ddata$pit) != "factor") ddata$pit <- as.factor(ddata$pit)
if (class(ddata$spp) != "character") ddata$spp <- as.character(ddata$spp)

# Convert Missing Values to NA for non-dates

ddata$plot <- as.factor(ifelse((trimws(as.character(ddata$plot)) == trimws("NA")), NA, as.character(ddata$plot)))
ddata$pit <- ifelse((trimws(as.character(ddata$pit)) == trimws("NA")), NA, ddata$pit)
suppressWarnings(ddata$pit <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(ddata$pit)) == as.character(as.numeric("NA"))), NA, ddata$pit))


#Exclude:
#-opened for two consecutive weeks every month for the period 16 June 1989 to 23 August 1991. Beginning after August 1991, traps were opened for two consecutive weeks quarterly: in February-March (following winter NPP measurements), in May-June (following spring NPP), in August, and in October-November (following fall NPP).
#-> reduce data to October, November, August, Februar, March, May, June
#- M-NORT grid installed 03/03/1995. Moved from M-RABB-C site. -exclude what?
#-G-SUMM grid installed 06/06/1995. Moved from G-IBPE-A site
# exclude double plots


# Standardisation ----
data.table::setnames(ddata, c("zone","spp"), c("local","species"))
ddata[, local := paste(local, site, plot, sep = "_")][, year := as.factor(format(date, "%Y"))]
## in 2005 and 2006, all empty pits were coded as pit 0, even if several pits were empty? this would lead to a significant underestimation of effort and we decide to exclude 2005 and 2006 entirely. ----
ddata <- ddata[!year %in% 2005L:2006L]
## exclude subsampled sites ----
ddata <- ddata[!is.na(plot)] #remove NA, I6-unknown location in site M-RABB
ddata <- ddata[!(site == 'SAND' & plot == 'C') & !(site == 'RABB' & plot == 'C') & !(site == 'IBPE' & plot == 'C')] # remove plots uncomplete in time - reduce to 1 plot
## resample individuals, based on the total abundance in the smallest sampling effort ----
### computing effort ----
ddata[, pit_ID := .GRP, by = .(local, pit)][, effort := length(unique(date)), by = .(year, local, pit_ID)][, effort := sum(effort), by = .(year, local)] # Effort is the minimal number of sampling operations ie the number of pitfall traps * the number of dates per local per year.


### pooling pits and dates ----
ddata <- ddata[, .(value = .N, effort = unique(effort)), by = .(year, local, species)]
### computing min total abundance for the local/year where the effort is the smallest ----
ddata[, sample_size := sum(value), by = .(local, year)]
min_sample_size <- ddata[effort == min(effort), min(sample_size)]
### resampling ----
source("./R/functions/resampling.r")
set.seed(42)
ddata[sample_size > min_sample_size, value := resampling(species, value, min_sample_size), by = .(local, year)]
ddata[sample_size < min_sample_size, value := resampling(species, value, min_sample_size, replace = TRUE), by = .(local, year)]
ddata <- ddata[!is.na(value)]

# communities ----
ddata[, ":="(
   dataset_id = dataset_id,

   regional = "Jornada Basin",

   metric = "abundance",
   unit = "count",

   sample_size = NULL,
   effort = NULL
)]


# metadata ----
meta <- unique(ddata[, .(dataset_id, year, regional, local)])
meta[, ":="(
   realm = "Terrestrial",
   taxon = "Herpetofauna",

   latitude = '32°40`08.4000"N',
   longitude = '106°51`54.0000"W',

   study_type = "ecological_sampling", #two possible values, or NA if not sure

   data_pooled_by_authors = FALSE,
   data_pooled_by_authors_comment = NA,
   sampling_years = NA,

   effort = 14L, # Effort is the minimal number of sampling operations ie the number of pitfall traps * the number of dates per local per year

   alpha_grain = pi*(15/2)^2,  #size/area of individual trap
   alpha_grain_unit = "cm2", #"acres", "ha", "km2", "m2", "cm2"
   alpha_grain_type = "trap",
   alpha_grain_comment = "15 cm2 diameter pitfall traps",

   gamma_bounding_box = 120L, #size of biggest common scale can be different values for different areas per region
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "box",
   gamma_bounding_box_comment = "complete area in which the 11 plots are located",

   gamma_sum_grains_unit = "cm2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "Each grid consisted of 4 x 4 rows of traps spaced at 15 meter intervals",

   comment = "Data extracted from EDI repository https://portal.edirepository.org/nis/mapbrowse?scope=knb-lter-jrn&identifier=210007001&revision=38 . The authors captured, marked and recaptured lizards in 4 zones, 2 to 3 plots per zone and a 4*4 grid of pitfal traps. Data is provided at the individual level per pitfall trap and we applied standardisation(described in comment_standardisation). Effort is the minimal number of sampling operations ie the number of pitfall traps * the number of dates per local per year.",
   comment_standardisation = "data from 2005 and 2006 are excluded because empty pits are underestimated. only sites resampled in the 2000s are included. because effort varies: varying number of traps and varying number of sampling events per year, individuals are resampled down to the minimal number of captured individuals among the least intensively sampled years i.e. 12 individuals.",
   doi = 'https://doi.org/10.6073/pasta/51814fa39f87aea44629a5be8602ec49'
)][, gamma_sum_grains := alpha_grain * effort]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
   row.names = FALSE
)
data.table::fwrite(
   meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
   row.names = FALSE
)
