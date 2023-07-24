# magnuson_2020
dataset_id <- "magnuson_2020"

if (!file.exists(paste0("./data/raw data/", dataset_id, "/rdata.rds"))) {
   # Package ID: knb-lter-ntl.13.34 Cataloging System:https://pasta.edirepository.org.
   # Data set title: North Temperate Lakes LTER Pelagic Macroinvertebrate Abundance 1983 - current.
   # Data set creator:  John Magnuson - University of Wisconsin
   # Data set creator:  Stephen Carpenter - University of Wisconsin
   # Data set creator:  Emily Stanley - University of Wisconsin
   # Contact:    -  NTL LTER  - ntl.infomgr@gmail.com
   # Stylesheet v2.11 for metadata conversion into program: John H. Porter, Univ. Virginia, jporter@virginia.edu

   inUrl1  <- "https://pasta.lternet.edu/package/data/eml/knb-lter-ntl/13/34/35a501a8e187da22f6cfc07015fca911"
   infile1 <- paste0("./data/cache/", dataset_id, "_knb-lter-ntl_13_34.csv")
  if (!file.exists(infile1)) try(download.file(inUrl1, infile1, method = "curl"))
  if (!file.exists(infile1)) download.file(inUrl1, infile1, method = "auto")


  dt1 <- data.table::fread(infile1,
    header = F,
    skip = 1,
    sep = ",",
    quot = '"',
    col.names = c(
      "lakeid",
      "year4",
      "sta",
      "depth",
      "taxon",
      "rep",
      "number_indiv"
    ), check.names = TRUE
  )


  # Fix any interval or ratio columns mistakenly read in as nominal and nominal columns read as numeric or dates read as strings

  if (class(dt1$lakeid)!="factor") dt1$lakeid<- as.factor(dt1$lakeid)
  if (class(dt1$year4)=="factor") dt1$year4 <-as.numeric(levels(dt1$year4))[as.integer(dt1$year4) ]
  if (class(dt1$year4)=="character") dt1$year4 <-as.numeric(dt1$year4)
  if (class(dt1$sta)!="factor") dt1$sta<- as.factor(dt1$sta)
  if (class(dt1$depth)=="factor") dt1$depth <-as.numeric(levels(dt1$depth))[as.integer(dt1$depth) ]
  if (class(dt1$depth)=="character") dt1$depth <-as.numeric(dt1$depth)
  if (class(dt1$taxon)!="factor") dt1$taxon<- as.factor(dt1$taxon)
  if (class(dt1$rep)!="factor") dt1$rep<- as.factor(dt1$rep)
  if (class(dt1$number_indiv)=="factor") dt1$number_indiv <-as.numeric(levels(dt1$number_indiv))[as.integer(dt1$number_indiv) ]
  if (class(dt1$number_indiv)=="character") dt1$number_indiv <-as.numeric(dt1$number_indiv)

  dir.create(paste0("./data/raw data/", dataset_id), showWarnings = FALSE)
  base::saveRDS(dt1, file = paste0("./data/raw data/", dataset_id, "/rdata.rds"))
}
