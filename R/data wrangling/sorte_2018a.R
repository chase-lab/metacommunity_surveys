## sorte_2018a - fixed algae and invertebrates

dataset_id <- "sorte_2018a"

ddata <- base::readRDS(file = "data/raw data/sorte_2018/ddata.rds")[taxon == "Fixed algae and invertebrates"]

#Raw Data----

ddata[species == "Mytilus edulis (percent cover)", species := "Mytilus edulis"]

##community data----
ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Gulf of Maine",

  value = 1L,
  metric = "pa",
  unit = "pa",
  period = NULL
)]
ddata <- unique(ddata)


##meta data ----
env <- base::readRDS(file = "data/raw data/sorte_2018/env.rds")

meta <- unique(ddata[, .(dataset_id, regional, local, year, taxon)])
meta <- merge(meta, unique(env[local %in% c("Canoe Beach", "Chamberlain", "Pemaquid Point", "Grindstone Neck"), .SD[1], by = local, .SDcols = c("latitude", "longitude")]), all.x = TRUE)

meta[, ":="(
  realm = "Marine",
  taxon = "Marine plants",

  study_type = "ecological_sampling",

  data_pooled_by_authors = FALSE,

  alpha_grain = .25,
  alpha_grain_unit = "m2",
  alpha_grain_type = "sample",
  alpha_grain_comment = "Ten 0.25-m2 quadrats per 30m transect",

  comment = "Extracted from Sorte et al 2018 Supplementary (https://onlinelibrary.wiley.com/doi/full/10.1111/gcb.13425). Authors compiled historical records from the 1970s in 4 beaches and sampled algae and both fixed and mobile invertebrates in quadrats along horizontal transects (parallel to the shore) in the tidal zone. In sorte_2018a, we included observations of fixed organisms. Methodology and effort from historical and recent records are comparable. Regional is the Gulf of Maine, local a beach",
  comment_standardisation = "None"
)]

##save data----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata[,!c("taxon")], paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
                   row.names = FALSE
)


#Standardized Data ----
## removing cover and fixing typos in species names ----
Not_accepted_species_names <- c(
  "Notes",
  "Diatoms",
  "Cyanobacteria",
  "Green crust",
  "Brown crust",
  "Fleshy crust (Petrocelis cruenta,Ralfsia fungiformis)",
  "Sponge",
  "Colonial tunicate",
  grep("egg", unique(ddata$species), value = TRUE)
)

labs <- levels(ddata$species)
labs[grepl('%|percent', labs, fixed = FALSE, ignore.case = TRUE)] <- 'delete_me'
labs[labs %in% Not_accepted_species_names] <- 'delete_me'
labs <- gsub(" egg capsules| egg masses|\\.+[0-9]+$", "", labs, fixed = FALSE)
data.table::setattr(ddata$species, 'levels', labs)

if (any(ddata$species == 'delete_me')) ddata <- ddata[!species %in% 'delete_me']

##meta data -----
meta <- meta[unique(ddata[, .(dataset_id, local, regional, year)]),
             on = .(local, regional, year)]

meta[,":="(
  effort = 9L,

  gamma_sum_grains = .25 * 3 * 3 * 4,
  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "quadrat",
  gamma_sum_grains_comment = "3 quadrats per transect, 3 transects per island, 4 islands",

  gamma_bounding_box = 45L,
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "shore",
  gamma_bounding_box_comment = "450 km length of shore of the Gulf of Maine covered by the sampling sites, estimated 1/10km wide",

  comment_standardisation = "Two dates from the 2 most sampled months per year were pooled together. There are only 3 transects in some historical samples so only transects 1, 3 and 5 of all sites and years are kept and they were pooled together. Only quadrats at tide heights of Low, Mid and High (historical) or 0m, 1m, and 2m (modern) were kept and they were pooled together."
)]

##save data----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata[,!c("taxon")], paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardized_metadata.csv"),
                   row.names = FALSE
)

