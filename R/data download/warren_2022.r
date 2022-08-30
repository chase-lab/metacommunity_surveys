dataset_id <- "warren_2022"
#Package ID: knb-lter-cap.46.20 Cataloging System:https://pasta.edirepository.org.
# Data set title: Point-count bird censusing: long-term monitoring of bird abundance and diversity in central Arizona-Phoenix, ongoing since 2000.
# Data set creator:  Paige Warren - University of Massachusetts-Amherst 
# Data set creator:  Susannah Lerman - USDA Forest Service Northern Research Station 
# Data set creator:  Heather Bateman - Arizona State University 
# Data set creator:  Madhusudan Katti - Department of Forestry and Environmental Resources 
# Data set creator:  Eyal Shochat - Ben-Gurion University of the Negev 
# Metadata Provider:  Stevan Earl - Arizona State University 
# Contact:    - Information Manager Central ArizonaâPhoenix LTER  - caplter.data@asu.edu
# Stylesheet v2.11 for metadata conversion into program: John H. Porter, Univ. Virginia, jporter@virginia.edu 
if (!file.exists(paste0("./data/raw data/", dataset_id, "/rdata1.rds"))) {
inUrl1  <- "https://pasta.lternet.edu/package/data/eml/knb-lter-cap/46/20/832065765ce5a9a8238a0b25cb549722" 
infile1 <- paste0("./data/cache/", dataset_id, "46_bird_observations.csv")
if (!file.exists(infile1)) try(download.file(inUrl1, infile1, method = "curl"))
if (!file.exists(infile1)) download.file(inUrl1, infile1, method = "auto")


dt1 <-data.table::fread(infile1,header=F 
               ,skip=1
               ,sep=","  
               ,quot='"' 
               , col.names=c(
                 "survey_id",     
                 "site_code",     
                 "survey_date",     
                 "time_start",     
                 "time_end",     
                 "observer",     
                 "code",     
                 "common_name",     
                 "distance",     
                 "bird_count",     
                 "observation_notes",     
                 "seen",     
                 "heard",     
                 "direction",     
                 "qccomment"    ), check.names=TRUE)


# Fix any interval or ratio columns mistakenly read in as nominal and nominal columns read as numeric or dates read as strings

if (class(dt1$survey_id)!="factor") dt1$survey_id<- as.factor(dt1$survey_id)
if (class(dt1$site_code)!="factor") dt1$site_code<- as.factor(dt1$site_code)                                   
# attempting to convert dt1$survey_date dateTime string to R date structure (date or POSIXct)                                
tmpDateFormat<-"%Y-%m-%d"
tmp1survey_date<-as.Date(dt1$survey_date,format=tmpDateFormat)
# Keep the new dates only if they all converted correctly
if(length(tmp1survey_date) == length(tmp1survey_date[!is.na(tmp1survey_date)])){dt1$survey_date <- tmp1survey_date } else {print("Date conversion failed for dt1$survey_date. Please inspect the data and do the date conversion yourself.")}                                                                    
rm(tmpDateFormat,tmp1survey_date) 
if (class(dt1$observer)!="factor") dt1$observer<- as.factor(dt1$observer)
if (class(dt1$code)!="factor") dt1$code<- as.factor(dt1$code)
if (class(dt1$common_name)!="factor") dt1$common_name<- as.factor(dt1$common_name)
if (class(dt1$distance)!="factor") dt1$distance<- as.factor(dt1$distance)
if (class(dt1$bird_count)=="factor") dt1$bird_count <-as.numeric(levels(dt1$bird_count))[as.integer(dt1$bird_count) ]               
if (class(dt1$bird_count)=="character") dt1$bird_count <-as.numeric(dt1$bird_count)
if (class(dt1$observation_notes)!="factor") dt1$observation_notes<- as.factor(dt1$observation_notes)
if (class(dt1$seen)!="factor") dt1$seen<- as.factor(dt1$seen)
if (class(dt1$heard)!="factor") dt1$heard<- as.factor(dt1$heard)
if (class(dt1$direction)!="factor") dt1$direction<- as.factor(dt1$direction)
if (class(dt1$qccomment)!="factor") dt1$qccomment<- as.factor(dt1$qccomment)

# Convert Missing Values to NA for non-dates

dt1$distance <- as.factor(ifelse((trimws(as.character(dt1$distance))==trimws("NA")),NA,as.character(dt1$distance)))
dt1$bird_count <- ifelse((trimws(as.character(dt1$bird_count))==trimws("NA")),NA,dt1$bird_count)               
suppressWarnings(dt1$bird_count <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt1$bird_count))==as.character(as.numeric("NA"))),NA,dt1$bird_count))
dt1$observation_notes <- as.factor(ifelse((trimws(as.character(dt1$observation_notes))==trimws("NA")),NA,as.character(dt1$observation_notes)))
dt1$direction <- as.factor(ifelse((trimws(as.character(dt1$direction))==trimws("NA")),NA,as.character(dt1$direction)))
dt1$qccomment <- as.factor(ifelse((trimws(as.character(dt1$qccomment))==trimws("NA")),NA,as.character(dt1$qccomment)))


