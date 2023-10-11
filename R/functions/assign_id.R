assign_id <- function(dataset_id) {
   ids <- base::unique(dataset_id)
   # read saved codes
   unique_IDs <- base::readRDS(file = "data/unique_IDs.rds")
   # if there are new datasets, create a code for them, add them to the dictionnary
   new_dataset_ids <- ids[!ids %in% unique_IDs$dataset_id]
   if (!base::is.null(new_dataset_ids)) {
      unique_IDs <- base::rbind(unique_IDs, data.table::data.table(
      ## add new dataset_ids to the dictionnary
         new_dataset_ids,
      ## create new ID
         (base::max(unique_IDs$ID) + 1L) + base::seq_along(new_dataset_ids)
      ), use.names = FALSE)
      ## Save new version of the dictionnary
      base::saveRDS(unique_IDs, file = "data/unique_IDs.rds")
   } # end if
   # assign IDs
   ids <- unique_IDs$ID[base::match(dataset_id, unique_IDs$dataset_id)]
   return(ids)
}

# x <- data.table::fread("data/metadata_standardised.csv", select = "dataset_id")
# x <- unique(x)
# x[, ID := .GRP, by = dataset_id]
# saveRDS(x, file = "data/unique_IDs.rds")
