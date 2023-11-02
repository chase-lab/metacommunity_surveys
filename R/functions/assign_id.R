#' Creates and stores unique data set IDs
#'
#' @param dataset_id a vector of dataset_ids. Can be `factor` or `character`.
#' @returns A character vector of the same length as dataset_id containing unique IDs
#' @details If a data set already has an ID like `sagouis_2023` and is then split
#' into `sagouis_2023a` and `sagouis_2023b`, these data sets will receive entirely new IDs.
#' @importFrom data.table data.table


assign_id <- function(dataset_id) {
   ids <- base::unique(dataset_id)
   # read saved codes
   unique_IDs <- base::readRDS(file = "data/unique_IDs.rds")
   # if there are new datasets, create a code for them and add them to the dictionary
   new_dataset_ids <- base::setdiff(ids, unique_IDs$dataset_id)
   if (!base::is.null(new_dataset_ids)) {
      unique_IDs <- base::rbind(unique_IDs, data.table::data.table(
      ## add new dataset_ids to the dictionary
         new_dataset_ids,
      ## create new ID
         (base::max(unique_IDs$ID) + 1L) + base::seq_along(new_dataset_ids)
      ), use.names = FALSE)
      ## Save new version of the dictionary
      base::saveRDS(unique_IDs, file = "data/unique_IDs.rds")
   } # end if
   # assign IDs
   ids <- unique_IDs$ID[base::match(dataset_id, unique_IDs$dataset_id)]
   return(ids)
}

# # This section shows how the dictionary was built.
# x <- data.table::fread("data/metadata_standardised.csv", select = "dataset_id")
# x <- unique(x)
# x[, ID := .GRP, by = dataset_id]
# saveRDS(x, file = "data/unique_IDs.rds")
