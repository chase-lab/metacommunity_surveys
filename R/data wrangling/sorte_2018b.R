## sorte_2018b - mobile invertebrates

dataset_id <- "sorte_2018b"
ddata <- base::readRDS(file = "data/raw data/sorte_2018/ddata.rds")[taxon == "Invertebrates"]

# Data preparation ----
ddata[, date := data.table::as.IDate(date)
][, ":="(
   year = data.table::year(date),
   month = data.table::month(date),
   day = data.table::mday(date)
)]

# Raw Data ----

## community data ----
ddata[, ":="(
   dataset_id = dataset_id,

   regional = "Gulf of Maine",
   local = factor(data.table::fcase(
      is.na(`Transect #`), paste0(local, "_", `Tide Height`, "_",
                                  "q", `Quadrat #`),
      is.na(`Quadrat #`), paste0(local, "_", `Tide Height`, "_",
                                 "t", `Transect #`),
      !is.na(`Transect #`) & !is.na(`Quadrat #`), paste0(local, "_", `Tide Height`, "_",
                                                         "t", `Transect #`, "_", "q", `Quadrat #`)
   )),
   beach = local,

   metric = "abundance",
   unit = "count",

   period = NULL,
   taxon = NULL,
   date = NULL
)]


##meta data ----
meta <- unique(ddata[, .(dataset_id, regional, local, beach, year, month, day)])

env <- base::readRDS(file = "data/raw data/sorte_2018/env.rds")
data.table::setnames(env, old = "local", new = "beach")
meta[
   env,
   ":="(latitude = i.latitude, longitude = i.longitude),
   on = .(beach)]

meta[, ":="(
   realm = "Marine",
   taxon = "Invertebrates",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = .25,
   alpha_grain_unit = "m2",
   alpha_grain_type = "quadrat",
   alpha_grain_comment = "Ten 0.25-m2 quadrats per 30m transect",

   comment = "Extracted from Sorte et al 2018 Supplementary (https://onlinelibrary.wiley.com/doi/full/10.1111/gcb.13425). Authors compiled historical records from the 1970s in 4 beaches and sampled algae and both fixed and mobile invertebrates in quadrats along horizontal transects (parallel to the shore) in the tidal zone. In sorte_2018b, we included observations of mobile organisms. Methodology and effort from historical and recent records are comparable.
Regional is the Gulf of Maine, local a beach _ Tide height _ transect number _ quadrat number. Effort depends on the period. In the 70s, samples are at the quadrat level while modern ones are pooled at the transect level.",
   comment_standardisation = "Local is built as Beach name _ Tide Height _ t transect number _ q quadrat number",
   doi = 'https://doi.org/10.1111/gcb.13425',

   beach = NULL
)]

ddata[, beach := NULL]


## save raw data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata[, !c("Quadrat #","Transect #","Tide Height")],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)

# Standardised Data ----
## selecting sites ----
ddata[, c("regional", "local") := base::sub("_.*$", "", local)]
meta[, c("regional", "local") := base::sub("_.*$", "", local)]

## selecting data ----
ddata <- ddata[`Tide Height` %in% c("0", "1", "2", "Low", "Mid", "High") &
                  `Transect #` %in% c("1", "3", "5") &
                  !is.na(`Transect #`) &
                  !is.na(value) &
                  value != 0]

## Selecting transects with all 10 quadrats ----
ddata <- ddata[
   ddata[,
         data.table::uniqueN(`Quadrat #`),
         by = .(local, year, month, `Tide Height`, `Transect #`)][V1 == 1L | V1 == 10L],
   on = .(local, year, month, `Tide Height`, `Transect #`)
]

## Recoding Tide Height and local
ddata[, `Tide Height` := c(0L, 1L, 2L, 0L, 1L, 2L)[data.table::chmatch(
   `Tide Height`,
   c("0", "1", "2", "Low", "Mid", "High"))]
]

ddata[, local := factor(paste(`Tide Height`, `Transect #`, sep = "_"))][, c("Tide Height", "Transect #", "Quadrat #") := NULL]

# selecting years sampled more than 10 years apart
ddata <- ddata[
   ddata[, .(diff(range(year))), by = .(regional, local)][V1 >= 9L],
   on = .(regional, local)] # data.table style join

## we select 1 out of 8 most sampled momths ----
## When a site is sampled several times a year, selecting the 4 most frequently sampled month from the 8 sampled months ----
month_order <- ddata[, data.table::uniqueN(day), by = .(local, month)][, sum(V1), by = month][order(-V1)]
ddata[, month_order := (1L:8L)[match(month, month_order, nomatch = NULL)]]
data.table::setkey(ddata, month_order)

ddata <- ddata[
   unique(ddata[, .(local, year, month)])[, .SD[1L], by = .(local, year)],
   on = .(local, year, month)][, month_order := NULL][, month := NULL][, day := NULL]

## removing cover and fixing typos in species names ----
labs <- levels(ddata$species)
labs[grepl('%|percent', labs, fixed = FALSE, ignore.case = TRUE)] <- 'delete_me'
labs <- gsub(" egg capsules| egg masses|\\.+[0-9]+$", "", labs, fixed = FALSE)
data.table::setattr(ddata$species, 'levels', labs)

if (any(ddata$species == 'delete_me')) ddata <- ddata[species != 'delete_me']

### Pooling all samples from a year together and life stages ----
# ddata[, ":="(latitude = mean(latitude), longitude = mean(longitude)), by = .(regional, local)]
ddata <- ddata[, .(value = sum(value)),
               by = .(dataset_id, regional, local, year, species, metric, unit)]

## meta data----
meta[, c("month", "day") := NULL]
meta <- unique(meta)
meta <- unique(merge(x = meta, y = ddata[,.(regional, local, year)],
                     by.x = c("local", "year"), by.y = c("regional", "year"),
                     all.y = TRUE))

meta[, ":="(
   local = local.y,
   effort = 10L,

   gamma_sum_grains = .25 * 10,
   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "quadrat",
   gamma_sum_grains_comment = "10 quadrats per transect",

   gamma_bounding_box = 45L,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "shore",
   gamma_bounding_box_comment = "450 km length of shore of the Gulf of Maine covered by the sampling sites, estimated 1/10km wide",

   comment = "Extracted from Sorte et al 2018 Supplementary (https://onlinelibrary.wiley.com/doi/full/10.1111/gcb.13425). Authors compiled historical records from the 1970s in 4 beaches and sampled algae and both fixed and mobile invertebrates in quadrats along horizontal transects (parallel to the shore) in the tidal zone. In sorte_2018b, we included observations of mobile organisms. Methodology and effort from historical and recent records are comparable.
Regional is the beach name, local is a Tidal height _ transect number sample.",
comment_standardisation = "There are only 3 transects in some historical samples so only transects 1, 3 and 5 of all sites and years are kept.
Only quadrats at tide heights of Low, Mid and High (historical) or 0m, 1m, and 2m (modern) were kept.
`local` scale is built as Tide height _ Transect number.
Only `local` sites sampled at least 10 years appart are kept.
When a site is sampled several times a year, selecting the 4 most frequently sampled month from the 8 sampled months.
Cover values were turned into presence absence.",

local.y = NULL
)]

## save standardised data ----
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
