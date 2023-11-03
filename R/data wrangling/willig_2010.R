dataset_id <- "willig_2010"

ddata <- data.table::fread(
   file = "data/raw data/willig_2010/LFDPSnailCaptures.csv",
   sep = ",", header = TRUE, drop = c("UNKNOWN", "TOTABU", "COMMENTS")
)
data.table::setnames(ddata, new = tolower(colnames(ddata)))
data.table::setnames(ddata, old = "point", new = "local")

# Raw Data ----

# melting species aka wide to long format
for (i in 6L:ncol(ddata)) data.table::set(x = ddata, i = which(ddata[[i]] == 0L),
                                          j = i, value = NA_integer_)
ddata <- data.table::melt(data = ddata,
                          id.vars = c("year","season","run","local","date"),
                          variable.name = "species",
                          na.rm = TRUE
)

## community data ----
ddata <- ddata[date != ""]
ddata[, ":="(
   dataset_id = dataset_id,

   regional = "Luquillo Forest Dynamics Plot (LFDP)",

   local = factor(paste(local, run, sep = "_")),

   date = data.table::as.IDate(date, format = "%m/%d/%Y"),

   metric = "abundance",
   unit = "count",

   season = NULL
)][, ":="(
   month = data.table::month(date),
   day = data.table::mday(date),
   date = NULL
)]

## metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, month, day)])
meta[, ":="(
   taxon = "Invertebrates",
   realm = "Terrestrial",

   latitude = 18.3333,
   longitude = -65.8167,

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = pi * 3^2,
   alpha_grain_unit = "m2",
   alpha_grain_type = "plot",
   alpha_grain_comment = "circular quadrats",

   comment = "Extracted fron: https://doi.org/10.6073/pasta/45e3a90ed462f66acdde83636746f87f . 'One hundred sixty points were selected on the Hurricane Recovery Plot at El Verde. Circular quadrats (r = 3 m) were established at each point. From June 1991 to present, 40 points were sampled four times seasonally for the presence of Terrestrial snails[...]All surveys occurred between 19:30 and 03:00 hours to coincide with peak snail activity. Population densities were estimated as Minimum Number Known Alive (MNKA), the maximum number of individuals of each species recorded for a site in each season'  Standardisation: only the 1 sampling event per season per plot kept.",
   comment_standardisation = "None needed",
   doi = 'https://doi.org/10.6073/pasta/45e3a90ed462f66acdde83636746f87f'
)]

## saving data tables ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata[, !"run"],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)


# Standardised Data----
## Removing run name from local column ----
ddata[, local := sub("_.*$", "", local, perl = TRUE)]
meta[, local := sub("_.*$", "", local, perl = TRUE)]

# we want months with 2 or more runs
ddata <- ddata[
   i = !ddata[, j = data.table::uniqueN(run) < 2L,
              by = .(local, year, month)][(V1)],
   on = .(local, year, month)
]

set.seed(42)
# we randomly reduce the number of runs to two
ddata <- ddata[
   i = ddata[, j = .(run = sample(x = unique(run), size = 2L, replace = FALSE)),
             by = .(local, year, month)],
   on = .(local, year, month, run)
]

## When a site is sampled several times a year, selecting the most frequently sampled month from the 4 sampled months ----
month_order <- ddata[, data.table::uniqueN(day), by = .(local, month)][, sum(V1), by = month][order(-V1)]
ddata[, month_order := (1L:4L)[match(month, month_order, nomatch = NULL)]]
data.table::setkey(ddata, month_order)

ddata <- ddata[
   i = unique(ddata[, .(local, year, month)])[, .SD[1L], by = .(local, year)],
   on = .(local, year, month)][, month_order := NULL][, month := NULL][, day := NULL]

### Pooling all samples from a year together ----
# ddata[, ":="(latitude = mean(latitude), longitude = mean(longitude)), by = .(regional, local)]
ddata <- ddata[, .(value = sum(value)),
               keyby = .(dataset_id, regional, local, year, species, metric, unit)]

## Excluding sites that were not sampled at least twice 10 years apart ----
ddata <- ddata[
   i = !ddata[, diff(range(year)) < 9L, by = .(regional, local)][(V1)],
   on = .(regional, local)]

## Metadata ----
meta[, c("month","day") := NULL]
meta <- unique(meta)
meta <- meta[i = unique(ddata[, .(local, year)]),
             on = .(local, year)]

meta[, ":="(
   effort = 1L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of the areas of quadrats sampled each year",

   gamma_bounding_box = 16L,
   gamma_bounding_box_unit = "ha",
   gamma_bounding_box_type = "ecosystem",
   gamma_bounding_box_comment = "area of the LFDP given by the authors",

   comment_standardisation = "We want months with 2 or more runs.
We select 3 out of 4 most sampled momths.
Pooling all samples from a year together.
Sites that were not sampled at least twice 10 years apart were excluded."
)][, gamma_sum_grains := sum(alpha_grain), by = year]

##saving data tables ----
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
