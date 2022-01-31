# ellingsen_2018
dataset_id <- "ellingsen_2018"
#

if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
  path <- rdryad::dryad_download("10.5061/dryad.2v7m4")[[1]][2]

  # coming next is the script provided by the authors in the Dryad repository, modified, simplified and shortened to suit our needs.

  ############################################################################
  ##'
  ##' Script to analyse faunal composition according to the
  ##' 'lumping' and 'splitting' procedures presented in Ellingsen et al.
  ##' 'Long-term environmental monitoring for assessment of change:
  ##' measurement inconsistencies over time and potential solutions.
  ##' https://link.springer.com/article/10.1007%2Fs10661-017-6317-4
  ##'
  ##' Nigel Yoccoz (nigel.yoccoz@uit.no) and Torkild Tveraa (torkild.tveraa@nina.no)
  ##' Tromsø, November 2017
  ##'
  ############################################################################


  ##' First, read taxa names from first line of data frame
  r1bio.sn <- read.table(path, sep = "\t", nrows = 1, colClasses = rep("character", 389))

  ##' Second, read data on observations from the various stations (starting on line 7) in
  ##' datafile
  r1bio.dat <- read.table(path, sep = "\t", skip = 7)

  ##' ##' Set names to columns in datafile
  names(r1bio.dat) <- r1bio.sn[1, ]

  ## Year, Station and Replicate are substrings of first column in data file
  ## Year, Station and Replicate are substrings of first column in data file
  r1bio.dat$year <- as.numeric(substr(r1bio.dat[, 1], 1, 4))
  r1bio.dat$stat <- as.factor(substr(r1bio.dat[, 1], 6, 12))
  r1bio.dat$rep <- as.factor(substr(r1bio.dat[, 1], 16, 16))


  ##' Read datafile and substract dataframe  containing information on Scientific name,
  ##' Phylumm, Class etc.

  r1bio.syst <- read.table(path, sep = "\t", nrows = 7)

  ##' Count number of taxa
  n.taxa <- ncol(r1bio.syst) - 1

  ##' Identify to what taxonomic level identification was done for each reported
  ##' scientific name and print and summarize results; inf means species level, 7 = genus
  systlev <- integer(n.taxa)
  for (i in 1:n.taxa) systlev[i] <- min(which(as.vector(r1bio.syst[, i + 1]) == ""))

  ##' create two new data sets to include changes made wrt taxonomic levels

  r1bio.new1 <- r1bio.new2 <- r1bio.dat
  ##' for taxa which are ambiguous:
  ##' 1 is the data set with maximum reduction,
  ##' 2 is the one with keeping species
  ##' three possibilities:
  ##' only genus, no change needed
  ##' lump species with genus
  ##' or remove genus and keep all species

  ##' only genus, no change needed: 8,12,13,14,20,24,29,32,35,37,39,40,41,42,45,49,51,52,53,54,55,63,66,67

  ##'  ----------- LUMP SPECIES WITH GENUS ---------------
  ##'
  ##' Note that systlev = 7 denotes species identified to the genus level

  for (i.gen in c(1, 2, 4, 9, 11, 15, 17, 18, 19, 22, 27, 30, 33, 34, 36, 38, 44, 47, 48, 50, 57, 59, 62, 64, 65)) {
    genus <- as.character(r1bio.syst[6, which(systlev == 7)[i.gen] + 1])
    ind.gen <- which(r1bio.syst[6, ] == genus) # Note that row 6 in r1bio.syst contains Genus
    r1bio.new1[, ind.gen[1]] <- r1bio.new2[, ind.gen[1]] <- apply(r1bio.dat[, ind.gen], MAR = 1, sum) # sum genus and species
    r1bio.new1[, ind.gen[-1]] <- r1bio.new2[, ind.gen[-1]] <- 0 # put 0 for species
  }


  # apply(r1bio.dat[,ind.gen],MAR=2,sum)    # checking that numbers are right
  # apply(r1bio.new1[,ind.gen],MAR=2,sum)    # for the new file should be the sum

  ##' ------------ REMOVE GENUS, KEEP SPECIES -------------------

  for (i.gen in c(3, 6, 16, 21, 25, 28, 46, 58, 60)) {
    genus <- as.character(r1bio.syst[6, which(systlev == 7)[i.gen] + 1])
    # print(c('genus: ', genus))
    ind.gen <- which(r1bio.syst[6, ] == genus) # Note that row 6 in r1bio.syst contains Genus
    # print(c('ind.gen: ', ind.gen))
    r1bio.new1[, ind.gen[1]] <- r1bio.new2[, ind.gen[1]] <- 0 # put 0 for Genus
  }

  # apply(r1bio.dat[,ind.gen],MAR=2,sum)    # checking that numbers are right
  # apply(r1bio.new1[,ind.gen],MAR=2,sum)    # for the new file should be the sum

  # Taxa with two alternatives
  for (i.gen in c(5, 7, 10, 23, 26, 31, 43, 56, 61)) {
    genus <- as.character(r1bio.syst[6, which(systlev == 7)[i.gen] + 1])
    # print(c('genus: ', toString(genus)))
    ind.gen <- which(r1bio.syst[6, ] == genus)
    # print(c('ind.gen: ', toString(ind.gen)))
    r1bio.new1[, ind.gen[1]] <- apply(r1bio.dat[, ind.gen], MAR = 1, sum) # sum genus and species in new1
    r1bio.new1[, ind.gen[-1]] <- 0 # put 0 for species
    r1bio.new2[, ind.gen[1]] <- 0 # put 0 for Genus in new2
  }

  # apply(r1bio.dat[,ind.gen],MAR=2,sum)    # checking that numbers are right
  # apply(r1bio.new1[,ind.gen],MAR=2,sum)    # checking that numbers are right
  # apply(r1bio.new2[,ind.gen],MAR=2,sum)    # checking that numbers are right

  # checking all species are present

  # Eteone flava 1996 vs longa 1999 ff
  # shift between genus (1996) and species for Sphaerodorum gracilis (1999 ff)
  # Goniada mostly genus in 2005, Goniada maculata other years
  # Jasmineira shift between genus and species
  # Magelona shift between genus in 1996,99,02 and 2 species later
  # Caulleriella Genus only in 2002
  # Chaetozone: shift from species to genus in 2008
  # Bathyporeia species only in 2002, genus in other years
  # Cheirocratus: shift from species to genus in 2008
  # Diastylis: species in 1996, mostly genus later on
  # Thracia: genus only in 1996, species later
  # Philine, species only in 1999 to 2005, genus al years
  # Antalis, genus in 1996, 2008 and 2011, species in 1999, 2002, 2005
  # Phoronis, genus in 1996, 2008 and 2011, species in 1999, 2002, 2005

  # Family
  # which(systlev==6)
  n.fam <- sum(systlev == 6)

  i.fam <- 15
  famil <- as.character(r1bio.syst[5, which(systlev == 6)[i.fam] + 1])

  # Syllidae 1 Ampharetidae 2 Cirratulidae 3 Pectinariidae 4 Amphilochidae 5
  # Ischyroceridae 8 Lysianassidae 9 Oedicerotidae 10 removed
  # Aoridae 6 Caprellidae 7 Pleustidae 11 Stenothoidae 13 Paguridae 15 lump all together
  # Podoceridae 12 Majidae 14 no other group, no change
  for (i.fam in c(6, 7, 11, 13, 15)) { # c(6,7,11,13,15) lump family and other taxa
    famil <- as.character(r1bio.syst[5, which(systlev == 6)[i.fam] + 1])
    ind.fam <- which(r1bio.syst[5, ] == famil)
    ind.fam.c <- which(systlev[ind.fam - 1] == 6)
    r1bio.new1[, ind.fam[ind.fam.c]] <- r1bio.new2[, ind.fam[ind.fam.c]] <- apply(r1bio.dat[, ind.fam], MAR = 1, sum) # sum family and taxa
    r1bio.new1[, ind.fam[-ind.fam.c]] <- r1bio.new2[, ind.fam[-ind.fam.c]] <- 0 # put 0 for other taxa
  }


  # remove family, keep other taxa
  for (i.fam in c(1, 2, 3, 4, 5, 8, 9, 10)) {
    famil <- as.character(r1bio.syst[5, which(systlev == 6)[i.fam] + 1])
    # for (i in which(r1bio.syst[5,]==famil)) {
    # print(as.character(r1bio.sn[i]))
    # print(tapply(r1bio.dat[,i],INDEX=r1bio.dat[,c("year")],FUN=sum))
    # }
    ind.fam <- which(r1bio.syst[5, ] == famil)
    ind.fam.c <- which(systlev[ind.fam - 1] == 6)
    r1bio.new1[, ind.fam[ind.fam.c]] <- r1bio.new2[, ind.fam[ind.fam.c]] <- 0 # remove family
  }

  # Order
  n.ord <- sum(systlev == 5)

  for (i.ord in c(1, 2)) { # c(1,2)
    orde <- as.character(r1bio.syst[4, which(systlev == 5)[i.ord] + 1])
    ind.ord <- which(r1bio.syst[4, ] == orde)
    ind.ord.c <- which(systlev[ind.ord - 1] == 5)
    r1bio.new1[, ind.ord[ind.ord.c]] <- r1bio.new2[, ind.ord[ind.ord.c]] <- 0 # remove order
  }

  ind.ord <- which(r1bio.syst[4, ] == orde)
  ind.ord.c <- which(systlev[ind.ord - 1] == 5)
  r1bio.new1[, ind.ord[ind.ord.c]] <- r1bio.new2[, ind.ord[ind.ord.c]] <- apply(r1bio.dat[, ind.ord], MAR = 1, sum) # sum order and taxa
  r1bio.new1[, ind.ord[-ind.ord.c]] <- r1bio.new2[, ind.ord[-ind.ord.c]] <- 0 # put 0 for other taxa

  # Class
  n.cla <- sum(systlev == 4)
  i.cla <- 3
  clas <- as.character(r1bio.syst[3, which(systlev == 4)[i.cla] + 1])
  ind.cla <- which(r1bio.syst[3, ] == clas)
  ind.cla.c <- which(systlev[ind.cla - 1] == 4)
  r1bio.new1[, ind.cla[ind.cla.c]] <- r1bio.new2[, ind.cla[ind.cla.c]] <- apply(r1bio.dat[, ind.cla], MAR = 1, sum) # sum class and taxa
  r1bio.new1[, ind.cla[-ind.cla.c]] <- r1bio.new2[, ind.cla[-ind.cla.c]] <- 0 # put 0 for other taxa


  for (i.cla in c(4, 5)) { # 4,5
    clas <- as.character(r1bio.syst[3, which(systlev == 4)[i.cla] + 1])
    ind.cla <- which(r1bio.syst[3, ] == clas)
    ind.cla.c <- which(systlev[ind.cla - 1] == 4)
    r1bio.new1[, ind.cla[ind.cla.c]] <- r1bio.new2[, ind.cla[ind.cla.c]] <- 0 # put 0 for other taxa
  }

  # which(systlev==3)
  n.ord <- sum(systlev == 3)
  i.phy <- 1
  phyl <- as.character(r1bio.syst[2, which(systlev == 3)[i.phy] + 1])
  i.phy <- 6
  phyl <- as.character(r1bio.syst[2, which(systlev == 3)[i.phy] + 1])
  ind.phy <- which(r1bio.syst[2, ] == phyl)
  ind.phy.c <- which(systlev[ind.phy - 1] == 3)
  r1bio.new1[, ind.phy[ind.phy.c]] <- r1bio.new2[, ind.phy[ind.phy.c]] <- 0 # put 0 for other taxa

  i.phy <- 2
  phyl <- as.character(r1bio.syst[2, which(systlev == 3)[i.phy] + 1])
  ind.phy <- which(r1bio.syst[2, ] == phyl)
  ind.phy.c <- which(systlev[ind.phy - 1] == 3)
  r1bio.new1[, ind.phy[ind.phy.c]] <- r1bio.new2[, ind.phy[ind.phy.c]] <- apply(r1bio.dat[, ind.phy], MAR = 1, sum) # sum phylum and taxa
  r1bio.new1[, ind.phy[-ind.phy.c]] <- r1bio.new2[, ind.phy[-ind.phy.c]] <- 0 # put 0 for other taxa

  ##' removing null columns in r1bio.new1 and new2 after adding column names
  names(r1bio.dat) <- names(r1bio.new1) <- names(r1bio.new2) <- c(r1bio.sn, "year", "stat", "rep")
  n.tax <- length(names(r1bio.new1)) - 4
  col.dat.0 <- apply(r1bio.dat[, -c(1, n.tax + 2, n.tax + 3, n.tax + 4)], MAR = 2, sum)
  col.new1.0 <- apply(r1bio.new1[, -c(1, n.tax + 2, n.tax + 3, n.tax + 4)], MAR = 2, sum)
  col.new2.0 <- apply(r1bio.new2[, -c(1, n.tax + 2, n.tax + 3, n.tax + 4)], MAR = 2, sum)

  #' # removing null columns in new1 and new2
  c(1, as.vector(which(col.new1.0 != 0)), n.tax + 2, n.tax + 3, n.tax + 4)
  r1bio.dat.n <- r1bio.new1[, c(1, (as.numeric(which(col.dat.0 != 0)) + 1), n.tax + 2, n.tax + 3, n.tax + 4)]
  r1bio.new1.n <- r1bio.new1[, c(1, (as.numeric(which(col.new1.0 != 0)) + 1), n.tax + 2, n.tax + 3, n.tax + 4)]
  r1bio.new2.n <- r1bio.new2[, c(1, (as.numeric(which(col.new2.0 != 0)) + 1), n.tax + 2, n.tax + 3, n.tax + 4)]


  ##' Write alternative datasets to file
  # write.table(r1bio.dat.n, file="dataOrg.csv", row.names=FALSE, col.names=TRUE, sep=';')
  # write.table(r1bio.new1.n, file="data1.csv", row.names=FALSE, col.names=TRUE, sep=';')
  # write.table(r1bio.new2.n, file="data2.csv", row.names=FALSE, col.names=TRUE, sep=';')

  ####################################################################
  ####################################################################
  ####################################################################
  ####################################################################


  data.table::setDT(r1bio.new2.n)


  dir.create(paste0("data/raw data/", dataset_id), showWarnings = FALSE)
  base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
}
