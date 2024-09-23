# perry_2024
# Package ID: edi.1320.3 Cataloging System:https://pasta.edirepository.org.
# Data set title: Interagency Ecological Program: Phytoplankton monitoring in the Sacramento-San Joaquin Bay-Delta, collected by the Environmental Monitoring Program, 2008-2021.
# Data set creator:  Sarah Perry - CA Department of Water Resources
# Data set creator:  Tiffany Brown - CA Department of Water Resources
# Data set creator:  Vivian Klotz - CA Department of Water Resources
# Contact:  Tiffany Brown -  CA Department of Water Resources  - tiffany.brown@water.ca.gov
# Stylesheet for metadata conversion into program: John H. Porter, Univ. Virginia, jporter@Virginia.edu

inUrl1  <- "https://pasta.lternet.edu/package/data/eml/edi/1320/9/effebf596630b9b9bf4c01718f1cf93c"
infile1 <- 'data/cache/perry_2024.csv'
if (!file.exists(infile1)) curl::curl_download(inUrl1,infile1)

dt1 <- data.table::fread(infile1, header = TRUE, skip = 0, sep = ",",
                         stringsAsFactors = FALSE,
                         select = c('Lab', 'Date', 'Station', 'Taxon',
                                    'Units_per_mL', 'QualityCheck'))


# Convert Missing Values to NA for non-dates

dt1$Units_per_mL <- ifelse(
   (trimws(as.character(dt1$Units_per_mL)) == trimws("NA")),
   NA,
   dt1$Units_per_mL)

suppressWarnings(
   dt1$Units_per_mL <- ifelse(
      !is.na(as.numeric("NA")) & (trimws(as.character(dt1$Units_per_mL)) == as.character(as.numeric("NA"))),
      NA,
      dt1$Units_per_mL)
)


inUrl2  <- "https://pasta.lternet.edu/package/data/eml/edi/1320/9/e96e03d36de8b98e2ac8b9fec59cd0b0"
infile2 <- 'data/cache/perry_2024_environment.csv'
if (!file.exists(infile2)) curl::curl_download(inUrl2, infile2)

dt2 <- data.table::fread(infile2, header = TRUE, sep = ',',
                         stringsAsFactors = FALSE)

base::dir.create(path = 'data/raw data/perry_2024/', showWarnings = FALSE)
base::saveRDS(object = dt1[dt2, on = c(Station = 'StationCode')],
              file = 'data/raw data/perry_2024/rdata.rds'
)
