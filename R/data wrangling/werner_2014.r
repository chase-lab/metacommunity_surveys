dataset_id <- "werner_2014"
ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))

# Raw Data ----
data.table::setnames(ddata, "pond", "local")

#wide to long format
ddata <- data.table::melt(
   ddata,
   variable.name = "species",
   measure.vars = grep(colnames(ddata), pattern = "present"),
   measure.name = "value",
   na.rm = TRUE
)

## excluding  empty rows ----
ddata[, which(!colnames(ddata) %in% c("local", "year", "species", "value")) := NULL]
ddata <- ddata[value != 0L]

## community ----
ddata[, ":="(
   dataset_id = dataset_id,
   regional = "ES George Reserve",

   species = substr(species, 1L, 3L),
   metric = "pa",
   unit = "pa"
)]

## meta data ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
   realm = "Freshwater",
   taxon = "Herpetofauna",

   latitude = "42°28'N",
   longitude = "84°00'W",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = 200L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "lake_pond",
   alpha_grain_comment = "estimated area of individual ponds. The small ones are <100m2",

   comment = "Extracted from werner et al 2015 Dryad repo (https://datadryad.org/stash/dataset/doi:10.5061/dryad.js47k). Authors repeatedly sampled amphibian larvae. 'We estimated larval densities of 14 species of amphibians in 37 ponds on the University of Michigan’s E. S. George Reserve (hereafter ESGR) over 15 yrs (1996 to 2010).' Effort is constant.",
   comment_standardisation = "None needed",
   doi = 'https://doi.org/10.5061/dryad.js47k | https://doi.org/10.1371/journal.pone.0097387'
)]

##saving datasets ----
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

# Standardised Data ----
ddata <- ddata[
   !ddata[, diff(range(year)), by = local][V1 < 9L],
   on = 'local'
]

## meta data ----
meta <- unique(meta[
   unique(ddata[, .(local, year)]),
   on = .(local, year)
])

meta[, ":="(
   effort = 1L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "lake_pond",
   gamma_sum_grains_comment = "200m2 * number of sampled ponds during that year",

   gamma_bounding_box = 5.25,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "ecosystem",
   gamma_bounding_box_comment = "area of the ESGR according to the authors",

   comment_standardisation = "only ponds sampled at least 10 years appart were included"
)][, gamma_sum_grains := 200L * data.table::uniqueN(local), by = year]

##saving datasets ----
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
