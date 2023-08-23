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
            length(levels(dataset_id)) == 1L,
            length(levels(metric)) == 1L,
            length(levels(unit)) == 1L,
            levels(metric) %in% c("abundance", "relative abundance", "density",
                                  "cover", "pa"),
            levels(unit) %in% c("count", "pa", "individuals per liter",
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
            length(levels(dataset_id)) == 1L,
            length(levels(metric)) == 1L,
            length(levels(unit)) == 1L,
            levels(metric) %in% c("abundance", "relative abundance", "density",
                                  "cover", "pa"),
            levels(unit) %in% c("count", "pa", "individuals per liter",
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
            length(levels(dataset_id)) == 1L,
            length(levels(study_type)) == 1L,
            length(levels(taxon)) == 1L,
            length(levels(realm)) == 1L,
            length(levels(alpha_grain_unit)) == 1L,
            length(levels(alpha_grain_type)) == 1L,
            levels(study_type) %in% c("ecological_sampling", "resurvey"),
            levels(taxon) %in% c("Fish", "Invertebrates", "Plants", "Birds", "Mammals",
                                 "Herpetofauna", "Marine plants"),
            levels(realm) %in% c("Terrestrial","Freshwater","Marine"),
            try(levels(alpha_grain_unit) %in% c("acres", "ha", "km2", "m2", "cm2")),
            try(levels(alpha_grain_type) %in% c("island", "plot", "sample", "lake_pond",
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
            length(levels(dataset_id)) == 1L,
            length(levels(study_type)) == 1L,
            length(levels(taxon)) == 1L,
            length(levels(realm)) == 1L,
            length(levels(alpha_grain_unit)) == 1L,
            length(levels(alpha_grain_type)) == 1L,
            length(levels(gamma_bounding_box_type)) == 1L,
            length(levels(gamma_sum_grains_type)) == 1L,
            levels(study_type) %in% c("ecological_sampling", "resurvey"),
            levels(taxon) %in% c("Fish", "Invertebrates", "Plants", "Birds", "Mammals",
                                 "Herpetofauna", "Marine plants"),
            levels(realm) %in% c("Terrestrial","Freshwater","Marine"),
            try(levels(alpha_grain_type) %in% c("island", "plot", "sample", "lake_pond",
                                                "trap", "transect", "functional", "box",
                                                "quadrat","listening_point")),
            try(levels(alpha_grain_unit) %in% c("acres", "ha", "km2", "m2", "cm2")),
            try(levels(gamma_sum_grains_type) %in% c("archipelago", "sample", "lake_pond",
                                                     "plot", "quadrat", "transect",
                                                     "functional", "box")),
            try(levels(gamma_bounding_box_type) %in% c("administrative", "island", "functional",
                                                       "convex-hull", "watershed", "box",
                                                       "buffer", "ecosystem", "shore",
                                                       "lake_pond")),
            na.rm = TRUE
         ))]),
         info = i
      )
   }
})
