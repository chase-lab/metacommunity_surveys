# STANDARDISED DATA ----
library(dplyr)

## Merging ----
listfiles_community_standardised <- list.files(
   path = "data/wrangled data",
   pattern = "_standardised.csv",
   full.names = TRUE, recursive = TRUE
)
listfiles_metadata_standardised <- list.files(
   path = "data/wrangled data",
   pattern = "standardised_metadata.csv",
   full.names = TRUE, recursive = TRUE
)


template_community_standardised <- utils::read.csv(file = "data/template_communities_standardised.txt", header = TRUE, sep = "\t")
column_names_template_community_standardised <- template_community_standardised[, 1]

lst_community_standardised <- lapply(listfiles_community_standardised,
                                     FUN = data.table::fread,
                                     integer64 = "character", encoding = "UTF-8",
                                     stringsAsFactors = TRUE)
dt_standardised <- data.table::rbindlist(lst_community_standardised, fill = TRUE)

template_metadata_standardised <- utils::read.csv(file = "data/template_metadata_standardised.txt", header = TRUE, sep = "\t")
column_names_template_metadata_standardised <- template_metadata_standardised[, 1L]

lst_metadata_standardised <- lapply(listfiles_metadata_standardised,
                                    FUN = data.table::fread,
                                    integer64 = "character", encoding = "UTF-8",
                                    stringsAsFactors = TRUE)
meta_standardised <- data.table::rbindlist(lst_metadata_standardised, fill = TRUE)

## Checking data ----
source("R/functions/check_indispensable_variables.r")
check_indispensable_variables(dt_standardised, column_names_template_community_standardised[as.logical(template_community_standardised[, 2])])
check_indispensable_variables(meta_standardised, column_names_template_metadata_standardised[as.logical(template_metadata_standardised[, 2])])

if (anyNA(dt_standardised$year)) warning(paste("missing _year_ value in ", unique(dt_standardised[is.na(year), dataset_id]), collapse = ", "))
if (anyNA(meta_standardised$year)) warning(paste("missing _year_ value in ", unique(meta_standardised[is.na(year), dataset_id]), collapse = ", "))
if (dt_standardised[metric == "pa", any(value != 1)]) warning(paste("abnormal presence absence value in ", unique(dt_standardised[value != 1, dataset_id]), collapse = ", "))
if (dt_standardised[, any(is.na(regional) | regional == "")]) warning(paste("missing _regional_ value in ", unique(dt_standardised[is.na(regional) | regional == "", dataset_id]), collapse = ", "))
if (dt_standardised[, any(is.na(local) | local == "")]) warning(paste("missing _local_ value in ", unique(dt_standardised[is.na(local) | local == "", dataset_id]), collapse = ", "))
if (dt_standardised[, any(is.na(species) | species == "")]) warning(paste("missing _species_ value in ",
                                                                          paste(unique(dt_standardised[is.na(species) | species == "", dataset_id]), collapse = ", ")))
if (dt_standardised[, any(is.na(value) | value == "" | value <= 0)]) warning(paste("missing _value_ value in ", unique(dt_standardised[is.na(value) | value == "" | value <= 0, dataset_id]), collapse = ", "))
if (dt_standardised[, any(is.na(metric) | metric == "")]) warning(paste("missing _metric_ value in ", unique(dt_standardised[is.na(metric) | metric == "", dataset_id]), collapse = ", "))
if (dt_standardised[, any(is.na(unit) | unit == "")]) warning(paste("missing _unit_ value in ", unique(dt_standardised[is.na(unit) | unit == "", dataset_id]), collapse = ", "))

### Counting the study cases ----
dt_standardised |>
   dtplyr::lazy_dt() |>
   group_by(dataset_id) |>
   summarise(nsites = n_distinct(regional, local)) |>
   arrange(-nsites)

## Ordering ----
# data.table::setcolorder(dt, intersect(column_names_template, colnames(dt)))
data.table::setkey(dt_standardised, dataset_id, regional, local,
                   year, species)

## Deleting special characters in regional and local ----
# dt[, ":="(
#   local = iconv(local, from = "UTF-8", to = "ASCII")
# )]

## Checks ----
### checking species names ----
for (i in seq_along(lst_community_standardised)) if (is.character(lst_community_standardised[[i]]$species)) if (any(!unique(Encoding(lst_community_standardised[[i]]$species)) %in% c("UTF-8", "unknown"))) warning(paste0("Encoding issue in ", listfiles_community_standardised[i]))

