dataset_id <- "burlakova_2024"

ddata <- base::readRDS(file = 'data/raw data/burlakova_2024/rdata.rds')

# Raw data ----
## Replacing 0s ----
for (i in 8L:ncol(ddata)) data.table::set(x = ddata,
                                          i = which(ddata[, ..i] == 0),
                                          j = i,
                                          value = NA_real_)
## Melting species ----
ddata <- data.table::melt(ddata,
                 id.vars = c("Year", "Basin", "Station",
                             "Latitude_decimal", "Longitude_decimal"),
                 measure.vars = 8L:ncol(ddata),
                 variable.name = "species",
                 value.name = "value",
                 na.rm = TRUE)
data.table::setnames(ddata,
                     old = c("Year", "Basin", "Station",
                             "Latitude_decimal", "Longitude_decimal"),
                     new = c("year", "regional", "local",
                             "latitude", "longitude"))

## Community data ----
### Species names ----
taxo <- data.table::fread(file = "data/raw data/burlakova_2024/ErieBenthosTaxonomy.csv")
taxo[j = genus_species := stringi::stri_replace_first_fixed(str = Species,
                                                            pattern = Genus,
                                                            replacement = "$1 ") |>
        stringi::stri_replace_first_fixed(pattern = "$1",
                                          replacement = Genus)
        ][i = is.na(genus_species), j = genus_species := Species]
ddata[i = taxo,
      on = .(species = Species),
      j = species := i.genus_species]

### Units ----
ddata[, ":="(
   dataset_id = dataset_id,

   metric = "density",
   unit = "average individuals per square meter"
)]

### Samples with duplicate observations removed ----
ddata <- ddata[
   !ddata[, .N, by = .(regional, local, year, species)][N != 1],
   on = .(regional, local, year)]

## metadata ----
meta <- unique(ddata[, .(dataset_id, regional, local, year, latitude, longitude)])

meta[, ":="(
   taxon = "Invertebrates",
   realm = "Freshwater",

   study_type = "ecological_sampling",

   data_pooled_by_authors = TRUE,
   data_pooled_by_authors_comment = "Authors averaged an unknown number of replicates per station per year. Sampling_year = year.",
   sampling_years = year,

   alpha_grain = 1L,
   alpha_grain_unit = "m2",
   alpha_grain_type = "sample",
   alpha_grain_comment = "Real grain changes between campains but all densities are given in number of individuals per square meter.",

   comment = "Extracted from Burlakova et al 2024 Dryad repository Density data for Lake Erie benthic invertebrate assemblages from 1930 to 2019. The authors aggregated data from various benthic invertebrate sampling campains in Lake Erie. Sampling gear, methodology (e. g. number of replicates) and frequency varies between campains. Burlakova et al averaged abundances of collected species in a station in a year. Species: spaces were added between Genus and Species names, delete spaces if you want to match with the original names.
   Refer to the Dryad repository for complete and extensive documentation on each campaign: https://doi.org/10.5061/dryad.47d7wm3m0",

   doi = "https://doi.org/10.5061/dryad.47d7wm3m0 | https://doi.org/10.1016/j.jglr.2022.09.006"
)]

ddata[, c("latitude","longitude") := NULL]

## saving raw data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_raw_metadata.csv"),
   row.names = FALSE
)

# Standardised data ----
# Not standardisable
