# Wrangle raw data
base::dir.create("./data/wrangled data", showWarnings = FALSE)
library(tictoc)

for (script_path in list.files(path = "R/data wrangling", full.names = TRUE)) {
   unique_environment <- new.env()
   tic()
   try(source(file = script_path, local = unique_environment, echo = FALSE))
   print(script_path)
   toc()
}