### adding GBIF matched names by Dr. Wubing Xu ----
corrected_species_names <- data.table::fread(
   file = "data/requests to taxonomy databases/manual_community_species_filled_20230922.csv",
   colClasses = c(dataset_id = "factor",
                  species_original = "character",
                  species.new = "character",
                  species = "NULL",
                  comment = "NULL",
                  corrected = "NULL",
                  checked = "NULL")
)

#### removing new names assigned to several original names ----
corrected_species_names <- anti_join(
   x = corrected_species_names,
   y = corrected_species_names |>
      group_by(dataset_id, species.new) |>
      filter(n() != 1L))

#### data.table join with update by reference ----
dt_standardised <- dt_standardised |>
   dtplyr::lazy_dt(immutable = FALSE) |>
   left_join(corrected_species_names |>
                select(dataset_id, species = species_original, species.new),
             join_by(dataset_id, species)) |>
   rename(species_original = species,
          species = species.new) |>
   mutate(species = if_else(is.na(species),
                            true = species_original,
                            false = species)) |>
   data.table::as.data.table()

### checking duplicated rows ----
if (anyDuplicated(dt_standardised)) warning(
   paste(
      "Duplicated rows in dt, see:",
      paste(dt_standardised[duplicated(dt_standardised), unique(dataset_id)], collapse = ", ")
   )
)

if (any(dt_standardised[, .N, keyby = .(dataset_id, regional, local, year, species)]$N != 1L)) warning(
   paste(
      'duplicated species in:',
      paste(collapse = ', ',
            dt_standardised[, .N, keyby = .(dataset_id, regional, local, year, species)][N != 1L, unique(dataset_id)])))


### checking metrics and units ----
if (!all(dt_standardised[metric == "pa", unit == "pa"]) || !all(dt_standardised[unit == "pa", metric == "pa"]) || !all(dt_standardised[metric == "pa" | unit == "pa", value == 1])) warning("inconsistent presence absence coding")
if (any(dt_standardised[, data.table::uniqueN(unit), keyby = dataset_id]$V1 != 1L)) warning("several units in a single data set")


## Metadata ----
# meta_standardised <- meta_standardised[
#    unique(dt_standardised[, .(dataset_id, regional, local, year)]),
#    on = .(dataset_id, regional, local, year)
# ]

# Checking metadata
if (any(!unique(meta_standardised$taxon) %in% c("Invertebrates", "Plants", "Mammals", "Fish", "Marine plants", "Birds", "Herpetofauna"))) warning(
   paste("Abnormal taxon value in",
         paste(
            meta_standardised[!taxon %in% c("Invertebrates", "Plants", "Mammals", "Fish", "Marine plants", "Birds", "Herpetofauna"), unique(dataset_id)],
            collapse = ", ")
   )
)

if (any(!unique(meta_standardised$realm) %in% c("Terrestrial", "Marine", "Freshwater" ))) warning(
   paste("Abnormal realm value in",
         paste(
            meta_standardised[!realm %in% c("Terrestrial", "Marine", "Freshwater"), unique(dataset_id)],
            collapse = ", ")
   )
)

## Converting alpha grain and gamma extent units ----
### checking units ----
if (any(!na.omit(unique(meta_standardised$alpha_grain_unit)) %in% c("acres", "ha", "km2", "m2", "cm2"))) warning("Non standard unit in alpha")

if (any(!na.omit(unique(meta_standardised$gamma_sum_grains_unit)) %in% c("acres", "ha", "km2", "m2", "cm2"))) warning(paste(
   "Non standard unit in gamma_sum_grains, see",
   paste(
      meta_standardised[!is.na(gamma_sum_grains_unit)][!gamma_sum_grains_unit %in% c("acres", "ha", "km2", "m2", "cm2"), unique(dataset_id)],
      collapse = ", "
   )
)
)
if (any(!na.omit(unique(meta_standardised$gamma_bounding_box_unit)) %in% c("acres", "ha", "km2", "m2", "mile2"))) warning("Non standard unit in gamma_bounding_box")

