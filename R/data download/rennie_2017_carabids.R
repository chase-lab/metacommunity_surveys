# rennie_2017_carabids

if (!file.exists("data/raw data/rennie_2017_carabids/rdata.rds")) {

   # community data
   # Downloaded by hand behind this link: https://doi.org/10.5285/8385f864-dd41-410f-b248-028f923cb281
   rdata <-  data.table::fread(
      file = "data/cache/rennie_2017_carabids_ECN_IG1.csv",
      sep = ",", header = TRUE, stringsAsFactors = TRUE, drop = 'TYPE')

   # taxonomy
   ## this file was downloaded by hand from the Supporting information archive at https://doi.org/10.5285/8385f864-dd41-410f-b248-028f923cb281
   tax <- striprtf::read_rtf(file = 'data/cache/rennie_2017_carabids_8385f864-dd41-410f-b248-028f923cb281/supporting-documents/IG_dataStructure.rtf',
                             verbose = TRUE, ignore_tables = FALSE)[125:699]
   tax <- data.table::fread(input = paste(tax, collapse = '\n'), sep = '|',
                            stringsAsFactors = TRUE, header = FALSE)

   # joining
   rdata[, species := tax$V3[match(FIELDNAME, tax$V2, nomatch = NULL)]
   ][, species := data.table::fifelse(is.na(species), as.character(FIELDNAME), as.character(species))
   ][, FIELDNAME := NULL]

   rdata <- rdata[!grepl('Q[1-8]', species)]

   # saving
   base::dir.create("data/raw data/rennie_2017_carabids", showWarnings = FALSE)
   base::saveRDS(
      object = unique(rdata),
      file = "data/raw data/rennie_2017_carabids/rdata.rds"
   )
}