# Here is the structure of the input data frame:
str(dt1)                            
attach(dt1)                            
# The analyses below are basic descriptions of the variables. After testing, they should be replaced.                 

summary(survey_id)
summary(site_code)
summary(survey_date)
summary(time_start)
summary(time_end)
summary(observer)
summary(code)
summary(common_name)
summary(distance)
summary(bird_count)
summary(observation_notes)
summary(seen)
summary(heard)
summary(direction)
summary(qccomment) 
# Get more details on character variables

summary(as.factor(dt1$survey_id)) 
summary(as.factor(dt1$site_code)) 
summary(as.factor(dt1$observer)) 
summary(as.factor(dt1$code)) 
summary(as.factor(dt1$common_name)) 
summary(as.factor(dt1$distance)) 
summary(as.factor(dt1$observation_notes)) 
summary(as.factor(dt1$seen)) 
summary(as.factor(dt1$heard)) 
summary(as.factor(dt1$direction)) 
summary(as.factor(dt1$qccomment))
detach(dt1)

dir.create(paste0("./data/raw data/", dataset_id), showWarnings = FALSE)
base::saveRDS(dt1, file = paste0("./data/raw data/", dataset_id, "/rdata1.rds"))
}


if (!file.exists(paste0("./data/raw data/", dataset_id, "/rdata2.rds"))) {
inUrl2  <- "https://pasta.lternet.edu/package/data/eml/knb-lter-cap/46/20/86856afb2e6779f5acb261a2b04d1e13" 
infile2 <- paste0("./data/cache/", dataset_id, "46_bird_survey_locations.csv")
if (!file.exists(infile2)) try(download.file(inUrl2, infile2, method = "curl"))
if (!file.exists(infile2)) download.file(inUrl2, infile2, method = "auto")


dt2 <-data.table::fread(infile2,header=F 
               ,skip=1
               ,sep=","  
               ,quot='"' 
               , col.names=c(
                 "site_code",     
                 "location_type",     
                 "lat",     
                 "long",     
                 "begin_date",     
                 "begin_date_month",     
                 "begin_date_year",     
                 "end_date",     
                 "end_date_month",     
                 "end_date_year"    ), check.names=TRUE)



# Fix any interval or ratio columns mistakenly read in as nominal and nominal columns read as numeric or dates read as strings

if (class(dt2$site_code)!="factor") dt2$site_code<- as.factor(dt2$site_code)
if (class(dt2$location_type)!="factor") dt2$location_type<- as.factor(dt2$location_type)
if (class(dt2$lat)=="factor") dt2$lat <-as.numeric(levels(dt2$lat))[as.integer(dt2$lat) ]               
if (class(dt2$lat)=="character") dt2$lat <-as.numeric(dt2$lat)
if (class(dt2$long)=="factor") dt2$long <-as.numeric(levels(dt2$long))[as.integer(dt2$long) ]               
if (class(dt2$long)=="character") dt2$long <-as.numeric(dt2$long)                                   
# attempting to convert dt2$begin_date dateTime string to R date structure (date or POSIXct)                                
tmpDateFormat<-"%Y-%m-%d"
tmp2begin_date<-as.Date(dt2$begin_date,format=tmpDateFormat)
# Keep the new dates only if they all converted correctly
if(length(tmp2begin_date) == length(tmp2begin_date[!is.na(tmp2begin_date)])){dt2$begin_date <- tmp2begin_date } else {print("Date conversion failed for dt2$begin_date. Please inspect the data and do the date conversion yourself.")}                                                                    
rm(tmpDateFormat,tmp2begin_date) 
if (class(dt2$begin_date_month)=="factor") dt2$begin_date_month <-as.numeric(levels(dt2$begin_date_month))[as.integer(dt2$begin_date_month) ]               
if (class(dt2$begin_date_month)=="character") dt2$begin_date_month <-as.numeric(dt2$begin_date_month)
if (class(dt2$begin_date_year)=="factor") dt2$begin_date_year <-as.numeric(levels(dt2$begin_date_year))[as.integer(dt2$begin_date_year) ]               
if (class(dt2$begin_date_year)=="character") dt2$begin_date_year <-as.numeric(dt2$begin_date_year)                                   
# attempting to convert dt2$end_date dateTime string to R date structure (date or POSIXct)                                
tmpDateFormat<-"%Y-%m-%d"
tmp2end_date<-as.Date(dt2$end_date,format=tmpDateFormat)
# Keep the new dates only if they all converted correctly
if(length(tmp2end_date) == length(tmp2end_date[!is.na(tmp2end_date)])){dt2$end_date <- tmp2end_date } else {print("Date conversion failed for dt2$end_date. Please inspect the data and do the date conversion yourself.")}                                                                    
rm(tmpDateFormat,tmp2end_date) 
if (class(dt2$end_date_month)=="factor") dt2$end_date_month <-as.numeric(levels(dt2$end_date_month))[as.integer(dt2$end_date_month) ]               
if (class(dt2$end_date_month)=="character") dt2$end_date_month <-as.numeric(dt2$end_date_month)
if (class(dt2$end_date_year)=="factor") dt2$end_date_year <-as.numeric(levels(dt2$end_date_year))[as.integer(dt2$end_date_year) ]               
if (class(dt2$end_date_year)=="character") dt2$end_date_year <-as.numeric(dt2$end_date_year)

# Convert Missing Values to NA for non-dates

dt2$begin_date_month <- ifelse((trimws(as.character(dt2$begin_date_month))==trimws("NA")),NA,dt2$begin_date_month)               
suppressWarnings(dt2$begin_date_month <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt2$begin_date_month))==as.character(as.numeric("NA"))),NA,dt2$begin_date_month))
dt2$begin_date_year <- ifelse((trimws(as.character(dt2$begin_date_year))==trimws("NA")),NA,dt2$begin_date_year)               
suppressWarnings(dt2$begin_date_year <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt2$begin_date_year))==as.character(as.numeric("NA"))),NA,dt2$begin_date_year))
dt2$end_date_month <- ifelse((trimws(as.character(dt2$end_date_month))==trimws("NA")),NA,dt2$end_date_month)               
suppressWarnings(dt2$end_date_month <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt2$end_date_month))==as.character(as.numeric("NA"))),NA,dt2$end_date_month))
dt2$end_date_year <- ifelse((trimws(as.character(dt2$end_date_year))==trimws("NA")),NA,dt2$end_date_year)               
suppressWarnings(dt2$end_date_year <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt2$end_date_year))==as.character(as.numeric("NA"))),NA,dt2$end_date_year))


# Here is the structure of the input data frame:
str(dt2)                            
attach(dt2)                            
# The analyses below are basic descriptions of the variables. After testing, they should be replaced.                 

summary(site_code)
summary(location_type)
summary(lat)
summary(long)
summary(begin_date)
summary(begin_date_month)
summary(begin_date_year)
summary(end_date)
summary(end_date_month)
summary(end_date_year) 
# Get more details on character variables

summary(as.factor(dt2$site_code)) 
summary(as.factor(dt2$location_type))
detach(dt2)               

dir.create(paste0("./data/raw data/", dataset_id), showWarnings = FALSE)
base::saveRDS(dt2, file = paste0("./data/raw data/", dataset_id, "/rdata2.rds"))
}