# Paths to datasets ----
absolute_path <- rprojroot::find_rstudio_root_file()
listfiles <- list.files(
   path = paste0(absolute_path, "/data/wrangled data"),
   pattern = "_raw.csv",
   full.names = TRUE, recursive = TRUE
)
listfiles_metadata <- list.files(
   path = "./data/wrangled data",
   pattern = "raw_metadata.csv",
   full.names = TRUE, recursive = TRUE
)

# Testing column names ----
lst_column_names <- sapply(
   X = listfiles,
   FUN = data.table::fread, integer64 = "character", encoding = "UTF-8", sep = ",", nrows = 1L, header = FALSE
)

template <- utils::read.table(file = paste0(absolute_path, "./data/template_communities.txt"), header = TRUE, sep = "\t")
column_names_template <- template[, 1]

test_that(desc = "only valid column names - raw data", code =
             for (i in listfiles) expect_setequal(lst_column_names[[i]], column_names_template)
)


# Testing data dimension
lst_one_column <- sapply(X = listfiles, FUN = data.table::fread, integer64 = "character", encoding = "UTF-8", sep = ",", select = "value")
lst_metadata_one_column <- sapply(X = listfiles_metadata, FUN = data.table::fread, integer64 = "character", encoding = "UTF-8", sep = ",", select = "year")


test_that(desc = "ddata has mor rows than meta", code =
             expect_gte(sum(sapply(lst_one_column, nrow)), sum(sapply(lst_metadata_one_column, nrow)))
)