### converting areas ----
meta_standardised <- meta_standardised |>
   dtplyr::lazy_dt(immutable = FALSE) |>
   mutate(
      alpha_grain_unit = as.character(alpha_grain_unit),
      gamma_sum_grains_unit = as.character(gamma_sum_grains_unit),
      gamma_bounding_box_unit = as.character(gamma_bounding_box_unit)) |>
   mutate(
      alpha_grain = case_match(alpha_grain_unit,
                               "m2" ~ alpha_grain,
                               "cm2" ~ alpha_grain / 10^4,
                               "ha" ~ alpha_grain * 10^4,
                               "km2" ~ alpha_grain * 10,
                               "acres" ~ alpha_grain * 4046.856422),
      alpha_grain_unit = NULL,
      gamma_sum_grains = case_match(gamma_sum_grains_unit,
                                    "km2"~ gamma_sum_grains,
                                    "m2" ~ gamma_sum_grains / 10^6,
                                    "ha" ~ gamma_sum_grains / 100,
                                    "cm2" ~ gamma_sum_grains / 10^10,
                                    "acres" ~ gamma_sum_grains * 0.004046856422),
      gamma_sum_grains_unit = NULL,
      gamma_bounding_box = case_match(gamma_bounding_box_unit,
                                      "km2" ~ gamma_bounding_box,
                                      "m2" ~ gamma_bounding_box / 1000000,
                                      "ha" ~ gamma_bounding_box / 100,
                                      "acres" ~ gamma_bounding_box * 0.004046856422,
                                      "mile2" ~ gamma_bounding_box * 2.589988),
      gamma_bounding_box_unit = NULL) |>
   rename(alpha_grain_m2 = alpha_grain,
          gamma_bounding_box_km2 = gamma_bounding_box,
          gamma_sum_grains_km2 = gamma_sum_grains) |>
   data.table::as.data.table()

meta_standardised[is.na(alpha_grain_m2), unique(dataset_id)]
meta_standardised[is.na(gamma_sum_grains_km2) & is.na(gamma_bounding_box_km2), unique(dataset_id)]

# Converting coordinates into a common format with parzer ----
meta_standardised <- left_join(
   x = meta_standardised,
   y = unique(meta_standardised[, .(latitude, longitude)]) |>
      mutate(latitude = as.character(latitude),
             longitude = as.character(longitude)) |>
      mutate(lat = parzer::parse_lat(latitude),
             lon = parzer::parse_lon(longitude)),
   join_by(latitude, longitude)) |>
   mutate(latitude = NULL,
          longitude = NULL) |>
   rename(latitude = lat, longitude = lon)

# Coordinate scale ----
meta_standardised <- meta_standardised |>
   dtplyr::lazy_dt(immutable = FALSE) |>
   group_by(dataset_id, regional) |>
   mutate(is_coordinate_local_scale = n_distinct(latitude) != 1L &&
             n_distinct(longitude) != 1L) |>
   data.table::as.data.table()


## Checks ----
### checking duplicated rows ----
if (anyDuplicated(meta_standardised)) warning("Duplicated rows in metadata")

### checking taxon ----
if (any(meta_standardised[, data.table::uniqueN(taxon), keyby = dataset_id]$V1 != 1L)) warning(paste0("several taxa values in ", paste(meta_standardised[, data.table::uniqueN(taxon), keyby = dataset_id][V1 != 1L, dataset_id], collapse = ", ")))
if (any(!unique(meta_standardised$taxon) %in% c("Fish", "Invertebrates", "Plants", "Birds", "Mammals", "Herpetofauna", "Marine plants"))) warning(paste0("Non standard taxon category in ", paste(unique(meta_standardised[!taxon %in% c("Fish", "Invertebrates", "Plants", "Birds", "Mammals", "Herpetofauna", "Marine plants"), .(dataset_id), keyby = dataset_id]$dataset_id), collapse = ", ")))

### checking encoding ----
try(for (i in seq_along(lst_metadata_standardised)) if (any(!unlist(unique(apply(lst_metadata_standardised[[i]][, c("local", "regional", "comment")], 2L, Encoding))) %in% c("UTF-8", "unknown"))) warning(paste0("Encoding issue in ", listfiles_metadata_standardised[i])),
    silent = TRUE)


### checking year range length among regions ----
meta_standardised[, year := as.integer(as.character(year))]
if (any(meta_standardised[, diff(range(year)) < 9L, keyby = .(dataset_id, regional, local)]$V1)) warning(
   paste(
      "Time periods shorter than 10 years in: ",
      paste(meta_standardised[, .(diff(range(year))), keyby = .(dataset_id, regional, local)][V1 < 9L, unique(dataset_id)], collapse = ", ")
   )
)

