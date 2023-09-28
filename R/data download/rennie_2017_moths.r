# rennie_2017_moths

if (!file.exists("data/raw data/rennie_2017_moths/rdata.rds")) {

   # community data
   # Downloaded by hand behind this link: https://doi.org/10.5285/a2a49f47-49b3-46da-a434-bb22e524c5d2
   rdata <-  data.table::fread(
      file = "data/cache/rennie_2017_moths_ECN_IM1.csv",
      sep = ",", header = TRUE, stringsAsFactors = TRUE)

   # taxonomy
   ## this file was downloaded by hand from the Supporting information archive at https://doi.org/10.5285/a2a49f47-49b3-46da-a434-bb22e524c5d2
   tax <- striprtf::read_rtf(file = 'data/cache/rennie_2017_moths_a2a49f47-49b3-46da-a434-bb22e524c5d2/supporting-documents/IM_DATA_STRUCTUREedit.rtf',
                             verbose = TRUE, ignore_tables = FALSE)[119L:1013L]
   tax <- data.table::fread(input = paste(tax, collapse = '\n'), sep = '|',
                            stringsAsFactors = TRUE, header = FALSE, fill = TRUE)

   # joining
   rdata[, species := tax$V3[match(FIELDNAME, tax$V2, nomatch = NULL)]
   ][, species := data.table::fifelse(is.na(species) | species == '', as.character(FIELDNAME), as.character(species))
   ][, FIELDNAME := NULL]

   # saving
   base::dir.create("data/raw data/rennie_2017_moths", showWarnings = FALSE)
   base::saveRDS(
      object = rdata,
      file = "data/raw data/rennie_2017_moths/rdata.rds"
   )
}
