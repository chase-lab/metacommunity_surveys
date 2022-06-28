## lightfoot_2022

#data extraction
dt1 <-read.csv("data/raw data/lightfoot_2022/lizard_pitfall_data_89-06.csv",header=F 
               ,skip=1
               ,sep=","  
               ,quot='"' 
               , col.names=c(
                 "date",     
                 "zone",     
                 "site",     
                 "plot",     
                 "pit",     
                 "spp",     
                 "sex",     
                 "rcap",     
                 "toe_num",     
                 "SV_length",     
                 "total_length",     
                 "weight",     
                 "tail",     
                 "pc"    ), check.names=TRUE)


# Fix any interval or ratio columns mistakenly read in as nominal and nominal columns read as numeric or dates read as strings

# attempting to convert dt1$date dateTime string to R date structure (date or POSIXct)                                
tmpDateFormat<-"%Y-%m-%d"
tmp1date<-as.Date(dt1$date,format=tmpDateFormat)
# Keep the new dates only if they all converted correctly
if(length(tmp1date) == length(tmp1date[!is.na(tmp1date)])){dt1$date <- tmp1date } else {print("Date conversion failed for dt1$date. Please inspect the data and do the date conversion yourself.")}                                                                    
rm(tmpDateFormat,tmp1date) 
if (class(dt1$zone)!="factor") dt1$zone<- as.factor(dt1$zone)
if (class(dt1$site)!="factor") dt1$site<- as.factor(dt1$site)
if (class(dt1$plot)!="factor") dt1$plot<- as.factor(dt1$plot)
if (class(dt1$pit)=="factor") dt1$pit <-as.numeric(levels(dt1$pit))[as.integer(dt1$pit) ]               
if (class(dt1$pit)=="character") dt1$pit <-as.numeric(dt1$pit)
if (class(dt1$spp)!="factor") dt1$spp<- as.factor(dt1$spp)
if (class(dt1$sex)!="factor") dt1$sex<- as.factor(dt1$sex)
if (class(dt1$rcap)!="factor") dt1$rcap<- as.factor(dt1$rcap)
if (class(dt1$toe_num)=="factor") dt1$toe_num <-as.numeric(levels(dt1$toe_num))[as.integer(dt1$toe_num) ]               
if (class(dt1$toe_num)=="character") dt1$toe_num <-as.numeric(dt1$toe_num)
if (class(dt1$SV_length)=="factor") dt1$SV_length <-as.numeric(levels(dt1$SV_length))[as.integer(dt1$SV_length) ]               
if (class(dt1$SV_length)=="character") dt1$SV_length <-as.numeric(dt1$SV_length)
if (class(dt1$total_length)=="factor") dt1$total_length <-as.numeric(levels(dt1$total_length))[as.integer(dt1$total_length) ]               
if (class(dt1$total_length)=="character") dt1$total_length <-as.numeric(dt1$total_length)
if (class(dt1$weight)=="character") dt1$weight <-as.numeric(dt1$weight)
if (class(dt1$weight)=="factor") dt1$weight <-as.numeric(levels(dt1$weight))[as.integer(dt1$weight) ]               
if (class(dt1$tail)!="factor") dt1$tail<- as.factor(dt1$tail)
if (class(dt1$pc)!="factor") dt1$pc<- as.factor(dt1$pc)

# Convert Missing Values to NA for non-dates

