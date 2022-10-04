# Paths to datasets ----
absolute_path <- rprojroot::find_rstudio_root_file()

## raw data ----
listfiles_raw <- list.files(
   path = paste0(absolute_path, "/data/wrangled data"),
   pattern = "_raw.csv",
   full.names = TRUE, recursive = TRUE
)
listfiles_raw_metadata <- list.files(
   path = "./data/wrangled data",
   pattern = "raw_metadata.csv",
   full.names = TRUE, recursive = TRUE
)

## standardised data ----
listfiles_standardised <- list.files(
   path = paste0(absolute_path, "/data/wrangled data"),
   pattern = "_standardised.csv",
   full.names = TRUE, recursive = TRUE
)
listfiles_standardised_metadata <- list.files(
   path = "./data/wrangled data",
   pattern = "standardised_metadata.csv",
   full.names = TRUE, recursive = TRUE
)

# Testing column names ----

## raw data ----
lst_column_names_raw <- sapply(
   X = listfiles_raw,
   FUN = data.table::fread, integer64 = "character", encoding = "UTF-8", sep = ",", nrows = 1L, header = FALSE
)

template_raw <- utils::read.table(file = paste0(absolute_path, "./data/template_communities.txt"), header = TRUE, sep = "\t")
column_names_reference_raw <- template_raw[, 1]

test_that(desc = "only valid column names - raw data", code =
             for (i in listfiles_raw) {
                tested_column_names <-  lst_column_names_raw[[i]]
                expect_true(all(tested_column_names %in% column_names_reference_raw), info = i)
             }
)

## standardised data ----
lst_column_names_standardised <- sapply(
   X = listfiles_standardised,
   FUN = data.table::fread, integer64 = "character", encoding = "UTF-8", sep = ",", nrows = 1L, header = FALSE
)

template_standardised <- utils::read.table(file = paste0(absolute_path, "./data/template_communities.txt"), header = TRUE, sep = "\t")
column_names_reference_standardised <- template_standardised[, 1]

test_that(desc = "only valid column names - standardised data", code =
             for (i in listfiles_standardised) {
                tested_column_names <-  lst_column_names_standardised[[i]]
                expect_true(all(tested_column_names %in% column_names_reference_standardised), info = i)
             }
)




# Testing data dimension ----
## raw data ----
lst_one_column_raw <- sapply(X = listfiles_raw, FUN = data.table::fread, integer64 = "character", encoding = "UTF-8", sep = ",", select = "value")
lst_metadata_one_column_raw <- sapply(X = listfiles_raw_metadata, FUN = data.table::fread, integer64 = "character", encoding = "UTF-8", sep = ",", select = "year")


test_that(desc = "ddata has mor rows than meta - raw data", code =
             expect_gte(sum(sapply(lst_one_column_raw, nrow)), sum(sapply(lst_metadata_one_column_raw, length)))
)

## standardised data ----
lst_one_column_standardised <- sapply(X = listfiles_standardised, FUN = data.table::fread, integer64 = "character", encoding = "UTF-8", sep = ",", select = "value")
lst_metadata_one_column_standardised <- sapply(X = listfiles_standardised_metadata, FUN = data.table::fread, integer64 = "character", encoding = "UTF-8", sep = ",", select = "year")


test_that(desc = "ddata has mor rows than meta - standardised data", code =
             expect_gte(sum(sapply(lst_one_column_standardised, length)), sum(sapply(lst_metadata_one_column_standardised, length)))
)

