#willig_2010
dataset_id <- "willig_2010"

ddata <- data.table::fread(
  file = "./data/raw data/willig_2010/LFDPSnailCaptures.csv",
  sep = ",", header = TRUE, drop = c("UNKNOWN", "TOTABU", "COMMENTS")
)
data.table::setnames(ddata, tolower(colnames(ddata)))
data.table::setnames(ddata, "point", "local")

# melting species ----
for (i in 6L:ncol(ddata)) data.table::set(x = ddata, i = which(ddata[[i]] == 0L), i, NA_integer_)
ddata <- data.table::melt(ddata,
  id.vars = 1L:5L,
  variable.name = "species",
  na.rm = TRUE
)

# extracting month, year, day 
ddata[, formated_date := as.Date(x = date, format = "%m/%d/%Y")][, month := format(x = formated_date, format = "%m")][,day := format(x = formated_date, format = "%d" )]

# saving raw copy of ddata for standartisation
raw <- data.table::copy(ddata)


## community data ----
ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Luquillo Forest Dynamics Plot (LFDP)",
  
  metric = "abundance",
  unit = "count",
  run = NULL, 
  season = NULL,
  formated_date = NULL
)]

## metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
  taxon = "Invertebrates",
  realm = "Terrestrial",
  
  latitude = 18.3333,
  longitude = -65.8167,
  
  effort = 1L,
  
  study_type = "ecological_sampling",
  
  data_pooled_by_authors = FALSE,
  
  alpha_grain = pi * 3^2,
  alpha_grain_unit = "m2",
  alpha_grain_type = "plot",
  alpha_grain_comment = "circular quadrats",
  
  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "sample",
  gamma_sum_grains_comment = "sum of the areas of quadrats sampled each year",
  
  gamma_bounding_box = 16L,
  gamma_bounding_box_unit = "ha",
  gamma_bounding_box_type = "functional",
  gamma_bounding_box_comment = "area of the LFDP given by the authors",
  
  
  comment = "Extracted fron: https://doi.org/10.6073/pasta/45e3a90ed462f66acdde83636746f87f . 'One hundred sixty points were selected on the Hurricane Recovery Plot at El Verde. Circular quadrats (r = 3 m) were established at each point. From June 1991 to present, 40 points were sampled four times seasonally for the presence of Terrestrial snails[...]All surveys occurred between 19:30 and 03:00 hours to coincide with peak snail activity. Population densities were estimated as Minimum Number Known Alive (MNKA), the maximum number of individuals of each species recorded for a site in each season'",
  comment_standardisation = "None"
)][, gamma_sum_grains := sum(alpha_grain), by = year]

## saving data tables ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
                   row.names = FALSE
)


# Standardised Data ----

## selecting one sampling event per season, selecting two seasons ----
selecting_table <- unique(raw)
selecting_table <- selecting_table[!is.na(formated_date)]
selecting_table[, nseasons := length(unique(season)), by = .(year, local)]
selecting_table <- selecting_table[nseasons == 2L][, nseasons := NULL]
# for each season, keeping only one sampling event. From the most sampled months: March, or January, and July, June, August or May for the dry and wet seasons respectively.
selecting_table[, month_preference_order := c(1, 2, 1, 2, 3, 4)[match(month, c("03", "01", "07", "06", "08", "05"))]]
data.table::setorder(selecting_table, local, year, season, month_preference_order, formated_date)
selecting_table <- selecting_table[, .SD[1L], by = .(local, year, season)] # only the first event
ddata <- raw[selecting_table[, .(year, local, date)], on = .(year, local, date)]

##pooling seasons ----
ddata <- ddata[, .(value = sum(value)), by = .(year, local, species)] 

# community data ----
ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Luquillo Forest Dynamics Plot (LFDP)",

  metric = "abundance",
  unit = "count"
)]

## update meta ----
meta <- meta[unique(ddata[,.(dataset_id, regional, local, year)]), on = .(regional, local, year)]
meta[, ":=" (
  comment_standardisation = "Both seasons kept. For each season, keeping only one sampling event. From the most sampled months: March, or January, and July, June, August or May for the dry and wet seasons respectively. Then pooling both seasons together."
)][, gamma_sum_grains := sum(alpha_grain), by = year]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised.csv"),
  row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised_metadata.csv"),
  row.names = FALSE
)
