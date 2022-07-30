# wardlaw_2013
dataset_id <- "wardlaw_2013"

###Data manually downloaded from:
### https://supersites.tern.org.au/knb/metacat/lloyd.502/html
###Login for tern.org.au  needed. Data accessible after login without further requests.


#loading data
datapath <- "./data/raw data/wardslaw_2013/lloyd.504.1-asn_wrra_fauna_birds_external_control_1998-2010.csv"
speciespath <- "./data/raw data/wardslaw_2013/lloyd.505.1-asn_wrra_fauna_birds_species_external_control_1998-2010.csv"

ddata <- data.table::fread(datapath)
speciesdata <- data.table::fread(speciespath)

#merge ddata and speciesnames
ddata <- speciesdata[ddata, on = "Acronym"]

#rename cols: 
data.table::setnames(ddata, c("Species binomial", "Pointcode", "Number recorded"), c("Species","Local", "Abundance"))
ddata[,month := stringi::stri_extract_first_regex(str = Date, pattern = "(?<=/)[0-9]{1,2}")]

#Normalization
#Subset data
ddata <- ddata[month == "11" | month == "10"]
ddata <- ddata[ ddata[, .(Date = sample(Date, 1L)), by = .(Local, Year)], on = c("Year","Date","Local")]

#Exclude double sampled per day:
ddata <- ddata[ddata[, .(`Time of day` = sample(`Time of day`, 1L)), by = .(month, Local, Year)], on = c("month", "Year", "Local", "Time of day")]
#Sum number of occurrences with different distance, height and direction
ddata <- ddata[, sum(Abundance), by = .(Species, Local, Year)]
# remove NA. NA present before and after merge: 
ddata <- na.omit(ddata, on = "Year")


ddata[, ":="(
dataset_id = dataset_id,
Regional = "Bird Track",

metric = "abundance",
unit = "count",

month = NULL,
Acronym = NULL,
"Common name" = NULL,
Family = NULL,
"RAOU number" = NULL,
Guild = NULL,
Recno = NULL,
Date = NULL,
Height = NULL,
Distance = NULL,
Direction = NULL,
"Time of day" = NULL,
Samplecode = NULL,
Incidence = NULL
)]

data.table::setnames(ddata, tolower(colnames(ddata)))


# meta ----
meta <- unique(ddata[, .(dataset_id, year, regional, local)])
meta[, ":="(
  realm = "Terrestrial",
  taxon = "Birds",

  latitude = "42°37′30.00″ N",
  longitude = "146°22′30.00″ E",
  
  study_type = "ecological sampling", #two possible values, or NA if not sure
  
  data_pooled_by_authors = FALSE,
  data_pooled_by_authors_comment = NA,
  sampling_years = NA,
  
  effort = 1L, #Five-minute counts of birds (seen or hear) observed during >5 separate visits made each year.
  

  alpha_grain = pi*25^2L,
  alpha_grain_unit = "m2", #"acres", "ha", "km2", "m2", "cm2"
  alpha_grain_type = "plot",
  alpha_grain_comment = "presence of a bird species within 25 m of a sample point was recorded at the 20 sample points along BirdTrack",
  
  gamma_bounding_box = 97L, #size of biggest common scale can be different values for different areas per region
  gamma_bounding_box_unit = "km2",
  gamma_bounding_box_type = "box",
  gamma_bounding_box_comment = "Length of Bird Track",
  
  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "transect",
  gamma_sum_grains_comment = "sampled area per year",
  
  comment = "Data manually downloaded via https://supersites.tern.org.au/knb/metacat/lloyd.502/html with login for tern.org.au. The authors sampled birds (seen or heard) during 5 minutes on 20 samplepoints located at 50-meter intervals along Bird Track. Bird Track spanns across Tasmania and is 97km long according to coordinates given at webpage. Records stem from annual visits made in 2004-2010.",
  comment_standardisation = "randomly selcted one date in october or november due to uneven amount of sampling events per year per site. Empty rows were deleted."
)][,
   gamma_sum_grains := sum(alpha_grain), by = year
]


dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)
