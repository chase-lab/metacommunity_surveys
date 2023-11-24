# Using testthat Edition 3
testthat::local_edition(3)

# Paths to datasets ----
absolute_path <- rprojroot::find_rstudio_root_file()
require(withr)

#read input argument: edited files since last commit
# args <- commandArgs()
# listfiles <- tail(args, -5)

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
   path = paste0(absolute_path, "/data/wrangled data"),
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
# listfiles_community_standardised <- unique(grep(paste(listfiles, collapse = "|"),
#                                                 listfiles_community_standardised, value = TRUE))


listfiles_metadata_standardised <- list.files(
   path = paste0(absolute_path, "/data/wrangled data"),
   pattern = "standardised_metadata.csv",
   full.names = TRUE, recursive = TRUE
)

# intersect listfiles_metadata_standardised with modified listfiles
# listfiles_metadata_standardised <- unique(grep(paste(listfiles, collapse = "|"),
#                                                listfiles_metadata_standardised, value = TRUE))

indispensable_variables <- sapply(X = c(
   "/data/template_communities_raw.txt",
   "/data/template_metadata_raw.txt",
   "/data/template_communities_standardised.txt",
   "/data/template_metadata_standardised.txt"),
   \(x) {
      tmp <- data.table::fread(
         file = paste0(absolute_path, x),
         sep = "\t", header = TRUE, stringsAsFactors = FALSE) |>
         _[i = (necessary), j = `variable name`]
   }, USE.NAMES = TRUE, simplify = FALSE)







# Tests ----
## Raw data ----
### Community data ----
testthat::test_that(
   desc = "no NA values - community data - raw data",
   code = {
      variables <- unlist(indispensable_variables["/data/template_communities_raw.txt"])

      for (i in listfiles_community_raw) {
         testthat::expect_false(
            base::any(
               data.table::fread(
                  file = i, sep = ",", dec = ".",
                  header = TRUE, stringsAsFactors = TRUE
               )[j = lapply(.SD, checkmate::anyMissing),
                 .SDcols = variables]
            ), info = i
         )
      }
   })


### Meta data ----
testthat::test_that(
   desc = "no NA values - metadata - raw data",
   code = {
      variables <- unlist(indispensable_variables["/data/template_metadata_raw.txt"])

      for (i in listfiles_metadata_raw) {
         testthat::expect_false(
            base::any(
               data.table::fread(
                  file = i, sep = ",", dec = ".",
                  header = TRUE, stringsAsFactors = TRUE
               )[j = lapply(.SD, checkmate::anyMissing),
                 .SDcols = variables]
            ), info = i
         )
      }
   })

## Standardised data ----
### Community data ----
testthat::test_that(
   desc = "no NA values - community data - standardised data",
   code = {
      variables <- unlist(indispensable_variables["/data/template_communities_standardised.txt"])

      for (i in listfiles_community_standardised) {
         testthat::expect_false(
            base::any(
               data.table::fread(
                  file = i, sep = ",", dec = ".",
                  header = TRUE, stringsAsFactors = TRUE
               )[j = lapply(.SD, checkmate::anyMissing),
                 .SDcols = variables]
            ), info = i
         )
      }
   })

### Meta data ----
testthat::test_that(
   desc = "no NA values - metadata - standardised data",
   code = {
      variables <- unlist(indispensable_variables["/data/template_metadata_standardised.txt"])

      for (i in listfiles_metadata_standardised) {
         testthat::expect_false(
            base::any(
               data.table::fread(
                  file = i, sep = ",", dec = ".",
                  header = TRUE, stringsAsFactors = TRUE
               )[j = lapply(.SD, checkmate::anyMissing),
                 .SDcols = variables]
            ), info = i
         )
      }
   })
