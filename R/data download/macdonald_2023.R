# macdonald_2023
# Downloaded by hand because behind a form-wall: https://borealisdata.ca/dataset.xhtml?persistentId=doi:10.5683/SP3/YAQCWD

# coords <- data.table::fread(
#    file = 'data/cache/macdonald_2023_quadrats.csv', stringsAsFactors = TRUE,
#    drop = 'Comment')

base::dir.create('data/raw data/macdonald_2023', showWarnings = FALSE)
base::saveRDS(
   object = data.table::fread(
      file = 'data/cache/macdonald_2023_Understory_data_raw_data.csv',
      stringsAsFactors = TRUE, na.strings = '.',
      drop = c("Tree_cover","Dead_trees","Fine_DWD","Lich","Mineral","Trail","Pine_cones","Comment")), # "Q-2010","Q-1989","Q-1967"),
   file = 'data/raw data/macdonald_2023/rdata.rds'
)
