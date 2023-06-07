# macdonald_2023_trees
# Downloaded by hand because behind a form-wall: https://borealisdata.ca/dataset.xhtml?persistentId=doi:10.5683/SP3/YAQCWD

base::dir.create('data/raw data/macdonald_2023_trees', showWarnings = FALSE)
base::saveRDS(
   object = data.table::fread(
      file = 'data/cache/macdonald_2023_Tree_data_1967_1989_2012_quadrat_level.csv',
      stringsAsFactors = TRUE, na.strings = '0',
      drop = c('TOT1-18','TOT3-18','TOT6-18','TOT9-18','TOT12-18','TOT15-18','Can-Cov',
               'dead_SEE','dead_TRA','dead_1-3','dead_3-6','dead_6-9','dead_9-12',
               'dead_12-15','dead_15-18','dead_24-27','dead_TOTAL','dead-BA','Comments')),
   file = 'data/raw data/macdonald_2023_trees/rdata.rds'
)
