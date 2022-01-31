# van-cleve_2021

dataset_id <- "van-cleve_2021"
ddata <- base::readRDS("./data/raw data/van-cleve_2021/rdata.rds")
data.table::setnames(ddata, tolower(colnames(ddata)))

# pooling individuals together
ddata <- unique(ddata[, .(value = .N), by = .(date, site, plot, species)][!species %in% c("", "?", "NoTrees", "nd")])
ddata[, species := tolower(trimws(species))]

# pooling dates
ddata[, year := format(date, "%Y")]
## keeping only the first sampling event per site, plot, year
## COMMENTED OUT because those are sampling events spread on 2 (and in some rare instances 3) consecutive days
# ddata <- ddata[unique(ddata[, .(site, plot, year, date)])[, .SD[1L,], by = .(site, plot, year)], on = .(site, plot, year, date)]

# pooling plots
## deleting sites with less than 12 plots
ddata <- ddata[ddata[, .(`12_sites_or_more` = length(unique(plot)) >= 12L), by = .(site, year)][(`12_sites_or_more`)], on = .(site, year)]

## reducing the number of plots to 12 in oversampled sites
set.seed(42L)
ddata <- ddata[ddata[, .(plot = unique(plot)[sample(1:length(unique(plot)), 12L)]), by = .(site, year)], on = .(site, plot, year)] # data.table style join

## pooling plots together
ddata <- unique(ddata[, .(value = sum(value)), by = .(site, year, species)][!is.na(species)])

data.table::setnames(ddata, "site", "local")

## community data ----

ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Bonanza Creek LTER",

  species = c("Picea mariana", "Picea glauca", "Picea sp.", "Populus balsamifera", "Populus tremuloides", "Betula neoalaskana", "Larix laricina")[data.table::chmatch(species, c("picmar", "picgla", "picea", "popbal", "poptre", "betneo", "larlar"))],

  metric = "abundance",
  unit = "count"


)]

## metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])

meta[, ":="(
  realm = "Terrestrial",
  taxon = "Plants",

  effort = 12L,

  study_type = "ecological_sampling",

  data_pooled_by_authors = FALSE,

  latitude = mean(c(66.2655, 63.6958)),
  longitude = mean(c(-144.332, -150.4031)),

  alpha_grain = 1200L,
  alpha_grain_unit = "m2",
  alpha_grain_type = "plot",
  alpha_grain_comment = "sum of the 12 10*10m plots per site",

  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "plot",
  gamma_sum_grains_comment = "number of sites per year * 1200m2",

  gamma_bounding_box = 50L,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "functional",
  gamma_bounding_box_comment = "area of the Bonanza Creek Experimental Forest",


  comment = "Extracted from EDI repository knb-lter-bnz.320.23 https://doi.org/10.6073/pasta/93067176968c707ac8491ce98b3c9dca . Authors publish forest past and ongoing results from forest community samplings and individual tree DBH measures. Authors provided species codes only and Species scientific names were assumed.",
  comment_standardisation = "Standardisation: number of sampling events per year per plot reduced to 1 and number of plots per site per year reduced to 12 then all plots from a year and site were pooled together and abundances summed"
)][, gamma_sum_grains := length(unique(local)) * 1200L, by = year]


dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
