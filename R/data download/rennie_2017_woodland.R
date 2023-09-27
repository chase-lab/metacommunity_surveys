# rennie_2017_woodland

if (!file.exists("data/raw data/rennie_2017_woodland/rdata.rds")) {

   # community data
   # Downloaded by hand behind this link: https://doi.org/10.5285/94aef007-634e-42db-bc52-9aae86adbd33
   rdata <-  data.table::fread(
      file = "data/cache/rennie_2017_woodland_ECN_VW1.csv",
      sep = ",", header = TRUE, stringsAsFactors = TRUE,
      drop = c('STEMID','FIELDNAME','VALUE'))
   rdata <- rdata[!is.na(TREE_SPEC)]

   # taxonomy
   ## this file was downloaded by hand from the Supporting information archive at https://doi.org/10.5285/94aef007-634e-42db-bc52-9aae86adbd33
   tax <- striprtf::read_rtf(file = 'data/cache/rennie_2017_woodland_94aef007-634e-42db-bc52-9aae86adbd33/supporting-documents/VW_DATA_STRUCTURE.rtf',
                             verbose = TRUE, ignore_tables = FALSE)[102:1323]
   tax <- data.table::fread(input = paste(tax, collapse = '\n'), sep = '|',
                            stringsAsFactors = TRUE)

   # joining
   rdata[, species := tax$`Name in BRC database`[match(TREE_SPEC, tax$`Field name`)]
   ][, species := data.table::fifelse(is.na(species), as.character(TREE_SPEC), as.character(species))
   ][, TREE_SPEC := NULL]

   # melting individuals
   rdata <- rdata[, .(value = data.table::uniqueN(TREEID)), by = .(regional = SITECODE, year = SYEAR, plot = PLOTPID, local = CELLID, species)]

   # saving
   base::dir.create("data/raw data/rennie_2017_woodland", showWarnings = FALSE)
   base::saveRDS(
      object = unique(rdata),
      file = "data/raw data/rennie_2017_woodland/rdata.rds"
   )
}
