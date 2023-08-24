dataset_id <- "wright_2021"

ddata <- data.table::fread(
   file = "./data/raw data/wright_2021/SEVBeeData2002-2019.csv",
   sep = ",", quote = '"', header = TRUE,
   drop = "direction"
)
taxo <- data.table::fread(
   file = "./data/raw data/wright_2021/SEVBeeSpeciesList2002-2019.csv",
   sep = ",", quote = '"', header = TRUE,
   select = c("code", "genus", "species", "author")
)

# Raw data ----
ddata <- ddata[!(is.na(start_date) | is.na(end_date))]

# melting species
variable_list <- c("year", "month","start_date", "end_date", "complete_sampling_year",
                   "complete_sampling_month", "ecosystem", "transect","color")
species_list <- colnames(ddata)[!names(ddata) %in% variable_list]
# replace all 0 values by NA
ddata[, (species_list) := lapply(
   .SD,
   function(column) base::replace(column, column == 0L, NA_integer_)),
   .SDcols = species_list]

ddata <- data.table::melt(
   ddata,
   id.vars = variable_list,
   measure.vars = species_list,
   variable.name = "code",
   na.rm = TRUE
)

ddata[taxo, species := paste(i.genus, i.species), on = "code"][, code := NULL]

#rename: regional - ecosystem , local - transect
ddata <- data.table::setnames(
   ddata,
   old = c("ecosystem", "transect"),
   new = c("regional", "local")
)

ddata[, ":="(
   start_date = as.integer(start_date),
   end_date = as.integer(end_date)
)][, date := data.table::as.IDate(apply(data.frame(start_date, end_date), 1, mean))
][, c("start_date", "end_date") := NULL]

## communities ----
ddata[, ":="(
   dataset_id = dataset_id,

   regional = c("plain grasslands", "desert shrubland", "desert grassland")[data.table::chmatch(regional, c("B", "C", "G"))],
   local = factor(paste(local, color, sep = "_")),

   year = data.table::year(date),
   month = data.table::month(date),
   day = data.table::mday(date),

   metric = "abundance",
   unit = "count",

   color = NULL,
   date = NULL
)]

## metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, month, day)])
meta[, ":="(
   taxon = "Invertebrates",
   realm = "Terrestrial",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   latitude = c(34.3364, 34.3329, 34.3362)[data.table::chmatch(regional, c("plains grasslands", "desert shrubland", "desert grassland"))],
   longitude = c(-106.6345, -106.7358, -106.7212)[data.table::chmatch(regional, c("plains grasslands", "desert shrubland", "desert grassland"))],

   alpha_grain = pi * (1.4 / 2)^2,
   alpha_grain_unit = "m2",
   alpha_grain_type = "trap",
   alpha_grain_comment = "area of funnel trap opening. 2 traps per transect.",

   comment = "Extracted from Wright et al EDI repository 	knb-lter-sev.321.2 doi:10.6073/pasta/cbe04a94b5f6f3859a3d9c98f5be0fc8 . Bee abundances were summed per year per transect. Methods: 'We focused on three major ecosystem types: Chihuahuan Desert shrubland, which is dominated by creosote bush (Larrea tridentata), Chihuahuan Desert grassland, which is dominated by black grama grass (Bouteloua eriopoda (Torr.) Torr.), and Plains grassland, which is dominated by blue grama grass (Bouteloua gracilis (Willd. Ex Kunth) Lag. Ex Griffiths). In our study, the two Chihuahuan Desert sites were separated by ~2 km; the Plains grassland site was ~10 km from the Chihuahuan Desert sites.[...] Bees were sampled along five transects located within each of the three focal ecosystem types. To sample bees, we installed one passive funnel trap at each end of five 200 m transects/site. Each trap consisted of a 946 mL paint can filled with ~275 mL of propylene glycol and topped with a plastic automotive funnel with the narrow part of the funnel sawed off (funnel height = 10 cm, top diameter = 14 cm, bottom diameter = 2.5 cm. The funnels’ interiors were painted with either blue or yellow fluorescent paint (Krylon, Cleveland, OH or Ace Hardware, Oak Brook, IL). On each transect, we randomly assigned one trap to be blue and the other to be yellow (total across the three sites: N = 30 traps, with 15 traps/color). Each trap was placed on a 45 cm high platform that was surrounded by a 60 cm high chicken wire cage to prevent wildlife and wind disturbance. Funnel traps provide a measure of bee activity, not a measure of presence, and may be biased by bee taxon and sociality. From 2002 to 2014, bees were sampled each month from March through October' IMPORTANT the authors warn that the abundance values they report should be considered as proxies of bee activity, not relative importance.",
   comment_standardisation = "none needed",
   doi = 'https://doi.org/10.6073/pasta/cbe04a94b5f6f3859a3d9c98f5be0fc8'
)]

