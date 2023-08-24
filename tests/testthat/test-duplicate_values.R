# Using testthat Edition 3
testthat::local_edition(3)

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
testthat::test_that(desc = "no duplicates - community data - raw data", code = {
   for (i in listfiles_community_raw) {
      col_names <- data.table::fread(file = i, sep = ",", dec = ".",
                                     header = FALSE, nrows = 1L)
      testthat::expect_true(
         if (all(c("month", "day") %in% col_names)) {
            data.table::fread(
               file = i, sep = ",", dec = ".", header = TRUE, stringsAsFactors = TRUE
            )[, .N, by = .(regional, local, year, month, day, species)][, all(N == 1L)]

         } else if ("month" %in% col_names) {
            data.table::fread(
               file = i, sep = ",", dec = ".", header = TRUE, stringsAsFactors = TRUE
            )[, .N, by = .(regional, local, year, month, species)][, all(N == 1L)]

         } else { data.table::fread(
            file = i, sep = ",", dec = ".", header = TRUE, stringsAsFactors = TRUE
         )[, .N, by = .(regional, local, year, species)][, all(N == 1L)]
         },
         info = i
      )
   }
})

testthat::test_that(desc = "no duplicates - community data - standardised data", code = {
   for (i in listfiles_community_standardised) {
      testthat::expect_true(
         data.table::fread(
            file = i, sep = ",", dec = ".", header = TRUE, stringsAsFactors = TRUE
         )[, .N, by = .(regional, local, year, species)][, all(N == 1L)],
         info = i
      )
   }
})

## Meta data ----
testthat::test_that(desc = "no duplicates - metadata data - raw data", code = {
   for (i in listfiles_metadata_raw) {
      testthat::expect_true(
         anyDuplicated(data.table::fread(
            file = i, sep = ",", dec = ".", header = TRUE, stringsAsFactors = TRUE
         )) == 0L,
         info = i
      )
   }
})


testthat::test_that(desc = "no duplicates - metadata data - standardised data", code = {
   for (i in listfiles_metadata_standardised) {
      testthat::expect_true(
         anyDuplicated(data.table::fread(
            file = i, sep = ",", dec = ".", header = TRUE, stringsAsFactors = TRUE
         )) == 0L,
         info = i
      )
   }
})
