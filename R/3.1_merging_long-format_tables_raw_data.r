# RAW DATA ----
## Merging ----
listfiles_community_raw <- list.files(
   path = "data/wrangled data",
   pattern = "_raw.csv",
   full.names = TRUE, recursive = TRUE
)
listfiles_metadata_raw <- list.files(
   path = "data/wrangled data",
   pattern = "raw_metadata.csv",
   full.names = TRUE, recursive = TRUE
)


template_community_raw <- utils::read.csv(file = "data/template_communities_raw.txt", header = TRUE, sep = "\t")
column_names_template_community_raw <- template_community_raw[, 1]

lst_community_raw <- lapply(listfiles_community_raw, data.table::fread, integer64 = "character", encoding = "UTF-8")
dt_raw <- data.table::rbindlist(lst_community_raw, fill = TRUE)

template_metadata_raw <- utils::read.csv(file = "data/template_metadata_raw.txt", header = TRUE, sep = "\t")
column_names_template_metadata_raw <- template_metadata_raw[, 1L]

lst_metadata_raw <- lapply(listfiles_metadata_raw, data.table::fread, integer64 = "character", encoding = "UTF-8")
meta_raw <- data.table::rbindlist(lst_metadata_raw, fill = TRUE)

## Checking data ----
source("R/functions/check_indispensable_variables.r")
check_indispensable_variables(dt_raw, column_names_template_community_raw[as.logical(template_community_raw[, 2])])
check_indispensable_variables(meta_raw, column_names_template_metadata_raw[as.logical(template_metadata_raw[, 2])])

if (anyNA(dt_raw$year)) warning(paste("missing _year_ value in ", unique(dt_raw[is.na(year), dataset_id]), collapse = ", "))
if (anyNA(meta_raw$year)) warning(paste("missing _year_ value in ", unique(meta_raw[is.na(year), dataset_id]), collapse = ", "))
if (any(dt_raw[metric == "pa", value] != 1)) warning(paste("abnormal presence absence value in ", unique(dt_raw[value != 1, dataset_id]), collapse = ", "))
if (any(dt_raw[, .(is.na(regional) | regional == "")])) warning(paste("missing _regional_ value in ", unique(dt_raw[is.na(regional) | regional == "", dataset_id]), collapse = ", "))
if (any(dt_raw[, .(is.na(local) | local == "")])) warning(paste("missing _local_ value in ", unique(dt_raw[is.na(local) | local == "", dataset_id]), collapse = ", "))
if (any(dt_raw[, .(is.na(species) | species == "")])) warning(paste("missing _species_  value in ", unique(dt_raw[is.na(species) | species == "", dataset_id]), collapse = ", "))
if (any(dt_raw[, .(is.na(value) | value == "" | value <= 0)])) warning(paste("missing _value_  value in ", unique(dt_raw[is.na(value) | value == "" | value <= 0, dataset_id]), collapse = ", "))
if (any(dt_raw[, .(is.na(metric) | metric == "")])) warning(paste("missing _metric_  value in ", unique(dt_raw[is.na(metric) | metric == "", dataset_id]), collapse = ", "))
if (any(dt_raw[, .(is.na(unit) | unit == "")])) warning(paste("missing _unit_  value in ", unique(dt_raw[is.na(unit) | unit == "", dataset_id]), collapse = ", "))

### Counting the study cases ----
dt_raw[, .(nsites = length(unique(local))), by = dataset_id][order(nsites, decreasing = TRUE)]

## Ordering ----
# data.table::setcolorder(dt, intersect(column_names_template, colnames(dt)))
data.table::setorder(dt_raw, dataset_id, regional, local, year, species)

## Deleting special characters in regional and local ----
# dt[, ":="(
#   local = iconv(local, from = "UTF-8", to = "ASCII")
# )]

## Checks ----

### checking duplicated rows ----
if (anyDuplicated(dt_raw)) warning(
   paste(
      "Duplicated rows in dt, see:",
      paste(dt_raw[duplicated(dt_raw), unique(dataset_id)], collapse = ",")
   )
)

### checking values ----
if (dt_raw[unit == "count", any(!is.integer(value))]) warning(paste("Non integer values in", paste(dt_raw[unit == "count" & !is.integer(value), unique(dataset_id)], collapse = ", ")))

### checking species names ----
for (i in seq_along(lst_community_raw)) if (is.character(lst_community_raw[[i]]$species)) if (any(!unique(Encoding(lst_community_raw[[i]]$species)) %in% c("UTF-8", "unknown"))) warning(paste0("Encoding issue in ", listfiles_community_raw[i]))
#### adding GBIF matched names by Dr. Wubing Xu ----
load("./data/requests to taxonomy databases/bhsplist_gbif.RDATA")
data.table::setDT(bh_species)

