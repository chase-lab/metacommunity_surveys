# alber_2022

# Package ID: knb-lter-gce.605.14 Cataloging System:https://pasta.edirepository.org.
# Data set title: Long-term Mollusc Population Abundance and Size Data from the Georgia Coastal Ecosystems LTER Fall Marsh Monitoring Program.
# Data set creator:    - Georgia Coastal Ecosystems LTER Project
# Data set creator: Dr. Merryl Alber - University of Georgia
# Metadata Provider:    -
# Contact:    - GCE-LTER Information Manager   - gcelter@uga.edu
# Stylesheet v2.11 for metadata conversion into program: John H. Porter, Univ. Virginia, jporter@virginia.edu
infile1 <- "./data/cache/alber_2022_abundances.csv"
if (!file.exists(infile1)) {
   inUrl1  <- "https://pasta.lternet.edu/package/data/eml/knb-lter-gce/605/14/97c09b8ba676a1a750665d2ff1908b9e"
   if (!file.exists(infile1)) try(curl::curl_download(inUrl1,infile1,method="curl"))
   if (is.na(file.size(infile1))) curl::curl_download(inUrl1,infile1,method="auto")


   dt1 <-read.csv(infile1,header=F
                  ,skip=5
                  ,sep=","
                  ,quot='"'
                  , col.names=c(
                     "Date",
                     "Year",
                     "Site_Name",
                     "Site",
                     "Zone",
                     "Plot",
                     "Location",
                     "Flag_Location",
                     "Location_Notes",
                     "Longitude",
                     "Flag_Longitude",
                     "Latitude",
                     "Flag_Latitude",
                     "Species",
                     "Mollusc_Count",
                     "Quadrat_Area",
                     "Mollusc_Density",
                     "Notes"    ), check.names=TRUE)

   data.table::setDT(dt1)

   # Fix any interval or ratio columns mistakenly read in as nominal and nominal columns read as numeric or dates read as strings

   # attempting to convert dt1$Date dateTime string to R date structure (date or POSIXct)
   tmpDateFormat<-"%Y-%m-%d"
   tmp1Date<-as.Date(dt1$Date,format=tmpDateFormat)
   # Keep the new dates only if they all converted correctly
   if(length(tmp1Date) == length(tmp1Date[!is.na(tmp1Date)])){dt1$Date <- tmp1Date } else {print("Date conversion failed for dt1$Date. Please inspect the data and do the date conversion yourself.")}
   rm(tmpDateFormat,tmp1Date)
   if (class(dt1$Year) !="factor") dt1$Year <- as.factor(dt1$Year)
   if (class(dt1$Site_Name)!="factor") dt1$Site_Name<- as.factor(dt1$Site_Name)
   if (class(dt1$Site)!="factor") dt1$Site<- as.factor(dt1$Site)
   if (class(dt1$Zone)!="factor") dt1$Zone<- as.factor(dt1$Zone)
   if (class(dt1$Plot)!="factor") dt1$Plot<- as.factor(dt1$Plot)
   if (class(dt1$Location)!="factor") dt1$Location<- as.factor(dt1$Location)
   if (class(dt1$Flag_Location)!="factor") dt1$Flag_Location<- as.factor(dt1$Flag_Location)
   if (class(dt1$Location_Notes)!="factor") dt1$Location_Notes<- as.factor(dt1$Location_Notes)
   if (class(dt1$Longitude)=="factor") dt1$Longitude <-as.numeric(levels(dt1$Longitude))[as.integer(dt1$Longitude) ]
   if (class(dt1$Longitude)=="character") dt1$Longitude <-as.numeric(dt1$Longitude)
   if (class(dt1$Flag_Longitude)!="factor") dt1$Flag_Longitude<- as.factor(dt1$Flag_Longitude)
   if (class(dt1$Latitude)=="factor") dt1$Latitude <-as.numeric(levels(dt1$Latitude))[as.integer(dt1$Latitude) ]
   if (class(dt1$Latitude)=="character") dt1$Latitude <-as.numeric(dt1$Latitude)
   if (class(dt1$Flag_Latitude)!="factor") dt1$Flag_Latitude<- as.factor(dt1$Flag_Latitude)
   if (class(dt1$Species)!="factor") dt1$Species<- as.factor(dt1$Species)
   if (class(dt1$Mollusc_Count)=="factor") dt1$Mollusc_Count <-as.numeric(levels(dt1$Mollusc_Count))[as.integer(dt1$Mollusc_Count) ]
   if (class(dt1$Mollusc_Count)=="character") dt1$Mollusc_Count <-as.numeric(dt1$Mollusc_Count)
   if (class(dt1$Quadrat_Area)=="factor") dt1$Quadrat_Area <-as.numeric(levels(dt1$Quadrat_Area))[as.integer(dt1$Quadrat_Area) ]
   if (class(dt1$Quadrat_Area)=="character") dt1$Quadrat_Area <-as.numeric(dt1$Quadrat_Area)
   if (class(dt1$Mollusc_Density)=="factor") dt1$Mollusc_Density <-as.numeric(levels(dt1$Mollusc_Density))[as.integer(dt1$Mollusc_Density) ]
   if (class(dt1$Mollusc_Density)=="character") dt1$Mollusc_Density <-as.numeric(dt1$Mollusc_Density)
   if (class(dt1$Notes)!="factor") dt1$Notes<- as.factor(dt1$Notes)

   # Convert Missing Values to NA for non-dates

   dt1$Year <- ifelse((trimws(as.character(dt1$Year))==trimws("NaN")),NA,dt1$Year)
   suppressWarnings(dt1$Year <- ifelse(!is.na(as.numeric("NaN")) & (trimws(as.character(dt1$Year))==as.character(as.numeric("NaN"))),NA,dt1$Year))
   dt1$Site <- as.factor(ifelse((trimws(as.character(dt1$Site))==trimws("NaN")),NA,as.character(dt1$Site)))
   dt1$Zone <- as.factor(ifelse((trimws(as.character(dt1$Zone))==trimws("NaN")),NA,as.character(dt1$Zone)))
   dt1$Plot <- as.factor(ifelse((trimws(as.character(dt1$Plot))==trimws("NaN")),NA,as.character(dt1$Plot)))
   dt1$Longitude <- ifelse((trimws(as.character(dt1$Longitude))==trimws("NaN")),NA,dt1$Longitude)
   suppressWarnings(dt1$Longitude <- ifelse(!is.na(as.numeric("NaN")) & (trimws(as.character(dt1$Longitude))==as.character(as.numeric("NaN"))),NA,dt1$Longitude))
   dt1$Latitude <- ifelse((trimws(as.character(dt1$Latitude))==trimws("NaN")),NA,dt1$Latitude)
   suppressWarnings(dt1$Latitude <- ifelse(!is.na(as.numeric("NaN")) & (trimws(as.character(dt1$Latitude))==as.character(as.numeric("NaN"))),NA,dt1$Latitude))
   dt1$Mollusc_Count <- ifelse((trimws(as.character(dt1$Mollusc_Count))==trimws("NaN")),NA,dt1$Mollusc_Count)
   suppressWarnings(dt1$Mollusc_Count <- ifelse(!is.na(as.numeric("NaN")) & (trimws(as.character(dt1$Mollusc_Count))==as.character(as.numeric("NaN"))),NA,dt1$Mollusc_Count))
   dt1$Quadrat_Area <- ifelse((trimws(as.character(dt1$Quadrat_Area))==trimws("NaN")),NA,dt1$Quadrat_Area)
   suppressWarnings(dt1$Quadrat_Area <- ifelse(!is.na(as.numeric("NaN")) & (trimws(as.character(dt1$Quadrat_Area))==as.character(as.numeric("NaN"))),NA,dt1$Quadrat_Area))
   dt1$Mollusc_Density <- ifelse((trimws(as.character(dt1$Mollusc_Density))==trimws("NaN")),NA,dt1$Mollusc_Density)
   suppressWarnings(dt1$Mollusc_Density <- ifelse(!is.na(as.numeric("NaN")) & (trimws(as.character(dt1$Mollusc_Density))==as.character(as.numeric("NaN"))),NA,dt1$Mollusc_Density))

   dir.create("./data/raw data/alber_2022/", showWarnings = FALSE)
   base::saveRDS(dt1, "./data/raw data/alber_2022/rdata.rds")
}

