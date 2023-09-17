# STANDARDISED DATA ----
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
                                     FUN = data.table::fread, integer64 = "character", encoding = "UTF-8",
                                     stringsAsFactors = TRUE)
dt_standardised <- data.table::rbindlist(lst_community_standardised, fill = TRUE)

template_metadata_standardised <- utils::read.csv(file = "data/template_metadata_standardised.txt", header = TRUE, sep = "\t")
column_names_template_metadata_standardised <- template_metadata_standardised[, 1L]

lst_metadata_standardised <- lapply(listfiles_metadata_standardised,
                                    FUN = data.table::fread, integer64 = "character", encoding = "UTF-8",
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
if (dt_standardised[, any(is.na(species) | species == "")]) warning(paste("missing _species_ value in ", unique(dt_standardised[is.na(species) | species == "", dataset_id]), collapse = ", "))
if (dt_standardised[, any(is.na(value) | value == "" | value <= 0)]) warning(paste("missing _value_ value in ", unique(dt_standardised[is.na(value) | value == "" | value <= 0, dataset_id]), collapse = ", "))
if (dt_standardised[, any(is.na(metric) | metric == "")]) warning(paste("missing _metric_ value in ", unique(dt_standardised[is.na(metric) | metric == "", dataset_id]), collapse = ", "))
if (dt_standardised[, any(is.na(unit) | unit == "")]) warning(paste("missing _unit_ value in ", unique(dt_standardised[is.na(unit) | unit == "", dataset_id]), collapse = ", "))

### Counting the study cases ----
dt_standardised[, .(nsites = data.table::uniqueN(.SD)), .SDcols = c('regional', 'local'), by = .(dataset_id)][order(nsites, decreasing = TRUE)]

## Ordering ----
# data.table::setcolorder(dt, intersect(column_names_template, colnames(dt)))
data.table::setorder(dt_standardised, dataset_id, regional, local,
                     year, species)

## Deleting special characters in regional and local ----
# dt[, ":="(
#   local = iconv(local, from = "UTF-8", to = "ASCII")
# )]

## Checks ----

### checking duplicated rows ----
if (anyDuplicated(dt_standardised)) warning(
   paste(
      "Duplicated rows in dt, see:",
      paste(dt_standardised[duplicated(dt_standardised), unique(dataset_id)], collapse = ", ")
   )
)

if (any(dt_standardised[, .N, by = .(dataset_id, regional, local, year, species)]$N != 1L))
   warning(paste(
      'duplicated species in:',
      paste(collapse = ', ',
            dt_standardised[, .N, by = .(dataset_id, regional, local, year, species)][N != 1L, unique(dataset_id)])))

### checking values ----
if (dt_standardised[unit == "count", any(!is.integer(value))]) warning(paste("Non integer values in", paste(dt_standardised[unit == "count" & !is.integer(value), unique(dataset_id)], collapse = ", ")))

### checking species names ----
for (i in seq_along(lst_community_standardised)) if (is.character(lst_community_standardised[[i]]$species)) if (any(!unique(Encoding(lst_community_standardised[[i]]$species)) %in% c("UTF-8", "unknown"))) warning(paste0("Encoding issue in ", listfiles_community_standardised[i]))

#### adding GBIF matched names by Dr. Wubing Xu ----
corrected_species_names <- data.table::fread(
   file = "data/requests to taxonomy databases/manual_community_species_filled_20221003.csv",
   select = c("dataset_id", "species", "species.new")
)

# data.table join with update by reference
dt_standardised[corrected_species_names, on = .(dataset_id, species), species.new := i.species.new]

data.table::setnames(dt_standardised, c("species", "species.new"), c("species_original", "species"))
dt_standardised[is.na(species), species := species_original]
# unique(dt[grepl("[^a-zA-Z\\._ ]", species) & nchar(species) < 10L, .(dataset_id)])
# unique(dt[grepl("[^a-zA-Z\\._ \\(\\)0-9\\-\\&]", species), .(dataset_id, species)])[sample(1:1299, 50)]
# unique(dt[grepl("Â", species), .(dataset_id, species)])


### checking metrics and units ----
if (!all(dt_standardised[metric == "pa", unit == "pa"]) || !all(dt_standardised[unit == "pa", metric == "pa"]) || !all(dt_standardised[metric == "pa" | unit == "pa", value == 1])) warning("inconsistent presence absence coding")
if (any(dt_standardised[, data.table::uniqueN(unit), by = dataset_id]$V1 != 1L)) warning("several units in a single data set")


## Metadata ----
meta_standardised <- meta_standardised[
   unique(dt_standardised[, .(dataset_id, regional, local, year)]),
   on = .(dataset_id, regional, local, year)
]

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
meta_standardised[, alpha_grain := as.numeric(alpha_grain)][,
                                                            alpha_grain := data.table::fcase(
                                                               alpha_grain_unit == "m2", alpha_grain,
                                                               alpha_grain_unit == "cm2", alpha_grain / 10^4,
                                                               alpha_grain_unit == "ha", alpha_grain * 10^4,
                                                               alpha_grain_unit == "km2", alpha_grain * 10,
                                                               alpha_grain_unit == "acres", alpha_grain * 4046.856422
                                                            )
][, alpha_grain_unit := NULL]

meta_standardised[, gamma_sum_grains := as.numeric(gamma_sum_grains)][,
                                                                      gamma_sum_grains := data.table::fcase(
                                                                         gamma_sum_grains_unit == "km2", gamma_sum_grains,
                                                                         gamma_sum_grains_unit == "m2", gamma_sum_grains / 10^6,
                                                                         gamma_sum_grains_unit == "ha", gamma_sum_grains / 100,
                                                                         gamma_sum_grains_unit == "cm2", gamma_sum_grains / 10^10,
                                                                         gamma_sum_grains_unit == "acres", gamma_sum_grains * 0.004046856422
                                                                      )
][, gamma_sum_grains_unit := NULL]

meta_standardised[, gamma_bounding_box := as.numeric(gamma_bounding_box)][,
                                                                          gamma_bounding_box := data.table::fcase(
                                                                             gamma_bounding_box_unit == "km2", gamma_bounding_box,
                                                                             gamma_bounding_box_unit == "m2", gamma_bounding_box / 1000000,
                                                                             gamma_bounding_box_unit == "ha", gamma_bounding_box / 100,
                                                                             gamma_bounding_box_unit == "acres", gamma_bounding_box * 0.004046856422,
                                                                             gamma_bounding_box_unit == "mile2", gamma_bounding_box * 2.589988
                                                                          )
][, gamma_bounding_box_unit := NULL]

data.table::setnames(meta_standardised, c("alpha_grain", "gamma_bounding_box", "gamma_sum_grains"), c("alpha_grain_m2", "gamma_bounding_box_km2", "gamma_sum_grains_km2"))

meta_standardised[is.na(alpha_grain_m2), unique(dataset_id)]
meta_standardised[is.na(gamma_sum_grains_km2) & is.na(gamma_bounding_box_km2), unique(dataset_id)]

## Converting coordinates into a common format with parzer ----
meta_standardised[, ":="(
   latitude = as.character(latitude),
   longitude = as.character(longitude)
)]
unique_coordinates_standardised <- unique(meta_standardised[, .(latitude, longitude)])
unique_coordinates_standardised[, ":="(
   lat = parzer::parse_lat(latitude),
   lon = parzer::parse_lon(longitude)
)]
unique_coordinates_standardised[is.na(lat) | is.na(lon)]
# data.table join with update by reference
meta_standardised[
   unique_coordinates_standardised,
   on = .(latitude, longitude),
   ":="(latitude = i.lat, longitude = i.lon)]
# meta_standardised <- merge(meta_standardised, unique_coordinates_standardised, by = c("latitude", "longitude"))
# meta_standardised[, c("latitude", "longitude") := NULL]
# data.table::setnames(meta_standardised, c("lat", "lon"), c("latitude", "longitude"))

## Coordinate scale ----
meta_standardised[, is_coordinate_local_scale := data.table::uniqueN(latitude) != 1L && data.table::uniqueN(longitude) != 1L,
                  by = .(dataset_id, regional)]


## Checks ----
### checking duplicated rows ----
if (anyDuplicated(meta_standardised)) warning("Duplicated rows in metadata")

### checking taxon ----
if (any(meta_standardised[, data.table::uniqueN(taxon), by = dataset_id]$V1 != 1L)) warning(paste0("several taxa values in ", paste(meta_standardised[, data.table::uniqueN(taxon), by = dataset_id][V1 != 1L, dataset_id], collapse = ", ")))
if (any(!unique(meta_standardised$taxon) %in% c("Fish", "Invertebrates", "Plants", "Birds", "Mammals", "Herpetofauna", "Marine plants"))) warning(paste0("Non standard taxon category in ", paste(unique(meta_standardised[!taxon %in% c("Fish", "Invertebrates", "Plants", "Birds", "Mammals", "Herpetofauna", "Marine plants"), .(dataset_id), by = dataset_id]$dataset_id), collapse = ", ")))

### checking encoding ----
try(for (i in seq_along(lst_metadata_standardised)) if (any(!unlist(unique(apply(lst_metadata_standardised[[i]][, c("local", "regional", "comment")], 2L, Encoding))) %in% c("UTF-8", "unknown"))) warning(paste0("Encoding issue in ", listfiles_metadata_standardised[i])))


### checking year range length among regions ----
if (any(meta_standardised[, diff(range(year)) < 9L, by = .(dataset_id, regional, local)]$V1))
   warning(
      paste(
         "Time periods shorter than 10 years in: ",
         paste(meta_standardised[, .(diff(range(year))), by = .(dataset_id, regional, local)][V1 < 9L, unique(dataset_id)], collapse = ", ")
      )
   )

### checking year range homogeneity among regions ----
if (any(meta_standardised[, data.table::uniqueN(paste(range(year), collapse = "-")),
                          by = .(dataset_id, regional)]$V1 != 1L)) warning("all local scale sites were not sampled for the same years and timepoints has to be consistent with years")

### checking study_type ----
if (any(!meta_standardised$study_type %in% c("ecological_sampling", "resurvey")))
   warning(
      paste(
         "study_type has to be either 'ecological_sampling' or 'resurvey', see: ",
         paste(meta_standardised[!study_type  %in% c("ecological_sampling", "resurvey"), unique(dataset_id)], collapse = ", ")
      )
   )

### checking effort ----
unique(meta_standardised[effort == "unknown" | is.na(effort), .(dataset_id, effort)])
# all(meta[(checklist), effort] == 1)

### checking data_pooled_by_authors ----
meta_standardised[is.na(data_pooled_by_authors), data_pooled_by_authors := FALSE]
if (any(meta_standardised[(data_pooled_by_authors), is.na(sampling_years)])) warning(
   paste0("Missing sampling_years values in: ",
          paste(meta_standardised[(data_pooled_by_authors) & is.na(sampling_years), unique(dataset_id)], collapse = ", "))
)
if (any(meta_standardised[(data_pooled_by_authors), is.na(data_pooled_by_authors_comment)])) warning(paste("Missing data_pooled_by_authors_comment values in", meta_standardised[(data_pooled_by_authors) & is.na(data_pooled_by_authors_comment), paste(unique(dataset_id), collapse = ", ")]))

## checking comment ----
if (anyNA(meta_standardised$comment)) warning("Missing comment value")
if (data.table::uniqueN(meta_standardised$comment) != data.table::uniqueN(meta_standardised$dataset_id)) warning("Redundant comment values")

### checking comment_standardisation ----
if (anyNA(meta_standardised$comment_standardisation)) warning("Missing comment_standardisation value")

## Checking that there is only one alpha_grain value per dataset_id ----
if (any(meta_standardised[, any(data.table::uniqueN(alpha_grain_m2) != 1L),
                          by = .(dataset_id, regional)]$V1)) warning(paste(
                             "Inconsistent grain in",
                             meta_standardised[, data.table::uniqueN(alpha_grain_m2) != 1L,
                                               by = .(dataset_id, regional)][, unique(dataset_id)]
                          ))

### checking alpha_grain_type ----
# meta[(!checklist), .(lterm = diff(range(year)), taxon = taxon, realm = realm, alpha_grain_type = alpha_grain_type), by = .(dataset_id, regional)][lterm >= 10L][taxon == "Fish" & realm == "Freshwater" & grep("lake",alpha_grain_type), unique(dataset_id)]
if (any(!unique(meta_standardised$alpha_grain_type) %in% c("island", "plot", "sample", "lake_pond", "trap", "transect", "functional", "box", "quadrat", "listening_point"))) warning(paste("Invalid alpha_grain_type value in", paste(unique(meta_standardised[!alpha_grain_type %in% c("island", "plot", "sample", "lake_pond", "trap", "transect", "functional", "box", "quadrat", "listening_point"), dataset_id]), collapse = ", ")))

### checking gamma_sum_grains_type & gamma_bounding_box_type ----
if (any(!na.omit(unique(meta_standardised$gamma_sum_grains_type)) %in% c("archipelago", "sample", "lake_pond", "plot", "quadrat", "transect", "functional", "box"))) warning(paste("Invalid gamma_sum_grains_type value in", paste(unique(meta_standardised[!is.na(gamma_sum_grains_type) & !gamma_sum_grains_type %in% c("archipelago", "sample", "lake_pond", "plot", "quadrat", "transect", "functional", "box"), dataset_id]), collapse = ", ")))

if (any(!na.omit(unique(meta_standardised$gamma_bounding_box_type)) %in% c("administrative", "island", "functional", "convex-hull", "watershed", "box", "buffer", "ecosystem", "shore", "lake_pond"))) warning(paste("Invalid gamma_bounding_box_type value in", paste(unique(meta_standardised[!is.na(gamma_bounding_box_type) & !gamma_bounding_box_type %in% c("administrative", "island", "functional", "convex-hull", "watershed", "box", "buffer", "ecosystem", "shore", "lake_pond"), dataset_id]), collapse = ", ")))

## Ordering metadata ----
data.table::setorder(meta_standardised, dataset_id, regional, local, year)
data.table::setcolorder(meta_standardised, base::intersect(column_names_template_metadata_standardised, colnames(meta_standardised)))



## Checking that all data sets have both community and metadata data ----
if (length(base::setdiff(unique(dt_standardised$dataset_id), unique(meta_standardised$dataset_id))) > 0L) warning("Incomplete community or metadata tables")
if (any(meta_standardised[, .N, by = .(dataset_id, regional, local, year)][, N != 1L])) warning(
   paste("Several values per local year in metadata of data sets:",
         paste(meta_standardised[, .N, by = .(dataset_id, regional, local, year)][N != 1L][, unique(dataset_id)], collapse = ", ")))
if (nrow(meta_standardised) != nrow(unique(meta_standardised[, .(dataset_id, regional, local, year)]))) warning("Redundant rows in meta")
if (nrow(meta_standardised) != nrow(unique(dt_standardised[, .(dataset_id, regional, local, year)]))) warning("Discrepancies between dt and meta")


## Saving dt ----
data.table::setcolorder(dt_standardised, c("dataset_id", "regional", "local", "year", "species", "species_original", "value", "metric", "unit"))

data.table::fwrite(dt_standardised, "data/communities_standardised.csv", row.names = FALSE) # for iDiv data portal: add , na = "NA"

# if (file.exists("data/references/homogenisation_dropbox_folder_path.rds")) {
#    path_to_homogenisation_dropbox_folder <- base::readRDS(file = "data/references/homogenisation_dropbox_folder_path.rds")
#    data.table::fwrite(dt_standardised, paste0(path_to_homogenisation_dropbox_folder, "/metacommunity-survey-raw-communities.csv"), row.names = FALSE)
# }


## Saving meta ----
data.table::fwrite(meta_standardised, "data/metadata_standardised.csv", sep = ", ", row.names = FALSE) # for iDiv data portal: add , na = "NA"
# if (file.exists("data/references/homogenisation_dropbox_folder_path.rds"))
#    data.table::fwrite(meta_standardised, paste0(path_to_homogenisation_dropbox_folder, "/metacommunity-survey-metadata-raw.csv"), sep = ", ", row.names = FALSE)
