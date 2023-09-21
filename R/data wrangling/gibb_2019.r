## gibb_2019
dataset_id <- "gibb_2019"

ddata <- base::readRDS(paste0("data/raw data/", dataset_id, "/ddata.rds"))
env <- base::readRDS(paste0("data/raw data/", dataset_id, "/env.rds"))

# Raw data ----
## melting species ----
ddata <- data.table::melt(ddata, id.vars = "code", variable.name = "species")
ddata <- ddata[value > 0]

## merging ddata and env ----
ddata <- merge(ddata, env[, .(code, site, position, date)], all.y = TRUE)

## community data ----
ddata[, date := data.table::as.IDate(date, format = "%Y-%m-%d")]
ddata[, ":="(
   dataset_id = dataset_id,

   regional = "Main Camp area of the Ethabuka Reserve",
   local = paste(site, position, sep = "_"),

   year = data.table::year(date),
   month = data.table::month(date),
   day = data.table::mday(date),


   metric = "abundance",
   unit = "count",

   date = NULL,
   site = NULL,
   position = NULL
)]

## meta data ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, month, day)])
meta[, ":="(
   taxon = "Invertebrates",
   realm = "Terrestrial",

   latitude = "23°46'S",
   longitude = "138°28'E",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = pi * (5^2),
   alpha_grain_unit = "cm2",
   alpha_grain_type = "sample",
   alpha_grain_comment = "area of a single pitfall trap",

   comment = "Data extracted from dryad repo 10.5061/dryad.vc80r13. On each 1ha site, 2 invertebrate trap grids with 6 pitfall traps were set, one at the top and one at the bottom of the dune. In some site-year, two samplings occurred each year, one in spring, one in winter. Only spring samples were kept. In some cases pitfall traps were lost. Only site-year surveys where all pitfall traps were recovered were kept. The authors do not make clear that pitfall grids are accurately placed at the same spot over the years and sampling was annual or seasonal hence the 'ecological_sampling' categorisation. IMPORTANT in each 1ha site, each grid is considered separately: each local value is a grid meaning that independence between grids belonging to the same site should be taken into account.",
   comment_standardisation = "Deleting absences",
   doi = 'https://doi.org/10.5061/dryad.vc80r13 | https://doi.org/10.1111/1365-2656.13052'
)]

## Save raw data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata[, !"code"],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)

# Standardised data ----

## standardisation: 1) deleting winter samples and 2) selecting only surveys where all pitfall traps were recovered. ----
env[, Ngrids := .N, by = .(year, site)]
ddata <- ddata[
   env[season == "Spring" & no.traps == 6L & Ngrids == 2L, .(code)],
   on = .(code)]
ddata[, c("month", "day", "code") := NULL]

##meta data ----
meta[, c("month","day") := NULL]
meta <- unique(meta)
meta <- meta[
   unique(ddata[, .(local, year)]),
   on = .(local, year)
]
meta[, ":="(
   effort = 1L,

   gamma_sum_grains = pi * (0.05^2) * 6,
   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of the area of the 6 pitfall traps per grid",

   gamma_bounding_box = pi * (10^2),
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "ecosystem",
   gamma_bounding_box_comment = "'five sites within 10 km of 'Main Camp'",

   comment_standardisation = "1) deleting winter samples and 2) selecting only surveys where all pitfall traps were recovered."
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
