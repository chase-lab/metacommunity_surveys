# rennie_2017_coarsegrain

if (!file.exists("data/raw data/rennie_2017_coarsegrain/rdata.rds")) {

   # community data
   # Downloaded by hand behind this link: https://doi.org/10.5285/d349babc-329a-4d6e-9eca-92e630e1be3f
   rdata <- data.table::fread(
      file = "data/cache/rennie_2017_coarsegrain_d349babc-329a-4d6e-9eca-92e630e1be3f/data/ECN_VC1.csv",
      sep = ",", header = TRUE, stringsAsFactors = TRUE)

   # taxonomy
   ## this file was downloaded by hand from the Supporting information archive at ttps://doi.org/10.5285/d349babc-329a-4d6e-9eca-92e630e1be3f
   tax <- striprtf::read_rtf(file = 'data/cache/rennie_2017_coarsegrain_d349babc-329a-4d6e-9eca-92e630e1be3f/supporting-documents/VC_DATA_STRUCTURE.rtf',
                             verbose = TRUE, ignore_tables = FALSE)[160:1381]
   tax <- data.table::fread(input = paste(tax, collapse = '\n'), sep = '|',
                            stringsAsFactors = TRUE)

   # joining
   rdata[, species := tax$`Name in BRC database`[match(VALUE, tax$`Field name`)]
         ][, species := data.table::fifelse(is.na(species), as.character(VALUE), as.character(species))
           ][, VALUE := NULL][, FIELDNAME := NULL]

   # saving
   base::dir.create("data/raw data/rennie_2017_coarsegrain", showWarnings = FALSE)
   base::saveRDS(
      object = unique(rdata),
      file = "data/raw data/rennie_2017_coarsegrain/rdata.rds"
   )
}
