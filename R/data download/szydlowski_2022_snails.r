# szydlowski_2022_snails

# Package ID: knb-lter-ntl.417.1 Cataloging System:https://pasta.edirepository.org.
# Data set title: Aquatic snail and macrophyte abundance and richness data for ten lakes in Vilas County,       WI, USA, 1987-2020.
# Data set creator:  Daniel Szydlowski - Center for Limnology, University of Wisconsin-Madison
# Data set creator: Dr. Ashley Elgin - National Oceanic and Atmospheric Administration, Great Lakes Environmental
# Research Laboratory, Muskegon, Michigan
# Data set creator: Dr. David Lodge - Cornell Atkinson Center for Sustainability, and Department of Ecology and
# Evolutionary Biology, Cornell University
# Data set creator:  Jeremy Tiemann - Illinois Natural History Survey, University of Illinois at
# Urbana-Champaign
# Data set creator: Dr. Eric Larson - Department of Natural Resources and Environmental Sciences, University of
# Illinois at Urbana-Champaign
# Metadata Provider:  Daniel Szydlowski - Center for Limnology, University of Wisconsin-Madison
# Contact:  Daniel Szydlowski -  Center for Limnology, University of Wisconsin-Madison  - dszydlowski@wisc.edu
# Stylesheet v2.11 for metadata conversion into program: John H. Porter, Univ. Virginia, jporter@virginia.edu

