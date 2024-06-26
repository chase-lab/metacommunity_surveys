# amesbury_1999
dataset_id <- "amesbury_1999"

ddata <- base::readRDS(file = paste0("data/raw data/", dataset_id, "/ddata.rds"))

ddata <- data.table::melt(ddata,
                          id.vars = c("species"),
                          value.name = "value",
                          variable.name = "local_year"
)

ddata[, c("local", "year") := data.table::tstrsplit(local_year, "_")]

ddata <- ddata[value != ""]

ddata[, ":="(
   dataset_id = dataset_id,
   regional = "Gawel transects",

   metric = "abundance",
   unit = "count",

   local_year = NULL
)]

meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
   realm = "Marine",
   taxon = "Fish",

   latitude = '13°25`21.03"N',
   longitude = '144°40`32.38"E',

   effort = 4L,

   study_type = "resurvey",

   data_pooled_by_authors = FALSE,

   alpha_grain = 100L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "sample",
   alpha_grain_comment = "50m long 2m wide transect",

   gamma_sum_grains = 4L * 100L,
   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "sum of the sampled transects",

   gamma_bounding_box = 1002L,
   gamma_bounding_box_unit = "acres",
   gamma_bounding_box_type = "administrative",
   gamma_bounding_box_comment = "sum of the water area of the War in Pacific National Park.",

   comment = "Extracted from Amesbury_1999 table 17. Abundances (in modern) turned into presence absence (as in historical). Effort is comparable: 'Four of the fish transects surveyed by Gawel(1977) [...] were resurveyed using Gawel's survey methods' and 'Fish were surveyed by an investigator swimming the length of the transect line enumerating by species fish which were seen within 1 m of either side of the line (an area of 100 m2).' Exact protocol is described in Eldredge, L.G., R. Dickinson, and S. Moras (eds.) 1977. Marine Survey of Agat Bay. Univ. Guam Mar.Lab., Tech. Rept. No. 31,251 p. Location of the 4 resurveyed transects in the different parts of the park is unknown.",
   comment_standardisation = "none needed",
   doi = NA
)]

# saving raw data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)

drop_col <- c("effort",
              "gamma_sum_grains", "gamma_sum_grains_unit","gamma_sum_grains_type","gamma_sum_grains_comment",
              "gamma_bounding_box","gamma_bounding_box_unit", "gamma_bounding_box_type","gamma_bounding_box_comment")
data.table::fwrite(
   x = meta[, !..drop_col],
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)

# Standardised data ----
ddata <- ddata[value != "x"]
ddata[, ":="(
   value = 1L,
   metric = "pa",
   unit = "pa"
)]
meta[, comment_standardisation := "Abundance scores turned into presence absence"]

# saving standardised data ----
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
