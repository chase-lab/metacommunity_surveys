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

#intersect listfiles_metadata_standardised with modified listfiles
listfiles_metadata_standardised <- unique(grep(paste(listfiles, collapse = "|"),
                                               listfiles_metadata_standardised, value = TRUE))


# Testing column names ----
## community data ----
### raw data ----
lst_column_names_community_raw <- sapply(
   X = listfiles_community_raw,
   FUN = data.table::fread, integer64 = "character", encoding = "UTF-8",
   sep = ",", nrows = 1L, header = FALSE
)

template_community_raw <- utils::read.table(
   file = paste0(absolute_path, "/data/template_communities_raw.txt"),
   header = TRUE, sep = "\t")
reference_column_names_community_raw <- template_community_raw[, 1L]

testthat::test_that(desc = "only valid column names - community data - raw data", code = {
   for (i in listfiles_community_raw) {
      testthat::expect_true(
         all(lst_column_names_community_raw[[i]] %in% reference_column_names_community_raw),
         info = i
      )
   }
})

### standardised data ----
lst_column_names_community_standardised <- sapply(
   X = listfiles_community_standardised,
   FUN = data.table::fread, integer64 = "character", encoding = "UTF-8",
   sep = ",", nrows = 1L, header = FALSE
)

template_community_standardised <- utils::read.table(
   file = paste0(absolute_path, "/data/template_communities_raw.txt"),
   header = TRUE, sep = "\t")
reference_column_names_community_standardised <- template_community_standardised[, 1L]

testthat::test_that(desc = "only valid column names - community data - standardised data", code = {
   for (i in listfiles_community_standardised) {
      testthat::expect_true(
         all(lst_column_names_community_standardised[[i]] %in% reference_column_names_community_standardised),
         info = i
      )
   }
})




## metadata ----
### raw data ----
lst_column_names_metadata_raw <- sapply(
   X = listfiles_metadata_raw,
   FUN = data.table::fread, integer64 = "character", encoding = "UTF-8", sep = ",", nrows = 1L, header = FALSE
)

template_metadata_raw <- utils::read.table(
   file = paste0(absolute_path, "/data/template_metadata_raw.txt"),
   header = TRUE, sep = "\t")
reference_column_names_metadata_raw <- template_metadata_raw[, 1L]

testthat::test_that(desc = "only valid column names - metadata - raw data", code = {
   for (i in listfiles_metadata_raw) {
      testthat::expect_true(
         all(lst_column_names_metadata_raw[[i]] %in% reference_column_names_metadata_raw),
         info = i
      )
   }
})

### standardised data ----
lst_column_names_metadata_standardised <- sapply(
   X = listfiles_metadata_standardised,
   FUN = data.table::fread, integer64 = "character", encoding = "UTF-8",
   sep = ",", nrows = 1L, header = FALSE
)

template_metadata_standardised <- utils::read.table(
   file = paste0(absolute_path, "/data/template_metadata_standardised.txt"),
   header = TRUE, sep = "\t")
reference_column_names_metadata_standardised <- template_metadata_standardised[, 1L]

testthat::test_that(desc = "only valid column names - metadata - standardised data", code = {
   for (i in listfiles_metadata_standardised) {
      testthat::expect_true(
         all(lst_column_names_metadata_standardised[[i]] %in% reference_column_names_metadata_standardised),
         info = i
      )
   }
})






# Testing data dimension ----
## raw data ----
# tested_column_name_community <- "value"
# testthat::test_that(
#    desc = paste0("all community raw files have a _", tested_column_name_community, "_ column"),
#    testthat::expect_silent({
#       lst_one_column_community_raw <- sapply(
#          X = listfiles_community_raw,
#          FUN = data.table::fread, integer64 = "character", encoding = "UTF-8",
#          sep = ",", select = tested_column_name_community
#       )
#    })
# )
#
# tested_column_name_metadata <- "year"
# testthat::test_that(
#    desc = paste0("all metadata raw files have a _", tested_column_name_metadata, "_ column"),
#    testthat::expect_silent({
#       lst_one_column_metadata_raw <- sapply(
#          X = listfiles_metadata_raw,
#          FUN = data.table::fread, integer64 = "character", encoding = "UTF-8",
#          sep = ",", select = tested_column_name_metadata
#       )
#    })
# )

lst_first_column_community_raw <- sapply(
   X = listfiles_community_raw,
   FUN = data.table::fread, integer64 = "character", encoding = "UTF-8",
   sep = ",", select = 1L, header = FALSE, stringsAsFactors = TRUE
)

lst_first_column_metadata_raw <- sapply(
   X = listfiles_metadata_raw,
   FUN = data.table::fread, integer64 = "character", encoding = "UTF-8",
   sep = ",", select = 1L, header = FALSE, stringsAsFactors = TRUE
)

testthat::test_that(
   desc = "ddata has more rows than meta - raw data",
   code = testthat::expect_gte(
      sum(sapply(lst_first_column_community_raw, length)),
      sum(sapply(lst_first_column_metadata_raw, length))
   )
)


## standardised data ----
# testthat::test_that(
#    desc = paste0("all community standardised files have a _", tested_column_name_community, "_ column"),
#    testthat::expect_silent({
#       lst_one_column_community_standardised <- sapply(
#          X = listfiles_community_standardised,
#          FUN = data.table::fread, integer64 = "character", encoding = "UTF-8",
#          sep = ",", select = tested_column_name_community
#       )
#    })
# )
#
# testthat::test_that(
#    desc = paste0("all metadata standardised files have a _", tested_column_name_metadata, "_ column"),
#    testthat::expect_silent({
#       lst_one_column_metadata_standardised <- sapply(
#          X = listfiles_metadata_standardised,
#          FUN = data.table::fread, integer64 = "character", encoding = "UTF-8",
#          sep = ",", select = tested_column_name_metadata
#       )
#    })
# )

lst_first_column_community_standardised <- sapply(
   X = listfiles_community_standardised,
   FUN = data.table::fread, integer64 = "character", encoding = "UTF-8",
   sep = ",", select = 1L, header = FALSE, stringsAsFactors = TRUE
)

lst_first_column_metadata_standardised <- sapply(
   X = listfiles_metadata_standardised,
   FUN = data.table::fread, integer64 = "character", encoding = "UTF-8",
   sep = ",", select = 1L, header = FALSE, stringsAsFactors = TRUE
)

testthat::test_that(
   desc = "ddata has more rows than meta - standardised data",
   code = testthat::expect_gte(
      sum(sapply(lst_first_column_community_standardised, length)),
      sum(sapply(lst_first_column_metadata_standardised, length))
   )
)

# Every site/year in community is also in metadata ----
# Checking for NAs ----
