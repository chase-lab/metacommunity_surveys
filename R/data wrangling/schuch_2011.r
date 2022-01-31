## schuch_2011

dataset_id <- "schuch_2011"


ddata <- base::readRDS(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
data.table::setnames(ddata, c("species", paste0("1951_site ", as.roman(c(1:6, 10:12))), paste0("2009_site ", as.roman(c(1:6, 10:12)))))

# cleaning
ddata <- ddata[!(grepl("[0-9]|Auchenorrhyncha|Heteroptera|Orthoptera|Ecological charactistics|Ecological characteristics", species) | is.na(species))]

# splitting and melting years and sites
ddata <- data.table::melt(ddata, id.vars = "species", na.rm = TRUE)
ddata <- ddata[value > 0]
ddata[, c("year", "local") := data.table::tstrsplit(variable, "_")]


# data
ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Lower Saxony",

  metric = "abundance",
  unit = "count",

  variable = NULL
)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  taxon = "Invertebrates",
  realm = "Terrestrial",

  latitude = "52°45'22'N",
  longitude = "9°23'35'",

  effort = 8L,

  study_type = "resurvey",

  data_pooled_by_authors = FALSE,

  alpha_grain = 100L,
  alpha_grain_unit = "m2",
  alpha_grain_type = "sample",
  alpha_grain_comment = "estimated area",

  gamma_sum_grains = 100L * 9L * 8L,
  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "sample",
  gamma_sum_grains_comment = "sum of the sampled transect areas per region * 8 times per year",

  gamma_bounding_box = 14.21988214,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "box",
  gamma_bounding_box_comment = "bounding box around the sites found in Marchand 1953",


  comment = 'Data was extracted from the supplementary file 1 https://doi.org/10.1111/j.1439-0418.2011.01645.x . "We sampled eight times at each site beginning in May and ending in September 2009, trying to match sampling dates of Marchand as closely as possible (Appendix S1). Marchand sampled with a sweep net (Ø 30 cm; 100 beats per sampling); we used the same method and assume that comparisons between years are justified". Based on the number of beats, alpha grain is estimated at 100 square meters. ',
  comment_standardisation = "In the supplementary file, two abnormal values were excluded: site IV 1951 Orthops kalmii = 0 AND site V 1951 Forcipata forcipata = 0."
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
