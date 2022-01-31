# Wrangle raw data
dir.create("./data/wrangled data", showWarnings = FALSE)
for (script_path in list.files(path = "./R/data wrangling", full.names = TRUE)) source(file = script_path, local = TRUE, echo = FALSE)
