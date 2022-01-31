# Package ID: knb-lter-sbc.51.10 Cataloging System:https://pasta.edirepository.org.
# Data set title: SBC LTER: Beach: Time series of abundance of birds and stranded kelp on selected beaches, ongoing since 2008.
# Data set creator:    - Santa Barbara Coastal LTER
# Data set creator:  Jenifer E Dugan -
# Contact:    - Information Manager, Santa Barbara Coastal LTER   - sbclter@msi.ucsb.edu
# Stylesheet v2.11 for metadata conversion into program: John H. Porter, Univ. Virginia, jporter@virginia.edu

if (!file.exists("./data/raw data/dugan_2021/rdata.rds")) {
  inUrl1 <- "https://pasta.lternet.edu/package/data/eml/knb-lter-sbc/51/10/c63213ebb13dbd5371ced78f039fa73d"
  dir.create("./data/raw data/dugan_2021", showWarnings = FALSE)
  infile1 <- "./data/raw data/dugan_2021/rdata.csv"
  if (!file.exists(infile1)) try(download.file(inUrl1, infile1, method = "curl"))
  if (!file.exists(infile1)) download.file(inUrl1, infile1, method = "auto")


  dt1 <- read.csv(infile1,
    header = F,
    skip = 1,
    sep = ",",
    quot = '"',
    col.names = c(
      "YEAR",
      "MONTH",
      "DATE",
      "SITE",
      "COMMON_NAME",
      "TOTAL",
      "TAXON_GENUS",
      "TAXON_SPECIES",
      "TAXON_GROUP",
      "SURVEY",
      "TAXON_KINGDOM",
      "TAXON_PHYLUM",
      "TAXON_CLASS",
      "TAXON_ORDER",
      "TAXON_FAMILY"
    ), check.names = TRUE
  )

  unlink(infile1)

  # Fix any interval or ratio columns mistakenly read in as nominal and nominal columns read as numeric or dates read as strings

  if (class(dt1$MONTH) != "factor") dt1$MONTH <- as.factor(dt1$MONTH)
  # attempting to convert dt1$DATE dateTime string to R date structure (date or POSIXct)
  tmpDateFormat <- "%m/%d/%Y"
  tmp1DATE <- as.Date(dt1$DATE, format = tmpDateFormat)
  # Keep the new dates only if they all converted correctly
  if (length(tmp1DATE) == length(tmp1DATE[!is.na(tmp1DATE)])) {
    dt1$DATE <- tmp1DATE
  } else {
    print("Date conversion failed for dt1$DATE. Please inspect the data and do the date conversion yourself.")
  }
  rm(tmpDateFormat, tmp1DATE)
  if (class(dt1$SITE) != "factor") dt1$SITE <- as.factor(dt1$SITE)
  if (class(dt1$COMMON_NAME) != "factor") dt1$COMMON_NAME <- as.factor(dt1$COMMON_NAME)
  if (class(dt1$TOTAL) == "factor") dt1$TOTAL <- as.numeric(levels(dt1$TOTAL))[as.integer(dt1$TOTAL)]
  if (class(dt1$TOTAL) == "character") dt1$TOTAL <- as.numeric(dt1$TOTAL)
  if (class(dt1$TAXON_GENUS) != "factor") dt1$TAXON_GENUS <- as.factor(dt1$TAXON_GENUS)
  if (class(dt1$TAXON_SPECIES) != "factor") dt1$TAXON_SPECIES <- as.factor(dt1$TAXON_SPECIES)
  if (class(dt1$TAXON_GROUP) != "factor") dt1$TAXON_GROUP <- as.factor(dt1$TAXON_GROUP)
  if (class(dt1$SURVEY) != "factor") dt1$SURVEY <- as.factor(dt1$SURVEY)
  if (class(dt1$TAXON_KINGDOM) != "factor") dt1$TAXON_KINGDOM <- as.factor(dt1$TAXON_KINGDOM)
  if (class(dt1$TAXON_PHYLUM) != "factor") dt1$TAXON_PHYLUM <- as.factor(dt1$TAXON_PHYLUM)
  if (class(dt1$TAXON_CLASS) != "factor") dt1$TAXON_CLASS <- as.factor(dt1$TAXON_CLASS)
  if (class(dt1$TAXON_ORDER) != "factor") dt1$TAXON_ORDER <- as.factor(dt1$TAXON_ORDER)
  if (class(dt1$TAXON_FAMILY) != "factor") dt1$TAXON_FAMILY <- as.factor(dt1$TAXON_FAMILY)

  # Convert Missing Values to NA for non-dates

  dt1$COMMON_NAME <- as.factor(ifelse((trimws(as.character(dt1$COMMON_NAME)) == trimws("-99999")), NA, as.character(dt1$COMMON_NAME)))
  dt1$TOTAL <- ifelse((trimws(as.character(dt1$TOTAL)) == trimws("-99999")), NA, dt1$TOTAL)
  suppressWarnings(dt1$TOTAL <- ifelse(!is.na(as.numeric("-99999")) & (trimws(as.character(dt1$TOTAL)) == as.character(as.numeric("-99999"))), NA, dt1$TOTAL))
  dt1$TAXON_GENUS <- as.factor(ifelse((trimws(as.character(dt1$TAXON_GENUS)) == trimws("-99999")), NA, as.character(dt1$TAXON_GENUS)))
  dt1$TAXON_SPECIES <- as.factor(ifelse((trimws(as.character(dt1$TAXON_SPECIES)) == trimws("-99999")), NA, as.character(dt1$TAXON_SPECIES)))
  dt1$TAXON_GROUP <- as.factor(ifelse((trimws(as.character(dt1$TAXON_GROUP)) == trimws("-99999")), NA, as.character(dt1$TAXON_GROUP)))
  dt1$SURVEY <- as.factor(ifelse((trimws(as.character(dt1$SURVEY)) == trimws("-99999")), NA, as.character(dt1$SURVEY)))
  dt1$TAXON_KINGDOM <- as.factor(ifelse((trimws(as.character(dt1$TAXON_KINGDOM)) == trimws("-99999")), NA, as.character(dt1$TAXON_KINGDOM)))
  dt1$TAXON_PHYLUM <- as.factor(ifelse((trimws(as.character(dt1$TAXON_PHYLUM)) == trimws("-99999")), NA, as.character(dt1$TAXON_PHYLUM)))
  dt1$TAXON_CLASS <- as.factor(ifelse((trimws(as.character(dt1$TAXON_CLASS)) == trimws("-99999")), NA, as.character(dt1$TAXON_CLASS)))
  dt1$TAXON_ORDER <- as.factor(ifelse((trimws(as.character(dt1$TAXON_ORDER)) == trimws("-99999")), NA, as.character(dt1$TAXON_ORDER)))
  dt1$TAXON_FAMILY <- as.factor(ifelse((trimws(as.character(dt1$TAXON_FAMILY)) == trimws("-99999")), NA, as.character(dt1$TAXON_FAMILY)))

  data.table::setDT(dt1)
  base::saveRDS(dt1, "./data/raw data/dugan_2021/rdata.rds")
}