dt_raw <- merge(dt_raw, bh_species[, .(dataset_id, species, species.new, gbif_specieskey)],
                by = c("dataset_id", "species"), all.x = TRUE)
data.table::setnames(dt_raw, c("species", "species.new"), c("species_original", "species"))
dt_raw[is.na(species), species := species_original]
# unique(dt[grepl("[^a-zA-Z\\._ ]", species) & nchar(species) < 10L, .(dataset_id)])
# unique(dt[grepl("[^a-zA-Z\\._ \\(\\)0-9\\-\\&]", species), .(dataset_id, species)])[sample(1:1299, 50)]
# unique(dt[grepl("Â", species), .(dataset_id, species)])


### checking metrics and units ----
if (!all(dt_raw[metric == "pa", unit == "pa"]) || !all(dt_raw[unit == "pa", metric == "pa"]) || !all(dt_raw[metric == "pa" | unit == "pa", value == 1])) warning("inconsistent presence absence coding")
if (any(dt_raw[, length(unique(unit)), by = dataset_id]$V1) != 1L) warning("several units in a single data set")

## Saving dt ----
data.table::setcolorder(dt_raw, c("dataset_id", "regional", "local", "year", "species", "species_original", "gbif_specieskey", "value", "metric", "unit"))

data.table::fwrite(dt_raw, "data/communities_raw.csv", row.names = FALSE, na = "NA")

if (file.exists("./data/references/homogenisation_dropbox_folder_path.rds")) {
   path_to_homogenisation_dropbox_folder <- base::readRDS(file = "./data/references/homogenisation_dropbox_folder_path.rds")
   data.table::fwrite(dt_raw, paste0(path_to_homogenisation_dropbox_folder, "/_data_extraction/metacommunity-survey-raw-communities.csv"), row.names = FALSE)
}



## Metadata ----
meta_raw <- merge(meta_raw, unique(dt_raw[, .(dataset_id, regional, local, year)]), all.x = TRUE)

# Checking metadata
if (any(!unique(meta_raw$taxon) %in% c("Invertebrates", "Plants", "Mammals", "Fish", "Marine plants", "Birds", "Herpetofauna"))) warning(
   paste("Abnormal taxon value in",
         paste(
            meta_raw[!taxon %in% c("Invertebrates", "Plants", "Mammals", "Fish", "Marine plants", "Birds", "Herpetofauna"), unique(dataset_id)],
            collapse = ",")
   )
)

if (any(!unique(meta_raw$realm) %in% c("Terrestrial", "Marine", "Freshwater" ))) warning(
   paste("Abnormal realm value in",
         paste(
            meta_raw[!realm %in% c("Terrestrial", "Marine", "Freshwater"), unique(dataset_id)],
            collapse = ",")
   )
)

## Converting alpha grain units ----
### checking units ----
if (any(!na.omit(unique(meta_raw$alpha_grain_unit)) %in% c("acres", "ha", "km2", "m2", "cm2"))) warning("Non standard unit in alpha")
### converting areas ----
meta_raw[, alpha_grain := as.numeric(alpha_grain)][,
                                                   alpha_grain := data.table::fcase(
                                                      alpha_grain_unit == "m2", alpha_grain,
                                                      alpha_grain_unit == "cm2", alpha_grain / 10000,
                                                      alpha_grain_unit == "ha", alpha_grain * 10000,
                                                      alpha_grain_unit == "km2", alpha_grain * 1000000,
                                                      alpha_grain_unit == "acres", alpha_grain * 4046.856422
                                                   )
][, alpha_grain_unit := NULL]

data.table::setnames(meta_raw, "alpha_grain", "alpha_grain_m2")

meta_raw[is.na(alpha_grain_m2), unique(dataset_id)]

## Converting coordinates into a common format with parzer ----
unique_coordinates_raw <- unique(meta_raw[, .(latitude, longitude)])
unique_coordinates_raw[, ":="(
   lat = parzer::parse_lat(latitude),
   lon = parzer::parse_lon(longitude)
)]
unique_coordinates_raw[is.na(lat) | is.na(lon)]
meta_raw <- merge(meta_raw, unique_coordinates_raw, by = c("latitude", "longitude"))
meta_raw[, c("latitude", "longitude") := NULL]
data.table::setnames(meta_raw, c("lat", "lon"), c("latitude", "longitude"))

## Coordinate scale ----
meta_raw[, is_coordinate_local_scale := length(unique(latitude)) != 1L && length(unique(longitude)) != 1L, by = .(dataset_id, regional)]


## Checks ----
### checking duplicated rows ----
if (anyDuplicated(meta_raw)) warning("Duplicated rows in metadata")

