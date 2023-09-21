dataset_id <- "van-cleve_2021"

ddata <- base::readRDS("data/raw data/van-cleve_2021/rdata.rds")
data.table::setnames(ddata, new = tolower(colnames(ddata)))
data.table::setnames(ddata, old = "site", new = "local")

# Raw Data ----
ddata[, ":="(
   species = tolower(trimws(species)),

   year = data.table::year(date),
   month = data.table::month(date),
   day = data.table::mday(date)
)]

## pooling individuals together -----
ddata <- ddata[, .(value = .N), by = .(year, month, day, local, plot, species)
][!is.na(species) & !species %in% c("", "?", "notrees", "nd")]

## community data ----

ddata[, ":="(
   dataset_id = dataset_id,

   regional = "Bonanza Creek LTER",
   local = factor(paste(local, plot, sep = "_")),

   species = factor(c(
      "Picea mariana", "Picea glauca",
      "Picea sp.", "Populus balsamifera",
      "Populus tremuloides", "Betula neoalaskana",
      "Larix laricina"))[data.table::chmatch(species, c(
         "picmar", "picgla",
         "picea", "popbal",
         "poptre", "betneo",
         "larlar"))],

   metric = "abundance",
   unit = "count"
)]

## metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, month, day)])

meta[, ":="(
   realm = "Terrestrial",
   taxon = "Plants",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   latitude = mean(c(66.2655, 63.6958)),
   longitude = mean(c(-144.332, -150.4031)),

   alpha_grain = 1200L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "plot",
   alpha_grain_comment = "sum of the 12 10*10m plots per site",

   comment = "Extracted from EDI repository knb-lter-bnz.320.23 https://doi.org/10.6073/pasta/93067176968c707ac8491ce98b3c9dca . Authors publish forest past and ongoing results from forest community samplings and individual tree DBH measures. Authors provided species codes only and Species scientific names were assumed.",
   comment_standardisation = "Individual observations, with DBH measuremnt were pooled to get species abundances.",
   doi = 'https://doi.org/10.6073/pasta/93067176968c707ac8491ce98b3c9dca | https://doi.org/10.1002/hyp.14251'
)]

## saving eaw data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata[, !c("plot")],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)

# Standardised Data ----
## Removing sector name from local column ----
ddata[, local := gsub("_.*$", "", local, FALSE, TRUE)]
meta[, local := gsub("_.*$", "", local, FALSE, TRUE)]

## pooling dates -----
## keeping only the first sampling event per site, plot, year
## COMMENTED OUT because those are sampling events spread on 2 (and in some rare instances 3) consecutive days
# ddata <- ddata[unique(ddata[, .(local, plot, year, date)])[, .SD[1L,], by = .(local, plot, year)], on = .(site, plot, year, date)]

## pooling plots ----
## deleting sites with less than 12 plots
ddata <- ddata[
   ddata[,
         .(`12_sites_or_more` = data.table::uniqueN(plot) >= 12L),
         by = .(local, year)][(`12_sites_or_more`)],
   on = .(local, year)]

## reducing number of plots to 12 in oversampled sites ----
set.seed(42L)
ddata <- ddata[
   ddata[,
         .(plot = unique(plot)[sample(seq_len(data.table::uniqueN(plot)), 12L)]),
         by = .(local, year)],
   on = .(local, plot, year)][, `12_sites_or_more` := NULL]

## Randomly selecting 1 date per plot per local per year ----

## When a site is sampled several times a year, selecting the 1 most frequently sampled month from the 4 sampled months ----
month_order <- ddata[, data.table::uniqueN(day), by = .(local, month)][, sum(V1), by = month][order(-V1)]
ddata[, month_order := (1L:4L)[match(month, month_order, nomatch = NULL)]]
data.table::setkey(ddata, month_order)

ddata <- ddata[
   unique(ddata[, .(local, year, month)])[, .SD[1L], by = .(local, year)],
   on = .(local, year, month)][, month_order := NULL]

## When a site is sampled twice a month, selecting the first visit ----
ddata <- ddata[
   unique(ddata[, .(local, year, month, day)])[, .SD[1L], by = .(local, year, month)],
   on = .(local, year, month, day)][, month := NULL][, day := NULL]

### Pooling all samples from a year together ----
ddata <- ddata[, .(value = sum(value)),
               by = .(dataset_id, regional, local, year, species, metric, unit)]

## Excluding sites that were not sampled at least twice 10 years apart ----
ddata <- ddata[!ddata[, diff(range(year)) < 9L, by = .(regional, local)][(V1)],
               on = .(regional, local)]

## Metadata ----
meta[, c("month","day") := NULL]
meta <- unique(meta)
meta <- meta[
   unique(ddata[, .(local, year)]),
   on = .(local, year)]

meta[, ":="(
   effort = 12L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "number of sites per year * 1200m2",

   gamma_bounding_box = 50L,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "ecosystem",
   gamma_bounding_box_comment = "area of the Bonanza Creek Experimental Forest",

   comment_standardisation = "Standardisation: number of sampling events per year per plot reduced to 1 and number of plots per site per year reduced to 12 then all plots from a year and site were pooled together and abundances summed.
Sites that were not sampled at least twice 10 years apart were excluded."
)][, gamma_sum_grains := sum(alpha_grain), by = year]

## saving standardised data ----
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
