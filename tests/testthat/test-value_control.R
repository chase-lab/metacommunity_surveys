# Using testthat Edition 3
testthat::local_edition(3)

# Paths to datasets ----
absolute_path <- rprojroot::find_rstudio_root_file()
require(withr)

#read input argument: edited files since last commit
args <- commandArgs()
listfiles <- tail(args, -5)

## raw data ----
listfiles_community_raw <- list.files(
   path = paste0(absolute_path, "/data/wrangled data"),
   pattern = "_raw.csv",
   full.names = TRUE, recursive = TRUE
)
#intersect listfiles_community_raw with modified listfiles
# listfiles_community_raw <- unique(grep(paste(listfiles, collapse = "|"),
#                                        listfiles_community_raw, value = TRUE))

listfiles_metadata_raw <- list.files(
   path = "data/wrangled data",
   pattern = "raw_metadata.csv",
   full.names = TRUE, recursive = TRUE
)
#intersect listfiles_metadata_raw with modified listfiles
# listfiles_metadata_raw <- unique(grep(paste(listfiles, collapse = "|"),
#                                       listfiles_metadata_raw, value = TRUE))

## standardised data ----
listfiles_community_standardised <- list.files(
   path = paste0(absolute_path, "/data/wrangled data"),
   pattern = "_standardised.csv",
   full.names = TRUE, recursive = TRUE
)
#intersect listfiles_community_standardsed with modified listfiles
# listfiles_community_standardised <- unique(grep(
#    paste(listfiles, collapse = "|"),
#    listfiles_community_standardised, value = TRUE))


listfiles_metadata_standardised <- list.files(
   path = paste0(absolute_path, "/data/wrangled data"),
   pattern = "standardised_metadata.csv",
   full.names = TRUE, recursive = TRUE
)

# intersect listfiles_metadata_standardised with modified listfiles
# listfiles_metadata_standardised <- unique(grep(
#    paste(listfiles, collapse = "|"),
#    listfiles_metadata_standardised, value = TRUE))


# Tests ----
## Community data ----
testthat::test_that(desc = "data quality check - community data - raw data", code = {
   for (i in listfiles_community_raw) {
      X <-  data.table::fread(file = i, sep = ",", dec = ".",
                              header = TRUE, stringsAsFactors = TRUE)
      testthat::expect_true(
         all(data.table::between(X$year, 1500L, 2023L)),
         info = paste("Year range", i))
      # if ("month" %in% colnames(X) && any(!is.na(X$month))) testthat::expect_true(
      #    X[, all(data.table::between(month, 1L, 12L))],
      #    info = paste("Month range", i))
      # if ("day" %in% colnames(X) && any(!is.na(X$day))) testthat::expect_true(
      #    X[, all(data.table::between(day, 1L, 31L))],
      #    info = paste("Day range", i))
      testthat::expect_true(
         suppressWarnings(
            X[, all(is.na(value) | is.factor(value) | value >= 0)]
         ),
         info = paste("Positive values", i))
      testthat::expect_equal(nlevels(X$dataset_id), 1L)
      testthat::expect_equal(nlevels(X$metric), 1L)
      testthat::expect_equal(nlevels(X$unit), 1L)
      checkmate::expect_choice(
         x = levels(X$metric),
         choices = c("abundance", "relative abundance", "density",
                     "cover", "Braun-Blanquet scale", "incidence",
                     "pa"),
         info = paste("metric is correct", i), null.ok = TRUE)
      checkmate::expect_choice(
         x = levels(X$unit),
         choices = c("count", "pa", "individuals per liter",
                     "individuals per mL", "individuals per sqm",
                     "individuals per 250m2",
                     "individuals per transect",
                     "cpue", "percent", "hits", "score", "unknown"),
         info = paste("unit is correct", i), null.ok = TRUE)
   }
})

testthat::test_that(desc = "data quality check - community data - standardised data", code = {
   for (i in listfiles_community_standardised) {
      X <- data.table::fread(file = i, sep = ",", dec = ".",
                             header = TRUE, stringsAsFactors = TRUE)
      testthat::expect_true(
         all(data.table::between(X$year, 1500L, 2023L)),
         info = paste("Year range", i))
      # if ("month" %in% colnames(X) && any(!is.na(X$month))) testthat::expect_true(
      #    X[, all(data.table::between(month, 1L, 12L))],
      #    info = paste("Month range", i))
      # if ("day" %in% colnames(X) && any(!is.na(X$day))) testthat::expect_true(
      #    X[, all(data.table::between(day, 1L, 31L))],
      #    info = paste("Day range", i))
      testthat::expect_true(
         suppressWarnings(
            X[, all(is.na(value) | is.factor(value) | value >= 0)]
         ),
         info = paste("Positive values", i))
      testthat::expect_equal(nlevels(X$dataset_id), 1L)
      testthat::expect_equal(nlevels(X$metric), 1L)
      testthat::expect_equal(nlevels(X$unit), 1L)
      checkmate::expect_choice(
         x = levels(X$metric),
         choices = c("abundance", "relative abundance", "density",
                     "cover", "pa"),
         info = paste("metric is correct", i), null.ok = TRUE)
      checkmate::expect_choice(
         x = levels(X$unit),
         choices = c("count", "pa", "individuals per liter",
                     "individuals per mL", "individuals per transect",
                     "individuals per 250m2", "individuals per sqm",
                     "cpue", "percent","unknown"),
         info = paste("unit is correct", i), null.ok = TRUE)
   }
})

