## price_2017

dataset_id <- "price_2017"
ddata <- data.table::fread(paste0("data/raw data/", dataset_id, "/rdata.csv"),
  header = TRUE
)

data.table::setnames(
  ddata, c("SiteID", "Year"),
  c("local", "year")
)

ddata <- data.table::melt(ddata,
  variable.name = "species",
  measure.vars = 4:ncol(ddata),
  measure.name = "value"
)
ddata <- ddata[, .(local, year, species, value)]

ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Illinois",
  year = c(2000L, 2005L, 2010L, 2015L)[match(year, 1:4)],

  metric = "cover",
  unit = "percent cover"
)]

ddata <- ddata[!is.na(value) & value > 0]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  realm = "Terrestrial",
  taxon = "Plants",

  latitude = "39.00 N",
  longitude = "89.00 W",

  effort = 1L,
  study_type = "ecological_sampling",

  data_pooled_by_authors = TRUE,
  data_pooled_by_authors_comment = "ecosystems sampled once per sampling period",
  sampling_years = c("1997-2000", "2002-2005", "2007-2010", "2012-2015")[match(year, c(2000L, 2005L, 2010L, 2015L))],

  alpha_grain = 200L,
  alpha_grain_unit = "m2",
  alpha_grain_type = "sample",
  alpha_grain_comment = "20 0.5m2 quadrats per wetland per survey",

  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "sample",
  gamma_sum_grains_comment = "sum of sampled stream stretch areas per region and per year",

  gamma_bounding_box = 149997L,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "administrative",
  gamma_bounding_box_comment = "area of the state of Illinois considered as gamma scale extent by the authors.",

  comment = "Extracted from Price et al 2017 Supplementary (https://doi.org/10.13012/B2IDB-0478588_V2 manual download only(?)). Data was produced as part of a Critical Trends Assessment Program and wetlands were sampled every 5 years since 1997. The sampling periods used in this study are as follows: 1997–2000, 2002–2005, 2007–2010 and 2012–2015. Effort is consistent over time: vegetation sampled in standard quadrats.",
  comment_standardisation = "none needed",
doi = 'https://doi.org/10.13012/B2IDB-0478588_V2 | https://doi.org/10.1111/1365-2745.12883'
)][, gamma_sum_grains := 200L * length(unique(local)), by = .(regional, year)]


dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
