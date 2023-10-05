# gaiser_2021_diatoms

# Package ID: knb-lter-fce.1211.4 Cataloging System:https://pasta.edirepository.org.
# Data set title: Relative Abundance Diatom Data from Periphyton Samples Collected from the Greater Everglades, Florida USA from September 2005 to November 2014.
# Data set creator: Dr. Evelyn Gaiser - Florida Coastal Everglades LTER Program
# Metadata Provider:    - Florida Coastal Everglades LTER Program
# Contact:    - Information Manager Florida Coastal Everglades LTER Program  - fcelter@fiu.edu
# Stylesheet v2.11 for metadata conversion into program: John H. Porter, Univ. Virginia, jporter@virginia.edu

inUrl1  <- "https://pasta.lternet.edu/package/data/eml/knb-lter-fce/1211/4/c55358e65d766fc8f2b2b3b28dec4600"
infile1 <- 'data/cache/gaiser_2021_diatoms.csv'
if (!file.exists(infile1)) try(curl::curl_download(inUrl1,infile1,method="curl", mode = 'wb'))
if (!file.exists(infile1)) curl::curl_download(inUrl1,infile1,method="auto", mode = 'wb')


rdata <- data.table::fread(file = infile1, header=F
               ,skip=1
               ,sep=","
               , col.names=c(
                  "TAG.hyphen.ID",
                  "OBS_DATE",
                  "PRIMARY_SAMPLING_UNIT",
                  "DRAW",
                  "FIELD_REPLICATE",
                  "EPISODE",
                  "EASTING_UTM",
                  "NORTHING_UTM",
                  "WETLAND_BASIN",
                  "LSU",
                  "LSU_NAME",
                  "ACHADNADN",
                  "ACHCITCIT",
                  "ACHCOACOA",
                  "ACHCURCUR",
                  "ACHFTSP01",
                  "ACHFTSP07",
                  "ACHFTSP13",
                  "ACHFTSP15",
                  "ACHSPPSPP",
                  "ACMGRAGRA",
                  "ACMLINLIN",
                  "ACMMINMIN",
                  "ACMPYRPYR",
                  "ACMSPPSPP",
                  "ACTOCTOCT",
                  "AMCDISDIS",
                  "AMISPESPE",
                  "AMPARCARC",
                  "AMPAWSP06",
                  "AMPCFCOCA",
                  "AMPCOPCOP",
                  "AMPCRECRE",
                  "AMPFTSP02",
                  "AMPFTSP04",
                  "AMPFTSP05",
                  "AMPLIBLIB",
                  "AMPOVAOVA",
                  "AMPPROPRO",
                  "AMPPSEPSE",
                  "AMPSLSP01",
                  "AMPSLSP02",
                  "AMPSPPSPP",
                  "ANOCOSCOS",
                  "ANOSPHGRA",
                  "APLPELPEL",
                  "APTCFOCTO",
                  "APTSENSEN",
                  "ASTCFBAHU",
                  "AULCFAMBI",
                  "AULCFDIST",
                  "AULCFGRAN",
                  "AULGRAGRA",
                  "AULITATEN",
                  "AULSPPSPP",
                  "BACPAXPAX",
                  "BRAAPOAPO",
                  "BRABREBRE",
                  "BRAMICMIC",
                  "BRAPROPRO",
                  "BRAPSEPSE",
                  "BRASERSER",
                  "BRASPPSPP",
                  "BRAVITVIT",
                  "CALBUDBUD",
                  "CALCFBACI",
                  "CALCFBUDE",
                  "CALCFCLEV",
                  "CALFTSP02",
                  "CALSABSAB",
                  "CALSPPSPP",
                  "CAMSPPSPP",
                  "CAPCARCAR",
                  "CATADHADH",
                  "CAVMACMAC",
                  "COCBARBAR",
                  "COCPEDPED",
                  "COCPELPEL",
                  "COCPLAPLA",
                  "COCSCUSCU",
                  "COCSPPSPP",
                  "CODOCUIRI",
                  "CRAACCACC",
                  "CRACUSCUS",
                  "CRASPPSPP",
                  "CYCIRIIRI",
                  "CYCMENMEN",
                  "CYCRADRAD",
                  "CYCSPPSPP",
                  "CYMASPASP",
                  "CYMFTSP04",
                  "CYMFTSP05",
                  "CYMLAELAE",
                  "CYMSPPSPP",
                  "DENSUBSUB",
                  "DIACONCON",
                  "DIPCFELLI",
                  "DIPCFNOLB",
                  "DIPOBLOBL",
                  "DIPPARPAR",
                  "DIPPUEPUE",
                  "DIPSPPSPP",
                  "DISPSEPSE",
                  "DISSTESTE",
                  "ECYMICMIC",
                  "ECYSPPSPP",
                  "ECYSUBSUB",
                  "ENCCFEVER",
                  "ENCCFFT01",
                  "ENCCTSP01",
                  "ENCEVEEVE",
                  "ENCFTSP04",
                  "ENCGRAGRA",
                  "ENCLACLAC",
                  "ENCMESMES",
                  "ENCSILELE",
                  "ENCSILSIL",
                  "ENCSJSP03",
                  "ENCSPPSPP",
                  "ENTPULPUL",
                  "ENVCFPACH",
                  "ENVCFPSEU",
                  "ENVMETMET",
                  "ENVVANVAN",
                  "EPIGIBGIB",
                  "EPIPACPAC",
                  "EPIPORPOR",
                  "EPISPPSPP",
                  "EUNARCARC",
                  "EUNBILBIL",
                  "EUNCAMARC",
                  "EUNCAMCAM",
                  "EUNCARCAR",
                  "EUNCFNOV1",
                  "EUNCFPALU",
                  "EUNEGSP01",
                  "EUNFLEFLE",
                  "EUNFORFOR",
                  "EUNFTSP01",
                  "EUNFTSP03",
                  "EUNFTSP04",
                  "EUNFTSP05",
                  "EUNFTSP10",
                  "EUNFTSP11",
                  "EUNFTSP13",
                  "EUNIMPIMP",
                  "EUNINCINC",
                  "EUNMONMON",
                  "EUNNAENAE",
                  "EUNPANPAN",
                  "EUNSILSIL",
                  "EUNSPPSPP",
                  "EUNZYGELO",
                  "EUNZYGZYG",
                  "FLCFLOFLO",
                  "FLCLITLIT",
                  "FLCPYGPYG",
                  "FLCSLSP02",
                  "FLCSLSP03",
                  "FLCSPPSPP",
                  "FRACAPCAP",
                  "FRACFTENE",
                  "FRAFTSP07",
                  "FRAFTSP14",
                  "FRAFTSP15",
                  "FRAFTSP16",
                  "FRAFTSP19",
                  "FRAGRAGRA",
                  "FRAMESMES",
                  "FRASPPSPP",
                  "FRASYNSYN",
                  "FRATENNAN",
                  "FRAVAUVAU",
                  "FRFVIRCAP",
                  "FRUCRACRA",
                  "FRURHORHO",
                  "GOLOLIOLI",
                  "GOMAFFAFF",
                  "GOMAFFRHO",
                  "GOMAURAUR",
                  "GOMCFVIBR",
                  "GOMCORCOR",
                  "GOMEXIEXI",
                  "GOMFTSP22",
                  "GOMFTSP30",
                  "GOMGRAGRA",
                  "GOMLAGLAG",
                  "GOMMACMAC",
                  "GOMNEONEO",
                  "GOMPARPAR",
                  "GOMPRAPRA",
                  "GOMSAPSAP",
                  "GOMSPPSPP",
                  "GOMSUBMEX",
                  "GOMTURTUR",
                  "GOMVIRVIR",
                  "GYROBSOBS",
                  "HALAPOAPO",
                  "HALCYMHER",
                  "HALHOLHOL",
                  "HALHYBHYB",
                  "HALMONMON",
                  "HALSUBSUB",
                  "HANAMPAMP",
                  "HANCFGRNE",
                  "HANELOELO",
                  "HANFTSP01",
                  "HANFTSP04",
                  "HANSPESPE",
                  "HANSPPSPP",
                  "HANVIVVIV",
                  "HIPHUNHUN",
                  "HYDSCOSCO",
                  "ICOCURCUR",
                  "KARCFSUBM",
                  "KOBCFPARA",
                  "KOBJAAJAA",
                  "KRKEGSP01",
                  "KRKFLOFLO",
                  "KRKFTSP02",
                  "LEMEXIEXI",
                  "LEMHUNHUN",
                  "MASASPASP",
                  "MASASRASR",
                  "MASBARBAR",
                  "MASBRABRA",
                  "MASCALCAL",
                  "MASCFERIT",
                  "MASCRUALT",
                  "MASCRUCRU",
                  "MASELEELE",
                  "MASELLELL",
                  "MASHORHOR",
                  "MASLANLAN",
                  "MASOVAOVA",
                  "MASPSEPSE",
                  "MASSPPSPP",
                  "MELSPPSPP",
                  "NAVANGANG",
                  "NAVCFCAPI",
                  "NAVCFCINC",
                  "NAVCFNEOW",
                  "NAVCFRECE",
                  "NAVCFVENE",
                  "NAVCRPCRP",
                  "NAVCRYCRY",
                  "NAVDENDEN",
                  "NAVFTSP01",
                  "NAVFTSP03",
                  "NAVFTSP12",
                  "NAVFTSP16",
                  "NAVFTSP18",
                  "NAVFTSP21",
                  "NAVFTSP25",
                  "NAVFTSP26",
                  "NAVFTSP27",
                  "NAVFTSP29",
                  "NAVGREGRE",
                  "NAVRADRAD",
                  "NAVRAFRAF",
                  "NAVSAISAI",
                  "NAVSALSAL",
                  "NAVSJSP01",
                  "NAVSLSP01",
                  "NAVSLSP04",
                  "NAVSPPSPP",
                  "NAVTENTEN",
                  "NCYPUSPUS",
                  "NEIAMPAMP",
                  "NEISPPSPP",
                  "NFRKRUKRU",
                  "NITACDACD",
                  "NITACIACI",
                  "NITAMPAMP",
                  "NITAMPFRA",
                  "NITCAPCAP",
                  "NITCAPTEN",
                  "NITCFSEMI",
                  "NITFILFIL",
                  "NITFONFON",
                  "NITFTSP01",
                  "NITFTSP02",
                  "NITFTSP04",
                  "NITFTSP06",
                  "NITFTSP08",
                  "NITFTSP09",
                  "NITFTSP14",
                  "NITFTSP15",
                  "NITFTSP16",
                  "NITFTSP17",
                  "NITFTSP18",
                  "NITFTSP19",
                  "NITFTSP24",
                  "NITFTSP25",
                  "NITFTSP26",
                  "NITGRAGRA",
                  "NITINTINT",
                  "NITLACLAC",
                  "NITLIELIE",
                  "NITLINLIN",
                  "NITMICMIC",
                  "NITNANNAN",
                  "NITPALDEB",
                  "NITREVREV",
                  "NITSERSER",
                  "NITSIGSIG",
                  "NITSPPSPP",
                  "NITSUBSUB",
                  "NITTERTER",
                  "NITTHEMIN",
                  "NITUMBUMB",
                  "OPEMARMAR",
                  "PARPANPAN",
                  "PAUTAETAE",
                  "PCKOCEOCE",
                  "PGTSPPSPP",
                  "PINACRACR",
                  "PINBRNBRN",
                  "PINCFFERR",
                  "PINFTSP01",
                  "PINFTSP10",
                  "PINFTSP11",
                  "PINFTSP13",
                  "PINFTSP14",
                  "PINFTSP15",
                  "PINFTSP16",
                  "PINFTSP17",
                  "PINFTSP18",
                  "PINFTSP19",
                  "PINFTSP20",
                  "PINFTSP21",
                  "PINGIBGIB",
                  "PINGIFGIF",
                  "PININTINT",
                  "PINMAJMAJ",
                  "PINMEDMED",
                  "PINMICMIC",
                  "PINNANNAN",
                  "PINPULPUL",
                  "PINRUTRUT",
                  "PINSCHSCH",
                  "PINSLSP01",
                  "PINSLSP02",
                  "PINSPPSPP",
                  "PINSTOSTO",
                  "PINSTRSTR",
                  "PINSUBUND",
                  "PINSUISUI",
                  "PINVIRVIR",
                  "PLACFDELI",
                  "PLACFENGE",
                  "PLACFHAUC",
                  "PLACFSEPT",
                  "PLADUBDUB",
                  "PLALANLAN",
                  "PLAROSROS",
                  "PLCCONCON",
                  "PLESALSAL",
                  "PLGSIMSIM",
                  "PSMGRIGRI",
                  "PSSGEOGEO",
                  "PSTBREBRE",
                  "PSTCRUCRU",
                  "PSTPARPAR",
                  "RHOACUACU",
                  "RHOBREBRE",
                  "RHOCFMUSC",
                  "RHOGIRVAN",
                  "RHOSPPSPP",
                  "SELLAELAE",
                  "SELLATLAT",
                  "SELPUPPUP",
                  "SELRECREC",
                  "SELSEMSEM",
                  "SELSLSP01",
                  "SELSPPSPP",
                  "SELSTRSTR",
                  "SEMEULEUL",
                  "SEMROBROB",
                  "SEMSPPSPP",
                  "SEMSTRSTR",
                  "SKAOESOES",
                  "SPDMEDMED",
                  "SPDMINMIN",
                  "SPDSPPSPP",
                  "SRACONCON",
                  "SSRPINPIN",
                  "STAJAVJAV",
                  "STAKRIKRI",
                  "STAPHOPHO",
                  "STASPPSPP",
                  "SYNFILEXI",
                  "SYNSPPSPP",
                  "TABFASFAS",
                  "TERMUSMUS",
                  "THABRABRA",
                  "THAFTSP01",
                  "THALEPLEP",
                  "THASPPSPP",
                  "TRCRETRET",
                  "TRYSALSAL",
                  "TRYSCASCA",
                  "TTASULSUL",
                  "ULNACUACU",
                  "ULNAMPAMP",
                  "ULNDELDEL",
                  "ULNULNULN",
                  "UNKWNGIRD",
                  "UNKWNVALV"    ), check.names=TRUE)


# Fix any interval or ratio columns mistakenly read in as nominal and nominal columns read as numeric or dates read as strings

