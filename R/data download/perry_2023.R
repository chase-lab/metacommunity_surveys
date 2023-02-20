# perry_2023
# Package ID: edi.1320.3 Cataloging System:https://pasta.edirepository.org.
# Data set title: Interagency Ecological Program: Phytoplankton monitoring in the Sacramento-San Joaquin Bay-Delta, collected by the Environmental Monitoring Program, 2008-2021.
# Data set creator:  Sarah Perry - CA Department of Water Resources
# Data set creator:  Tiffany Brown - CA Department of Water Resources
# Data set creator:  Vivian Klotz - CA Department of Water Resources
# Contact:  Tiffany Brown -  CA Department of Water Resources  - tiffany.brown@water.ca.gov
# Stylesheet v2.11 for metadata conversion into program: John H. Porter, Univ. Virginia, jporter@virginia.edu

inUrl1  <- "https://pasta.lternet.edu/package/data/eml/edi/1320/3/1eee2c2a562a5b856398082c487dc1a7"
infile1 <- 'data/cache/perry_2023.csv'
if (is.na(file.size(infile1))) download.file(inUrl1,infile1,method="curl")
if (is.na(file.size(infile1))) download.file(inUrl1,infile1,method="auto")


dt1 <-data.table::fread(infile1, header = TRUE, skip = 0, sep = ",",
                        stringsAsFactors = FALSE,
                        select = c('Lab', 'SampleDate', 'StationCode', 'Name', 'Organisms_per_mL', 'QualityCheck'))

# attempting to convert dt1$SampleDate dateTime string to R date structure (date or POSIXct)
tmpDateFormat<-"%Y-%m-%d"
tmp1SampleDate<-as.Date(dt1$SampleDate,format=tmpDateFormat)
# Keep the new dates only if they all converted correctly
if(length(tmp1SampleDate) == length(tmp1SampleDate[!is.na(tmp1SampleDate)])){dt1$SampleDate <- tmp1SampleDate } else {print("Date conversion failed for dt1$SampleDate. Please inspect the data and do the date conversion yourself.")}

# Convert Missing Values to NA for non-dates

dt1$Organisms_per_mL <- ifelse((trimws(as.character(dt1$Organisms_per_mL))==trimws("NA")),NA,dt1$Organisms_per_mL)
suppressWarnings(dt1$Organisms_per_mL <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt1$Organisms_per_mL))==as.character(as.numeric("NA"))),NA,dt1$Organisms_per_mL))


inUrl2  <- "https://pasta.lternet.edu/package/data/eml/edi/1320/3/00b61678378071f779f1135be223fe0a"
infile2 <- 'data/cache/perry_2023_environment.csv'
if (is.na(file.size(infile2))) download.file(inUrl2 ,infile2, method = "curl")
if (is.na(file.size(infile2))) download.file(inUrl2,infile2, method = "auto")


dt2 <- data.table::fread(infile2, header = TRUE, sep = ',', stringsAsFactors = FALSE, drop = 'Location')

base::dir.create(path = 'data/raw data/perry_2023/', showWarnings = FALSE)
base::saveRDS(object = dt1[dt2, on = 'StationCode'],
              file = 'data/raw data/perry_2023/rdata.rds'
)


