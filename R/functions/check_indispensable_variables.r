# function used to systematically check the presence of NA values in columns where they should not be any
# x is a data.table
# indispensable_variables is a character vector of column names where no NA is allowed

check_indispensable_variables <- function(x, indispensable_variables) {
   na_variables <- apply(x[, ..indispensable_variables], 2, function(variable) any(is.na(variable)))
   if (any(na_variables)) {
      na_variables_names <- indispensable_variables[na_variables]

      for (na_variable in na_variables_names) {
         warning(paste0("The variable -", na_variable, "- has missing values in the following datasets: ", paste(unique(x[c(is.na(x[, ..na_variable])), "dataset_id"]), collapse = ", ")))
      }
   }
}