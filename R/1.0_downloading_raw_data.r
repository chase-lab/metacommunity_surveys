# Downloading raw data
for (script_path in list.files(path = "./R/data download", full.names = TRUE)) {
   unique_environment <- new.env()
   source(file = script_path, local = unique_environment, echo = FALSE)
}