## Meta data ----
testthat::test_that(desc = "data quality check - metadata data - raw data", code = {
   for (i in listfiles_metadata_raw) {
      X <- data.table::fread(file = i, sep = ",", dec = ".",
                             header = TRUE, stringsAsFactors = TRUE)
      X[, year := as.integer(as.character(year))]

      testthat::expect_true(
         all(data.table::between(X$year, 1500L, 2023L)),
         info = paste("Year range", i))
      testthat::expect_equal(nlevels(X$dataset_id), 1L)
      testthat::expect_equal(nlevels(X$study_type), 1L)
      testthat::expect_equal(nlevels(X$taxon), 1L)
      testthat::expect_equal(nlevels(X$realm), 1L)
      testthat::expect_true(
         nlevels(X$alpha_grain_unit) == 1L ||
            nlevels(X$alpha_grain_unit) == 0L,
         info = paste("alpha_grain_unit is unique", i))
      testthat::expect_true(
         nlevels(X$alpha_grain_type) == 1L ||
            nlevels(X$alpha_grain_type) == 0L,
         info = paste("alpha_grain_type is unique", i))

      checkmate::expect_choice(
         x = levels(X$study_type),
         choices = c("ecological_sampling", "resurvey"),
         info = paste("study_type is correct", i), null.ok = TRUE)
      checkmate::expect_choice(
         x = levels(X$taxon),
         choices = c("Fish", "Invertebrates", "Plants", "Birds", "Mammals",
                     "Herpetofauna", "Marine plants"),
         info = paste("taxon is correct", i), null.ok = TRUE)
      checkmate::expect_choice(
         x = levels(X$realm),
         choices = c("Terrestrial","Freshwater","Marine"),
         info = paste("realm is correct", i), null.ok = TRUE)
      checkmate::expect_choice(
         x = levels(X$alpha_grain_type),
         choices = c("island", "plot", "sample", "lake_pond", "trap","transect",
                     "functional", "box", "quadrat","listening_point"),
         info = paste("alpha_grain_type is correct", i), null.ok = TRUE)
      checkmate::expect_choice(
         x = levels(X$alpha_grain_unit),
         choices = c("acres", "ha", "km2", "m2", "cm2"),
         info = paste("alpha_grain_unit is correct", i), null.ok = TRUE)
   }
})


testthat::test_that(desc = "data quality check - metadata data - standardised data", code = {
   for (i in listfiles_metadata_standardised) {
      X <- data.table::fread(file = i, sep = ",", dec = ".",
                             header = TRUE, stringsAsFactors = TRUE)
      X[, year := as.integer(as.character(year))]

      testthat::expect_true(
         all(data.table::between(X$year, 1500L, 2023L)),
         info = paste("Year range", i))
      testthat::expect_equal(nlevels(X$dataset_id), 1L)
      testthat::expect_equal(nlevels(X$study_type), 1L)
      testthat::expect_equal(nlevels(X$taxon), 1L)
      testthat::expect_equal(nlevels(X$realm), 1L)
      testthat::expect_true(
         nlevels(X$alpha_grain_unit) == 1L ||
            nlevels(X$alpha_grain_unit) == 0L,
         info = paste("alpha_grain_unit is unique", i))
      testthat::expect_true(
         nlevels(X$alpha_grain_type) == 1L ||
            nlevels(X$alpha_grain_type) == 0L,
         info = paste("alpha_grain_type is unique", i))
      testthat::expect_true(
         nlevels(X$gamma_bounding_box_type) == 1L ||
            nlevels(X$gamma_bounding_box_type) == 0L,
         info = paste("gamma_bounding_box_type is unique", i))
      testthat::expect_true(
         nlevels(X$gamma_sum_grains_type) == 1L ||
            nlevels(X$gamma_sum_grains_type) == 0L,
         info = paste("gamma_sum_grains_type is unique", i))

      checkmate::expect_choice(
         x = levels(X$study_type),
         choices = c("ecological_sampling", "resurvey"),
         info = paste("study_type is correct", i), null.ok = TRUE)
      checkmate::expect_choice(
         x = levels(X$taxon),
         choices = c("Fish", "Invertebrates", "Plants", "Birds", "Mammals",
                     "Herpetofauna", "Marine plants"),
         info = paste("taxon is correct", i), null.ok = TRUE)
      checkmate::expect_choice(
         x = levels(X$realm),
         choices = c("Terrestrial","Freshwater","Marine"),
         info = paste("realm is correct", i), null.ok = TRUE)
      checkmate::expect_choice(
         x = levels(X$alpha_grain_type),
         choices = c("island", "plot", "sample", "lake_pond", "trap","transect",
                     "functional", "box", "quadrat","listening_point"),
         info = paste("alpha_grain_type is correct", i), null.ok = TRUE)
      checkmate::expect_choice(
         x = levels(X$alpha_grain_unit),
         choices = c("acres", "ha", "km2", "m2", "cm2"),
         info = paste("alpha_grain_unit is correct", i), null.ok = TRUE)
      checkmate::expect_choice(
         x = levels(X$gamma_sum_grains_type),
         choices = c("archipelago", "sample", "lake_pond", "plot", "quadrat",
                     "transect", "functional", "box"),
         info = paste("gamma_sum_grains_type is correct", i), null.ok = TRUE)
      checkmate::expect_choice(
         x = levels(X$gamma_bounding_box_type),
         choices = c("administrative", "island", "functional", "convex-hull",
                     "watershed", "box", "buffer", "ecosystem", "shore", "lake_pond"),
         info = paste("gamma_bounding_box_type is correct", i), null.ok = TRUE)
   }
})
