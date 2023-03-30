dataset_id <- "sonnier_2022"

# Package ID: edi.1157.1 Cataloging System:https://pasta.edirepository.org.
# Data set title: Long-term response of wetland plant communities to management intensity, grazing abandonment, and prescribed fire.
# Data set creator:  GrÃ©gory Sonnier - Archbold Biological Station
# Data set creator:  Ruth Whittington - Colorado Natural Heritage Program
# Data set creator:  Elizabeth Boughton - Archbold Biological Station
# Contact:  Data Manager -  Archbold Biological Station  - datamanager@archbold-station.org
# Stylesheet v2.11 for metadata conversion into program: John H. Porter, Univ. Virginia, jporter@virginia.edu
if (!file.exists("./data/raw data/sonnier_2022/rdata.rds")) {

   inUrl1  <- "https://pasta.lternet.edu/package/data/eml/edi/1157/1/5876c13b2d6c4a668729b76f0d800c3d"
   infile1 <- "./data/cache/sonnier_dt31.csv"
   try(download.file(inUrl1,infile1,method="curl"))
   if (is.na(file.size(infile1))) download.file(inUrl1,infile1,method="auto")


   dt1 <-read.csv(infile1,header=F
                  ,skip=1
                  ,sep=","
                  ,quot='"'
                  , col.names=c(
                     "year",
                     "wetland_ID",
                     "species_ID",
                     "incidence"    ), check.names=TRUE)

   # Fix any interval or ratio columns mistakenly read in as nominal and nominal columns read as numeric or dates read as strings

   if (class(dt1$wetland_ID)!="factor") dt1$wetland_ID<- as.factor(dt1$wetland_ID)
   if (class(dt1$species_ID)!="factor") dt1$species_ID<- as.factor(dt1$species_ID)
   if (class(dt1$incidence)=="factor") dt1$incidence <-as.numeric(levels(dt1$incidence))[as.integer(dt1$incidence) ]
   if (class(dt1$incidence)=="character") dt1$incidence <-as.numeric(dt1$incidence)


   inUrl3  <- "https://pasta.lternet.edu/package/data/eml/edi/1157/1/a927e111541e05414ab1b387e929a28f"
   infile3 <- "./data/cache/sonnier_dt3.csv"
   try(download.file(inUrl3,infile3,method="curl"))
   if (is.na(file.size(infile3))) download.file(inUrl3,infile3,method="auto")


   dt3 <-read.csv(infile3,header=F
                  ,skip=1
                  ,sep=","
                  ,quot='"'
                  , col.names=c(
                     "species_ID",
                     "scientific_name",
                     "family",
                     "clade",
                     "growthform",
                     "duration",
                     "origin",
                     "wetland_status",
                     "coefficient_conservatism"    ), check.names=TRUE)

   # Fix any interval or ratio columns mistakenly read in as nominal and nominal columns read as numeric or dates read as strings

   if (class(dt3$species_ID)!="factor") dt3$species_ID<- as.factor(dt3$species_ID)
   if (class(dt3$scientific_name)!="factor") dt3$scientific_name<- as.factor(dt3$scientific_name)
   if (class(dt3$family)!="factor") dt3$family<- as.factor(dt3$family)
   if (class(dt3$clade)!="factor") dt3$clade<- as.factor(dt3$clade)
   if (class(dt3$growthform)!="factor") dt3$growthform<- as.factor(dt3$growthform)
   if (class(dt3$duration)!="factor") dt3$duration<- as.factor(dt3$duration)
   if (class(dt3$origin)!="factor") dt3$origin<- as.factor(dt3$origin)
   if (class(dt3$wetland_status)!="factor") dt3$wetland_status<- as.factor(dt3$wetland_status)
   if (class(dt3$coefficient_conservatism)=="factor") dt3$coefficient_conservatism <-as.numeric(levels(dt3$coefficient_conservatism))[as.integer(dt3$coefficient_conservatism) ]
   if (class(dt3$coefficient_conservatism)=="character") dt3$coefficient_conservatism <-as.numeric(dt3$coefficient_conservatism)

   #combine dt1 and dt3
   dt1 <- unique(dt1)
   ddata <- base::merge(dt1,dt3[, c("species_ID","scientific_name")], by = "species_ID", all = TRUE)
   data.table::setDT(ddata)
   base::saveRDS(ddata, "./data/raw data/sonnier_2022/rdata.rds")
}
