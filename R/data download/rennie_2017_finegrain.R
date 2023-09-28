# rennie_2017_finegrain

if (!file.exists("data/raw data/rennie_2017_finegrain/rdata.rds")) {

   # community data
   # Downloaded by hand behind this link: https://catalogue.ceh.ac.uk/datastore/eidchub/b98efec8-6de0-4e0c-85dc-fe4cdf01f086
   rdata <-  data.table::fread(
      file = "data/cache/rennie_2017_finegrain_ECN_VF1.csv",
      sep = ",", header = TRUE, stringsAsFactors = TRUE)
   rdata <- rdata[FIELDNAME == 'VEG_SPEC'][, FIELDNAME := NULL]

   # taxonomy
   ## this file was downloaded by hand from the Supporting information archive at https://catalogue.ceh.ac.uk/documents/b98efec8-6de0-4e0c-85dc-fe4cdf01f086
   tax <- striprtf::read_rtf(file = 'data/cache/rennie_2017_finegrain_VF_DATA_STRUCTURE.rtf',
                      verbose = TRUE, ignore_tables = FALSE)[185:1406]
   tax <- data.table::fread(input = paste(tax, collapse = '\n'), sep = '|',
                            stringsAsFactors = TRUE)

   # joining
   rdata[, species := tax$`Name in BRC database`[match(VALUE, tax$`Field name`)]
   ][, species := data.table::fifelse(is.na(species), as.character(VALUE), as.character(species))
   ][, VALUE := NULL]

   # saving
   base::dir.create("data/raw data/rennie_2017_finegrain", showWarnings = FALSE)
   base::saveRDS(
      object = unique(rdata),
      file = "data/raw data/rennie_2017_finegrain/rdata.rds"
   )
}