##saving data tables ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata[, !c("complete_sampling_month", "complete_sampling_year")],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)

# Standardised Data ----
## Removing trap color name from local column ----
ddata[, c("local","color") := data.table::tstrsplit(local, "_")]
meta[, local := sub("_.*$", "", local, FALSE, TRUE)]

## selecting data with complete_sampling_year & complete_sampling_month = 1 ----
ddata <- ddata[complete_sampling_year == 1L & complete_sampling_month == 1L]
ddata[, c("complete_sampling_year", "complete_sampling_month") := NULL]

## selecting months with both types of traps equally sampled ----
set.seed(42)
ddata[, sampleID := .GRP, by = .(regional, local, month, day, color)]
ddata <- ddata[
   ddata[, data.table::uniqueN(sampleID), by = .(regional, local, year, month)][V1 == 2L],
   on = .(regional, local, year, month)]
ddata <- ddata[
   ddata[, .(sampleID = sample(unique(sampleID), 2L, replace = FALSE)),
         by = .(regional, local, year, month)],
   on = .(regional, local, year, month, sampleID)
]


## we select 4 out of 7 most sampled momths ----
## When a site is sampled several times a year, selecting the 4 most frequently sampled month from the 7 sampled months ----
month_order <- ddata[, data.table::uniqueN(day), by = .(local, month)][, sum(V1), by = month][order(-V1)]
ddata[, month_order := (1L:7L)[match(month, month_order, nomatch = NULL)]]
data.table::setkey(ddata, month_order)

# Some years have less than 4 months so these year/local have to be excluded
ddata <- ddata[
   !ddata[, data.table::uniqueN(month), by = .(local, year)][V1 < 4L],
   on = .(local, year)]

ddata <- ddata[
   unique(ddata[, .(local, year, month)])[, .SD[1L:4L], by = .(local, year)],
   on = .(local, year, month)][, month_order := NULL][, month := NULL][, day := NULL]

### Pooling all samples from a year together ----
# ddata[, ":="(latitude = mean(latitude), longitude = mean(longitude)), by = .(regional, local)]
ddata <- ddata[, .(value = sum(value)),
               by = .(dataset_id, regional, local, year, species, metric, unit)]



## metadata ----
meta[, c("month", "day") := NULL]
meta <- unique(meta)
meta <- meta[unique(ddata[, .(regional, local, year)]),
                        on = .(regional, local, year)]

meta[, ":="(
   effort = 16L,

   gamma_sum_grains = (pi * (1.4 / 2)^2) * 2 * 5,
   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of trap areas per site",

   gamma_bounding_box = c(800L * 800L, 1400L * 400L, 1000L * 600L)[data.table::chmatch(regional, c("plains grasslands", "desert shrubland", "desert grassland"))],
   # gamma_bounding_box = 930, # 230 000 acres area of the Sevilleta National Wildlife Refuge
   gamma_bounding_box_unit = "m2",
   gamma_bounding_box_type = "box",
   gamma_bounding_box_comment = "coarse box measured on figS1 from https://doi.org/10.1038/s41598-020-57553-2",

   comment_standardisation = "only samples considered complete by the authors were kept.
Selecting months with both types of traps equally sampled
We select 4 out of 7 most sampled months
Pooling all samples from a year together the transect level."
)]

## saving data tables ----
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