### checking year range homogeneity among regions ----
if (any(meta_standardised[, data.table::uniqueN(paste(range(year), collapse = "-")),
                          keyby = .(dataset_id, regional)]$V1 != 1L)) warning("all local scale sites were not sampled for the same years and timepoints has to be consistent with years")

### checking study_type ----
if (any(!meta_standardised$study_type %in% c("ecological_sampling", "resurvey"))) warning(
   paste(
      "study_type has to be either 'ecological_sampling' or 'resurvey', see: ",
      paste(meta_standardised[!study_type  %in% c("ecological_sampling", "resurvey"), unique(dataset_id)], collapse = ", ")
   )
)

### checking effort ----
unique(meta_standardised[effort == "unknown" | is.na(effort), .(dataset_id, effort)])
# all(meta[(checklist), effort] == 1)

### checking data_pooled_by_authors ----
meta_standardised <- meta_standardised |>
   mutate(data_pooled_by_authors = as.logical(data_pooled_by_authors)) |>
   mutate(data_pooled_by_authors = if_else(
      condition = is.na(data_pooled_by_authors),
      true = FALSE,
      false = data_pooled_by_authors))

if (any(meta_standardised[(data_pooled_by_authors), is.na(sampling_years)])) warning(
   paste0("Missing sampling_years values in: ",
          paste(meta_standardised[(data_pooled_by_authors) & is.na(sampling_years), unique(dataset_id)], collapse = ", ")))

if (any(meta_standardised[(data_pooled_by_authors), is.na(data_pooled_by_authors_comment)])) warning(paste("Missing data_pooled_by_authors_comment values in", meta_standardised[(data_pooled_by_authors) & is.na(data_pooled_by_authors_comment), paste(unique(dataset_id), collapse = ", ")]))

## checking comment ----
if (anyNA(meta_standardised$comment)) warning("Missing comment value")
if (data.table::uniqueN(meta_standardised$comment) != data.table::uniqueN(meta_standardised$dataset_id)) warning("Redundant comment values")

### checking comment_standardisation ----
if (anyNA(meta_standardised$comment_standardisation)) warning("Missing comment_standardisation value")

## Checking that there is only one alpha_grain value per dataset_id ----
if (meta_standardised[, data.table::uniqueN(alpha_grain_m2), keyby = dataset_id][, any(V1 != 1L)]) warning(paste(
   "Inconsistent grain in",
   paste(
      meta_standardised[, data.table::uniqueN(alpha_grain_m2), keyby = dataset_id][V1 != 1L, unique(dataset_id)],
      collapse = ", ")
))

### checking alpha_grain_type ----
# meta[(!checklist), .(lterm = diff(range(year)), taxon = taxon, realm = realm, alpha_grain_type = alpha_grain_type), keyby = .(dataset_id, regional)][lterm >= 10L][taxon == "Fish" & realm == "Freshwater" & grep("lake",alpha_grain_type), unique(dataset_id)]
if (any(!unique(meta_standardised$alpha_grain_type) %in% c("island", "plot", "sample", "lake_pond", "trap", "transect", "functional", "box", "quadrat", "listening_point"))) warning(paste("Invalid alpha_grain_type value in", paste(unique(meta_standardised[!alpha_grain_type %in% c("island", "plot", "sample", "lake_pond", "trap", "transect", "functional", "box", "quadrat", "listening_point"), dataset_id]), collapse = ", ")))

### checking gamma_sum_grains_type & gamma_bounding_box_type ----
if (any(!na.omit(unique(meta_standardised$gamma_sum_grains_type)) %in% c("archipelago", "sample", "lake_pond", "plot", "quadrat", "transect", "functional", "box"))) warning(paste("Invalid gamma_sum_grains_type value in", paste(unique(meta_standardised[!is.na(gamma_sum_grains_type) & !gamma_sum_grains_type %in% c("archipelago", "sample", "lake_pond", "plot", "quadrat", "transect", "functional", "box"), dataset_id]), collapse = ", ")))

if (any(!na.omit(unique(meta_standardised$gamma_bounding_box_type)) %in% c("administrative", "island", "functional", "convex-hull", "watershed", "box", "buffer", "ecosystem", "shore", "lake_pond"))) warning(paste("Invalid gamma_bounding_box_type value in", paste(unique(meta_standardised[!is.na(gamma_bounding_box_type) & !gamma_bounding_box_type %in% c("administrative", "island", "functional", "convex-hull", "watershed", "box", "buffer", "ecosystem", "shore", "lake_pond"), dataset_id]), collapse = ", ")))

