# Package ID: knb-lter-bnz.320.23 Cataloging System:https://pasta.edirepository.org.
# Data set title: Bonanza Creek LTER: Tree Inventory Data from 1989 to present at Core research sites in Interior Alaska.
# Data set creator:  Keith Van Cleve -
# Data set creator:  F Chapin -
# Data set creator:  Roger Ruess -
# Data set creator:    - Bonanza Creek LTER
# Metadata Provider:    - Bonanza Creek LTER
# Contact:    - Data Manager Bonanza Creek LTER  - uaf-bnz-im-team@alaska.edu
# Stylesheet v2.11 for metadata conversion into program: John H. Porter, Univ. Virginia, jporter@virginia.edu

if (!file.exists("./data/raw data/van-cleve_2021/rdata.rds")) {
  inUrl1 <- "https://pasta.lternet.edu/package/data/eml/knb-lter-bnz/320/23/858dc623b84dd3dc2e0e877ca6fdc3c5"
  infile1 <- "./data/cache/van-cleve_2021.csv"
  if (!file.exists(infile1)) try(download.file(inUrl1, infile1, method = "curl"))
  if (!file.exists(infile1)) download.file(inUrl1, infile1, method = "auto")


  dt1 <- read.csv(infile1,
    header = F,
    skip = 1,
    sep = ",",
    quot = '"',
    col.names = c(
      "DATE",
      "SITE",
      "PLOT",
      "TREE",
      "SPECIES",
      "DBH",
      "DA",
      "TOP",
      "LEAN",
      "BOW",
      "DOWN",
      "NOTE"
    ), check.names = TRUE
  )


  # Fix any interval or ratio columns mistakenly read in as nominal and nominal columns read as numeric or dates read as strings

  # attempting to convert dt1$DATE dateTime string to R date structure (date or POSIXct)
  tmpDateFormat <- "%Y-%m-%d"
  tmp1DATE <- as.Date(dt1$DATE, format = tmpDateFormat)
  # Keep the new dates only if they all converted correctly
  if (length(tmp1DATE) == length(tmp1DATE[!is.na(tmp1DATE)])) {
    dt1$DATE <- tmp1DATE
  } else {
    print("Date conversion failed for dt1$DATE. Please inspect the data and do the date conversion yourself.")
  }

  data.table::setDT(dt1)

  dir.create("./data/raw data/van-cleve_2021", showWarnings = FALSE)
  base::saveRDS(dt1, "./data/raw data/van-cleve_2021/rdata.rds")
}
