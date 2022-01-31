# magnuson_2020
dataset_id <- "magnuson_2020"

if (!file.exists(paste0("./data/raw data/", dataset_id, "/rdata.rds"))) {
  # Package ID: knb-lter-ntl.13.32 Cataloging System:https://pasta.edirepository.org.
  # Data set title: North Temperate Lakes LTER Pelagic Macroinvertebrate Abundance 1983 - current.
  # Data set creator:  John Magnuson - University of Wisconsin
  # Data set creator:  Stephen Carpenter - University of Wisconsin
  # Data set creator:  Emily Stanley - University of Wisconsin
  # Metadata Provider:  NTL Information Manager - University of Wisconsin
  # Contact:  NTL Information Manager -  University of Wisconsin  - ntl.infomgr@gmail.com
  # Contact:  NTL Lead PI -  University of Wisconsin  - ntl.leadpi@gmail.com
  # Stylesheet v2.11 for metadata conversion into program: John H. Porter, Univ. Virginia, jporter@virginia.edu

  inUrl1 <- "https://pasta.lternet.edu/package/data/eml/knb-lter-ntl/13/32/35a501a8e187da22f6cfc07015fca911"
  infile1 <- paste0("./data/cache/", dataset_id, "_knb-lter-ntl_13_32.csv")
  if (!file.exists(infile1)) try(download.file(inUrl1, infile1, method = "curl"))
  if (!file.exists(infile1)) download.file(inUrl1, infile1, method = "auto")


  rdata <- data.table::fread(infile1,
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

  if (class(rdata$lakeid) != "factor") rdata$lakeid <- as.factor(rdata$lakeid)
  if (class(rdata$year4) == "factor") rdata$year4 <- as.numeric(levels(rdata$year4))[as.integer(rdata$year4)]
  if (class(rdata$year4) == "character") rdata$year4 <- as.numeric(rdata$year4)
  if (class(rdata$sta) != "factor") rdata$sta <- as.factor(rdata$sta)
  if (class(rdata$depth) == "factor") rdata$depth <- as.numeric(levels(rdata$depth))[as.integer(rdata$depth)]
  if (class(rdata$depth) == "character") rdata$depth <- as.numeric(rdata$depth)
  if (class(rdata$taxon) != "factor") rdata$taxon <- as.factor(rdata$taxon)
  if (class(rdata$rep) != "factor") rdata$rep <- as.factor(rdata$rep)
  if (class(rdata$number_indiv) == "factor") rdata$number_indiv <- as.numeric(levels(rdata$number_indiv))[as.integer(rdata$number_indiv)]
  if (class(rdata$number_indiv) == "character") rdata$number_indiv <- as.numeric(rdata$number_indiv)

  # Convert Missing Values to NA for non-dates



  # Here is the structure of the input data frame:
  str(rdata)
  attach(rdata)
  # The analyses below are basic descriptions of the variables. After testing, they should be replaced.

  summary(lakeid)
  summary(year4)
  summary(sta)
  summary(depth)
  summary(taxon)
  # summary(rep)
  summary(number_indiv)
  # Get more details on character variables

  summary(as.factor(rdata$lakeid))
  summary(as.factor(rdata$sta))
  summary(as.factor(rdata$taxon))
  summary(as.factor(rdata$rep))
  detach(rdata)

  dir.create(paste0("./data/raw data/", dataset_id), showWarnings = FALSE)
  base::saveRDS(rdata, file = paste0("./data/raw data/", dataset_id, "/rdata.rds"))
}