if (!file.exists("./data/raw data/szydlowski_2022_snails/rdata.rds")) {
   inUrl1  <- "https://pasta.lternet.edu/package/data/eml/knb-lter-ntl/417/1/b2883a4bf1f0d8e67559e9680d0d945c"
   infile1 <- "./data/cache/szydlowski_2022_final_MLS_snails.csv"
   if (!file.exists(infile1)) try(curl::curl_download(inUrl1,infile1,method="curl"))
   if (!file.exists(infile1)) curl::curl_download(inUrl1,infile1,method="auto")


   dt1 <- data.table::fread(file = infile1, header=F
                            ,skip=1
                            ,sep=","
                            ,quot='"'
                            , col.names=c(
                               "ID",
                               "year",
                               "date",
                               "lake",
                               "sector",
                               "code",
                               "yearcode",
                               "lat",
                               "long",
                               "depth",
                               "substrate",
                               "gear",
                               "INHS_catalog_num",
                               "richness",
                               "abundance",
                               "Acella_haldemani",
                               "Amnicola_limosa",
                               "Campeloma_decisum",
                               "Cipangopaludina_chinensis",
                               "Ferrisia_spp",
                               "Galba_obrussa",
                               "Galba_parva",
                               "Galba_spp",
                               "Gyraulus_deflectus",
                               "Gyraulus_parvus",
                               "Helisoma_anceps",
                               "Helisoma_campanulata",
                               "Lymnaea_stagnalis",
                               "Lymnaeidae_spp",
                               "Lyogyrus_walkeri",
                               "Marstonia_lustrica",
                               "Physa_spp",
                               "Planorbella_trivolvis",
                               "Promenetus_exacuous",
                               "Stagnicola_elodes",
                               "Stagnicola_emarginata",
                               "Stagnicola_spp",
                               "Stagnicola_woodruffi",
                               "Unknown",
                               "Valvata_bicarinata",
                               "Valvata_lewisi",
                               "Valvata_sincera",
                               "Valvata_spp",
                               "Valvata_tricarinata",
                               "Viviparus_georgianus"    ), check.names=TRUE)



   # Fix any interval or ratio columns mistakenly read in as nominal and nominal columns read as numeric or dates read as strings

   if (class(dt1$ID)!="factor") dt1$ID<- as.factor(dt1$ID)
   if (class(dt1$date)!="factor") dt1$date<- as.factor(dt1$date)
   if (class(dt1$lake)!="factor") dt1$lake<- as.factor(dt1$lake)
   if (class(dt1$sector)!="factor") dt1$sector<- as.factor(dt1$sector)
   if (class(dt1$code)!="factor") dt1$code<- as.factor(dt1$code)
   if (class(dt1$yearcode)!="factor") dt1$yearcode<- as.factor(dt1$yearcode)
   if (class(dt1$lat)!="numeric") dt1$lat<- as.numeric(dt1$lat)
   if (class(dt1$long)!="numeric") dt1$long<- as.numeric(dt1$long)
   if (class(dt1$depth)!="factor") dt1$depth<- as.factor(dt1$depth)
   if (class(dt1$substrate)!="factor") dt1$substrate<- as.factor(dt1$substrate)
   if (class(dt1$gear)!="factor") dt1$gear<- as.factor(dt1$gear)
   if (class(dt1$INHS_catalog_num)!="factor") dt1$INHS_catalog_num<- as.factor(dt1$INHS_catalog_num)
   if (class(dt1$richness)=="factor") dt1$richness <-as.numeric(levels(dt1$richness))[as.integer(dt1$richness) ]
   if (class(dt1$richness)=="character") dt1$richness <-as.numeric(dt1$richness)
   if (class(dt1$abundance)=="factor") dt1$abundance <-as.numeric(levels(dt1$abundance))[as.integer(dt1$abundance) ]
   if (class(dt1$abundance)=="character") dt1$abundance <-as.numeric(dt1$abundance)
   if (class(dt1$Acella_haldemani)=="factor") dt1$Acella_haldemani <-as.numeric(levels(dt1$Acella_haldemani))[as.integer(dt1$Acella_haldemani) ]
   if (class(dt1$Acella_haldemani)=="character") dt1$Acella_haldemani <-as.numeric(dt1$Acella_haldemani)
   if (class(dt1$Amnicola_limosa)=="factor") dt1$Amnicola_limosa <-as.numeric(levels(dt1$Amnicola_limosa))[as.integer(dt1$Amnicola_limosa) ]
   if (class(dt1$Amnicola_limosa)=="character") dt1$Amnicola_limosa <-as.numeric(dt1$Amnicola_limosa)
   if (class(dt1$Campeloma_decisum)=="factor") dt1$Campeloma_decisum <-as.numeric(levels(dt1$Campeloma_decisum))[as.integer(dt1$Campeloma_decisum) ]
   if (class(dt1$Campeloma_decisum)=="character") dt1$Campeloma_decisum <-as.numeric(dt1$Campeloma_decisum)
   if (class(dt1$Cipangopaludina_chinensis)=="factor") dt1$Cipangopaludina_chinensis <-as.numeric(levels(dt1$Cipangopaludina_chinensis))[as.integer(dt1$Cipangopaludina_chinensis) ]
   if (class(dt1$Cipangopaludina_chinensis)=="character") dt1$Cipangopaludina_chinensis <-as.numeric(dt1$Cipangopaludina_chinensis)
   if (class(dt1$Ferrisia_spp)=="factor") dt1$Ferrisia_spp <-as.numeric(levels(dt1$Ferrisia_spp))[as.integer(dt1$Ferrisia_spp) ]
   if (class(dt1$Ferrisia_spp)=="character") dt1$Ferrisia_spp <-as.numeric(dt1$Ferrisia_spp)
   if (class(dt1$Galba_obrussa)=="factor") dt1$Galba_obrussa <-as.numeric(levels(dt1$Galba_obrussa))[as.integer(dt1$Galba_obrussa) ]
   if (class(dt1$Galba_obrussa)=="character") dt1$Galba_obrussa <-as.numeric(dt1$Galba_obrussa)
   if (class(dt1$Galba_parva)=="factor") dt1$Galba_parva <-as.numeric(levels(dt1$Galba_parva))[as.integer(dt1$Galba_parva) ]
   if (class(dt1$Galba_parva)=="character") dt1$Galba_parva <-as.numeric(dt1$Galba_parva)
   if (class(dt1$Galba_spp)=="factor") dt1$Galba_spp <-as.numeric(levels(dt1$Galba_spp))[as.integer(dt1$Galba_spp) ]
   if (class(dt1$Galba_spp)=="character") dt1$Galba_spp <-as.numeric(dt1$Galba_spp)
   if (class(dt1$Gyraulus_deflectus)=="factor") dt1$Gyraulus_deflectus <-as.numeric(levels(dt1$Gyraulus_deflectus))[as.integer(dt1$Gyraulus_deflectus) ]
   if (class(dt1$Gyraulus_deflectus)=="character") dt1$Gyraulus_deflectus <-as.numeric(dt1$Gyraulus_deflectus)
   if (class(dt1$Gyraulus_parvus)=="factor") dt1$Gyraulus_parvus <-as.numeric(levels(dt1$Gyraulus_parvus))[as.integer(dt1$Gyraulus_parvus) ]
   if (class(dt1$Gyraulus_parvus)=="character") dt1$Gyraulus_parvus <-as.numeric(dt1$Gyraulus_parvus)
   if (class(dt1$Helisoma_anceps)=="factor") dt1$Helisoma_anceps <-as.numeric(levels(dt1$Helisoma_anceps))[as.integer(dt1$Helisoma_anceps) ]
   if (class(dt1$Helisoma_anceps)=="character") dt1$Helisoma_anceps <-as.numeric(dt1$Helisoma_anceps)
   if (class(dt1$Helisoma_campanulata)=="factor") dt1$Helisoma_campanulata <-as.numeric(levels(dt1$Helisoma_campanulata))[as.integer(dt1$Helisoma_campanulata) ]
   if (class(dt1$Helisoma_campanulata)=="character") dt1$Helisoma_campanulata <-as.numeric(dt1$Helisoma_campanulata)
   if (class(dt1$Lymnaea_stagnalis)=="factor") dt1$Lymnaea_stagnalis <-as.numeric(levels(dt1$Lymnaea_stagnalis))[as.integer(dt1$Lymnaea_stagnalis) ]
   if (class(dt1$Lymnaea_stagnalis)=="character") dt1$Lymnaea_stagnalis <-as.numeric(dt1$Lymnaea_stagnalis)
   if (class(dt1$Lymnaeidae_spp)=="factor") dt1$Lymnaeidae_spp <-as.numeric(levels(dt1$Lymnaeidae_spp))[as.integer(dt1$Lymnaeidae_spp) ]
   if (class(dt1$Lymnaeidae_spp)=="character") dt1$Lymnaeidae_spp <-as.numeric(dt1$Lymnaeidae_spp)
   if (class(dt1$Lyogyrus_walkeri)=="factor") dt1$Lyogyrus_walkeri <-as.numeric(levels(dt1$Lyogyrus_walkeri))[as.integer(dt1$Lyogyrus_walkeri) ]
   if (class(dt1$Lyogyrus_walkeri)=="character") dt1$Lyogyrus_walkeri <-as.numeric(dt1$Lyogyrus_walkeri)
   if (class(dt1$Marstonia_lustrica)=="factor") dt1$Marstonia_lustrica <-as.numeric(levels(dt1$Marstonia_lustrica))[as.integer(dt1$Marstonia_lustrica) ]
   if (class(dt1$Marstonia_lustrica)=="character") dt1$Marstonia_lustrica <-as.numeric(dt1$Marstonia_lustrica)
   if (class(dt1$Physa_spp)=="factor") dt1$Physa_spp <-as.numeric(levels(dt1$Physa_spp))[as.integer(dt1$Physa_spp) ]
   if (class(dt1$Physa_spp)=="character") dt1$Physa_spp <-as.numeric(dt1$Physa_spp)
   if (class(dt1$Planorbella_trivolvis)=="factor") dt1$Planorbella_trivolvis <-as.numeric(levels(dt1$Planorbella_trivolvis))[as.integer(dt1$Planorbella_trivolvis) ]
   if (class(dt1$Planorbella_trivolvis)=="character") dt1$Planorbella_trivolvis <-as.numeric(dt1$Planorbella_trivolvis)
   if (class(dt1$Promenetus_exacuous)=="factor") dt1$Promenetus_exacuous <-as.numeric(levels(dt1$Promenetus_exacuous))[as.integer(dt1$Promenetus_exacuous) ]
   if (class(dt1$Promenetus_exacuous)=="character") dt1$Promenetus_exacuous <-as.numeric(dt1$Promenetus_exacuous)
   if (class(dt1$Stagnicola_elodes)=="factor") dt1$Stagnicola_elodes <-as.numeric(levels(dt1$Stagnicola_elodes))[as.integer(dt1$Stagnicola_elodes) ]
   if (class(dt1$Stagnicola_elodes)=="character") dt1$Stagnicola_elodes <-as.numeric(dt1$Stagnicola_elodes)
   if (class(dt1$Stagnicola_emarginata)=="factor") dt1$Stagnicola_emarginata <-as.numeric(levels(dt1$Stagnicola_emarginata))[as.integer(dt1$Stagnicola_emarginata) ]
   if (class(dt1$Stagnicola_emarginata)=="character") dt1$Stagnicola_emarginata <-as.numeric(dt1$Stagnicola_emarginata)
   if (class(dt1$Stagnicola_spp)=="factor") dt1$Stagnicola_spp <-as.numeric(levels(dt1$Stagnicola_spp))[as.integer(dt1$Stagnicola_spp) ]
   if (class(dt1$Stagnicola_spp)=="character") dt1$Stagnicola_spp <-as.numeric(dt1$Stagnicola_spp)
   if (class(dt1$Stagnicola_woodruffi)=="factor") dt1$Stagnicola_woodruffi <-as.numeric(levels(dt1$Stagnicola_woodruffi))[as.integer(dt1$Stagnicola_woodruffi) ]
   if (class(dt1$Stagnicola_woodruffi)=="character") dt1$Stagnicola_woodruffi <-as.numeric(dt1$Stagnicola_woodruffi)
   if (class(dt1$Unknown)=="factor") dt1$Unknown <-as.numeric(levels(dt1$Unknown))[as.integer(dt1$Unknown) ]
   if (class(dt1$Unknown)=="character") dt1$Unknown <-as.numeric(dt1$Unknown)
   if (class(dt1$Valvata_bicarinata)=="factor") dt1$Valvata_bicarinata <-as.numeric(levels(dt1$Valvata_bicarinata))[as.integer(dt1$Valvata_bicarinata) ]
   if (class(dt1$Valvata_bicarinata)=="character") dt1$Valvata_bicarinata <-as.numeric(dt1$Valvata_bicarinata)
   if (class(dt1$Valvata_lewisi)=="factor") dt1$Valvata_lewisi <-as.numeric(levels(dt1$Valvata_lewisi))[as.integer(dt1$Valvata_lewisi) ]
   if (class(dt1$Valvata_lewisi)=="character") dt1$Valvata_lewisi <-as.numeric(dt1$Valvata_lewisi)
   if (class(dt1$Valvata_sincera)=="factor") dt1$Valvata_sincera <-as.numeric(levels(dt1$Valvata_sincera))[as.integer(dt1$Valvata_sincera) ]
   if (class(dt1$Valvata_sincera)=="character") dt1$Valvata_sincera <-as.numeric(dt1$Valvata_sincera)
   if (class(dt1$Valvata_spp)=="factor") dt1$Valvata_spp <-as.numeric(levels(dt1$Valvata_spp))[as.integer(dt1$Valvata_spp) ]
   if (class(dt1$Valvata_spp)=="character") dt1$Valvata_spp <-as.numeric(dt1$Valvata_spp)
   if (class(dt1$Valvata_tricarinata)=="factor") dt1$Valvata_tricarinata <-as.numeric(levels(dt1$Valvata_tricarinata))[as.integer(dt1$Valvata_tricarinata) ]
   if (class(dt1$Valvata_tricarinata)=="character") dt1$Valvata_tricarinata <-as.numeric(dt1$Valvata_tricarinata)
   if (class(dt1$Viviparus_georgianus)=="factor") dt1$Viviparus_georgianus <-as.numeric(levels(dt1$Viviparus_georgianus))[as.integer(dt1$Viviparus_georgianus) ]
   if (class(dt1$Viviparus_georgianus)=="character") dt1$Viviparus_georgianus <-as.numeric(dt1$Viviparus_georgianus)

   # Convert Missing Values to NA for non-dates

   dt1$gear <- as.factor(ifelse((trimws(as.character(dt1$gear))==trimws("NA")),NA,as.character(dt1$gear)))
   dt1$INHS_catalog_num <- as.factor(ifelse((trimws(as.character(dt1$INHS_catalog_num))==trimws("NA")),NA,as.character(dt1$INHS_catalog_num)))

   dir.create(path = "./data/raw data/szydlowski_2022_snails", showWarnings = FALSE)
   base::saveRDS(object = dt1, file = "./data/raw data/szydlowski_2022_snails/rdata.rds")
}
