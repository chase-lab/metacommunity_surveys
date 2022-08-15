# Package ID: knb-lter-arc.10577.7 Cataloging System:https://pasta.edirepository.org.
# Data set title: Fish captures in lakes of the Arctic LTER region Toolik Field Station Alaska from 1986 to 2021..
# Data set creator:  Phaedra Budy -
# Data set creator:  Christopher Luecke -
# Data set creator:  Michael McDonald -
# Metadata Provider:  Arctic LTER MBL -
# Contact:  Arctic_LTER Information Manager -  Arctic Long Term Ecological Research  - arc_im@mbl.edu
# Stylesheet v2.11 for metadata conversion into program: John H. Porter, Univ. Virginia, jporter@virginia.edu

if (!file.exists("./data/raw data/budy_2021/rdata.rds")) {
   inUrl1  <- "https://pasta.lternet.edu/package/data/eml/knb-lter-arc/10577/7/e3bb94205560a7a6985660a2a1bcc817"
   infile1 <- "./data/cache/budy_2021_ArcLTER_LakesFish_1986-2009.csv"
   try(download.file(inUrl1,infile1,method="curl"))
   if (is.na(file.size(infile1))) download.file(inUrl1,infile1,method="auto")


   dt1 <- data.table::fread(infile1
                            ,sep = ","
                            ,quote = '"', na.strings = ".",
                            ,select = c("Date",
                                        "Site",
                                        "Lake",
                                        "Fish I.D.",
                                        "Species",
                                        "Sampling",
                                        "Locality",
                                        "Comments"))

   dt1[, date := as.Date(Date, format = "%d-%b-%Y")][is.na(date), date := as.Date("1988-01-01")][, Date := NULL]



   inUrl2  <- "https://pasta.lternet.edu/package/data/eml/knb-lter-arc/10577/7/467fa96795d3b9a76ea79e4e8d33c446"
   infile2 <- "./data/cache/budy_2021_ArcLTER_LakesFish_2010-2021.csv"
   try(download.file(inUrl2,infile2,method="curl"))
   if (is.na(file.size(infile2))) download.file(inUrl2,infile2,method="auto")


   dt2 <- data.table::fread(infile2, header = FALSE
                            ,skip = 4
                            ,sep = ","
                            ,quote = '"'
                            ,col.names = c("Site",
                                           "Date",
                                           "Fish.I.D.",
                                           "Lake",
                                           "Species",
                                           "Total.Length..paren.mm.paren.",
                                           "FL..paren.mm.paren.",
                                           "SL..paren.mm.paren.",
                                           "Mass..paren.g.paren.",
                                           "Sampling"), check.names = TRUE
   )
   dt2[, c("Total.Length..paren.mm.paren.",
           "FL..paren.mm.paren.",
           "SL..paren.mm.paren.",
           "Mass..paren.g.paren.") := NULL]
   data.table::setnames(dt2, c("Fish.I.D.", "Date"), c("Fish I.D.", "date"))
   dt2[, date := as.Date(date)]

   dt <- rbind(dt1, dt2, fill = TRUE, use.names = TRUE)

   dir.create("./data/raw data/budy_2021/", showWarnings = FALSE)
   base::saveRDS(object = dt, file = "./data/raw data/budy_2021/rdata.rds")
}

