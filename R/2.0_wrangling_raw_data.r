# Wrangle raw data
base::dir.create("data/wrangled data", showWarnings = FALSE)
library(tictoc)

# op <- options(warn = 2) # WARNING this stop the execution inside the source in case of warning, use only for debugging
for (script_path in list.files(path = "R/data wrangling", full.names = TRUE)) {
   unique_environment <- new.env()
   tic()
   cat("Now working on:", script_path, "\n")
   try(
      expr = source(file = script_path, local = unique_environment, echo = FALSE),
      silent = FALSE)
   toc()
}
