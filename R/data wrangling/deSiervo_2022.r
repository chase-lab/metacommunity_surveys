dataset_id <- "deSiervo_2022"

ddata <- base::readRDS("data/raw data/deSiervo_2022/.rdata.rds")

##Raw Data ----
##pooling life stages: canopy, seedling and sapling
prefixes =  sub("[CAN|SAP]{3}[1-9]{4}", "", colnames(ddata))[-c(1, 37, 38, 39, 40)]

ddata <- cbind(ddata, sapply(unique(sub("[SEED]{4}[1-9]{4}", "", prefixes)),function(i){
   rowSums(ddata[, grepl(i, colnames(ddata)), with = FALSE])
}))

ddata <- ddata[, grep("[CAN|SAP|SEED]{3}[1-9]{4}", colnames(ddata)) := NULL]
ddata <- ddata[, c("Elev.dem.", "heatload") := NULL]

##renaming columns ---
data.table::setnames(ddata, c("Plot.number", "Year"), c("local", "year"))

##wide to long format ----
ddata <- data.table::melt(data = ddata,
                          id.vars = c("local", "year"),
                          variable.name = "species"
)
##community data ----
ddata[, ":="(
   dataset_id = dataset_id,

   regional = "Russian wilderness",

   metric = "cover",
   unit = "percent"
)]

### Excluding absences ----
ddata <- ddata[value != 0]

# meta ----
meta <- unique(ddata[, .(dataset_id, year, regional, local)])
meta[, ":="(
   realm = "Terrestrial",
   taxon = "Plants",

   latitude =  "41° 19′ 12″ N",
   longitude = "122° 28′ 44.4″ W", #coordinates from wikipedia klamath mountains

   study_type = "ecological_sampling", #two possible values, or NA if not sure

   data_pooled_by_authors = FALSE,

   alpha_grain =  804.25,
   alpha_grain_unit = "m2", #"acres", "ha", "km2", "m2", "cm2"
   alpha_grain_type = "plot",
   alpha_grain_comment = "16 m radius circular plot (804.25 m 2 ) and used this size and shape for plots. not certain that this was the exact plot size used in 1969, estimates of cover would be robust to slight differences in plot size, especially because the plots were located within larger, compositionally homogenous stands",

   comment = "Data manually downloaded via https://datadryad.org/stash/dataset/doi:10.5061%2Fdryad.9s4mw6mj7. The authors estimated percent coverage in 16m radius circular plots. The authors surveyed this area once in 2014 and compare this data to historical data of the same plots in 1969.  Regional in this dataset is the russian wilderness area in klamath mountains, local is defined as plot. Sum of percent coverage of seedlings, saplings and canope of species.",
   comment_standardisation = "all life stages pooled together, if lifestages are of interest they can be found in the raw raw data on dryad",
   doi = 'https://doi.org/10.5061/dryad.9s4mw6mj7'
)]

##save data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)

#Standarized Data ----
## Excluding sites that were not sampled at least twice 10 years apart ----
ddata <- ddata[!ddata[, diff(range(year)) < 9L, by = local][(V1)],
               on = "local"]

##community data ----
## turn percent cover into presence absence ----
ddata[, ":="(
   value = 1L,
   metric = "pa",
   unit = "pa"
)]

##meta data ----
meta <- meta[unique(ddata[, .(local, year)]),
             on = .(local, year)]
meta[, ":="(
   effort = 1L, #one observation in 1969 and 2015

   gamma_bounding_box = 5000L,
   gamma_bounding_box_unit = "ha",
   gamma_bounding_box_type = "box",
   gamma_bounding_box_comment = "Russian Wilderness, a 5000 ha landscape within the east-central Klamath Mountain",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "sampled area per year",

   comment_standardisation = "all life stages pooled together, if lifestages are of interest they can be found in the raw raw data on dryad. Percent cover turned into presence absence.
Sites that were not sampled at least twice 10 years apart were excluded."
)][, gamma_sum_grains := sum(alpha_grain), by = .(regional, year)]

##save data ----
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
