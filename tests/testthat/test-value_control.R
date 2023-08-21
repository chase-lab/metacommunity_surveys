# Paths to datasets ----
absolute_path <- rprojroot::find_rstudio_root_file()

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
listfiles_community_raw <- unique(grep(paste(listfiles, collapse = "|"),
                                       listfiles_community_raw, value = TRUE))

listfiles_metadata_raw <- list.files(
   path = "data/wrangled data",
   pattern = "raw_metadata.csv",
   full.names = TRUE, recursive = TRUE
)
#intersect listfiles_metadata_raw with modified listfiles
listfiles_metadata_raw <- unique(grep(paste(listfiles, collapse = "|"),
                                      listfiles_metadata_raw, value = TRUE))

## standardised data ----
listfiles_community_standardised <- list.files(
   path = paste0(absolute_path, "/data/wrangled data"),
   pattern = "_standardised.csv",
   full.names = TRUE, recursive = TRUE
)
#intersect listfiles_community_standardsed with modified listfiles
listfiles_community_standardised <- unique(grep(paste(listfiles, collapse = "|"),
                                                listfiles_community_standardised, value = TRUE))


listfiles_metadata_standardised <- list.files(
   path = paste0(absolute_path, "/data/wrangled data"),
   pattern = "standardised_metadata.csv",
   full.names = TRUE, recursive = TRUE
)

# intersect listfiles_metadata_standardised with modified listfiles
listfiles_metadata_standardised <- unique(grep(paste(listfiles, collapse = "|"),
                                               listfiles_metadata_standardised, value = TRUE))


# Tests ----
## Community data ----
testthat::test_that(desc = "data quality check - community data - raw data", code = {
   for (i in listfiles_community_raw) {
      testthat::expect_true(unlist(
         data.table::fread(
            file = i, sep = ",", dec = ".", header = TRUE, stringsAsFactors = TRUE
         )[, .(all(
            all(data.table::between(year, 1500L, 2023L)),
            all(try(data.table::between(month, 1L, 12L))),
            all(try(data.table::between(day, 1L, 31L))),
            all(value > 0),
            data.table::uniqueN(dataset_id) == 1L,
            data.table::uniqueN(metric) == 1L,
            data.table::uniqueN(unit) == 1L,
            metric[1L] %in% c("abundance", "relative abundance", "density",
                              "cover", "pa"),
            unit[1L] %in% c("count", "pa", "individuals per liter",
                            "individuals per mL", "individuals per transect",
                            "cpue", "percent"),
            na.rm = TRUE
         ))]),
         info = i
      )
   }
})

testthat::test_that(desc = "data quality check - community data - standardised data", code = {
   for (i in listfiles_community_standardised) {
      testthat::expect_true(unlist(
         data.table::fread(
            file = i, sep = ",", dec = ".", header = TRUE, stringsAsFactors = TRUE
         )[, .(all(
            all(data.table::between(year, 1500L, 2023L)),
            all(value > 0),
            data.table::uniqueN(dataset_id) == 1L,
            data.table::uniqueN(metric) == 1L,
            data.table::uniqueN(unit) == 1L,
            metric[1L] %in% c("abundance", "relative abundance", "density",
                              "cover", "pa"),
            unit[1L] %in% c("count", "pa", "individuals per liter",
                            "individuals per mL", "individuals per transect",
                            "cpue", "percent"),
            na.rm = TRUE
         ))]),
         info = i
      )
   }
})

## Meta data ----
testthat::test_that(desc = "data quality check - metadata data - raw data", code = {
   for (i in listfiles_metadata_raw) {
      testthat::expect_true(unlist(
         data.table::fread(
            file = i, sep = ",", dec = ".", header = TRUE, stringsAsFactors = TRUE
         )[, .(all(
            all(data.table::between(year, 1500L, 2023L)),
            data.table::uniqueN(dataset_id) == 1L,
            data.table::uniqueN(study_type) == 1L,
            data.table::uniqueN(taxon) == 1L,
            data.table::uniqueN(realm) == 1L,
            data.table::uniqueN(alpha_grain_unit) == 1L,
            data.table::uniqueN(alpha_grain_type) == 1L,
            study_type[1L] %in% c("ecological_sampling", "resurvey"),
            taxon[1L] %in% c("Fish", "Invertebrates", "Plants", "Birds", "Mammals",
                             "Herpetofauna", "Marine plants"),
            realm[1L] %in% c("Terrestrial","Freshwater","Marine"),
            try(alpha_grain_unit[1L] %in% c("acres", "ha", "km2", "m2", "cm2")),
            try(alpha_grain_type[1L] %in% c("island", "plot", "sample", "lake_pond",
                                        "trap", "transect", "functional", "box",
                                        "quadrat","listening_point")),
            na.rm = TRUE
         ))]),
         info = i
      )
   }
})


testthat::test_that(desc = "data quality check - metadata data - standardised data", code = {
   for (i in listfiles_metadata_standardised) {
      testthat::expect_true(unlist(
         data.table::fread(
            file = i, sep = ",", dec = ".", header = TRUE, stringsAsFactors = TRUE
         )[, .(all(
            all(data.table::between(year, 1500L, 2023L)),
            data.table::uniqueN(dataset_id) == 1L,
            data.table::uniqueN(study_type) == 1L,
            data.table::uniqueN(taxon) == 1L,
            data.table::uniqueN(realm) == 1L,
            data.table::uniqueN(alpha_grain_unit) == 1L,
            data.table::uniqueN(alpha_grain_type) == 1L,
            data.table::uniqueN(gamma_bounding_box_type) == 1L,
            data.table::uniqueN(gamma_sum_grains_type) == 1L,
            study_type[1L] %in% c("ecological_sampling", "resurvey"),
            taxon[1L] %in% c("Fish", "Invertebrates", "Plants", "Birds", "Mammals",
                             "Herpetofauna", "Marine plants"),
            realm[1L] %in% c("Terrestrial","Freshwater","Marine"),
            try(alpha_grain_type[1L] %in% c("island", "plot", "sample", "lake_pond",
                                        "trap", "transect", "functional", "box",
                                        "quadrat","listening_point")),
            try(alpha_grain_unit[1L] %in% c("acres", "ha", "km2", "m2", "cm2")),
            try(gamma_sum_grains_type[1L] %in% c("archipelago", "sample", "lake_pond",
                                             "plot", "quadrat", "transect",
                                             "functional", "box")),
            try(gamma_bounding_box_type[1L] %in% c("administrative", "island", "functional",
                                               "convex-hull", "watershed", "box",
                                               "buffer", "ecosystem", "shore",
                                               "lake_pond")),
            na.rm = TRUE
         ))]),
         info = i
      )
   }
})
