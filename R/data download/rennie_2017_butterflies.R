# rennie_2017_butterflies

if (!file.exists("data/raw data/rennie_2017_butterflies/rdata.rds")) {

   # community data
   # Downloaded by hand behind this link: https://doi.org/10.5285/5aeda581-b4f2-4e51-b1a6-890b6b3403a3
   rdata <-  data.table::fread(
      file = "data/cache/rennie_2017_butterflies_ECN_IB1.csv",
      sep = ",", header = TRUE, stringsAsFactors = TRUE, drop = 'BROODED')

   # taxonomy
   ## this file was downloaded by hand from the Supporting information archive at https://doi.org/10.5285/5aeda581-b4f2-4e51-b1a6-890b6b3403a3
   tax <- striprtf::read_rtf(file = 'data/cache/rennie_2017_butterflies_5aeda581-b4f2-4e51-b1a6-890b6b3403a3/supporting-documents/IB_DATA_STRUCTURE.rtf',
                             verbose = TRUE, ignore_tables = FALSE)[125L:198L]
   tax <- data.table::fread(input = paste(tax, collapse = '\n'), sep = '|',
                            stringsAsFactors = TRUE, header = TRUE)

   # joining
   rdata[, species := tax$`Latin name`[match(FIELDNAME, tax$`Species code`, nomatch = NULL)]
   ][, species := data.table::fifelse(is.na(species) | species == '', as.character(FIELDNAME), as.character(species))
   ][, FIELDNAME := NULL]

   # saving
   base::dir.create("data/raw data/rennie_2017_butterflies", showWarnings = FALSE)
   base::saveRDS(
      object = rdata,
      file = "data/raw data/rennie_2017_butterflies/rdata.rds"
   )
}