if (class(dt1$TAG.hyphen.ID)!="factor") dt1$TAG.hyphen.ID<- as.factor(dt1$TAG.hyphen.ID)
# attempting to convert dt1$OBS_DATE dateTime string to R date structure (date or POSIXct)
tmpDateFormat<-"%Y-%m-%d"
tmp1OBS_DATE<-as.Date(dt1$OBS_DATE,format=tmpDateFormat)
# Keep the new dates only if they all converted correctly
if(length(tmp1OBS_DATE) == length(tmp1OBS_DATE[!is.na(tmp1OBS_DATE)])){dt1$OBS_DATE <- tmp1OBS_DATE } else {print("Date conversion failed for dt1$OBS_DATE. Please inspect the data and do the date conversion yourself.")}
rm(tmpDateFormat,tmp1OBS_DATE)
if (class(dt1$WETLAND_BASIN)!="factor") dt1$WETLAND_BASIN<- as.factor(dt1$WETLAND_BASIN)
if (class(dt1$LSU)!="factor") dt1$LSU<- as.factor(dt1$LSU)
if (class(dt1$LSU_NAME)!="factor") dt1$LSU_NAME<- as.factor(dt1$LSU_NAME)
if (class(dt1$ACHADNADN)=="factor") dt1$ACHADNADN <-as.numeric(levels(dt1$ACHADNADN))[as.integer(dt1$ACHADNADN) ]
if (class(dt1$ACHADNADN)=="character") dt1$ACHADNADN <-as.numeric(dt1$ACHADNADN)
if (class(dt1$ACHCITCIT)=="factor") dt1$ACHCITCIT <-as.numeric(levels(dt1$ACHCITCIT))[as.integer(dt1$ACHCITCIT) ]
if (class(dt1$ACHCITCIT)=="character") dt1$ACHCITCIT <-as.numeric(dt1$ACHCITCIT)
if (class(dt1$ACHCOACOA)=="factor") dt1$ACHCOACOA <-as.numeric(levels(dt1$ACHCOACOA))[as.integer(dt1$ACHCOACOA) ]
if (class(dt1$ACHCOACOA)=="character") dt1$ACHCOACOA <-as.numeric(dt1$ACHCOACOA)
if (class(dt1$ACHCURCUR)=="factor") dt1$ACHCURCUR <-as.numeric(levels(dt1$ACHCURCUR))[as.integer(dt1$ACHCURCUR) ]
if (class(dt1$ACHCURCUR)=="character") dt1$ACHCURCUR <-as.numeric(dt1$ACHCURCUR)
if (class(dt1$ACHFTSP01)=="factor") dt1$ACHFTSP01 <-as.numeric(levels(dt1$ACHFTSP01))[as.integer(dt1$ACHFTSP01) ]
if (class(dt1$ACHFTSP01)=="character") dt1$ACHFTSP01 <-as.numeric(dt1$ACHFTSP01)
if (class(dt1$ACHFTSP07)=="factor") dt1$ACHFTSP07 <-as.numeric(levels(dt1$ACHFTSP07))[as.integer(dt1$ACHFTSP07) ]
if (class(dt1$ACHFTSP07)=="character") dt1$ACHFTSP07 <-as.numeric(dt1$ACHFTSP07)
if (class(dt1$ACHFTSP13)=="factor") dt1$ACHFTSP13 <-as.numeric(levels(dt1$ACHFTSP13))[as.integer(dt1$ACHFTSP13) ]
if (class(dt1$ACHFTSP13)=="character") dt1$ACHFTSP13 <-as.numeric(dt1$ACHFTSP13)
if (class(dt1$ACHFTSP15)=="factor") dt1$ACHFTSP15 <-as.numeric(levels(dt1$ACHFTSP15))[as.integer(dt1$ACHFTSP15) ]
if (class(dt1$ACHFTSP15)=="character") dt1$ACHFTSP15 <-as.numeric(dt1$ACHFTSP15)
if (class(dt1$ACHSPPSPP)=="factor") dt1$ACHSPPSPP <-as.numeric(levels(dt1$ACHSPPSPP))[as.integer(dt1$ACHSPPSPP) ]
if (class(dt1$ACHSPPSPP)=="character") dt1$ACHSPPSPP <-as.numeric(dt1$ACHSPPSPP)
if (class(dt1$ACMGRAGRA)=="factor") dt1$ACMGRAGRA <-as.numeric(levels(dt1$ACMGRAGRA))[as.integer(dt1$ACMGRAGRA) ]
if (class(dt1$ACMGRAGRA)=="character") dt1$ACMGRAGRA <-as.numeric(dt1$ACMGRAGRA)
if (class(dt1$ACMLINLIN)=="factor") dt1$ACMLINLIN <-as.numeric(levels(dt1$ACMLINLIN))[as.integer(dt1$ACMLINLIN) ]
if (class(dt1$ACMLINLIN)=="character") dt1$ACMLINLIN <-as.numeric(dt1$ACMLINLIN)
if (class(dt1$ACMMINMIN)=="factor") dt1$ACMMINMIN <-as.numeric(levels(dt1$ACMMINMIN))[as.integer(dt1$ACMMINMIN) ]
if (class(dt1$ACMMINMIN)=="character") dt1$ACMMINMIN <-as.numeric(dt1$ACMMINMIN)
if (class(dt1$ACMPYRPYR)=="factor") dt1$ACMPYRPYR <-as.numeric(levels(dt1$ACMPYRPYR))[as.integer(dt1$ACMPYRPYR) ]
if (class(dt1$ACMPYRPYR)=="character") dt1$ACMPYRPYR <-as.numeric(dt1$ACMPYRPYR)
if (class(dt1$ACMSPPSPP)=="factor") dt1$ACMSPPSPP <-as.numeric(levels(dt1$ACMSPPSPP))[as.integer(dt1$ACMSPPSPP) ]
if (class(dt1$ACMSPPSPP)=="character") dt1$ACMSPPSPP <-as.numeric(dt1$ACMSPPSPP)
if (class(dt1$ACTOCTOCT)=="factor") dt1$ACTOCTOCT <-as.numeric(levels(dt1$ACTOCTOCT))[as.integer(dt1$ACTOCTOCT) ]
if (class(dt1$ACTOCTOCT)=="character") dt1$ACTOCTOCT <-as.numeric(dt1$ACTOCTOCT)
if (class(dt1$AMCDISDIS)=="factor") dt1$AMCDISDIS <-as.numeric(levels(dt1$AMCDISDIS))[as.integer(dt1$AMCDISDIS) ]
if (class(dt1$AMCDISDIS)=="character") dt1$AMCDISDIS <-as.numeric(dt1$AMCDISDIS)
if (class(dt1$AMISPESPE)=="factor") dt1$AMISPESPE <-as.numeric(levels(dt1$AMISPESPE))[as.integer(dt1$AMISPESPE) ]
if (class(dt1$AMISPESPE)=="character") dt1$AMISPESPE <-as.numeric(dt1$AMISPESPE)
if (class(dt1$AMPARCARC)=="factor") dt1$AMPARCARC <-as.numeric(levels(dt1$AMPARCARC))[as.integer(dt1$AMPARCARC) ]
if (class(dt1$AMPARCARC)=="character") dt1$AMPARCARC <-as.numeric(dt1$AMPARCARC)
if (class(dt1$AMPAWSP06)=="factor") dt1$AMPAWSP06 <-as.numeric(levels(dt1$AMPAWSP06))[as.integer(dt1$AMPAWSP06) ]
if (class(dt1$AMPAWSP06)=="character") dt1$AMPAWSP06 <-as.numeric(dt1$AMPAWSP06)
if (class(dt1$AMPCFCOCA)=="factor") dt1$AMPCFCOCA <-as.numeric(levels(dt1$AMPCFCOCA))[as.integer(dt1$AMPCFCOCA) ]
if (class(dt1$AMPCFCOCA)=="character") dt1$AMPCFCOCA <-as.numeric(dt1$AMPCFCOCA)
if (class(dt1$AMPCOPCOP)=="factor") dt1$AMPCOPCOP <-as.numeric(levels(dt1$AMPCOPCOP))[as.integer(dt1$AMPCOPCOP) ]
if (class(dt1$AMPCOPCOP)=="character") dt1$AMPCOPCOP <-as.numeric(dt1$AMPCOPCOP)
if (class(dt1$AMPCRECRE)=="factor") dt1$AMPCRECRE <-as.numeric(levels(dt1$AMPCRECRE))[as.integer(dt1$AMPCRECRE) ]
if (class(dt1$AMPCRECRE)=="character") dt1$AMPCRECRE <-as.numeric(dt1$AMPCRECRE)
if (class(dt1$AMPFTSP02)=="factor") dt1$AMPFTSP02 <-as.numeric(levels(dt1$AMPFTSP02))[as.integer(dt1$AMPFTSP02) ]
if (class(dt1$AMPFTSP02)=="character") dt1$AMPFTSP02 <-as.numeric(dt1$AMPFTSP02)
if (class(dt1$AMPFTSP04)=="factor") dt1$AMPFTSP04 <-as.numeric(levels(dt1$AMPFTSP04))[as.integer(dt1$AMPFTSP04) ]
if (class(dt1$AMPFTSP04)=="character") dt1$AMPFTSP04 <-as.numeric(dt1$AMPFTSP04)
if (class(dt1$AMPFTSP05)=="factor") dt1$AMPFTSP05 <-as.numeric(levels(dt1$AMPFTSP05))[as.integer(dt1$AMPFTSP05) ]
if (class(dt1$AMPFTSP05)=="character") dt1$AMPFTSP05 <-as.numeric(dt1$AMPFTSP05)
if (class(dt1$AMPLIBLIB)=="factor") dt1$AMPLIBLIB <-as.numeric(levels(dt1$AMPLIBLIB))[as.integer(dt1$AMPLIBLIB) ]
if (class(dt1$AMPLIBLIB)=="character") dt1$AMPLIBLIB <-as.numeric(dt1$AMPLIBLIB)
if (class(dt1$AMPOVAOVA)=="factor") dt1$AMPOVAOVA <-as.numeric(levels(dt1$AMPOVAOVA))[as.integer(dt1$AMPOVAOVA) ]
if (class(dt1$AMPOVAOVA)=="character") dt1$AMPOVAOVA <-as.numeric(dt1$AMPOVAOVA)
if (class(dt1$AMPPROPRO)=="factor") dt1$AMPPROPRO <-as.numeric(levels(dt1$AMPPROPRO))[as.integer(dt1$AMPPROPRO) ]
if (class(dt1$AMPPROPRO)=="character") dt1$AMPPROPRO <-as.numeric(dt1$AMPPROPRO)
if (class(dt1$AMPPSEPSE)=="factor") dt1$AMPPSEPSE <-as.numeric(levels(dt1$AMPPSEPSE))[as.integer(dt1$AMPPSEPSE) ]
if (class(dt1$AMPPSEPSE)=="character") dt1$AMPPSEPSE <-as.numeric(dt1$AMPPSEPSE)
if (class(dt1$AMPSLSP01)=="factor") dt1$AMPSLSP01 <-as.numeric(levels(dt1$AMPSLSP01))[as.integer(dt1$AMPSLSP01) ]
if (class(dt1$AMPSLSP01)=="character") dt1$AMPSLSP01 <-as.numeric(dt1$AMPSLSP01)
if (class(dt1$AMPSLSP02)=="factor") dt1$AMPSLSP02 <-as.numeric(levels(dt1$AMPSLSP02))[as.integer(dt1$AMPSLSP02) ]
if (class(dt1$AMPSLSP02)=="character") dt1$AMPSLSP02 <-as.numeric(dt1$AMPSLSP02)
if (class(dt1$AMPSPPSPP)=="factor") dt1$AMPSPPSPP <-as.numeric(levels(dt1$AMPSPPSPP))[as.integer(dt1$AMPSPPSPP) ]
if (class(dt1$AMPSPPSPP)=="character") dt1$AMPSPPSPP <-as.numeric(dt1$AMPSPPSPP)
if (class(dt1$ANOCOSCOS)=="factor") dt1$ANOCOSCOS <-as.numeric(levels(dt1$ANOCOSCOS))[as.integer(dt1$ANOCOSCOS) ]
if (class(dt1$ANOCOSCOS)=="character") dt1$ANOCOSCOS <-as.numeric(dt1$ANOCOSCOS)
if (class(dt1$ANOSPHGRA)=="factor") dt1$ANOSPHGRA <-as.numeric(levels(dt1$ANOSPHGRA))[as.integer(dt1$ANOSPHGRA) ]
if (class(dt1$ANOSPHGRA)=="character") dt1$ANOSPHGRA <-as.numeric(dt1$ANOSPHGRA)
if (class(dt1$APLPELPEL)=="factor") dt1$APLPELPEL <-as.numeric(levels(dt1$APLPELPEL))[as.integer(dt1$APLPELPEL) ]
if (class(dt1$APLPELPEL)=="character") dt1$APLPELPEL <-as.numeric(dt1$APLPELPEL)
if (class(dt1$APTCFOCTO)=="factor") dt1$APTCFOCTO <-as.numeric(levels(dt1$APTCFOCTO))[as.integer(dt1$APTCFOCTO) ]
if (class(dt1$APTCFOCTO)=="character") dt1$APTCFOCTO <-as.numeric(dt1$APTCFOCTO)
if (class(dt1$APTSENSEN)=="factor") dt1$APTSENSEN <-as.numeric(levels(dt1$APTSENSEN))[as.integer(dt1$APTSENSEN) ]
if (class(dt1$APTSENSEN)=="character") dt1$APTSENSEN <-as.numeric(dt1$APTSENSEN)
if (class(dt1$ASTCFBAHU)=="factor") dt1$ASTCFBAHU <-as.numeric(levels(dt1$ASTCFBAHU))[as.integer(dt1$ASTCFBAHU) ]
if (class(dt1$ASTCFBAHU)=="character") dt1$ASTCFBAHU <-as.numeric(dt1$ASTCFBAHU)
if (class(dt1$AULCFAMBI)=="factor") dt1$AULCFAMBI <-as.numeric(levels(dt1$AULCFAMBI))[as.integer(dt1$AULCFAMBI) ]
if (class(dt1$AULCFAMBI)=="character") dt1$AULCFAMBI <-as.numeric(dt1$AULCFAMBI)
if (class(dt1$AULCFDIST)=="factor") dt1$AULCFDIST <-as.numeric(levels(dt1$AULCFDIST))[as.integer(dt1$AULCFDIST) ]
if (class(dt1$AULCFDIST)=="character") dt1$AULCFDIST <-as.numeric(dt1$AULCFDIST)
if (class(dt1$AULCFGRAN)=="factor") dt1$AULCFGRAN <-as.numeric(levels(dt1$AULCFGRAN))[as.integer(dt1$AULCFGRAN) ]
if (class(dt1$AULCFGRAN)=="character") dt1$AULCFGRAN <-as.numeric(dt1$AULCFGRAN)
if (class(dt1$AULGRAGRA)=="factor") dt1$AULGRAGRA <-as.numeric(levels(dt1$AULGRAGRA))[as.integer(dt1$AULGRAGRA) ]
if (class(dt1$AULGRAGRA)=="character") dt1$AULGRAGRA <-as.numeric(dt1$AULGRAGRA)
if (class(dt1$AULITATEN)=="factor") dt1$AULITATEN <-as.numeric(levels(dt1$AULITATEN))[as.integer(dt1$AULITATEN) ]
if (class(dt1$AULITATEN)=="character") dt1$AULITATEN <-as.numeric(dt1$AULITATEN)
if (class(dt1$AULSPPSPP)=="factor") dt1$AULSPPSPP <-as.numeric(levels(dt1$AULSPPSPP))[as.integer(dt1$AULSPPSPP) ]
if (class(dt1$AULSPPSPP)=="character") dt1$AULSPPSPP <-as.numeric(dt1$AULSPPSPP)
if (class(dt1$BACPAXPAX)=="factor") dt1$BACPAXPAX <-as.numeric(levels(dt1$BACPAXPAX))[as.integer(dt1$BACPAXPAX) ]
if (class(dt1$BACPAXPAX)=="character") dt1$BACPAXPAX <-as.numeric(dt1$BACPAXPAX)
if (class(dt1$BRAAPOAPO)=="factor") dt1$BRAAPOAPO <-as.numeric(levels(dt1$BRAAPOAPO))[as.integer(dt1$BRAAPOAPO) ]
if (class(dt1$BRAAPOAPO)=="character") dt1$BRAAPOAPO <-as.numeric(dt1$BRAAPOAPO)
if (class(dt1$BRABREBRE)=="factor") dt1$BRABREBRE <-as.numeric(levels(dt1$BRABREBRE))[as.integer(dt1$BRABREBRE) ]
if (class(dt1$BRABREBRE)=="character") dt1$BRABREBRE <-as.numeric(dt1$BRABREBRE)
if (class(dt1$BRAMICMIC)=="factor") dt1$BRAMICMIC <-as.numeric(levels(dt1$BRAMICMIC))[as.integer(dt1$BRAMICMIC) ]
if (class(dt1$BRAMICMIC)=="character") dt1$BRAMICMIC <-as.numeric(dt1$BRAMICMIC)
if (class(dt1$BRAPROPRO)=="factor") dt1$BRAPROPRO <-as.numeric(levels(dt1$BRAPROPRO))[as.integer(dt1$BRAPROPRO) ]
if (class(dt1$BRAPROPRO)=="character") dt1$BRAPROPRO <-as.numeric(dt1$BRAPROPRO)
if (class(dt1$BRAPSEPSE)=="factor") dt1$BRAPSEPSE <-as.numeric(levels(dt1$BRAPSEPSE))[as.integer(dt1$BRAPSEPSE) ]
if (class(dt1$BRAPSEPSE)=="character") dt1$BRAPSEPSE <-as.numeric(dt1$BRAPSEPSE)
if (class(dt1$BRASERSER)=="factor") dt1$BRASERSER <-as.numeric(levels(dt1$BRASERSER))[as.integer(dt1$BRASERSER) ]
if (class(dt1$BRASERSER)=="character") dt1$BRASERSER <-as.numeric(dt1$BRASERSER)
if (class(dt1$BRASPPSPP)=="factor") dt1$BRASPPSPP <-as.numeric(levels(dt1$BRASPPSPP))[as.integer(dt1$BRASPPSPP) ]
if (class(dt1$BRASPPSPP)=="character") dt1$BRASPPSPP <-as.numeric(dt1$BRASPPSPP)
if (class(dt1$BRAVITVIT)=="factor") dt1$BRAVITVIT <-as.numeric(levels(dt1$BRAVITVIT))[as.integer(dt1$BRAVITVIT) ]
if (class(dt1$BRAVITVIT)=="character") dt1$BRAVITVIT <-as.numeric(dt1$BRAVITVIT)
if (class(dt1$CALBUDBUD)=="factor") dt1$CALBUDBUD <-as.numeric(levels(dt1$CALBUDBUD))[as.integer(dt1$CALBUDBUD) ]
if (class(dt1$CALBUDBUD)=="character") dt1$CALBUDBUD <-as.numeric(dt1$CALBUDBUD)
if (class(dt1$CALCFBACI)=="factor") dt1$CALCFBACI <-as.numeric(levels(dt1$CALCFBACI))[as.integer(dt1$CALCFBACI) ]
if (class(dt1$CALCFBACI)=="character") dt1$CALCFBACI <-as.numeric(dt1$CALCFBACI)
if (class(dt1$CALCFBUDE)=="factor") dt1$CALCFBUDE <-as.numeric(levels(dt1$CALCFBUDE))[as.integer(dt1$CALCFBUDE) ]
if (class(dt1$CALCFBUDE)=="character") dt1$CALCFBUDE <-as.numeric(dt1$CALCFBUDE)
if (class(dt1$CALCFCLEV)=="factor") dt1$CALCFCLEV <-as.numeric(levels(dt1$CALCFCLEV))[as.integer(dt1$CALCFCLEV) ]
if (class(dt1$CALCFCLEV)=="character") dt1$CALCFCLEV <-as.numeric(dt1$CALCFCLEV)
if (class(dt1$CALFTSP02)=="factor") dt1$CALFTSP02 <-as.numeric(levels(dt1$CALFTSP02))[as.integer(dt1$CALFTSP02) ]
if (class(dt1$CALFTSP02)=="character") dt1$CALFTSP02 <-as.numeric(dt1$CALFTSP02)
if (class(dt1$CALSABSAB)=="factor") dt1$CALSABSAB <-as.numeric(levels(dt1$CALSABSAB))[as.integer(dt1$CALSABSAB) ]
if (class(dt1$CALSABSAB)=="character") dt1$CALSABSAB <-as.numeric(dt1$CALSABSAB)
if (class(dt1$CALSPPSPP)=="factor") dt1$CALSPPSPP <-as.numeric(levels(dt1$CALSPPSPP))[as.integer(dt1$CALSPPSPP) ]
if (class(dt1$CALSPPSPP)=="character") dt1$CALSPPSPP <-as.numeric(dt1$CALSPPSPP)
if (class(dt1$CAMSPPSPP)=="factor") dt1$CAMSPPSPP <-as.numeric(levels(dt1$CAMSPPSPP))[as.integer(dt1$CAMSPPSPP) ]
if (class(dt1$CAMSPPSPP)=="character") dt1$CAMSPPSPP <-as.numeric(dt1$CAMSPPSPP)
if (class(dt1$CAPCARCAR)=="factor") dt1$CAPCARCAR <-as.numeric(levels(dt1$CAPCARCAR))[as.integer(dt1$CAPCARCAR) ]
if (class(dt1$CAPCARCAR)=="character") dt1$CAPCARCAR <-as.numeric(dt1$CAPCARCAR)
if (class(dt1$CATADHADH)=="factor") dt1$CATADHADH <-as.numeric(levels(dt1$CATADHADH))[as.integer(dt1$CATADHADH) ]
if (class(dt1$CATADHADH)=="character") dt1$CATADHADH <-as.numeric(dt1$CATADHADH)
if (class(dt1$CAVMACMAC)=="factor") dt1$CAVMACMAC <-as.numeric(levels(dt1$CAVMACMAC))[as.integer(dt1$CAVMACMAC) ]
if (class(dt1$CAVMACMAC)=="character") dt1$CAVMACMAC <-as.numeric(dt1$CAVMACMAC)
if (class(dt1$COCBARBAR)=="factor") dt1$COCBARBAR <-as.numeric(levels(dt1$COCBARBAR))[as.integer(dt1$COCBARBAR) ]
if (class(dt1$COCBARBAR)=="character") dt1$COCBARBAR <-as.numeric(dt1$COCBARBAR)
if (class(dt1$COCPEDPED)=="factor") dt1$COCPEDPED <-as.numeric(levels(dt1$COCPEDPED))[as.integer(dt1$COCPEDPED) ]
if (class(dt1$COCPEDPED)=="character") dt1$COCPEDPED <-as.numeric(dt1$COCPEDPED)
if (class(dt1$COCPELPEL)=="factor") dt1$COCPELPEL <-as.numeric(levels(dt1$COCPELPEL))[as.integer(dt1$COCPELPEL) ]
if (class(dt1$COCPELPEL)=="character") dt1$COCPELPEL <-as.numeric(dt1$COCPELPEL)
if (class(dt1$COCPLAPLA)=="factor") dt1$COCPLAPLA <-as.numeric(levels(dt1$COCPLAPLA))[as.integer(dt1$COCPLAPLA) ]
if (class(dt1$COCPLAPLA)=="character") dt1$COCPLAPLA <-as.numeric(dt1$COCPLAPLA)
if (class(dt1$COCSCUSCU)=="factor") dt1$COCSCUSCU <-as.numeric(levels(dt1$COCSCUSCU))[as.integer(dt1$COCSCUSCU) ]
if (class(dt1$COCSCUSCU)=="character") dt1$COCSCUSCU <-as.numeric(dt1$COCSCUSCU)
if (class(dt1$COCSPPSPP)=="factor") dt1$COCSPPSPP <-as.numeric(levels(dt1$COCSPPSPP))[as.integer(dt1$COCSPPSPP) ]
if (class(dt1$COCSPPSPP)=="character") dt1$COCSPPSPP <-as.numeric(dt1$COCSPPSPP)
if (class(dt1$CODOCUIRI)=="factor") dt1$CODOCUIRI <-as.numeric(levels(dt1$CODOCUIRI))[as.integer(dt1$CODOCUIRI) ]
if (class(dt1$CODOCUIRI)=="character") dt1$CODOCUIRI <-as.numeric(dt1$CODOCUIRI)
if (class(dt1$CRAACCACC)=="factor") dt1$CRAACCACC <-as.numeric(levels(dt1$CRAACCACC))[as.integer(dt1$CRAACCACC) ]
if (class(dt1$CRAACCACC)=="character") dt1$CRAACCACC <-as.numeric(dt1$CRAACCACC)
if (class(dt1$CRACUSCUS)=="factor") dt1$CRACUSCUS <-as.numeric(levels(dt1$CRACUSCUS))[as.integer(dt1$CRACUSCUS) ]
if (class(dt1$CRACUSCUS)=="character") dt1$CRACUSCUS <-as.numeric(dt1$CRACUSCUS)
if (class(dt1$CRASPPSPP)=="factor") dt1$CRASPPSPP <-as.numeric(levels(dt1$CRASPPSPP))[as.integer(dt1$CRASPPSPP) ]
if (class(dt1$CRASPPSPP)=="character") dt1$CRASPPSPP <-as.numeric(dt1$CRASPPSPP)
if (class(dt1$CYCIRIIRI)=="factor") dt1$CYCIRIIRI <-as.numeric(levels(dt1$CYCIRIIRI))[as.integer(dt1$CYCIRIIRI) ]
if (class(dt1$CYCIRIIRI)=="character") dt1$CYCIRIIRI <-as.numeric(dt1$CYCIRIIRI)
if (class(dt1$CYCMENMEN)=="factor") dt1$CYCMENMEN <-as.numeric(levels(dt1$CYCMENMEN))[as.integer(dt1$CYCMENMEN) ]
if (class(dt1$CYCMENMEN)=="character") dt1$CYCMENMEN <-as.numeric(dt1$CYCMENMEN)
if (class(dt1$CYCRADRAD)=="factor") dt1$CYCRADRAD <-as.numeric(levels(dt1$CYCRADRAD))[as.integer(dt1$CYCRADRAD) ]
if (class(dt1$CYCRADRAD)=="character") dt1$CYCRADRAD <-as.numeric(dt1$CYCRADRAD)
if (class(dt1$CYCSPPSPP)=="factor") dt1$CYCSPPSPP <-as.numeric(levels(dt1$CYCSPPSPP))[as.integer(dt1$CYCSPPSPP) ]
if (class(dt1$CYCSPPSPP)=="character") dt1$CYCSPPSPP <-as.numeric(dt1$CYCSPPSPP)
if (class(dt1$CYMASPASP)=="factor") dt1$CYMASPASP <-as.numeric(levels(dt1$CYMASPASP))[as.integer(dt1$CYMASPASP) ]
if (class(dt1$CYMASPASP)=="character") dt1$CYMASPASP <-as.numeric(dt1$CYMASPASP)
if (class(dt1$CYMFTSP04)=="factor") dt1$CYMFTSP04 <-as.numeric(levels(dt1$CYMFTSP04))[as.integer(dt1$CYMFTSP04) ]
if (class(dt1$CYMFTSP04)=="character") dt1$CYMFTSP04 <-as.numeric(dt1$CYMFTSP04)
if (class(dt1$CYMFTSP05)=="factor") dt1$CYMFTSP05 <-as.numeric(levels(dt1$CYMFTSP05))[as.integer(dt1$CYMFTSP05) ]
if (class(dt1$CYMFTSP05)=="character") dt1$CYMFTSP05 <-as.numeric(dt1$CYMFTSP05)
if (class(dt1$CYMLAELAE)=="factor") dt1$CYMLAELAE <-as.numeric(levels(dt1$CYMLAELAE))[as.integer(dt1$CYMLAELAE) ]
if (class(dt1$CYMLAELAE)=="character") dt1$CYMLAELAE <-as.numeric(dt1$CYMLAELAE)
if (class(dt1$CYMSPPSPP)=="factor") dt1$CYMSPPSPP <-as.numeric(levels(dt1$CYMSPPSPP))[as.integer(dt1$CYMSPPSPP) ]
if (class(dt1$CYMSPPSPP)=="character") dt1$CYMSPPSPP <-as.numeric(dt1$CYMSPPSPP)
if (class(dt1$DENSUBSUB)=="factor") dt1$DENSUBSUB <-as.numeric(levels(dt1$DENSUBSUB))[as.integer(dt1$DENSUBSUB) ]
if (class(dt1$DENSUBSUB)=="character") dt1$DENSUBSUB <-as.numeric(dt1$DENSUBSUB)
if (class(dt1$DIACONCON)=="factor") dt1$DIACONCON <-as.numeric(levels(dt1$DIACONCON))[as.integer(dt1$DIACONCON) ]
if (class(dt1$DIACONCON)=="character") dt1$DIACONCON <-as.numeric(dt1$DIACONCON)
if (class(dt1$DIPCFELLI)=="factor") dt1$DIPCFELLI <-as.numeric(levels(dt1$DIPCFELLI))[as.integer(dt1$DIPCFELLI) ]
if (class(dt1$DIPCFELLI)=="character") dt1$DIPCFELLI <-as.numeric(dt1$DIPCFELLI)
if (class(dt1$DIPCFNOLB)=="factor") dt1$DIPCFNOLB <-as.numeric(levels(dt1$DIPCFNOLB))[as.integer(dt1$DIPCFNOLB) ]
if (class(dt1$DIPCFNOLB)=="character") dt1$DIPCFNOLB <-as.numeric(dt1$DIPCFNOLB)
if (class(dt1$DIPOBLOBL)=="factor") dt1$DIPOBLOBL <-as.numeric(levels(dt1$DIPOBLOBL))[as.integer(dt1$DIPOBLOBL) ]
if (class(dt1$DIPOBLOBL)=="character") dt1$DIPOBLOBL <-as.numeric(dt1$DIPOBLOBL)
if (class(dt1$DIPPARPAR)=="factor") dt1$DIPPARPAR <-as.numeric(levels(dt1$DIPPARPAR))[as.integer(dt1$DIPPARPAR) ]
if (class(dt1$DIPPARPAR)=="character") dt1$DIPPARPAR <-as.numeric(dt1$DIPPARPAR)
if (class(dt1$DIPPUEPUE)=="factor") dt1$DIPPUEPUE <-as.numeric(levels(dt1$DIPPUEPUE))[as.integer(dt1$DIPPUEPUE) ]
if (class(dt1$DIPPUEPUE)=="character") dt1$DIPPUEPUE <-as.numeric(dt1$DIPPUEPUE)
if (class(dt1$DIPSPPSPP)=="factor") dt1$DIPSPPSPP <-as.numeric(levels(dt1$DIPSPPSPP))[as.integer(dt1$DIPSPPSPP) ]
if (class(dt1$DIPSPPSPP)=="character") dt1$DIPSPPSPP <-as.numeric(dt1$DIPSPPSPP)
if (class(dt1$DISPSEPSE)=="factor") dt1$DISPSEPSE <-as.numeric(levels(dt1$DISPSEPSE))[as.integer(dt1$DISPSEPSE) ]
if (class(dt1$DISPSEPSE)=="character") dt1$DISPSEPSE <-as.numeric(dt1$DISPSEPSE)
if (class(dt1$DISSTESTE)=="factor") dt1$DISSTESTE <-as.numeric(levels(dt1$DISSTESTE))[as.integer(dt1$DISSTESTE) ]
if (class(dt1$DISSTESTE)=="character") dt1$DISSTESTE <-as.numeric(dt1$DISSTESTE)
if (class(dt1$ECYMICMIC)=="factor") dt1$ECYMICMIC <-as.numeric(levels(dt1$ECYMICMIC))[as.integer(dt1$ECYMICMIC) ]
if (class(dt1$ECYMICMIC)=="character") dt1$ECYMICMIC <-as.numeric(dt1$ECYMICMIC)
if (class(dt1$ECYSPPSPP)=="factor") dt1$ECYSPPSPP <-as.numeric(levels(dt1$ECYSPPSPP))[as.integer(dt1$ECYSPPSPP) ]
if (class(dt1$ECYSPPSPP)=="character") dt1$ECYSPPSPP <-as.numeric(dt1$ECYSPPSPP)
if (class(dt1$ECYSUBSUB)=="factor") dt1$ECYSUBSUB <-as.numeric(levels(dt1$ECYSUBSUB))[as.integer(dt1$ECYSUBSUB) ]
if (class(dt1$ECYSUBSUB)=="character") dt1$ECYSUBSUB <-as.numeric(dt1$ECYSUBSUB)
if (class(dt1$ENCCFEVER)=="factor") dt1$ENCCFEVER <-as.numeric(levels(dt1$ENCCFEVER))[as.integer(dt1$ENCCFEVER) ]
if (class(dt1$ENCCFEVER)=="character") dt1$ENCCFEVER <-as.numeric(dt1$ENCCFEVER)
if (class(dt1$ENCCFFT01)=="factor") dt1$ENCCFFT01 <-as.numeric(levels(dt1$ENCCFFT01))[as.integer(dt1$ENCCFFT01) ]
if (class(dt1$ENCCFFT01)=="character") dt1$ENCCFFT01 <-as.numeric(dt1$ENCCFFT01)
if (class(dt1$ENCCTSP01)=="factor") dt1$ENCCTSP01 <-as.numeric(levels(dt1$ENCCTSP01))[as.integer(dt1$ENCCTSP01) ]
if (class(dt1$ENCCTSP01)=="character") dt1$ENCCTSP01 <-as.numeric(dt1$ENCCTSP01)
if (class(dt1$ENCEVEEVE)=="factor") dt1$ENCEVEEVE <-as.numeric(levels(dt1$ENCEVEEVE))[as.integer(dt1$ENCEVEEVE) ]
if (class(dt1$ENCEVEEVE)=="character") dt1$ENCEVEEVE <-as.numeric(dt1$ENCEVEEVE)
if (class(dt1$ENCFTSP04)=="factor") dt1$ENCFTSP04 <-as.numeric(levels(dt1$ENCFTSP04))[as.integer(dt1$ENCFTSP04) ]
if (class(dt1$ENCFTSP04)=="character") dt1$ENCFTSP04 <-as.numeric(dt1$ENCFTSP04)
if (class(dt1$ENCGRAGRA)=="factor") dt1$ENCGRAGRA <-as.numeric(levels(dt1$ENCGRAGRA))[as.integer(dt1$ENCGRAGRA) ]
if (class(dt1$ENCGRAGRA)=="character") dt1$ENCGRAGRA <-as.numeric(dt1$ENCGRAGRA)
if (class(dt1$ENCLACLAC)=="factor") dt1$ENCLACLAC <-as.numeric(levels(dt1$ENCLACLAC))[as.integer(dt1$ENCLACLAC) ]
if (class(dt1$ENCLACLAC)=="character") dt1$ENCLACLAC <-as.numeric(dt1$ENCLACLAC)
if (class(dt1$ENCMESMES)=="factor") dt1$ENCMESMES <-as.numeric(levels(dt1$ENCMESMES))[as.integer(dt1$ENCMESMES) ]
if (class(dt1$ENCMESMES)=="character") dt1$ENCMESMES <-as.numeric(dt1$ENCMESMES)
if (class(dt1$ENCSILELE)=="factor") dt1$ENCSILELE <-as.numeric(levels(dt1$ENCSILELE))[as.integer(dt1$ENCSILELE) ]
if (class(dt1$ENCSILELE)=="character") dt1$ENCSILELE <-as.numeric(dt1$ENCSILELE)
if (class(dt1$ENCSILSIL)=="factor") dt1$ENCSILSIL <-as.numeric(levels(dt1$ENCSILSIL))[as.integer(dt1$ENCSILSIL) ]
if (class(dt1$ENCSILSIL)=="character") dt1$ENCSILSIL <-as.numeric(dt1$ENCSILSIL)
if (class(dt1$ENCSJSP03)=="factor") dt1$ENCSJSP03 <-as.numeric(levels(dt1$ENCSJSP03))[as.integer(dt1$ENCSJSP03) ]
if (class(dt1$ENCSJSP03)=="character") dt1$ENCSJSP03 <-as.numeric(dt1$ENCSJSP03)
if (class(dt1$ENCSPPSPP)=="factor") dt1$ENCSPPSPP <-as.numeric(levels(dt1$ENCSPPSPP))[as.integer(dt1$ENCSPPSPP) ]
if (class(dt1$ENCSPPSPP)=="character") dt1$ENCSPPSPP <-as.numeric(dt1$ENCSPPSPP)
if (class(dt1$ENTPULPUL)=="factor") dt1$ENTPULPUL <-as.numeric(levels(dt1$ENTPULPUL))[as.integer(dt1$ENTPULPUL) ]
if (class(dt1$ENTPULPUL)=="character") dt1$ENTPULPUL <-as.numeric(dt1$ENTPULPUL)
if (class(dt1$ENVCFPACH)=="factor") dt1$ENVCFPACH <-as.numeric(levels(dt1$ENVCFPACH))[as.integer(dt1$ENVCFPACH) ]
if (class(dt1$ENVCFPACH)=="character") dt1$ENVCFPACH <-as.numeric(dt1$ENVCFPACH)
if (class(dt1$ENVCFPSEU)=="factor") dt1$ENVCFPSEU <-as.numeric(levels(dt1$ENVCFPSEU))[as.integer(dt1$ENVCFPSEU) ]
if (class(dt1$ENVCFPSEU)=="character") dt1$ENVCFPSEU <-as.numeric(dt1$ENVCFPSEU)
if (class(dt1$ENVMETMET)=="factor") dt1$ENVMETMET <-as.numeric(levels(dt1$ENVMETMET))[as.integer(dt1$ENVMETMET) ]
if (class(dt1$ENVMETMET)=="character") dt1$ENVMETMET <-as.numeric(dt1$ENVMETMET)
if (class(dt1$ENVVANVAN)=="factor") dt1$ENVVANVAN <-as.numeric(levels(dt1$ENVVANVAN))[as.integer(dt1$ENVVANVAN) ]
if (class(dt1$ENVVANVAN)=="character") dt1$ENVVANVAN <-as.numeric(dt1$ENVVANVAN)
if (class(dt1$EPIGIBGIB)=="factor") dt1$EPIGIBGIB <-as.numeric(levels(dt1$EPIGIBGIB))[as.integer(dt1$EPIGIBGIB) ]
if (class(dt1$EPIGIBGIB)=="character") dt1$EPIGIBGIB <-as.numeric(dt1$EPIGIBGIB)
if (class(dt1$EPIPACPAC)=="factor") dt1$EPIPACPAC <-as.numeric(levels(dt1$EPIPACPAC))[as.integer(dt1$EPIPACPAC) ]
if (class(dt1$EPIPACPAC)=="character") dt1$EPIPACPAC <-as.numeric(dt1$EPIPACPAC)
if (class(dt1$EPIPORPOR)=="factor") dt1$EPIPORPOR <-as.numeric(levels(dt1$EPIPORPOR))[as.integer(dt1$EPIPORPOR) ]
if (class(dt1$EPIPORPOR)=="character") dt1$EPIPORPOR <-as.numeric(dt1$EPIPORPOR)
if (class(dt1$EPISPPSPP)=="factor") dt1$EPISPPSPP <-as.numeric(levels(dt1$EPISPPSPP))[as.integer(dt1$EPISPPSPP) ]
if (class(dt1$EPISPPSPP)=="character") dt1$EPISPPSPP <-as.numeric(dt1$EPISPPSPP)
if (class(dt1$EUNARCARC)=="factor") dt1$EUNARCARC <-as.numeric(levels(dt1$EUNARCARC))[as.integer(dt1$EUNARCARC) ]
if (class(dt1$EUNARCARC)=="character") dt1$EUNARCARC <-as.numeric(dt1$EUNARCARC)
if (class(dt1$EUNBILBIL)=="factor") dt1$EUNBILBIL <-as.numeric(levels(dt1$EUNBILBIL))[as.integer(dt1$EUNBILBIL) ]
if (class(dt1$EUNBILBIL)=="character") dt1$EUNBILBIL <-as.numeric(dt1$EUNBILBIL)
if (class(dt1$EUNCAMARC)=="factor") dt1$EUNCAMARC <-as.numeric(levels(dt1$EUNCAMARC))[as.integer(dt1$EUNCAMARC) ]
if (class(dt1$EUNCAMARC)=="character") dt1$EUNCAMARC <-as.numeric(dt1$EUNCAMARC)
if (class(dt1$EUNCAMCAM)=="factor") dt1$EUNCAMCAM <-as.numeric(levels(dt1$EUNCAMCAM))[as.integer(dt1$EUNCAMCAM) ]
if (class(dt1$EUNCAMCAM)=="character") dt1$EUNCAMCAM <-as.numeric(dt1$EUNCAMCAM)
if (class(dt1$EUNCARCAR)=="factor") dt1$EUNCARCAR <-as.numeric(levels(dt1$EUNCARCAR))[as.integer(dt1$EUNCARCAR) ]
if (class(dt1$EUNCARCAR)=="character") dt1$EUNCARCAR <-as.numeric(dt1$EUNCARCAR)
if (class(dt1$EUNCFNOV1)=="factor") dt1$EUNCFNOV1 <-as.numeric(levels(dt1$EUNCFNOV1))[as.integer(dt1$EUNCFNOV1) ]
if (class(dt1$EUNCFNOV1)=="character") dt1$EUNCFNOV1 <-as.numeric(dt1$EUNCFNOV1)
if (class(dt1$EUNCFPALU)=="factor") dt1$EUNCFPALU <-as.numeric(levels(dt1$EUNCFPALU))[as.integer(dt1$EUNCFPALU) ]
if (class(dt1$EUNCFPALU)=="character") dt1$EUNCFPALU <-as.numeric(dt1$EUNCFPALU)
if (class(dt1$EUNEGSP01)=="factor") dt1$EUNEGSP01 <-as.numeric(levels(dt1$EUNEGSP01))[as.integer(dt1$EUNEGSP01) ]
if (class(dt1$EUNEGSP01)=="character") dt1$EUNEGSP01 <-as.numeric(dt1$EUNEGSP01)
if (class(dt1$EUNFLEFLE)=="factor") dt1$EUNFLEFLE <-as.numeric(levels(dt1$EUNFLEFLE))[as.integer(dt1$EUNFLEFLE) ]
if (class(dt1$EUNFLEFLE)=="character") dt1$EUNFLEFLE <-as.numeric(dt1$EUNFLEFLE)
if (class(dt1$EUNFORFOR)=="factor") dt1$EUNFORFOR <-as.numeric(levels(dt1$EUNFORFOR))[as.integer(dt1$EUNFORFOR) ]
if (class(dt1$EUNFORFOR)=="character") dt1$EUNFORFOR <-as.numeric(dt1$EUNFORFOR)
if (class(dt1$EUNFTSP01)=="factor") dt1$EUNFTSP01 <-as.numeric(levels(dt1$EUNFTSP01))[as.integer(dt1$EUNFTSP01) ]
if (class(dt1$EUNFTSP01)=="character") dt1$EUNFTSP01 <-as.numeric(dt1$EUNFTSP01)
if (class(dt1$EUNFTSP03)=="factor") dt1$EUNFTSP03 <-as.numeric(levels(dt1$EUNFTSP03))[as.integer(dt1$EUNFTSP03) ]
if (class(dt1$EUNFTSP03)=="character") dt1$EUNFTSP03 <-as.numeric(dt1$EUNFTSP03)
if (class(dt1$EUNFTSP04)=="factor") dt1$EUNFTSP04 <-as.numeric(levels(dt1$EUNFTSP04))[as.integer(dt1$EUNFTSP04) ]
if (class(dt1$EUNFTSP04)=="character") dt1$EUNFTSP04 <-as.numeric(dt1$EUNFTSP04)
if (class(dt1$EUNFTSP05)=="factor") dt1$EUNFTSP05 <-as.numeric(levels(dt1$EUNFTSP05))[as.integer(dt1$EUNFTSP05) ]
if (class(dt1$EUNFTSP05)=="character") dt1$EUNFTSP05 <-as.numeric(dt1$EUNFTSP05)
if (class(dt1$EUNFTSP10)=="factor") dt1$EUNFTSP10 <-as.numeric(levels(dt1$EUNFTSP10))[as.integer(dt1$EUNFTSP10) ]
if (class(dt1$EUNFTSP10)=="character") dt1$EUNFTSP10 <-as.numeric(dt1$EUNFTSP10)
if (class(dt1$EUNFTSP11)=="factor") dt1$EUNFTSP11 <-as.numeric(levels(dt1$EUNFTSP11))[as.integer(dt1$EUNFTSP11) ]
if (class(dt1$EUNFTSP11)=="character") dt1$EUNFTSP11 <-as.numeric(dt1$EUNFTSP11)
if (class(dt1$EUNFTSP13)=="factor") dt1$EUNFTSP13 <-as.numeric(levels(dt1$EUNFTSP13))[as.integer(dt1$EUNFTSP13) ]
if (class(dt1$EUNFTSP13)=="character") dt1$EUNFTSP13 <-as.numeric(dt1$EUNFTSP13)
if (class(dt1$EUNIMPIMP)=="factor") dt1$EUNIMPIMP <-as.numeric(levels(dt1$EUNIMPIMP))[as.integer(dt1$EUNIMPIMP) ]
if (class(dt1$EUNIMPIMP)=="character") dt1$EUNIMPIMP <-as.numeric(dt1$EUNIMPIMP)
if (class(dt1$EUNINCINC)=="factor") dt1$EUNINCINC <-as.numeric(levels(dt1$EUNINCINC))[as.integer(dt1$EUNINCINC) ]
if (class(dt1$EUNINCINC)=="character") dt1$EUNINCINC <-as.numeric(dt1$EUNINCINC)
if (class(dt1$EUNMONMON)=="factor") dt1$EUNMONMON <-as.numeric(levels(dt1$EUNMONMON))[as.integer(dt1$EUNMONMON) ]
if (class(dt1$EUNMONMON)=="character") dt1$EUNMONMON <-as.numeric(dt1$EUNMONMON)
if (class(dt1$EUNNAENAE)=="factor") dt1$EUNNAENAE <-as.numeric(levels(dt1$EUNNAENAE))[as.integer(dt1$EUNNAENAE) ]
if (class(dt1$EUNNAENAE)=="character") dt1$EUNNAENAE <-as.numeric(dt1$EUNNAENAE)
if (class(dt1$EUNPANPAN)=="factor") dt1$EUNPANPAN <-as.numeric(levels(dt1$EUNPANPAN))[as.integer(dt1$EUNPANPAN) ]
if (class(dt1$EUNPANPAN)=="character") dt1$EUNPANPAN <-as.numeric(dt1$EUNPANPAN)
if (class(dt1$EUNSILSIL)=="factor") dt1$EUNSILSIL <-as.numeric(levels(dt1$EUNSILSIL))[as.integer(dt1$EUNSILSIL) ]
if (class(dt1$EUNSILSIL)=="character") dt1$EUNSILSIL <-as.numeric(dt1$EUNSILSIL)
if (class(dt1$EUNSPPSPP)=="factor") dt1$EUNSPPSPP <-as.numeric(levels(dt1$EUNSPPSPP))[as.integer(dt1$EUNSPPSPP) ]
if (class(dt1$EUNSPPSPP)=="character") dt1$EUNSPPSPP <-as.numeric(dt1$EUNSPPSPP)
if (class(dt1$EUNZYGELO)=="factor") dt1$EUNZYGELO <-as.numeric(levels(dt1$EUNZYGELO))[as.integer(dt1$EUNZYGELO) ]
if (class(dt1$EUNZYGELO)=="character") dt1$EUNZYGELO <-as.numeric(dt1$EUNZYGELO)
if (class(dt1$EUNZYGZYG)=="factor") dt1$EUNZYGZYG <-as.numeric(levels(dt1$EUNZYGZYG))[as.integer(dt1$EUNZYGZYG) ]
if (class(dt1$EUNZYGZYG)=="character") dt1$EUNZYGZYG <-as.numeric(dt1$EUNZYGZYG)
if (class(dt1$FLCFLOFLO)=="factor") dt1$FLCFLOFLO <-as.numeric(levels(dt1$FLCFLOFLO))[as.integer(dt1$FLCFLOFLO) ]
if (class(dt1$FLCFLOFLO)=="character") dt1$FLCFLOFLO <-as.numeric(dt1$FLCFLOFLO)
if (class(dt1$FLCLITLIT)=="factor") dt1$FLCLITLIT <-as.numeric(levels(dt1$FLCLITLIT))[as.integer(dt1$FLCLITLIT) ]
if (class(dt1$FLCLITLIT)=="character") dt1$FLCLITLIT <-as.numeric(dt1$FLCLITLIT)
if (class(dt1$FLCPYGPYG)=="factor") dt1$FLCPYGPYG <-as.numeric(levels(dt1$FLCPYGPYG))[as.integer(dt1$FLCPYGPYG) ]
if (class(dt1$FLCPYGPYG)=="character") dt1$FLCPYGPYG <-as.numeric(dt1$FLCPYGPYG)
if (class(dt1$FLCSLSP02)=="factor") dt1$FLCSLSP02 <-as.numeric(levels(dt1$FLCSLSP02))[as.integer(dt1$FLCSLSP02) ]
if (class(dt1$FLCSLSP02)=="character") dt1$FLCSLSP02 <-as.numeric(dt1$FLCSLSP02)
if (class(dt1$FLCSLSP03)=="factor") dt1$FLCSLSP03 <-as.numeric(levels(dt1$FLCSLSP03))[as.integer(dt1$FLCSLSP03) ]
if (class(dt1$FLCSLSP03)=="character") dt1$FLCSLSP03 <-as.numeric(dt1$FLCSLSP03)
if (class(dt1$FLCSPPSPP)=="factor") dt1$FLCSPPSPP <-as.numeric(levels(dt1$FLCSPPSPP))[as.integer(dt1$FLCSPPSPP) ]
if (class(dt1$FLCSPPSPP)=="character") dt1$FLCSPPSPP <-as.numeric(dt1$FLCSPPSPP)
if (class(dt1$FRACAPCAP)=="factor") dt1$FRACAPCAP <-as.numeric(levels(dt1$FRACAPCAP))[as.integer(dt1$FRACAPCAP) ]
if (class(dt1$FRACAPCAP)=="character") dt1$FRACAPCAP <-as.numeric(dt1$FRACAPCAP)
if (class(dt1$FRACFTENE)=="factor") dt1$FRACFTENE <-as.numeric(levels(dt1$FRACFTENE))[as.integer(dt1$FRACFTENE) ]
if (class(dt1$FRACFTENE)=="character") dt1$FRACFTENE <-as.numeric(dt1$FRACFTENE)
if (class(dt1$FRAFTSP07)=="factor") dt1$FRAFTSP07 <-as.numeric(levels(dt1$FRAFTSP07))[as.integer(dt1$FRAFTSP07) ]
if (class(dt1$FRAFTSP07)=="character") dt1$FRAFTSP07 <-as.numeric(dt1$FRAFTSP07)
if (class(dt1$FRAFTSP14)=="factor") dt1$FRAFTSP14 <-as.numeric(levels(dt1$FRAFTSP14))[as.integer(dt1$FRAFTSP14) ]
if (class(dt1$FRAFTSP14)=="character") dt1$FRAFTSP14 <-as.numeric(dt1$FRAFTSP14)
if (class(dt1$FRAFTSP15)=="factor") dt1$FRAFTSP15 <-as.numeric(levels(dt1$FRAFTSP15))[as.integer(dt1$FRAFTSP15) ]
if (class(dt1$FRAFTSP15)=="character") dt1$FRAFTSP15 <-as.numeric(dt1$FRAFTSP15)
if (class(dt1$FRAFTSP16)=="factor") dt1$FRAFTSP16 <-as.numeric(levels(dt1$FRAFTSP16))[as.integer(dt1$FRAFTSP16) ]
if (class(dt1$FRAFTSP16)=="character") dt1$FRAFTSP16 <-as.numeric(dt1$FRAFTSP16)
if (class(dt1$FRAFTSP19)=="factor") dt1$FRAFTSP19 <-as.numeric(levels(dt1$FRAFTSP19))[as.integer(dt1$FRAFTSP19) ]
if (class(dt1$FRAFTSP19)=="character") dt1$FRAFTSP19 <-as.numeric(dt1$FRAFTSP19)
if (class(dt1$FRAGRAGRA)=="factor") dt1$FRAGRAGRA <-as.numeric(levels(dt1$FRAGRAGRA))[as.integer(dt1$FRAGRAGRA) ]
if (class(dt1$FRAGRAGRA)=="character") dt1$FRAGRAGRA <-as.numeric(dt1$FRAGRAGRA)
if (class(dt1$FRAMESMES)=="factor") dt1$FRAMESMES <-as.numeric(levels(dt1$FRAMESMES))[as.integer(dt1$FRAMESMES) ]
if (class(dt1$FRAMESMES)=="character") dt1$FRAMESMES <-as.numeric(dt1$FRAMESMES)
if (class(dt1$FRASPPSPP)=="factor") dt1$FRASPPSPP <-as.numeric(levels(dt1$FRASPPSPP))[as.integer(dt1$FRASPPSPP) ]
if (class(dt1$FRASPPSPP)=="character") dt1$FRASPPSPP <-as.numeric(dt1$FRASPPSPP)
if (class(dt1$FRASYNSYN)=="factor") dt1$FRASYNSYN <-as.numeric(levels(dt1$FRASYNSYN))[as.integer(dt1$FRASYNSYN) ]
if (class(dt1$FRASYNSYN)=="character") dt1$FRASYNSYN <-as.numeric(dt1$FRASYNSYN)
if (class(dt1$FRATENNAN)=="factor") dt1$FRATENNAN <-as.numeric(levels(dt1$FRATENNAN))[as.integer(dt1$FRATENNAN) ]
if (class(dt1$FRATENNAN)=="character") dt1$FRATENNAN <-as.numeric(dt1$FRATENNAN)
if (class(dt1$FRAVAUVAU)=="factor") dt1$FRAVAUVAU <-as.numeric(levels(dt1$FRAVAUVAU))[as.integer(dt1$FRAVAUVAU) ]
if (class(dt1$FRAVAUVAU)=="character") dt1$FRAVAUVAU <-as.numeric(dt1$FRAVAUVAU)
if (class(dt1$FRFVIRCAP)=="factor") dt1$FRFVIRCAP <-as.numeric(levels(dt1$FRFVIRCAP))[as.integer(dt1$FRFVIRCAP) ]
if (class(dt1$FRFVIRCAP)=="character") dt1$FRFVIRCAP <-as.numeric(dt1$FRFVIRCAP)
if (class(dt1$FRUCRACRA)=="factor") dt1$FRUCRACRA <-as.numeric(levels(dt1$FRUCRACRA))[as.integer(dt1$FRUCRACRA) ]
if (class(dt1$FRUCRACRA)=="character") dt1$FRUCRACRA <-as.numeric(dt1$FRUCRACRA)
if (class(dt1$FRURHORHO)=="factor") dt1$FRURHORHO <-as.numeric(levels(dt1$FRURHORHO))[as.integer(dt1$FRURHORHO) ]
if (class(dt1$FRURHORHO)=="character") dt1$FRURHORHO <-as.numeric(dt1$FRURHORHO)
if (class(dt1$GOLOLIOLI)=="factor") dt1$GOLOLIOLI <-as.numeric(levels(dt1$GOLOLIOLI))[as.integer(dt1$GOLOLIOLI) ]
if (class(dt1$GOLOLIOLI)=="character") dt1$GOLOLIOLI <-as.numeric(dt1$GOLOLIOLI)
if (class(dt1$GOMAFFAFF)=="factor") dt1$GOMAFFAFF <-as.numeric(levels(dt1$GOMAFFAFF))[as.integer(dt1$GOMAFFAFF) ]
if (class(dt1$GOMAFFAFF)=="character") dt1$GOMAFFAFF <-as.numeric(dt1$GOMAFFAFF)
if (class(dt1$GOMAFFRHO)=="factor") dt1$GOMAFFRHO <-as.numeric(levels(dt1$GOMAFFRHO))[as.integer(dt1$GOMAFFRHO) ]
if (class(dt1$GOMAFFRHO)=="character") dt1$GOMAFFRHO <-as.numeric(dt1$GOMAFFRHO)
if (class(dt1$GOMAURAUR)=="factor") dt1$GOMAURAUR <-as.numeric(levels(dt1$GOMAURAUR))[as.integer(dt1$GOMAURAUR) ]
if (class(dt1$GOMAURAUR)=="character") dt1$GOMAURAUR <-as.numeric(dt1$GOMAURAUR)
if (class(dt1$GOMCFVIBR)=="factor") dt1$GOMCFVIBR <-as.numeric(levels(dt1$GOMCFVIBR))[as.integer(dt1$GOMCFVIBR) ]
if (class(dt1$GOMCFVIBR)=="character") dt1$GOMCFVIBR <-as.numeric(dt1$GOMCFVIBR)
if (class(dt1$GOMCORCOR)=="factor") dt1$GOMCORCOR <-as.numeric(levels(dt1$GOMCORCOR))[as.integer(dt1$GOMCORCOR) ]
if (class(dt1$GOMCORCOR)=="character") dt1$GOMCORCOR <-as.numeric(dt1$GOMCORCOR)
if (class(dt1$GOMEXIEXI)=="factor") dt1$GOMEXIEXI <-as.numeric(levels(dt1$GOMEXIEXI))[as.integer(dt1$GOMEXIEXI) ]
if (class(dt1$GOMEXIEXI)=="character") dt1$GOMEXIEXI <-as.numeric(dt1$GOMEXIEXI)
if (class(dt1$GOMFTSP22)=="factor") dt1$GOMFTSP22 <-as.numeric(levels(dt1$GOMFTSP22))[as.integer(dt1$GOMFTSP22) ]
if (class(dt1$GOMFTSP22)=="character") dt1$GOMFTSP22 <-as.numeric(dt1$GOMFTSP22)
if (class(dt1$GOMFTSP30)=="factor") dt1$GOMFTSP30 <-as.numeric(levels(dt1$GOMFTSP30))[as.integer(dt1$GOMFTSP30) ]
if (class(dt1$GOMFTSP30)=="character") dt1$GOMFTSP30 <-as.numeric(dt1$GOMFTSP30)
if (class(dt1$GOMGRAGRA)=="factor") dt1$GOMGRAGRA <-as.numeric(levels(dt1$GOMGRAGRA))[as.integer(dt1$GOMGRAGRA) ]
if (class(dt1$GOMGRAGRA)=="character") dt1$GOMGRAGRA <-as.numeric(dt1$GOMGRAGRA)
if (class(dt1$GOMLAGLAG)=="factor") dt1$GOMLAGLAG <-as.numeric(levels(dt1$GOMLAGLAG))[as.integer(dt1$GOMLAGLAG) ]
if (class(dt1$GOMLAGLAG)=="character") dt1$GOMLAGLAG <-as.numeric(dt1$GOMLAGLAG)
if (class(dt1$GOMMACMAC)=="factor") dt1$GOMMACMAC <-as.numeric(levels(dt1$GOMMACMAC))[as.integer(dt1$GOMMACMAC) ]
if (class(dt1$GOMMACMAC)=="character") dt1$GOMMACMAC <-as.numeric(dt1$GOMMACMAC)
if (class(dt1$GOMNEONEO)=="factor") dt1$GOMNEONEO <-as.numeric(levels(dt1$GOMNEONEO))[as.integer(dt1$GOMNEONEO) ]
if (class(dt1$GOMNEONEO)=="character") dt1$GOMNEONEO <-as.numeric(dt1$GOMNEONEO)
if (class(dt1$GOMPARPAR)=="factor") dt1$GOMPARPAR <-as.numeric(levels(dt1$GOMPARPAR))[as.integer(dt1$GOMPARPAR) ]
if (class(dt1$GOMPARPAR)=="character") dt1$GOMPARPAR <-as.numeric(dt1$GOMPARPAR)
if (class(dt1$GOMPRAPRA)=="factor") dt1$GOMPRAPRA <-as.numeric(levels(dt1$GOMPRAPRA))[as.integer(dt1$GOMPRAPRA) ]
if (class(dt1$GOMPRAPRA)=="character") dt1$GOMPRAPRA <-as.numeric(dt1$GOMPRAPRA)
if (class(dt1$GOMSAPSAP)=="factor") dt1$GOMSAPSAP <-as.numeric(levels(dt1$GOMSAPSAP))[as.integer(dt1$GOMSAPSAP) ]
if (class(dt1$GOMSAPSAP)=="character") dt1$GOMSAPSAP <-as.numeric(dt1$GOMSAPSAP)
if (class(dt1$GOMSPPSPP)=="factor") dt1$GOMSPPSPP <-as.numeric(levels(dt1$GOMSPPSPP))[as.integer(dt1$GOMSPPSPP) ]
if (class(dt1$GOMSPPSPP)=="character") dt1$GOMSPPSPP <-as.numeric(dt1$GOMSPPSPP)
if (class(dt1$GOMSUBMEX)=="factor") dt1$GOMSUBMEX <-as.numeric(levels(dt1$GOMSUBMEX))[as.integer(dt1$GOMSUBMEX) ]
if (class(dt1$GOMSUBMEX)=="character") dt1$GOMSUBMEX <-as.numeric(dt1$GOMSUBMEX)
if (class(dt1$GOMTURTUR)=="factor") dt1$GOMTURTUR <-as.numeric(levels(dt1$GOMTURTUR))[as.integer(dt1$GOMTURTUR) ]
if (class(dt1$GOMTURTUR)=="character") dt1$GOMTURTUR <-as.numeric(dt1$GOMTURTUR)
if (class(dt1$GOMVIRVIR)=="factor") dt1$GOMVIRVIR <-as.numeric(levels(dt1$GOMVIRVIR))[as.integer(dt1$GOMVIRVIR) ]
if (class(dt1$GOMVIRVIR)=="character") dt1$GOMVIRVIR <-as.numeric(dt1$GOMVIRVIR)
if (class(dt1$GYROBSOBS)=="factor") dt1$GYROBSOBS <-as.numeric(levels(dt1$GYROBSOBS))[as.integer(dt1$GYROBSOBS) ]
if (class(dt1$GYROBSOBS)=="character") dt1$GYROBSOBS <-as.numeric(dt1$GYROBSOBS)
if (class(dt1$HALAPOAPO)=="factor") dt1$HALAPOAPO <-as.numeric(levels(dt1$HALAPOAPO))[as.integer(dt1$HALAPOAPO) ]
if (class(dt1$HALAPOAPO)=="character") dt1$HALAPOAPO <-as.numeric(dt1$HALAPOAPO)
if (class(dt1$HALCYMHER)=="factor") dt1$HALCYMHER <-as.numeric(levels(dt1$HALCYMHER))[as.integer(dt1$HALCYMHER) ]
if (class(dt1$HALCYMHER)=="character") dt1$HALCYMHER <-as.numeric(dt1$HALCYMHER)
if (class(dt1$HALHOLHOL)=="factor") dt1$HALHOLHOL <-as.numeric(levels(dt1$HALHOLHOL))[as.integer(dt1$HALHOLHOL) ]
if (class(dt1$HALHOLHOL)=="character") dt1$HALHOLHOL <-as.numeric(dt1$HALHOLHOL)
if (class(dt1$HALHYBHYB)=="factor") dt1$HALHYBHYB <-as.numeric(levels(dt1$HALHYBHYB))[as.integer(dt1$HALHYBHYB) ]
if (class(dt1$HALHYBHYB)=="character") dt1$HALHYBHYB <-as.numeric(dt1$HALHYBHYB)
if (class(dt1$HALMONMON)=="factor") dt1$HALMONMON <-as.numeric(levels(dt1$HALMONMON))[as.integer(dt1$HALMONMON) ]
if (class(dt1$HALMONMON)=="character") dt1$HALMONMON <-as.numeric(dt1$HALMONMON)
if (class(dt1$HALSUBSUB)=="factor") dt1$HALSUBSUB <-as.numeric(levels(dt1$HALSUBSUB))[as.integer(dt1$HALSUBSUB) ]
if (class(dt1$HALSUBSUB)=="character") dt1$HALSUBSUB <-as.numeric(dt1$HALSUBSUB)
if (class(dt1$HANAMPAMP)=="factor") dt1$HANAMPAMP <-as.numeric(levels(dt1$HANAMPAMP))[as.integer(dt1$HANAMPAMP) ]
if (class(dt1$HANAMPAMP)=="character") dt1$HANAMPAMP <-as.numeric(dt1$HANAMPAMP)
if (class(dt1$HANCFGRNE)=="factor") dt1$HANCFGRNE <-as.numeric(levels(dt1$HANCFGRNE))[as.integer(dt1$HANCFGRNE) ]
if (class(dt1$HANCFGRNE)=="character") dt1$HANCFGRNE <-as.numeric(dt1$HANCFGRNE)
if (class(dt1$HANELOELO)=="factor") dt1$HANELOELO <-as.numeric(levels(dt1$HANELOELO))[as.integer(dt1$HANELOELO) ]
if (class(dt1$HANELOELO)=="character") dt1$HANELOELO <-as.numeric(dt1$HANELOELO)
if (class(dt1$HANFTSP01)=="factor") dt1$HANFTSP01 <-as.numeric(levels(dt1$HANFTSP01))[as.integer(dt1$HANFTSP01) ]
if (class(dt1$HANFTSP01)=="character") dt1$HANFTSP01 <-as.numeric(dt1$HANFTSP01)
if (class(dt1$HANFTSP04)=="factor") dt1$HANFTSP04 <-as.numeric(levels(dt1$HANFTSP04))[as.integer(dt1$HANFTSP04) ]
if (class(dt1$HANFTSP04)=="character") dt1$HANFTSP04 <-as.numeric(dt1$HANFTSP04)
if (class(dt1$HANSPESPE)=="factor") dt1$HANSPESPE <-as.numeric(levels(dt1$HANSPESPE))[as.integer(dt1$HANSPESPE) ]
if (class(dt1$HANSPESPE)=="character") dt1$HANSPESPE <-as.numeric(dt1$HANSPESPE)
if (class(dt1$HANSPPSPP)=="factor") dt1$HANSPPSPP <-as.numeric(levels(dt1$HANSPPSPP))[as.integer(dt1$HANSPPSPP) ]
if (class(dt1$HANSPPSPP)=="character") dt1$HANSPPSPP <-as.numeric(dt1$HANSPPSPP)
if (class(dt1$HANVIVVIV)=="factor") dt1$HANVIVVIV <-as.numeric(levels(dt1$HANVIVVIV))[as.integer(dt1$HANVIVVIV) ]
if (class(dt1$HANVIVVIV)=="character") dt1$HANVIVVIV <-as.numeric(dt1$HANVIVVIV)
if (class(dt1$HIPHUNHUN)=="factor") dt1$HIPHUNHUN <-as.numeric(levels(dt1$HIPHUNHUN))[as.integer(dt1$HIPHUNHUN) ]
if (class(dt1$HIPHUNHUN)=="character") dt1$HIPHUNHUN <-as.numeric(dt1$HIPHUNHUN)
if (class(dt1$HYDSCOSCO)=="factor") dt1$HYDSCOSCO <-as.numeric(levels(dt1$HYDSCOSCO))[as.integer(dt1$HYDSCOSCO) ]
if (class(dt1$HYDSCOSCO)=="character") dt1$HYDSCOSCO <-as.numeric(dt1$HYDSCOSCO)
if (class(dt1$ICOCURCUR)=="factor") dt1$ICOCURCUR <-as.numeric(levels(dt1$ICOCURCUR))[as.integer(dt1$ICOCURCUR) ]
if (class(dt1$ICOCURCUR)=="character") dt1$ICOCURCUR <-as.numeric(dt1$ICOCURCUR)
if (class(dt1$KARCFSUBM)=="factor") dt1$KARCFSUBM <-as.numeric(levels(dt1$KARCFSUBM))[as.integer(dt1$KARCFSUBM) ]
if (class(dt1$KARCFSUBM)=="character") dt1$KARCFSUBM <-as.numeric(dt1$KARCFSUBM)
if (class(dt1$KOBCFPARA)=="factor") dt1$KOBCFPARA <-as.numeric(levels(dt1$KOBCFPARA))[as.integer(dt1$KOBCFPARA) ]
if (class(dt1$KOBCFPARA)=="character") dt1$KOBCFPARA <-as.numeric(dt1$KOBCFPARA)
if (class(dt1$KOBJAAJAA)=="factor") dt1$KOBJAAJAA <-as.numeric(levels(dt1$KOBJAAJAA))[as.integer(dt1$KOBJAAJAA) ]
if (class(dt1$KOBJAAJAA)=="character") dt1$KOBJAAJAA <-as.numeric(dt1$KOBJAAJAA)
if (class(dt1$KRKEGSP01)=="factor") dt1$KRKEGSP01 <-as.numeric(levels(dt1$KRKEGSP01))[as.integer(dt1$KRKEGSP01) ]
if (class(dt1$KRKEGSP01)=="character") dt1$KRKEGSP01 <-as.numeric(dt1$KRKEGSP01)
if (class(dt1$KRKFLOFLO)=="factor") dt1$KRKFLOFLO <-as.numeric(levels(dt1$KRKFLOFLO))[as.integer(dt1$KRKFLOFLO) ]
if (class(dt1$KRKFLOFLO)=="character") dt1$KRKFLOFLO <-as.numeric(dt1$KRKFLOFLO)
if (class(dt1$KRKFTSP02)=="factor") dt1$KRKFTSP02 <-as.numeric(levels(dt1$KRKFTSP02))[as.integer(dt1$KRKFTSP02) ]
if (class(dt1$KRKFTSP02)=="character") dt1$KRKFTSP02 <-as.numeric(dt1$KRKFTSP02)
if (class(dt1$LEMEXIEXI)=="factor") dt1$LEMEXIEXI <-as.numeric(levels(dt1$LEMEXIEXI))[as.integer(dt1$LEMEXIEXI) ]
if (class(dt1$LEMEXIEXI)=="character") dt1$LEMEXIEXI <-as.numeric(dt1$LEMEXIEXI)
if (class(dt1$LEMHUNHUN)=="factor") dt1$LEMHUNHUN <-as.numeric(levels(dt1$LEMHUNHUN))[as.integer(dt1$LEMHUNHUN) ]
if (class(dt1$LEMHUNHUN)=="character") dt1$LEMHUNHUN <-as.numeric(dt1$LEMHUNHUN)
if (class(dt1$MASASPASP)=="factor") dt1$MASASPASP <-as.numeric(levels(dt1$MASASPASP))[as.integer(dt1$MASASPASP) ]
if (class(dt1$MASASPASP)=="character") dt1$MASASPASP <-as.numeric(dt1$MASASPASP)
if (class(dt1$MASASRASR)=="factor") dt1$MASASRASR <-as.numeric(levels(dt1$MASASRASR))[as.integer(dt1$MASASRASR) ]
if (class(dt1$MASASRASR)=="character") dt1$MASASRASR <-as.numeric(dt1$MASASRASR)
if (class(dt1$MASBARBAR)=="factor") dt1$MASBARBAR <-as.numeric(levels(dt1$MASBARBAR))[as.integer(dt1$MASBARBAR) ]
if (class(dt1$MASBARBAR)=="character") dt1$MASBARBAR <-as.numeric(dt1$MASBARBAR)
if (class(dt1$MASBRABRA)=="factor") dt1$MASBRABRA <-as.numeric(levels(dt1$MASBRABRA))[as.integer(dt1$MASBRABRA) ]
if (class(dt1$MASBRABRA)=="character") dt1$MASBRABRA <-as.numeric(dt1$MASBRABRA)
if (class(dt1$MASCALCAL)=="factor") dt1$MASCALCAL <-as.numeric(levels(dt1$MASCALCAL))[as.integer(dt1$MASCALCAL) ]
if (class(dt1$MASCALCAL)=="character") dt1$MASCALCAL <-as.numeric(dt1$MASCALCAL)
if (class(dt1$MASCFERIT)=="factor") dt1$MASCFERIT <-as.numeric(levels(dt1$MASCFERIT))[as.integer(dt1$MASCFERIT) ]
if (class(dt1$MASCFERIT)=="character") dt1$MASCFERIT <-as.numeric(dt1$MASCFERIT)
if (class(dt1$MASCRUALT)=="factor") dt1$MASCRUALT <-as.numeric(levels(dt1$MASCRUALT))[as.integer(dt1$MASCRUALT) ]
if (class(dt1$MASCRUALT)=="character") dt1$MASCRUALT <-as.numeric(dt1$MASCRUALT)
if (class(dt1$MASCRUCRU)=="factor") dt1$MASCRUCRU <-as.numeric(levels(dt1$MASCRUCRU))[as.integer(dt1$MASCRUCRU) ]
if (class(dt1$MASCRUCRU)=="character") dt1$MASCRUCRU <-as.numeric(dt1$MASCRUCRU)
if (class(dt1$MASELEELE)=="factor") dt1$MASELEELE <-as.numeric(levels(dt1$MASELEELE))[as.integer(dt1$MASELEELE) ]
if (class(dt1$MASELEELE)=="character") dt1$MASELEELE <-as.numeric(dt1$MASELEELE)
if (class(dt1$MASELLELL)=="factor") dt1$MASELLELL <-as.numeric(levels(dt1$MASELLELL))[as.integer(dt1$MASELLELL) ]
if (class(dt1$MASELLELL)=="character") dt1$MASELLELL <-as.numeric(dt1$MASELLELL)
if (class(dt1$MASHORHOR)=="factor") dt1$MASHORHOR <-as.numeric(levels(dt1$MASHORHOR))[as.integer(dt1$MASHORHOR) ]
if (class(dt1$MASHORHOR)=="character") dt1$MASHORHOR <-as.numeric(dt1$MASHORHOR)
if (class(dt1$MASLANLAN)=="factor") dt1$MASLANLAN <-as.numeric(levels(dt1$MASLANLAN))[as.integer(dt1$MASLANLAN) ]
if (class(dt1$MASLANLAN)=="character") dt1$MASLANLAN <-as.numeric(dt1$MASLANLAN)
if (class(dt1$MASOVAOVA)=="factor") dt1$MASOVAOVA <-as.numeric(levels(dt1$MASOVAOVA))[as.integer(dt1$MASOVAOVA) ]
if (class(dt1$MASOVAOVA)=="character") dt1$MASOVAOVA <-as.numeric(dt1$MASOVAOVA)
if (class(dt1$MASPSEPSE)=="factor") dt1$MASPSEPSE <-as.numeric(levels(dt1$MASPSEPSE))[as.integer(dt1$MASPSEPSE) ]
if (class(dt1$MASPSEPSE)=="character") dt1$MASPSEPSE <-as.numeric(dt1$MASPSEPSE)
if (class(dt1$MASSPPSPP)=="factor") dt1$MASSPPSPP <-as.numeric(levels(dt1$MASSPPSPP))[as.integer(dt1$MASSPPSPP) ]
if (class(dt1$MASSPPSPP)=="character") dt1$MASSPPSPP <-as.numeric(dt1$MASSPPSPP)
if (class(dt1$MELSPPSPP)=="factor") dt1$MELSPPSPP <-as.numeric(levels(dt1$MELSPPSPP))[as.integer(dt1$MELSPPSPP) ]
if (class(dt1$MELSPPSPP)=="character") dt1$MELSPPSPP <-as.numeric(dt1$MELSPPSPP)
if (class(dt1$NAVANGANG)=="factor") dt1$NAVANGANG <-as.numeric(levels(dt1$NAVANGANG))[as.integer(dt1$NAVANGANG) ]
if (class(dt1$NAVANGANG)=="character") dt1$NAVANGANG <-as.numeric(dt1$NAVANGANG)
if (class(dt1$NAVCFCAPI)=="factor") dt1$NAVCFCAPI <-as.numeric(levels(dt1$NAVCFCAPI))[as.integer(dt1$NAVCFCAPI) ]
if (class(dt1$NAVCFCAPI)=="character") dt1$NAVCFCAPI <-as.numeric(dt1$NAVCFCAPI)
if (class(dt1$NAVCFCINC)=="factor") dt1$NAVCFCINC <-as.numeric(levels(dt1$NAVCFCINC))[as.integer(dt1$NAVCFCINC) ]
if (class(dt1$NAVCFCINC)=="character") dt1$NAVCFCINC <-as.numeric(dt1$NAVCFCINC)
if (class(dt1$NAVCFNEOW)=="factor") dt1$NAVCFNEOW <-as.numeric(levels(dt1$NAVCFNEOW))[as.integer(dt1$NAVCFNEOW) ]
if (class(dt1$NAVCFNEOW)=="character") dt1$NAVCFNEOW <-as.numeric(dt1$NAVCFNEOW)
if (class(dt1$NAVCFRECE)=="factor") dt1$NAVCFRECE <-as.numeric(levels(dt1$NAVCFRECE))[as.integer(dt1$NAVCFRECE) ]
if (class(dt1$NAVCFRECE)=="character") dt1$NAVCFRECE <-as.numeric(dt1$NAVCFRECE)
if (class(dt1$NAVCFVENE)=="factor") dt1$NAVCFVENE <-as.numeric(levels(dt1$NAVCFVENE))[as.integer(dt1$NAVCFVENE) ]
if (class(dt1$NAVCFVENE)=="character") dt1$NAVCFVENE <-as.numeric(dt1$NAVCFVENE)
if (class(dt1$NAVCRPCRP)=="factor") dt1$NAVCRPCRP <-as.numeric(levels(dt1$NAVCRPCRP))[as.integer(dt1$NAVCRPCRP) ]
if (class(dt1$NAVCRPCRP)=="character") dt1$NAVCRPCRP <-as.numeric(dt1$NAVCRPCRP)
if (class(dt1$NAVCRYCRY)=="factor") dt1$NAVCRYCRY <-as.numeric(levels(dt1$NAVCRYCRY))[as.integer(dt1$NAVCRYCRY) ]
if (class(dt1$NAVCRYCRY)=="character") dt1$NAVCRYCRY <-as.numeric(dt1$NAVCRYCRY)
if (class(dt1$NAVDENDEN)=="factor") dt1$NAVDENDEN <-as.numeric(levels(dt1$NAVDENDEN))[as.integer(dt1$NAVDENDEN) ]
if (class(dt1$NAVDENDEN)=="character") dt1$NAVDENDEN <-as.numeric(dt1$NAVDENDEN)
if (class(dt1$NAVFTSP01)=="factor") dt1$NAVFTSP01 <-as.numeric(levels(dt1$NAVFTSP01))[as.integer(dt1$NAVFTSP01) ]
if (class(dt1$NAVFTSP01)=="character") dt1$NAVFTSP01 <-as.numeric(dt1$NAVFTSP01)
if (class(dt1$NAVFTSP03)=="factor") dt1$NAVFTSP03 <-as.numeric(levels(dt1$NAVFTSP03))[as.integer(dt1$NAVFTSP03) ]
if (class(dt1$NAVFTSP03)=="character") dt1$NAVFTSP03 <-as.numeric(dt1$NAVFTSP03)
if (class(dt1$NAVFTSP12)=="factor") dt1$NAVFTSP12 <-as.numeric(levels(dt1$NAVFTSP12))[as.integer(dt1$NAVFTSP12) ]
if (class(dt1$NAVFTSP12)=="character") dt1$NAVFTSP12 <-as.numeric(dt1$NAVFTSP12)
if (class(dt1$NAVFTSP16)=="factor") dt1$NAVFTSP16 <-as.numeric(levels(dt1$NAVFTSP16))[as.integer(dt1$NAVFTSP16) ]
if (class(dt1$NAVFTSP16)=="character") dt1$NAVFTSP16 <-as.numeric(dt1$NAVFTSP16)
if (class(dt1$NAVFTSP18)=="factor") dt1$NAVFTSP18 <-as.numeric(levels(dt1$NAVFTSP18))[as.integer(dt1$NAVFTSP18) ]
if (class(dt1$NAVFTSP18)=="character") dt1$NAVFTSP18 <-as.numeric(dt1$NAVFTSP18)
if (class(dt1$NAVFTSP21)=="factor") dt1$NAVFTSP21 <-as.numeric(levels(dt1$NAVFTSP21))[as.integer(dt1$NAVFTSP21) ]
if (class(dt1$NAVFTSP21)=="character") dt1$NAVFTSP21 <-as.numeric(dt1$NAVFTSP21)
if (class(dt1$NAVFTSP25)=="factor") dt1$NAVFTSP25 <-as.numeric(levels(dt1$NAVFTSP25))[as.integer(dt1$NAVFTSP25) ]
if (class(dt1$NAVFTSP25)=="character") dt1$NAVFTSP25 <-as.numeric(dt1$NAVFTSP25)
if (class(dt1$NAVFTSP26)=="factor") dt1$NAVFTSP26 <-as.numeric(levels(dt1$NAVFTSP26))[as.integer(dt1$NAVFTSP26) ]
if (class(dt1$NAVFTSP26)=="character") dt1$NAVFTSP26 <-as.numeric(dt1$NAVFTSP26)
if (class(dt1$NAVFTSP27)=="factor") dt1$NAVFTSP27 <-as.numeric(levels(dt1$NAVFTSP27))[as.integer(dt1$NAVFTSP27) ]
if (class(dt1$NAVFTSP27)=="character") dt1$NAVFTSP27 <-as.numeric(dt1$NAVFTSP27)
if (class(dt1$NAVFTSP29)=="factor") dt1$NAVFTSP29 <-as.numeric(levels(dt1$NAVFTSP29))[as.integer(dt1$NAVFTSP29) ]
if (class(dt1$NAVFTSP29)=="character") dt1$NAVFTSP29 <-as.numeric(dt1$NAVFTSP29)
if (class(dt1$NAVGREGRE)=="factor") dt1$NAVGREGRE <-as.numeric(levels(dt1$NAVGREGRE))[as.integer(dt1$NAVGREGRE) ]
if (class(dt1$NAVGREGRE)=="character") dt1$NAVGREGRE <-as.numeric(dt1$NAVGREGRE)
if (class(dt1$NAVRADRAD)=="factor") dt1$NAVRADRAD <-as.numeric(levels(dt1$NAVRADRAD))[as.integer(dt1$NAVRADRAD) ]
if (class(dt1$NAVRADRAD)=="character") dt1$NAVRADRAD <-as.numeric(dt1$NAVRADRAD)
if (class(dt1$NAVRAFRAF)=="factor") dt1$NAVRAFRAF <-as.numeric(levels(dt1$NAVRAFRAF))[as.integer(dt1$NAVRAFRAF) ]
if (class(dt1$NAVRAFRAF)=="character") dt1$NAVRAFRAF <-as.numeric(dt1$NAVRAFRAF)
if (class(dt1$NAVSAISAI)=="factor") dt1$NAVSAISAI <-as.numeric(levels(dt1$NAVSAISAI))[as.integer(dt1$NAVSAISAI) ]
if (class(dt1$NAVSAISAI)=="character") dt1$NAVSAISAI <-as.numeric(dt1$NAVSAISAI)
if (class(dt1$NAVSALSAL)=="factor") dt1$NAVSALSAL <-as.numeric(levels(dt1$NAVSALSAL))[as.integer(dt1$NAVSALSAL) ]
if (class(dt1$NAVSALSAL)=="character") dt1$NAVSALSAL <-as.numeric(dt1$NAVSALSAL)
if (class(dt1$NAVSJSP01)=="factor") dt1$NAVSJSP01 <-as.numeric(levels(dt1$NAVSJSP01))[as.integer(dt1$NAVSJSP01) ]
if (class(dt1$NAVSJSP01)=="character") dt1$NAVSJSP01 <-as.numeric(dt1$NAVSJSP01)
if (class(dt1$NAVSLSP01)=="factor") dt1$NAVSLSP01 <-as.numeric(levels(dt1$NAVSLSP01))[as.integer(dt1$NAVSLSP01) ]
if (class(dt1$NAVSLSP01)=="character") dt1$NAVSLSP01 <-as.numeric(dt1$NAVSLSP01)
if (class(dt1$NAVSLSP04)=="factor") dt1$NAVSLSP04 <-as.numeric(levels(dt1$NAVSLSP04))[as.integer(dt1$NAVSLSP04) ]
if (class(dt1$NAVSLSP04)=="character") dt1$NAVSLSP04 <-as.numeric(dt1$NAVSLSP04)
if (class(dt1$NAVSPPSPP)=="factor") dt1$NAVSPPSPP <-as.numeric(levels(dt1$NAVSPPSPP))[as.integer(dt1$NAVSPPSPP) ]
if (class(dt1$NAVSPPSPP)=="character") dt1$NAVSPPSPP <-as.numeric(dt1$NAVSPPSPP)
if (class(dt1$NAVTENTEN)=="factor") dt1$NAVTENTEN <-as.numeric(levels(dt1$NAVTENTEN))[as.integer(dt1$NAVTENTEN) ]
if (class(dt1$NAVTENTEN)=="character") dt1$NAVTENTEN <-as.numeric(dt1$NAVTENTEN)
if (class(dt1$NCYPUSPUS)=="factor") dt1$NCYPUSPUS <-as.numeric(levels(dt1$NCYPUSPUS))[as.integer(dt1$NCYPUSPUS) ]
if (class(dt1$NCYPUSPUS)=="character") dt1$NCYPUSPUS <-as.numeric(dt1$NCYPUSPUS)
if (class(dt1$NEIAMPAMP)=="factor") dt1$NEIAMPAMP <-as.numeric(levels(dt1$NEIAMPAMP))[as.integer(dt1$NEIAMPAMP) ]
if (class(dt1$NEIAMPAMP)=="character") dt1$NEIAMPAMP <-as.numeric(dt1$NEIAMPAMP)
if (class(dt1$NEISPPSPP)=="factor") dt1$NEISPPSPP <-as.numeric(levels(dt1$NEISPPSPP))[as.integer(dt1$NEISPPSPP) ]
if (class(dt1$NEISPPSPP)=="character") dt1$NEISPPSPP <-as.numeric(dt1$NEISPPSPP)
if (class(dt1$NFRKRUKRU)=="factor") dt1$NFRKRUKRU <-as.numeric(levels(dt1$NFRKRUKRU))[as.integer(dt1$NFRKRUKRU) ]
if (class(dt1$NFRKRUKRU)=="character") dt1$NFRKRUKRU <-as.numeric(dt1$NFRKRUKRU)
if (class(dt1$NITACDACD)=="factor") dt1$NITACDACD <-as.numeric(levels(dt1$NITACDACD))[as.integer(dt1$NITACDACD) ]
if (class(dt1$NITACDACD)=="character") dt1$NITACDACD <-as.numeric(dt1$NITACDACD)
if (class(dt1$NITACIACI)=="factor") dt1$NITACIACI <-as.numeric(levels(dt1$NITACIACI))[as.integer(dt1$NITACIACI) ]
if (class(dt1$NITACIACI)=="character") dt1$NITACIACI <-as.numeric(dt1$NITACIACI)
if (class(dt1$NITAMPAMP)=="factor") dt1$NITAMPAMP <-as.numeric(levels(dt1$NITAMPAMP))[as.integer(dt1$NITAMPAMP) ]
if (class(dt1$NITAMPAMP)=="character") dt1$NITAMPAMP <-as.numeric(dt1$NITAMPAMP)
if (class(dt1$NITAMPFRA)=="factor") dt1$NITAMPFRA <-as.numeric(levels(dt1$NITAMPFRA))[as.integer(dt1$NITAMPFRA) ]
if (class(dt1$NITAMPFRA)=="character") dt1$NITAMPFRA <-as.numeric(dt1$NITAMPFRA)
if (class(dt1$NITCAPCAP)=="factor") dt1$NITCAPCAP <-as.numeric(levels(dt1$NITCAPCAP))[as.integer(dt1$NITCAPCAP) ]
if (class(dt1$NITCAPCAP)=="character") dt1$NITCAPCAP <-as.numeric(dt1$NITCAPCAP)
if (class(dt1$NITCAPTEN)=="factor") dt1$NITCAPTEN <-as.numeric(levels(dt1$NITCAPTEN))[as.integer(dt1$NITCAPTEN) ]
if (class(dt1$NITCAPTEN)=="character") dt1$NITCAPTEN <-as.numeric(dt1$NITCAPTEN)
if (class(dt1$NITCFSEMI)=="factor") dt1$NITCFSEMI <-as.numeric(levels(dt1$NITCFSEMI))[as.integer(dt1$NITCFSEMI) ]
if (class(dt1$NITCFSEMI)=="character") dt1$NITCFSEMI <-as.numeric(dt1$NITCFSEMI)
if (class(dt1$NITFILFIL)=="factor") dt1$NITFILFIL <-as.numeric(levels(dt1$NITFILFIL))[as.integer(dt1$NITFILFIL) ]
if (class(dt1$NITFILFIL)=="character") dt1$NITFILFIL <-as.numeric(dt1$NITFILFIL)
if (class(dt1$NITFONFON)=="factor") dt1$NITFONFON <-as.numeric(levels(dt1$NITFONFON))[as.integer(dt1$NITFONFON) ]
if (class(dt1$NITFONFON)=="character") dt1$NITFONFON <-as.numeric(dt1$NITFONFON)
if (class(dt1$NITFTSP01)=="factor") dt1$NITFTSP01 <-as.numeric(levels(dt1$NITFTSP01))[as.integer(dt1$NITFTSP01) ]
if (class(dt1$NITFTSP01)=="character") dt1$NITFTSP01 <-as.numeric(dt1$NITFTSP01)
if (class(dt1$NITFTSP02)=="factor") dt1$NITFTSP02 <-as.numeric(levels(dt1$NITFTSP02))[as.integer(dt1$NITFTSP02) ]
if (class(dt1$NITFTSP02)=="character") dt1$NITFTSP02 <-as.numeric(dt1$NITFTSP02)
if (class(dt1$NITFTSP04)=="factor") dt1$NITFTSP04 <-as.numeric(levels(dt1$NITFTSP04))[as.integer(dt1$NITFTSP04) ]
if (class(dt1$NITFTSP04)=="character") dt1$NITFTSP04 <-as.numeric(dt1$NITFTSP04)
if (class(dt1$NITFTSP06)=="factor") dt1$NITFTSP06 <-as.numeric(levels(dt1$NITFTSP06))[as.integer(dt1$NITFTSP06) ]
if (class(dt1$NITFTSP06)=="character") dt1$NITFTSP06 <-as.numeric(dt1$NITFTSP06)
if (class(dt1$NITFTSP08)=="factor") dt1$NITFTSP08 <-as.numeric(levels(dt1$NITFTSP08))[as.integer(dt1$NITFTSP08) ]
if (class(dt1$NITFTSP08)=="character") dt1$NITFTSP08 <-as.numeric(dt1$NITFTSP08)
if (class(dt1$NITFTSP09)=="factor") dt1$NITFTSP09 <-as.numeric(levels(dt1$NITFTSP09))[as.integer(dt1$NITFTSP09) ]
if (class(dt1$NITFTSP09)=="character") dt1$NITFTSP09 <-as.numeric(dt1$NITFTSP09)
if (class(dt1$NITFTSP14)=="factor") dt1$NITFTSP14 <-as.numeric(levels(dt1$NITFTSP14))[as.integer(dt1$NITFTSP14) ]
if (class(dt1$NITFTSP14)=="character") dt1$NITFTSP14 <-as.numeric(dt1$NITFTSP14)
if (class(dt1$NITFTSP15)=="factor") dt1$NITFTSP15 <-as.numeric(levels(dt1$NITFTSP15))[as.integer(dt1$NITFTSP15) ]
if (class(dt1$NITFTSP15)=="character") dt1$NITFTSP15 <-as.numeric(dt1$NITFTSP15)
if (class(dt1$NITFTSP16)=="factor") dt1$NITFTSP16 <-as.numeric(levels(dt1$NITFTSP16))[as.integer(dt1$NITFTSP16) ]
if (class(dt1$NITFTSP16)=="character") dt1$NITFTSP16 <-as.numeric(dt1$NITFTSP16)
if (class(dt1$NITFTSP17)=="factor") dt1$NITFTSP17 <-as.numeric(levels(dt1$NITFTSP17))[as.integer(dt1$NITFTSP17) ]
if (class(dt1$NITFTSP17)=="character") dt1$NITFTSP17 <-as.numeric(dt1$NITFTSP17)
if (class(dt1$NITFTSP18)=="factor") dt1$NITFTSP18 <-as.numeric(levels(dt1$NITFTSP18))[as.integer(dt1$NITFTSP18) ]
if (class(dt1$NITFTSP18)=="character") dt1$NITFTSP18 <-as.numeric(dt1$NITFTSP18)
if (class(dt1$NITFTSP19)=="factor") dt1$NITFTSP19 <-as.numeric(levels(dt1$NITFTSP19))[as.integer(dt1$NITFTSP19) ]
if (class(dt1$NITFTSP19)=="character") dt1$NITFTSP19 <-as.numeric(dt1$NITFTSP19)
if (class(dt1$NITFTSP24)=="factor") dt1$NITFTSP24 <-as.numeric(levels(dt1$NITFTSP24))[as.integer(dt1$NITFTSP24) ]
if (class(dt1$NITFTSP24)=="character") dt1$NITFTSP24 <-as.numeric(dt1$NITFTSP24)
if (class(dt1$NITFTSP25)=="factor") dt1$NITFTSP25 <-as.numeric(levels(dt1$NITFTSP25))[as.integer(dt1$NITFTSP25) ]
if (class(dt1$NITFTSP25)=="character") dt1$NITFTSP25 <-as.numeric(dt1$NITFTSP25)
if (class(dt1$NITFTSP26)=="factor") dt1$NITFTSP26 <-as.numeric(levels(dt1$NITFTSP26))[as.integer(dt1$NITFTSP26) ]
if (class(dt1$NITFTSP26)=="character") dt1$NITFTSP26 <-as.numeric(dt1$NITFTSP26)
if (class(dt1$NITGRAGRA)=="factor") dt1$NITGRAGRA <-as.numeric(levels(dt1$NITGRAGRA))[as.integer(dt1$NITGRAGRA) ]
if (class(dt1$NITGRAGRA)=="character") dt1$NITGRAGRA <-as.numeric(dt1$NITGRAGRA)
if (class(dt1$NITINTINT)=="factor") dt1$NITINTINT <-as.numeric(levels(dt1$NITINTINT))[as.integer(dt1$NITINTINT) ]
if (class(dt1$NITINTINT)=="character") dt1$NITINTINT <-as.numeric(dt1$NITINTINT)
if (class(dt1$NITLACLAC)=="factor") dt1$NITLACLAC <-as.numeric(levels(dt1$NITLACLAC))[as.integer(dt1$NITLACLAC) ]
if (class(dt1$NITLACLAC)=="character") dt1$NITLACLAC <-as.numeric(dt1$NITLACLAC)
if (class(dt1$NITLIELIE)=="factor") dt1$NITLIELIE <-as.numeric(levels(dt1$NITLIELIE))[as.integer(dt1$NITLIELIE) ]
if (class(dt1$NITLIELIE)=="character") dt1$NITLIELIE <-as.numeric(dt1$NITLIELIE)
if (class(dt1$NITLINLIN)=="factor") dt1$NITLINLIN <-as.numeric(levels(dt1$NITLINLIN))[as.integer(dt1$NITLINLIN) ]
if (class(dt1$NITLINLIN)=="character") dt1$NITLINLIN <-as.numeric(dt1$NITLINLIN)
if (class(dt1$NITMICMIC)=="factor") dt1$NITMICMIC <-as.numeric(levels(dt1$NITMICMIC))[as.integer(dt1$NITMICMIC) ]
if (class(dt1$NITMICMIC)=="character") dt1$NITMICMIC <-as.numeric(dt1$NITMICMIC)
if (class(dt1$NITNANNAN)=="factor") dt1$NITNANNAN <-as.numeric(levels(dt1$NITNANNAN))[as.integer(dt1$NITNANNAN) ]
if (class(dt1$NITNANNAN)=="character") dt1$NITNANNAN <-as.numeric(dt1$NITNANNAN)
if (class(dt1$NITPALDEB)=="factor") dt1$NITPALDEB <-as.numeric(levels(dt1$NITPALDEB))[as.integer(dt1$NITPALDEB) ]
if (class(dt1$NITPALDEB)=="character") dt1$NITPALDEB <-as.numeric(dt1$NITPALDEB)
if (class(dt1$NITREVREV)=="factor") dt1$NITREVREV <-as.numeric(levels(dt1$NITREVREV))[as.integer(dt1$NITREVREV) ]
if (class(dt1$NITREVREV)=="character") dt1$NITREVREV <-as.numeric(dt1$NITREVREV)
if (class(dt1$NITSERSER)=="factor") dt1$NITSERSER <-as.numeric(levels(dt1$NITSERSER))[as.integer(dt1$NITSERSER) ]
if (class(dt1$NITSERSER)=="character") dt1$NITSERSER <-as.numeric(dt1$NITSERSER)
if (class(dt1$NITSIGSIG)=="factor") dt1$NITSIGSIG <-as.numeric(levels(dt1$NITSIGSIG))[as.integer(dt1$NITSIGSIG) ]
if (class(dt1$NITSIGSIG)=="character") dt1$NITSIGSIG <-as.numeric(dt1$NITSIGSIG)
if (class(dt1$NITSPPSPP)=="factor") dt1$NITSPPSPP <-as.numeric(levels(dt1$NITSPPSPP))[as.integer(dt1$NITSPPSPP) ]
if (class(dt1$NITSPPSPP)=="character") dt1$NITSPPSPP <-as.numeric(dt1$NITSPPSPP)
if (class(dt1$NITSUBSUB)=="factor") dt1$NITSUBSUB <-as.numeric(levels(dt1$NITSUBSUB))[as.integer(dt1$NITSUBSUB) ]
if (class(dt1$NITSUBSUB)=="character") dt1$NITSUBSUB <-as.numeric(dt1$NITSUBSUB)
if (class(dt1$NITTERTER)=="factor") dt1$NITTERTER <-as.numeric(levels(dt1$NITTERTER))[as.integer(dt1$NITTERTER) ]
if (class(dt1$NITTERTER)=="character") dt1$NITTERTER <-as.numeric(dt1$NITTERTER)
if (class(dt1$NITTHEMIN)=="factor") dt1$NITTHEMIN <-as.numeric(levels(dt1$NITTHEMIN))[as.integer(dt1$NITTHEMIN) ]
if (class(dt1$NITTHEMIN)=="character") dt1$NITTHEMIN <-as.numeric(dt1$NITTHEMIN)
if (class(dt1$NITUMBUMB)=="factor") dt1$NITUMBUMB <-as.numeric(levels(dt1$NITUMBUMB))[as.integer(dt1$NITUMBUMB) ]
if (class(dt1$NITUMBUMB)=="character") dt1$NITUMBUMB <-as.numeric(dt1$NITUMBUMB)
if (class(dt1$OPEMARMAR)=="factor") dt1$OPEMARMAR <-as.numeric(levels(dt1$OPEMARMAR))[as.integer(dt1$OPEMARMAR) ]
if (class(dt1$OPEMARMAR)=="character") dt1$OPEMARMAR <-as.numeric(dt1$OPEMARMAR)
if (class(dt1$PARPANPAN)=="factor") dt1$PARPANPAN <-as.numeric(levels(dt1$PARPANPAN))[as.integer(dt1$PARPANPAN) ]
if (class(dt1$PARPANPAN)=="character") dt1$PARPANPAN <-as.numeric(dt1$PARPANPAN)
if (class(dt1$PAUTAETAE)=="factor") dt1$PAUTAETAE <-as.numeric(levels(dt1$PAUTAETAE))[as.integer(dt1$PAUTAETAE) ]
if (class(dt1$PAUTAETAE)=="character") dt1$PAUTAETAE <-as.numeric(dt1$PAUTAETAE)
if (class(dt1$PCKOCEOCE)=="factor") dt1$PCKOCEOCE <-as.numeric(levels(dt1$PCKOCEOCE))[as.integer(dt1$PCKOCEOCE) ]
if (class(dt1$PCKOCEOCE)=="character") dt1$PCKOCEOCE <-as.numeric(dt1$PCKOCEOCE)
if (class(dt1$PGTSPPSPP)=="factor") dt1$PGTSPPSPP <-as.numeric(levels(dt1$PGTSPPSPP))[as.integer(dt1$PGTSPPSPP) ]
if (class(dt1$PGTSPPSPP)=="character") dt1$PGTSPPSPP <-as.numeric(dt1$PGTSPPSPP)
if (class(dt1$PINACRACR)=="factor") dt1$PINACRACR <-as.numeric(levels(dt1$PINACRACR))[as.integer(dt1$PINACRACR) ]
if (class(dt1$PINACRACR)=="character") dt1$PINACRACR <-as.numeric(dt1$PINACRACR)
if (class(dt1$PINBRNBRN)=="factor") dt1$PINBRNBRN <-as.numeric(levels(dt1$PINBRNBRN))[as.integer(dt1$PINBRNBRN) ]
if (class(dt1$PINBRNBRN)=="character") dt1$PINBRNBRN <-as.numeric(dt1$PINBRNBRN)
if (class(dt1$PINCFFERR)=="factor") dt1$PINCFFERR <-as.numeric(levels(dt1$PINCFFERR))[as.integer(dt1$PINCFFERR) ]
if (class(dt1$PINCFFERR)=="character") dt1$PINCFFERR <-as.numeric(dt1$PINCFFERR)
if (class(dt1$PINFTSP01)=="factor") dt1$PINFTSP01 <-as.numeric(levels(dt1$PINFTSP01))[as.integer(dt1$PINFTSP01) ]
if (class(dt1$PINFTSP01)=="character") dt1$PINFTSP01 <-as.numeric(dt1$PINFTSP01)
if (class(dt1$PINFTSP10)=="factor") dt1$PINFTSP10 <-as.numeric(levels(dt1$PINFTSP10))[as.integer(dt1$PINFTSP10) ]
if (class(dt1$PINFTSP10)=="character") dt1$PINFTSP10 <-as.numeric(dt1$PINFTSP10)
if (class(dt1$PINFTSP11)=="factor") dt1$PINFTSP11 <-as.numeric(levels(dt1$PINFTSP11))[as.integer(dt1$PINFTSP11) ]
if (class(dt1$PINFTSP11)=="character") dt1$PINFTSP11 <-as.numeric(dt1$PINFTSP11)
if (class(dt1$PINFTSP13)=="factor") dt1$PINFTSP13 <-as.numeric(levels(dt1$PINFTSP13))[as.integer(dt1$PINFTSP13) ]
if (class(dt1$PINFTSP13)=="character") dt1$PINFTSP13 <-as.numeric(dt1$PINFTSP13)
if (class(dt1$PINFTSP14)=="factor") dt1$PINFTSP14 <-as.numeric(levels(dt1$PINFTSP14))[as.integer(dt1$PINFTSP14) ]
if (class(dt1$PINFTSP14)=="character") dt1$PINFTSP14 <-as.numeric(dt1$PINFTSP14)
if (class(dt1$PINFTSP15)=="factor") dt1$PINFTSP15 <-as.numeric(levels(dt1$PINFTSP15))[as.integer(dt1$PINFTSP15) ]
if (class(dt1$PINFTSP15)=="character") dt1$PINFTSP15 <-as.numeric(dt1$PINFTSP15)
if (class(dt1$PINFTSP16)=="factor") dt1$PINFTSP16 <-as.numeric(levels(dt1$PINFTSP16))[as.integer(dt1$PINFTSP16) ]
if (class(dt1$PINFTSP16)=="character") dt1$PINFTSP16 <-as.numeric(dt1$PINFTSP16)
if (class(dt1$PINFTSP17)=="factor") dt1$PINFTSP17 <-as.numeric(levels(dt1$PINFTSP17))[as.integer(dt1$PINFTSP17) ]
if (class(dt1$PINFTSP17)=="character") dt1$PINFTSP17 <-as.numeric(dt1$PINFTSP17)
if (class(dt1$PINFTSP18)=="factor") dt1$PINFTSP18 <-as.numeric(levels(dt1$PINFTSP18))[as.integer(dt1$PINFTSP18) ]
if (class(dt1$PINFTSP18)=="character") dt1$PINFTSP18 <-as.numeric(dt1$PINFTSP18)
if (class(dt1$PINFTSP19)=="factor") dt1$PINFTSP19 <-as.numeric(levels(dt1$PINFTSP19))[as.integer(dt1$PINFTSP19) ]
if (class(dt1$PINFTSP19)=="character") dt1$PINFTSP19 <-as.numeric(dt1$PINFTSP19)
if (class(dt1$PINFTSP20)=="factor") dt1$PINFTSP20 <-as.numeric(levels(dt1$PINFTSP20))[as.integer(dt1$PINFTSP20) ]
if (class(dt1$PINFTSP20)=="character") dt1$PINFTSP20 <-as.numeric(dt1$PINFTSP20)
if (class(dt1$PINFTSP21)=="factor") dt1$PINFTSP21 <-as.numeric(levels(dt1$PINFTSP21))[as.integer(dt1$PINFTSP21) ]
if (class(dt1$PINFTSP21)=="character") dt1$PINFTSP21 <-as.numeric(dt1$PINFTSP21)
if (class(dt1$PINGIBGIB)=="factor") dt1$PINGIBGIB <-as.numeric(levels(dt1$PINGIBGIB))[as.integer(dt1$PINGIBGIB) ]
if (class(dt1$PINGIBGIB)=="character") dt1$PINGIBGIB <-as.numeric(dt1$PINGIBGIB)
if (class(dt1$PINGIFGIF)=="factor") dt1$PINGIFGIF <-as.numeric(levels(dt1$PINGIFGIF))[as.integer(dt1$PINGIFGIF) ]
if (class(dt1$PINGIFGIF)=="character") dt1$PINGIFGIF <-as.numeric(dt1$PINGIFGIF)
if (class(dt1$PININTINT)=="factor") dt1$PININTINT <-as.numeric(levels(dt1$PININTINT))[as.integer(dt1$PININTINT) ]
if (class(dt1$PININTINT)=="character") dt1$PININTINT <-as.numeric(dt1$PININTINT)
if (class(dt1$PINMAJMAJ)=="factor") dt1$PINMAJMAJ <-as.numeric(levels(dt1$PINMAJMAJ))[as.integer(dt1$PINMAJMAJ) ]
if (class(dt1$PINMAJMAJ)=="character") dt1$PINMAJMAJ <-as.numeric(dt1$PINMAJMAJ)
if (class(dt1$PINMEDMED)=="factor") dt1$PINMEDMED <-as.numeric(levels(dt1$PINMEDMED))[as.integer(dt1$PINMEDMED) ]
if (class(dt1$PINMEDMED)=="character") dt1$PINMEDMED <-as.numeric(dt1$PINMEDMED)
if (class(dt1$PINMICMIC)=="factor") dt1$PINMICMIC <-as.numeric(levels(dt1$PINMICMIC))[as.integer(dt1$PINMICMIC) ]
if (class(dt1$PINMICMIC)=="character") dt1$PINMICMIC <-as.numeric(dt1$PINMICMIC)
if (class(dt1$PINNANNAN)=="factor") dt1$PINNANNAN <-as.numeric(levels(dt1$PINNANNAN))[as.integer(dt1$PINNANNAN) ]
if (class(dt1$PINNANNAN)=="character") dt1$PINNANNAN <-as.numeric(dt1$PINNANNAN)
if (class(dt1$PINPULPUL)=="factor") dt1$PINPULPUL <-as.numeric(levels(dt1$PINPULPUL))[as.integer(dt1$PINPULPUL) ]
if (class(dt1$PINPULPUL)=="character") dt1$PINPULPUL <-as.numeric(dt1$PINPULPUL)
if (class(dt1$PINRUTRUT)=="factor") dt1$PINRUTRUT <-as.numeric(levels(dt1$PINRUTRUT))[as.integer(dt1$PINRUTRUT) ]
if (class(dt1$PINRUTRUT)=="character") dt1$PINRUTRUT <-as.numeric(dt1$PINRUTRUT)
if (class(dt1$PINSCHSCH)=="factor") dt1$PINSCHSCH <-as.numeric(levels(dt1$PINSCHSCH))[as.integer(dt1$PINSCHSCH) ]
if (class(dt1$PINSCHSCH)=="character") dt1$PINSCHSCH <-as.numeric(dt1$PINSCHSCH)
if (class(dt1$PINSLSP01)=="factor") dt1$PINSLSP01 <-as.numeric(levels(dt1$PINSLSP01))[as.integer(dt1$PINSLSP01) ]
if (class(dt1$PINSLSP01)=="character") dt1$PINSLSP01 <-as.numeric(dt1$PINSLSP01)
if (class(dt1$PINSLSP02)=="factor") dt1$PINSLSP02 <-as.numeric(levels(dt1$PINSLSP02))[as.integer(dt1$PINSLSP02) ]
if (class(dt1$PINSLSP02)=="character") dt1$PINSLSP02 <-as.numeric(dt1$PINSLSP02)
if (class(dt1$PINSPPSPP)=="factor") dt1$PINSPPSPP <-as.numeric(levels(dt1$PINSPPSPP))[as.integer(dt1$PINSPPSPP) ]
if (class(dt1$PINSPPSPP)=="character") dt1$PINSPPSPP <-as.numeric(dt1$PINSPPSPP)
if (class(dt1$PINSTOSTO)=="factor") dt1$PINSTOSTO <-as.numeric(levels(dt1$PINSTOSTO))[as.integer(dt1$PINSTOSTO) ]
if (class(dt1$PINSTOSTO)=="character") dt1$PINSTOSTO <-as.numeric(dt1$PINSTOSTO)
if (class(dt1$PINSTRSTR)=="factor") dt1$PINSTRSTR <-as.numeric(levels(dt1$PINSTRSTR))[as.integer(dt1$PINSTRSTR) ]
if (class(dt1$PINSTRSTR)=="character") dt1$PINSTRSTR <-as.numeric(dt1$PINSTRSTR)
if (class(dt1$PINSUBUND)=="factor") dt1$PINSUBUND <-as.numeric(levels(dt1$PINSUBUND))[as.integer(dt1$PINSUBUND) ]
if (class(dt1$PINSUBUND)=="character") dt1$PINSUBUND <-as.numeric(dt1$PINSUBUND)
if (class(dt1$PINSUISUI)=="factor") dt1$PINSUISUI <-as.numeric(levels(dt1$PINSUISUI))[as.integer(dt1$PINSUISUI) ]
if (class(dt1$PINSUISUI)=="character") dt1$PINSUISUI <-as.numeric(dt1$PINSUISUI)
if (class(dt1$PINVIRVIR)=="factor") dt1$PINVIRVIR <-as.numeric(levels(dt1$PINVIRVIR))[as.integer(dt1$PINVIRVIR) ]
if (class(dt1$PINVIRVIR)=="character") dt1$PINVIRVIR <-as.numeric(dt1$PINVIRVIR)
if (class(dt1$PLACFDELI)=="factor") dt1$PLACFDELI <-as.numeric(levels(dt1$PLACFDELI))[as.integer(dt1$PLACFDELI) ]
if (class(dt1$PLACFDELI)=="character") dt1$PLACFDELI <-as.numeric(dt1$PLACFDELI)
if (class(dt1$PLACFENGE)=="factor") dt1$PLACFENGE <-as.numeric(levels(dt1$PLACFENGE))[as.integer(dt1$PLACFENGE) ]
if (class(dt1$PLACFENGE)=="character") dt1$PLACFENGE <-as.numeric(dt1$PLACFENGE)
if (class(dt1$PLACFHAUC)=="factor") dt1$PLACFHAUC <-as.numeric(levels(dt1$PLACFHAUC))[as.integer(dt1$PLACFHAUC) ]
if (class(dt1$PLACFHAUC)=="character") dt1$PLACFHAUC <-as.numeric(dt1$PLACFHAUC)
if (class(dt1$PLACFSEPT)=="factor") dt1$PLACFSEPT <-as.numeric(levels(dt1$PLACFSEPT))[as.integer(dt1$PLACFSEPT) ]
if (class(dt1$PLACFSEPT)=="character") dt1$PLACFSEPT <-as.numeric(dt1$PLACFSEPT)
if (class(dt1$PLADUBDUB)=="factor") dt1$PLADUBDUB <-as.numeric(levels(dt1$PLADUBDUB))[as.integer(dt1$PLADUBDUB) ]
if (class(dt1$PLADUBDUB)=="character") dt1$PLADUBDUB <-as.numeric(dt1$PLADUBDUB)
if (class(dt1$PLALANLAN)=="factor") dt1$PLALANLAN <-as.numeric(levels(dt1$PLALANLAN))[as.integer(dt1$PLALANLAN) ]
if (class(dt1$PLALANLAN)=="character") dt1$PLALANLAN <-as.numeric(dt1$PLALANLAN)
if (class(dt1$PLAROSROS)=="factor") dt1$PLAROSROS <-as.numeric(levels(dt1$PLAROSROS))[as.integer(dt1$PLAROSROS) ]
if (class(dt1$PLAROSROS)=="character") dt1$PLAROSROS <-as.numeric(dt1$PLAROSROS)
if (class(dt1$PLCCONCON)=="factor") dt1$PLCCONCON <-as.numeric(levels(dt1$PLCCONCON))[as.integer(dt1$PLCCONCON) ]
if (class(dt1$PLCCONCON)=="character") dt1$PLCCONCON <-as.numeric(dt1$PLCCONCON)
if (class(dt1$PLESALSAL)=="factor") dt1$PLESALSAL <-as.numeric(levels(dt1$PLESALSAL))[as.integer(dt1$PLESALSAL) ]
if (class(dt1$PLESALSAL)=="character") dt1$PLESALSAL <-as.numeric(dt1$PLESALSAL)
if (class(dt1$PLGSIMSIM)=="factor") dt1$PLGSIMSIM <-as.numeric(levels(dt1$PLGSIMSIM))[as.integer(dt1$PLGSIMSIM) ]
if (class(dt1$PLGSIMSIM)=="character") dt1$PLGSIMSIM <-as.numeric(dt1$PLGSIMSIM)
if (class(dt1$PSMGRIGRI)=="factor") dt1$PSMGRIGRI <-as.numeric(levels(dt1$PSMGRIGRI))[as.integer(dt1$PSMGRIGRI) ]
if (class(dt1$PSMGRIGRI)=="character") dt1$PSMGRIGRI <-as.numeric(dt1$PSMGRIGRI)
if (class(dt1$PSSGEOGEO)=="factor") dt1$PSSGEOGEO <-as.numeric(levels(dt1$PSSGEOGEO))[as.integer(dt1$PSSGEOGEO) ]
if (class(dt1$PSSGEOGEO)=="character") dt1$PSSGEOGEO <-as.numeric(dt1$PSSGEOGEO)
if (class(dt1$PSTBREBRE)=="factor") dt1$PSTBREBRE <-as.numeric(levels(dt1$PSTBREBRE))[as.integer(dt1$PSTBREBRE) ]
if (class(dt1$PSTBREBRE)=="character") dt1$PSTBREBRE <-as.numeric(dt1$PSTBREBRE)
if (class(dt1$PSTCRUCRU)=="factor") dt1$PSTCRUCRU <-as.numeric(levels(dt1$PSTCRUCRU))[as.integer(dt1$PSTCRUCRU) ]
if (class(dt1$PSTCRUCRU)=="character") dt1$PSTCRUCRU <-as.numeric(dt1$PSTCRUCRU)
if (class(dt1$PSTPARPAR)=="factor") dt1$PSTPARPAR <-as.numeric(levels(dt1$PSTPARPAR))[as.integer(dt1$PSTPARPAR) ]
if (class(dt1$PSTPARPAR)=="character") dt1$PSTPARPAR <-as.numeric(dt1$PSTPARPAR)
if (class(dt1$RHOACUACU)=="factor") dt1$RHOACUACU <-as.numeric(levels(dt1$RHOACUACU))[as.integer(dt1$RHOACUACU) ]
if (class(dt1$RHOACUACU)=="character") dt1$RHOACUACU <-as.numeric(dt1$RHOACUACU)
if (class(dt1$RHOBREBRE)=="factor") dt1$RHOBREBRE <-as.numeric(levels(dt1$RHOBREBRE))[as.integer(dt1$RHOBREBRE) ]
if (class(dt1$RHOBREBRE)=="character") dt1$RHOBREBRE <-as.numeric(dt1$RHOBREBRE)
if (class(dt1$RHOCFMUSC)=="factor") dt1$RHOCFMUSC <-as.numeric(levels(dt1$RHOCFMUSC))[as.integer(dt1$RHOCFMUSC) ]
if (class(dt1$RHOCFMUSC)=="character") dt1$RHOCFMUSC <-as.numeric(dt1$RHOCFMUSC)
if (class(dt1$RHOGIRVAN)=="factor") dt1$RHOGIRVAN <-as.numeric(levels(dt1$RHOGIRVAN))[as.integer(dt1$RHOGIRVAN) ]
if (class(dt1$RHOGIRVAN)=="character") dt1$RHOGIRVAN <-as.numeric(dt1$RHOGIRVAN)
if (class(dt1$RHOSPPSPP)=="factor") dt1$RHOSPPSPP <-as.numeric(levels(dt1$RHOSPPSPP))[as.integer(dt1$RHOSPPSPP) ]
if (class(dt1$RHOSPPSPP)=="character") dt1$RHOSPPSPP <-as.numeric(dt1$RHOSPPSPP)
if (class(dt1$SELLAELAE)=="factor") dt1$SELLAELAE <-as.numeric(levels(dt1$SELLAELAE))[as.integer(dt1$SELLAELAE) ]
if (class(dt1$SELLAELAE)=="character") dt1$SELLAELAE <-as.numeric(dt1$SELLAELAE)
if (class(dt1$SELLATLAT)=="factor") dt1$SELLATLAT <-as.numeric(levels(dt1$SELLATLAT))[as.integer(dt1$SELLATLAT) ]
if (class(dt1$SELLATLAT)=="character") dt1$SELLATLAT <-as.numeric(dt1$SELLATLAT)
if (class(dt1$SELPUPPUP)=="factor") dt1$SELPUPPUP <-as.numeric(levels(dt1$SELPUPPUP))[as.integer(dt1$SELPUPPUP) ]
if (class(dt1$SELPUPPUP)=="character") dt1$SELPUPPUP <-as.numeric(dt1$SELPUPPUP)
if (class(dt1$SELRECREC)=="factor") dt1$SELRECREC <-as.numeric(levels(dt1$SELRECREC))[as.integer(dt1$SELRECREC) ]
if (class(dt1$SELRECREC)=="character") dt1$SELRECREC <-as.numeric(dt1$SELRECREC)
if (class(dt1$SELSEMSEM)=="factor") dt1$SELSEMSEM <-as.numeric(levels(dt1$SELSEMSEM))[as.integer(dt1$SELSEMSEM) ]
if (class(dt1$SELSEMSEM)=="character") dt1$SELSEMSEM <-as.numeric(dt1$SELSEMSEM)
if (class(dt1$SELSLSP01)=="factor") dt1$SELSLSP01 <-as.numeric(levels(dt1$SELSLSP01))[as.integer(dt1$SELSLSP01) ]
if (class(dt1$SELSLSP01)=="character") dt1$SELSLSP01 <-as.numeric(dt1$SELSLSP01)
if (class(dt1$SELSPPSPP)=="factor") dt1$SELSPPSPP <-as.numeric(levels(dt1$SELSPPSPP))[as.integer(dt1$SELSPPSPP) ]
if (class(dt1$SELSPPSPP)=="character") dt1$SELSPPSPP <-as.numeric(dt1$SELSPPSPP)
if (class(dt1$SELSTRSTR)=="factor") dt1$SELSTRSTR <-as.numeric(levels(dt1$SELSTRSTR))[as.integer(dt1$SELSTRSTR) ]
if (class(dt1$SELSTRSTR)=="character") dt1$SELSTRSTR <-as.numeric(dt1$SELSTRSTR)
if (class(dt1$SEMEULEUL)=="factor") dt1$SEMEULEUL <-as.numeric(levels(dt1$SEMEULEUL))[as.integer(dt1$SEMEULEUL) ]
if (class(dt1$SEMEULEUL)=="character") dt1$SEMEULEUL <-as.numeric(dt1$SEMEULEUL)
if (class(dt1$SEMROBROB)=="factor") dt1$SEMROBROB <-as.numeric(levels(dt1$SEMROBROB))[as.integer(dt1$SEMROBROB) ]
if (class(dt1$SEMROBROB)=="character") dt1$SEMROBROB <-as.numeric(dt1$SEMROBROB)
if (class(dt1$SEMSPPSPP)=="factor") dt1$SEMSPPSPP <-as.numeric(levels(dt1$SEMSPPSPP))[as.integer(dt1$SEMSPPSPP) ]
if (class(dt1$SEMSPPSPP)=="character") dt1$SEMSPPSPP <-as.numeric(dt1$SEMSPPSPP)
if (class(dt1$SEMSTRSTR)=="factor") dt1$SEMSTRSTR <-as.numeric(levels(dt1$SEMSTRSTR))[as.integer(dt1$SEMSTRSTR) ]
if (class(dt1$SEMSTRSTR)=="character") dt1$SEMSTRSTR <-as.numeric(dt1$SEMSTRSTR)
if (class(dt1$SKAOESOES)=="factor") dt1$SKAOESOES <-as.numeric(levels(dt1$SKAOESOES))[as.integer(dt1$SKAOESOES) ]
if (class(dt1$SKAOESOES)=="character") dt1$SKAOESOES <-as.numeric(dt1$SKAOESOES)
if (class(dt1$SPDMEDMED)=="factor") dt1$SPDMEDMED <-as.numeric(levels(dt1$SPDMEDMED))[as.integer(dt1$SPDMEDMED) ]
if (class(dt1$SPDMEDMED)=="character") dt1$SPDMEDMED <-as.numeric(dt1$SPDMEDMED)
if (class(dt1$SPDMINMIN)=="factor") dt1$SPDMINMIN <-as.numeric(levels(dt1$SPDMINMIN))[as.integer(dt1$SPDMINMIN) ]
if (class(dt1$SPDMINMIN)=="character") dt1$SPDMINMIN <-as.numeric(dt1$SPDMINMIN)
if (class(dt1$SPDSPPSPP)=="factor") dt1$SPDSPPSPP <-as.numeric(levels(dt1$SPDSPPSPP))[as.integer(dt1$SPDSPPSPP) ]
if (class(dt1$SPDSPPSPP)=="character") dt1$SPDSPPSPP <-as.numeric(dt1$SPDSPPSPP)
if (class(dt1$SRACONCON)=="factor") dt1$SRACONCON <-as.numeric(levels(dt1$SRACONCON))[as.integer(dt1$SRACONCON) ]
if (class(dt1$SRACONCON)=="character") dt1$SRACONCON <-as.numeric(dt1$SRACONCON)
if (class(dt1$SSRPINPIN)=="factor") dt1$SSRPINPIN <-as.numeric(levels(dt1$SSRPINPIN))[as.integer(dt1$SSRPINPIN) ]
if (class(dt1$SSRPINPIN)=="character") dt1$SSRPINPIN <-as.numeric(dt1$SSRPINPIN)
if (class(dt1$STAJAVJAV)=="factor") dt1$STAJAVJAV <-as.numeric(levels(dt1$STAJAVJAV))[as.integer(dt1$STAJAVJAV) ]
if (class(dt1$STAJAVJAV)=="character") dt1$STAJAVJAV <-as.numeric(dt1$STAJAVJAV)
if (class(dt1$STAKRIKRI)=="factor") dt1$STAKRIKRI <-as.numeric(levels(dt1$STAKRIKRI))[as.integer(dt1$STAKRIKRI) ]
if (class(dt1$STAKRIKRI)=="character") dt1$STAKRIKRI <-as.numeric(dt1$STAKRIKRI)
if (class(dt1$STAPHOPHO)=="factor") dt1$STAPHOPHO <-as.numeric(levels(dt1$STAPHOPHO))[as.integer(dt1$STAPHOPHO) ]
if (class(dt1$STAPHOPHO)=="character") dt1$STAPHOPHO <-as.numeric(dt1$STAPHOPHO)
if (class(dt1$STASPPSPP)=="factor") dt1$STASPPSPP <-as.numeric(levels(dt1$STASPPSPP))[as.integer(dt1$STASPPSPP) ]
if (class(dt1$STASPPSPP)=="character") dt1$STASPPSPP <-as.numeric(dt1$STASPPSPP)
if (class(dt1$SYNFILEXI)=="factor") dt1$SYNFILEXI <-as.numeric(levels(dt1$SYNFILEXI))[as.integer(dt1$SYNFILEXI) ]
if (class(dt1$SYNFILEXI)=="character") dt1$SYNFILEXI <-as.numeric(dt1$SYNFILEXI)
if (class(dt1$SYNSPPSPP)=="factor") dt1$SYNSPPSPP <-as.numeric(levels(dt1$SYNSPPSPP))[as.integer(dt1$SYNSPPSPP) ]
if (class(dt1$SYNSPPSPP)=="character") dt1$SYNSPPSPP <-as.numeric(dt1$SYNSPPSPP)
if (class(dt1$TABFASFAS)=="factor") dt1$TABFASFAS <-as.numeric(levels(dt1$TABFASFAS))[as.integer(dt1$TABFASFAS) ]
if (class(dt1$TABFASFAS)=="character") dt1$TABFASFAS <-as.numeric(dt1$TABFASFAS)
if (class(dt1$TERMUSMUS)=="factor") dt1$TERMUSMUS <-as.numeric(levels(dt1$TERMUSMUS))[as.integer(dt1$TERMUSMUS) ]
if (class(dt1$TERMUSMUS)=="character") dt1$TERMUSMUS <-as.numeric(dt1$TERMUSMUS)
if (class(dt1$THABRABRA)=="factor") dt1$THABRABRA <-as.numeric(levels(dt1$THABRABRA))[as.integer(dt1$THABRABRA) ]
if (class(dt1$THABRABRA)=="character") dt1$THABRABRA <-as.numeric(dt1$THABRABRA)
if (class(dt1$THAFTSP01)=="factor") dt1$THAFTSP01 <-as.numeric(levels(dt1$THAFTSP01))[as.integer(dt1$THAFTSP01) ]
if (class(dt1$THAFTSP01)=="character") dt1$THAFTSP01 <-as.numeric(dt1$THAFTSP01)
if (class(dt1$THALEPLEP)=="factor") dt1$THALEPLEP <-as.numeric(levels(dt1$THALEPLEP))[as.integer(dt1$THALEPLEP) ]
if (class(dt1$THALEPLEP)=="character") dt1$THALEPLEP <-as.numeric(dt1$THALEPLEP)
if (class(dt1$THASPPSPP)=="factor") dt1$THASPPSPP <-as.numeric(levels(dt1$THASPPSPP))[as.integer(dt1$THASPPSPP) ]
if (class(dt1$THASPPSPP)=="character") dt1$THASPPSPP <-as.numeric(dt1$THASPPSPP)
if (class(dt1$TRCRETRET)=="factor") dt1$TRCRETRET <-as.numeric(levels(dt1$TRCRETRET))[as.integer(dt1$TRCRETRET) ]
if (class(dt1$TRCRETRET)=="character") dt1$TRCRETRET <-as.numeric(dt1$TRCRETRET)
if (class(dt1$TRYSALSAL)=="factor") dt1$TRYSALSAL <-as.numeric(levels(dt1$TRYSALSAL))[as.integer(dt1$TRYSALSAL) ]
if (class(dt1$TRYSALSAL)=="character") dt1$TRYSALSAL <-as.numeric(dt1$TRYSALSAL)
if (class(dt1$TRYSCASCA)=="factor") dt1$TRYSCASCA <-as.numeric(levels(dt1$TRYSCASCA))[as.integer(dt1$TRYSCASCA) ]
if (class(dt1$TRYSCASCA)=="character") dt1$TRYSCASCA <-as.numeric(dt1$TRYSCASCA)
if (class(dt1$TTASULSUL)=="factor") dt1$TTASULSUL <-as.numeric(levels(dt1$TTASULSUL))[as.integer(dt1$TTASULSUL) ]
if (class(dt1$TTASULSUL)=="character") dt1$TTASULSUL <-as.numeric(dt1$TTASULSUL)
if (class(dt1$ULNACUACU)=="factor") dt1$ULNACUACU <-as.numeric(levels(dt1$ULNACUACU))[as.integer(dt1$ULNACUACU) ]
if (class(dt1$ULNACUACU)=="character") dt1$ULNACUACU <-as.numeric(dt1$ULNACUACU)
if (class(dt1$ULNAMPAMP)=="factor") dt1$ULNAMPAMP <-as.numeric(levels(dt1$ULNAMPAMP))[as.integer(dt1$ULNAMPAMP) ]
if (class(dt1$ULNAMPAMP)=="character") dt1$ULNAMPAMP <-as.numeric(dt1$ULNAMPAMP)
if (class(dt1$ULNDELDEL)=="factor") dt1$ULNDELDEL <-as.numeric(levels(dt1$ULNDELDEL))[as.integer(dt1$ULNDELDEL) ]
if (class(dt1$ULNDELDEL)=="character") dt1$ULNDELDEL <-as.numeric(dt1$ULNDELDEL)
if (class(dt1$ULNULNULN)=="factor") dt1$ULNULNULN <-as.numeric(levels(dt1$ULNULNULN))[as.integer(dt1$ULNULNULN) ]
if (class(dt1$ULNULNULN)=="character") dt1$ULNULNULN <-as.numeric(dt1$ULNULNULN)
if (class(dt1$UNKWNGIRD)=="factor") dt1$UNKWNGIRD <-as.numeric(levels(dt1$UNKWNGIRD))[as.integer(dt1$UNKWNGIRD) ]
if (class(dt1$UNKWNGIRD)=="character") dt1$UNKWNGIRD <-as.numeric(dt1$UNKWNGIRD)
if (class(dt1$UNKWNVALV)=="factor") dt1$UNKWNVALV <-as.numeric(levels(dt1$UNKWNVALV))[as.integer(dt1$UNKWNVALV) ]
if (class(dt1$UNKWNVALV)=="character") dt1$UNKWNVALV <-as.numeric(dt1$UNKWNVALV)

base::dir.create('data/raw data/gaiser_2021_diatoms/', showWarnings = FALSE)
base::saveRDS(object = rdata, file = 'data/raw data/gaiser_2021_diatoms/rdata.rds')
