## cervantes-yoshida_2015
dataset_id <- "cervantes-yoshida_2015"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))

data.table::setnames(
  ddata, c("sample year", "paired.site.label"),
  c("year", "local")
)

ddata <- data.table::melt(ddata,
  measure.vars = which(colnames(ddata) == "Catostomus occidentalis"):ncol(ddata),
  variable.name = "species",
  value.name = "value"
)
ddata <- ddata[value > 0, .(local, year, species, value)]
ddata[year == 1993L, year := 1996L]

ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Alameda Creek Watershed",

  metric = "abundance",
  unit = "count"
)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  realm = "Freshwater",
  taxon = "Fish",

  latitude = "37.563333 N",
  longitude = "-122.130833 E",

  effort = 1L,

  study_type = "resurvey",

  data_pooled_by_authors = TRUE,
  data_pooled_by_authors_comment = "'Sixty-nine sites were initially surveyed by one of us (RAL) between April-October in 1992–1996, with the majority of sites sampled between May-August of 1993 and 1994'",
  sampling_years = c("1992-1996", "2009")[match(year, c(1996, 2009))],

  alpha_grain = 100L,
  alpha_grain_unit = "m2",
  alpha_grain_type = "sample",
  alpha_grain_comment = "estimated from effort (electrofishing of rivers, minimal length of the sampling reach = 30m. Constant through time for sites.)",

  gamma_sum_grains = 100L * 32L,
  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "sample",
  gamma_sum_grains_comment = "100m2 sample times 32 locations per year",

  gamma_bounding_box = 1800L,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "watershed",
  gamma_bounding_box_comment = "area of the watershed given in the article",

  comment = "Extracted from Cervantes-Yoshida et al 2015 Dryad repo. 'Fish distribution and abundance data were collected by the same lead scientist (RAL) in both the 1990s and 2009. Prior to revisiting sites in 2009, we reviewed the associated data sheets from the mid-1990s for details of site descriptions and sampling methodology. Here we were able to reconstruct an approximately identical study design and effort based on these field notes and from input from RAL. Each site was sampled in same location, and there was no difference in site reach length between the two time periods (paired t-test, P = 0.534).' Coordinates of the mouth of the Alameda Creek",
  comment_standardisation = "none needed"
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