### checking taxon ----
if (any(meta_raw[, length(unique(taxon)), by = dataset_id]$V1 != 1L)) warning(paste0("several taxa values in ", paste(meta_raw[, length(unique(taxon)), by = dataset_id][V1 != 1L, dataset_id], collapse = ", ")))
if (any(!unique(meta_raw$taxon) %in% c("Fish", "Invertebrates", "Plants", "Birds", "Mammals", "Herpetofauna", "Marine plants"))) warning(paste0("Non standard taxon category in ", paste(unique(meta_raw[!taxon %in% c("Fish", "Invertebrates", "Plants", "Birds", "Mammals", "Herpetofauna", "Marine plants"), .(dataset_id), by = dataset_id]$dataset_id), collapse = ", ")))

### checking encoding ----
for (i in seq_along(lst_metadata_raw)) if (any(!unlist(unique(apply(lst_metadata_raw[[i]][, c("local", "regional", "comment")], 2L, Encoding))) %in% c("UTF-8", "unknown"))) warning(paste0("Encoding issue in ", listfiles_metadata_raw[i]))

### checking year range homogeneity among regions ----
if (any(meta_raw[, length(unique(paste(range(year), collapse = "-"))), by = .(dataset_id, regional)]$V1 != 1L)) warning("all local scale sites were not sampled for the same years and timepoints has to be consistent with years")

### checking study_type ----
if (any(!meta_raw$study_type %in% c("ecological_sampling","resurvey")))
   warning(
      paste(
         "study_type has to be either 'ecological_sampling' or 'resurvey', see: ",
         paste(meta_raw[!study_type  %in% c("ecological_sampling","resurvey"), unique(dataset_id)], collapse = ",")
      )
   )

### checking effort ----
unique(meta_raw[effort == "unknown" | is.na(effort), .(dataset_id, effort)])
# all(meta[(checklist), effort] == 1)

### checking data_pooled_by_authors ----
meta_raw[is.na(data_pooled_by_authors), data_pooled_by_authors := FALSE]
if (any(meta_raw[(data_pooled_by_authors), is.na(sampling_years)])) warning(
   paste0("Missing sampling_years values in: ",
          paste(meta_raw[(data_pooled_by_authors) & is.na(sampling_years), unique(dataset_id)], collapse = ", "))
)
if (any(meta_raw[(data_pooled_by_authors), is.na(data_pooled_by_authors_comment)])) warning(paste("Missing data_pooled_by_authors_comment values in", meta_raw[(data_pooled_by_authors) & is.na(data_pooled_by_authors_comment), paste(unique(dataset_id), collapse = ", ")]))

### checking comment_standardisation ----
if (anyNA(meta_raw$comment_standardisation)) warning("Missing comment_standardisation value")

### checking alpha_grain_type ----
# meta[(!checklist), .(lterm = diff(range(year)), taxon = taxon, realm = realm, alpha_grain_type = alpha_grain_type), by = .(dataset_id, regional)][lterm >= 10L][taxon == "Fish" & realm == "Freshwater" & grep("lake",alpha_grain_type), unique(dataset_id)]
if (any(!unique(meta_raw$alpha_grain_type) %in% c("island", "plot", "sample", "lake_pond", "trap", "transect", "functional", "box", "quadrat"))) warning(paste("Invalid alpha_grain_type value in", paste(unique(meta_raw[!alpha_grain_type %in% c("island", "plot", "sample", "lake_pond", "trap", "transect", "functional", "box", "quadrat"), dataset_id]), collapse = ", ")))

## Ordering metadata ----
data.table::setorder(meta_raw, dataset_id, regional, local, year)
data.table::setcolorder(meta_raw, base::intersect(column_names_template_metadata_raw, colnames(meta_raw)))



## Checking that all data sets have both community and metadata data ----
if (length(base::setdiff(unique(dt_raw$dataset_id), unique(meta_raw$dataset_id))) > 0L) warning("Incomplete community or metadata tables")
if (nrow(meta_raw) != nrow(unique(meta_raw[, .(dataset_id, regional, local, year)]))) warning("Redundant rows in meta")
if (nrow(meta_raw) != nrow(unique(dt_raw[, .(dataset_id, regional, local, year)]))) warning("Discrepancies between dt and meta")


## Saving meta ----
data.table::fwrite(meta_raw, "data/metadata_raw.csv", sep = ",", row.names = FALSE, na = "NA")
if (file.exists("./data/references/homogenisation_dropbox_folder_path.rds"))
   data.table::fwrite(meta_raw, paste0(path_to_homogenisation_dropbox_folder, "/_data_extraction/metacommunity-survey-metadata-raw.csv"), sep = ",", row.names = FALSE)