### checking gamma_bouding_box ----
meta_standardised <- meta_standardised |>
mutate(gamma_bounding_box_km2 = if_else(
   condition = gamma_bounding_box_km2 == 0,
   true = NA_real_,
   false = gamma_bounding_box_km2))

# Adding a unique ID ----
source(file = "R/functions/assign_id.R")
meta_standardised <- meta_standardised |>
   mutate(ID = assign_id(dataset_id, regional))
dt_standardised <- dt_standardised |>
   mutate(ID = assign_id(dataset_id, regional))

# Ordering metadata ----
data.table::setorder(meta_standardised, ID, regional, local, year)
data.table::setcolorder(
   x = meta_standardised,
   neworder = c("ID",
                base::intersect(column_names_template_metadata_standardised,
                                colnames(meta_standardised))))
data.table::setcolorder(meta_standardised, "alpha_grain_m2",
                        before = "alpha_grain_type")
data.table::setcolorder(meta_standardised, "gamma_sum_grains_km2",
                        before = "gamma_sum_grains_type")
data.table::setcolorder(meta_standardised, "gamma_bounding_box_km2",
                        before = "gamma_bounding_box_type")
data.table::setcolorder(meta_standardised, "is_coordinate_local_scale",
                        before = "alpha_grain_m2")

# Checking that all data sets have both community and metadata data ----
if (length(base::setdiff(unique(dt_standardised$dataset_id), unique(meta_standardised$dataset_id))) > 0L) warning("Incomplete community or metadata tables")
if (any(meta_standardised[, .N, keyby = .(dataset_id, regional, local, year)][, N != 1L])) warning(
   paste("Several values per local year in metadata of data sets:",
         paste(meta_standardised[, .N, keyby = .(dataset_id, regional, local, year)][N != 1L][, unique(dataset_id)], collapse = ", ")))
if (nrow(meta_standardised) != nrow(unique(meta_standardised[, .(ID, regional, local, year)]))) warning("Redundant rows in meta")
if (nrow(meta_standardised) != nrow(unique(dt_standardised[, .(ID, regional, local, year)]))) warning(
   paste("Discrepancies between dt and meta",
         paste(unique(meta_standardised$dataset_id)[meta_standardised[, .N, keyby = ID]$N !=  dt_standardised[, data.table::uniqueN(.SD), .SDcols = c("ID","regional","local","year"), keyby = ID]$V1],
               collapse = ", ")
   )
)

# Saving private data ----
# if (file.exists("data/references/homogenisation_dropbox_folder_path.rds")) {
#    path_to_homogenisation_dropbox_folder <- base::readRDS(file = "data/references/homogenisation_dropbox_folder_path.rds")
#    data.table::fwrite(dt_standardised, paste0(path_to_homogenisation_dropbox_folder, "/metacommunity-survey_communities-standardised.csv"), row.names = FALSE)
# }
# if (file.exists("data/references/homogenisation_dropbox_folder_path.rds")) {
#    data.table::fwrite(meta_standardised, paste0(path_to_homogenisation_dropbox_folder, "/metacommunity-survey_metadata-standardised.csv"), sep = ",", row.names = FALSE)
# }

## Removing not shareable data sets before publication ----
dt_standardised <- dt_standardised |>
   filter(!grepl(pattern = "myers-smith|edgar", x = dataset_id))
meta_standardised <- meta_standardised |>
   filter(!grepl(pattern = "myers-smith|edgar", x = dataset_id))

# Saving public dt ----
data.table::setcolorder(x = dt_standardised,
                        neworder = c("ID", "dataset_id", "regional", "local",
                                     "year", "species", "species_original",
                                     "value", "metric", "unit"))
base::saveRDS(dt_standardised, file = "data/communities_standardised.rds")
# data.table::fwrite(dt_standardised, "data/communities_standardised.csv",
#                    sep = ",",
#                    row.names = FALSE) # for iDiv data portal: add , na = "NA"


# Saving public meta ----
base::saveRDS(meta_standardised, file = "data/metadata_standardised.rds")
# data.table::fwrite(meta_standardised, "data/metadata_standardised.csv",
#                    sep = ",",
#                    row.names = FALSE) # for iDiv data portal: add , na = "NA"
