## lightfoot_2022
library(ggplot2)
library(dplyr)
ddata<- readRDS("data/raw data/lightfoot_2022/lizard_pitfall_data_89-06.rds")
#data extraction
# Fix any interval or ratio columns mistakenly read in as nominal and nominal columns read as numeric or dates read as strings
dataset_id <- "lightfoot_2022"
# attempting to convert ddata$date dateTime string to R date structure (date or POSIXct)                                
tmpDateFormat<-"%Y-%m-%d"
tmp1date<-as.Date(ddata$date,format=tmpDateFormat)
# Keep the new dates only if they all converted correctly
if(length(tmp1date) == length(tmp1date[!is.na(tmp1date)])){ddata$date <- tmp1date } else {print("Date conversion failed for ddata$date. Please inspect the data and do the date conversion yourself.")}                                                                    
rm(tmpDateFormat,tmp1date) 
if (class(ddata$zone)!="factor") ddata$zone<- as.factor(ddata$zone)
if (class(ddata$site)!="factor") ddata$site<- as.factor(ddata$site)
if (class(ddata$plot)!="factor") ddata$plot<- as.factor(ddata$plot)
if (class(ddata$pit)=="factor") ddata$pit <-as.numeric(levels(ddata$pit))[as.integer(ddata$pit) ]               
if (class(ddata$pit)=="character") ddata$pit <-as.numeric(ddata$pit)
if (class(ddata$spp)!="factor") ddata$spp<- as.factor(ddata$spp)

# Convert Missing Values to NA for non-dates

ddata$plot <- as.factor(ifelse((trimws(as.character(ddata$plot))==trimws("NA")),NA,as.character(ddata$plot)))
ddata$pit <- ifelse((trimws(as.character(ddata$pit))==trimws("NA")),NA,ddata$pit)               
suppressWarnings(ddata$pit <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(ddata$pit))==as.character(as.numeric("NA"))),NA,ddata$pit))


#Exclude: 
#-opened for two consecutive weeks every month for the period 16 June 1989 to 23 August 1991. Beginning after August 1991, traps were opened for two consecutive weeks quarterly: in February-March (following winter NPP measurements), in May-June (following spring NPP), in August, and in October-November (following fall NPP). 
#-> reduce data to October, November, August, Februar, March, May, June
#- M-NORT grid installed 03/03/1995. Moved from M-RABB-C site. -exclude what?
#-G-SUMM grid installed 06/06/1995. Moved from G-IBPE-A site
# exclude double plots

ddata <-ddata[!is.na(ddata$plot), ] #remove NA, I6-unknown location in site M-RABB
ddata <- ddata[!(site == 'SAND' & plot == 'C')&!(site == 'RABB' & plot == 'C')&!(site == 'IBPE' & plot == 'C')] #remove plots uncomplete in time - reduce to 1 plot

#rename columns & cleaning: 
ddata <- unique(ddata[,.(date, zone, site, spp)])
#dataset
data.table::setnames(ddata, c("date","regional", "local", "species"))

ddata[, ":="(
  dataset_id = dataset_id,
  value = 1,
  metric = "pa",
  unit = "pa"
)]
#metadata
meta <- unique(ddata[, .(date, regional, local, plot)])

meta[, ":="(
  realm = "Terrestrial",
  taxon = "Herpetofauna",
  
  latitude = '32°40`08.4000"N',
  longitude = '106°51`54.0000"W',
  
  effort = 16L,  #plots per area?
  
  study_type = "ecological sampling", #two possible values, or NA if not sure 
  
  data_pooled_by_authors = FALSE, 
  data_pooled_by_authors_comment = NA, 
  sampling_years = NA, 
  
  alpha_grain = 90L,  #size/area of individual trap per local
  alpha_grain_unit = "cm2", #"acres", "ha", "km2", "m2", "cm2"
  alpha_grain_type = "trap", 
  alpha_grain_comment = "15 cm2 diameter pitfall traps",
  
  gamma_bounding_box = 120L, #size of biggest common scale can be different values for different areas per region
  gamma_bounding_box_unit = "km2", 
  gamma_bounding_box_type = "box", 
  gamma_bounding_box_comment = "complete area in which the 11 plots are located",
  
  gamma_sum_grains = 90L, #90x number of sites per year  
  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "plot",
  gamma_sum_grains_comment = "Each grid consisted of 4 x 4 rows of traps spaced at 15 meter intervals",

  comment = ""
  )]


#check standartisation in time - questionable effort equality
ym <- data.frame(substr(ddata$date, 1, 7))
ym <- as.data.frame(table(ym))
ym$Freq

m <- data.frame(substr(ddata$date, 6, 7))
m <- as.data.frame(table(m))
m$Freq


###understanding data:
#check how many samples per date
date_points =ddata %>% group_by(date) %>% count(date)
ggplot(date_points, aes(x = date, y = n)) +  
  geom_bar(stat = "identity") + theme(axis.text.x = element_text(size = 2,angle = 60, hjust = 1))
###not normally distibuted 

#check for how many individuals sampled per plot & date 
individuals_per_plot = ddata %>% group_by(date, plot, site) %>% count(date, plot)
ggplot(individuals_per_plot, aes(x = date, y = n)) +  
  geom_bar(stat = "identity") + facet_wrap( ~ site) +
  theme(axis.text.x = element_text(size = 2,angle = 60, hjust = 1))

#check which plot for site, how many entries
individ_plot_site = ddata %>% group_by( plot, local) %>% count(local)
ggplot(individ_plot_site, aes(x = plot, y = n)) +  
  geom_bar(stat = "identity") + facet_wrap( ~ local) +
  theme(axis.text.x = element_text(size = 2,angle = 60, hjust = 1))
