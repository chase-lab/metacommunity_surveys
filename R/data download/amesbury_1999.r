# amesbury_1999
dataset_id <- "amesbury_1999"

ddata <- data.table::fread(paste0("data/raw data/", dataset_id, "/rdata.csv"), skip = 1, header = TRUE)
ddata <- ddata[!genus %in% c("total number of species", "verification")]
ddata[, c("genus", "tmp2") := data.table::tstrsplit(genus, " ")][, species := data.table::fifelse(species == "", tmp2, species)]
ddata[, ":="(
  genus = stringi::stri_replace_all_regex(genus, "^[a-z]{1}", toupper(substr(genus, 1, 1))),
  species = tolower(species),
  tmp2 = NULL
)][, ":="(species = paste(genus, species),
  genus = NULL)]

base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))






# library(tabulizer)
# extract_tables(paste0('./data/raw data/', dataset_id, '/Amesbury et al. 1999 (Data on fish resurvey in Table 17).pdf'), pages = 67:69)
#
# coords <- data.table::fread(paste0('./data/raw data/', dataset_id, '/Tabula-Amesbury et al. 1999 (Data on fish resurvey in Table 17).csv'), header = TRUE, sep = '\t', skip = 1)
# coords[, local := gsub(',\ \\(.*\\)|\ \\(.*\\)|\\(.*\\)', '', local)]
# coords[,':='(
#    local = stringi::stri_extract_all_regex(local, '^[A-Z]{4}\ [0-9]{1,2}\ '),
#    latitude = stringi::stri_extract_all_regex(local, '13\ 2.*N'),
#    longitude = stringi::stri_extract_all_regex(local, '144\ .*E')
# )]
#
# save(coords, file = paste('data/raw data', dataset_id, 'coords', sep = '/'))