dt1$plot <- as.factor(ifelse((trimws(as.character(dt1$plot))==trimws("NA")),NA,as.character(dt1$plot)))
dt1$pit <- ifelse((trimws(as.character(dt1$pit))==trimws("NA")),NA,dt1$pit)               
suppressWarnings(dt1$pit <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt1$pit))==as.character(as.numeric("NA"))),NA,dt1$pit))
dt1$rcap <- as.factor(ifelse((trimws(as.character(dt1$rcap))==trimws("NA")),NA,as.character(dt1$rcap)))
dt1$sex <- as.factor(ifelse((trimws(as.character(dt1$sex))==trimws("NA")),NA,as.character(dt1$sex)))
dt1$toe_num <- ifelse((trimws(as.character(dt1$toe_num))==trimws("NA")),NA,dt1$toe_num)               
suppressWarnings(dt1$toe_num <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt1$toe_num))==as.character(as.numeric("NA"))),NA,dt1$toe_num))
dt1$SV_length <- ifelse((trimws(as.character(dt1$SV_length))==trimws("NA")),NA,dt1$SV_length)               
suppressWarnings(dt1$SV_length <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt1$SV_length))==as.character(as.numeric("NA"))),NA,dt1$SV_length))
dt1$total_length <- ifelse((trimws(as.character(dt1$total_length))==trimws("NA")),NA,dt1$total_length)               
suppressWarnings(dt1$total_length <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt1$total_length))==as.character(as.numeric("NA"))),NA,dt1$total_length))
dt1$weight <- ifelse((trimws(as.character(dt1$weight))==trimws("NA")),NA,dt1$weight)               
suppressWarnings(dt1$weight <- ifelse(!is.na(as.numeric("NA")) & (trimws(as.character(dt1$weight))==as.character(as.numeric("NA"))),NA,dt1$weight))
dt1$tail <- as.factor(ifelse((trimws(as.character(dt1$tail))==trimws("NA")),NA,as.character(dt1$tail)))



#help with metadata - where to find, what to usually include?
meta <- unique(dt1[, .(date, zone, site, plot, pit)])

meta[, ":="(
  
  realm = "Terrestrial",
  taxon = "Lizard",
  
  latitude = '32°40`08.4000"N',
  longitude = '-106°51`54.0000"E',
  
  effort = 4L,  ###what means effort
  
  study_type = "resurvey",
  
  data_pooled_by_authors = FALSE, ##what?
  data_pooled_by_authors_comment = NA, ##
  sampling_years = NA, ###
  
  alpha_grain = 100L,  ###what?
  alpha_grain_unit = "m2", #
  alpha_grain_type = "sample", #
  alpha_grain_comment = "50m long 2m wide transect",  ###pitfall traps
  
  gamma_bounding_box = 1002L, ###what?
  gamma_bounding_box_unit = "acres", #
  gamma_bounding_box_type = "administrative", #
  gamma_bounding_box_comment = "sum of the water area of the War in Pacific National Park.", ##
  
  gamma_sum_grains = 4L * 100L, #
  gamma_sum_grains_unit = "m2", #
  gamma_sum_grains_type = "plot", #
  gamma_sum_grains_comment = "sum of sampled transects", ##
)]

#Exclude: 
#-
#- M-NORT grid installed 03/03/1995. Moved from M-RABB-C site. -exclude what?
#-G-SUMM grid installed 06/06/1995. Moved from G-IBPE-A site

dt1 <-dt1[!is.na(dt1$plot), ] #remove NA, I6-unknown location in site M-RABB
dt1 <-dt1[!(dt1$site == 'SAND' && dt1$plot =='C'), ] # pitfall grid called C-SAND Plot C was discontinued in 1997


###understanding data:
#check how many samples per date
date_points =dt1 %>% group_by(date) %>% count(date)
ggplot(date_points, aes(x = date, y = n)) +  
  geom_bar(stat = "identity") + theme(axis.text.x = element_text(size = 2,angle = 60, hjust = 1))
###not normally distibuted 

#check for how many individuals sampled per plot & date 
individuals_per_plot = dt1 %>% group_by(date, plot, site) %>% count(date, plot)
ggplot(individuals_per_plot, aes(x = date, y = n)) +  
  geom_bar(stat = "identity") + facet_wrap( ~ site) +
  theme(axis.text.x = element_text(size = 2,angle = 60, hjust = 1))

#check which plot for site, how many entries
individ_plot_site = dt1 %>% group_by( plot, site) %>% count(site)
ggplot(individ_plot_site, aes(x = plot, y = n)) +  
  geom_bar(stat = "identity") + facet_wrap( ~ site) +
  theme(axis.text.x = element_text(size = 2,angle = 60, hjust = 1))
          
