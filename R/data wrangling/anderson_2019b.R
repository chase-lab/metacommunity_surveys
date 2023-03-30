# anderson_2019b - algae cover
dataset_id <- "anderson_2019b"

# no direct download link available, it is only behind a form.
ddata <- data.table::fread(
  file = "./data/raw data/anderson_2019/BMSC_Wizard_AlgalCover_1997-2009.tab",
  header = TRUE, sep = "\t", drop = "Bare rock"
)

data.table::setnames(ddata, 1L:4L, c("date", "regional", "exposure", "local"))


# melting species ----
for (i in 6L:ncol(ddata)) data.table::set(x = ddata, i = which(ddata[[i]] == 0L), i, NA_integer_)

ddata <- data.table::melt(ddata,
  id.vars = 1:5L,
  variable.name = "species",
  na.rm = TRUE
)

# standardisation ----
ddata[, date := as.Date(ddata$date, "%d-%b-%y")][, ":="(
  local = paste(local, exposure),
  year = format(date, "%Y")
)]

ddata <- ddata[`Tidal Height` %in% c(1, 1.5, 2, 2.5, 3)]
ddata[, effort := length(unique(`Tidal Height`)), by = .(regional, local, year)]
ddata <- unique(ddata[effort >= 5L][, .(value = sum(value)), by = .(regional, local, year, species)])


# community data ----
ddata[, ":="(
  dataset_id = dataset_id,

  value = 1L,
  metric = "pa",
  unit = "pa"
)]

# metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  taxon = "Marine plants",
  realm = "Marine",

  latitude = "48°51’29.5”N",
  longitude = "125°09’31”W",

  effort = 5L,

  study_type = "ecological_sampling",

  data_pooled_by_authors = FALSE,
  sampling_years = NA,

  alpha_grain = 25 * 25 * 5L,
  alpha_grain_unit = "cm2",
  alpha_grain_type = "plot",
  alpha_grain_comment = "sum of the areas of quadrats of each transect",

  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "sample",
  gamma_sum_grains_comment = "sum of the areas of quadrats of each island",

  gamma_bounding_box_unit = "ha",
  gamma_bounding_box_type = "island",
  gamma_bounding_box_comment = "area of the Wizard islet given by the authors",


  comment = "Data extracted from https://doi.org/10.5683/SP2/VBPBFN. Marine Plants data. 'In 1997 the Bamfield Marine Sciences Centre established a long-term monitoring project to collect baseline data on the distribution and abundance of macroorganisms at two intertidal sites on Wizard Islet in Barkley Sound. Both sites were resampled in 2001 and 2007, and the exposed site was resampled in 2002 and 2003. In 2009, both sites were sampled again, and a Microsoft Access database was created with comparable data from previous years (1997-2007). Data is presented here for algal cover (%), sessile invertebrate cover (%), invertebrate density, and sea star density for 2009 as well as the complete Microsoft Access database. Wizard Islet (48°51’29.5”N, 125°09’31”W) is located within the Deer Group Islands in Barkley Sound and has an area of 1.73 hectares at low tide. The sheltered site (with less wave exposure) is located on a 50m stretch of fixed rocky shore on the northeast side and is characterized by Fucus and Phyllospadix (seagrass). The exposed site is located on a 50m stretch of fixed rocky shore on the southwest side and is characterized by Egregia (feather-boa kelp), goose-necked barnacles and Alaria (brown alga). Fifteen transects were randomly selected at the sheltered site (tag numbers 7, 10, 11, 12, 15, 18, 21, 26, 34, 36, 38, 40, 42, 44, 48) and the exposed site (tag numbers 1, 3, 5, 11, 15, 17, 20, 23, 25, 32, 37, 40, 44, 46, 48). Sampling was done at tidal heights of 1, 1.5, 2, 2.5, 3 and 3.5m. In 2009 tidal height of 0.5m was not sampled due to time constraints and limited low tide series. Quadrats of 25x25cm were used for percent cover of bare rock, algae, colonial and encrusting species. Quadrats of 25x25cm were also used for counts of invertebrates with the exception of seastars which were counted in 50x50cm quadrats. To maintain consistency, all quadrats were positioned to the left and above each point on the transect (when facing away from the water).'  ",
  comment_standardisation = "Only the 5 middle tidal heights kept and only samples with all of these 5 tidal heights sampled kept. Samples from these 5 quadrats were then pooled together"
)][, gamma_sum_grains := sum(alpha_grain) / 10000L, by = .(regional, year)][regional == "Wizard", gamma_bounding_box := 1.73]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
  row.names = FALSE
)
