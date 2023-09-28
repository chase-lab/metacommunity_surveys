# gomez-gras_2021
dataset_id <- "gomez-gras_2021"

ddata <- base::readRDS("data/raw data/gomez-gras_2021/ddata.rds")

#Raw Data ---
data.table::setnames(ddata, 1L, "local")

##melting species ----
ddata <- data.table::melt(ddata,
                          id.vars = "local",
                          variable.name = "species")

##deleting absences ----
ddata <- ddata[value != 0]

##splitting year, local and plot
ddata[, c("year", "local", "habitat", "plot") := data.table::tstrsplit(local, split = "_")]
ddata[, habitat := c("cliff", "cave")[data.table::chmatch(habitat, c("par", "cor"))]
      ][, local := paste(local, habitat, plot, sep = "_")
        ][, habitat := NULL][, plot := NULL]

##community data ----
ddata[, ":="(
   dataset_id = dataset_id,

   regional = "Scandola Nature Reserve, France",

   metric = "cover",
   unit = "percent"
)]

##meta data ----
meta <- unique(ddata[, .(dataset_id, regional, local, year)])
meta[, ":="(
   taxon = "Invertebrates",
   realm = "Marine",

   latitude = "42°21'25''N",
   longitude = "8°34'0''E",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   alpha_grain = 0.25 * 0.25 * 24,
   alpha_grain_unit = "m2",
   alpha_grain_type = "sample",
   alpha_grain_comment = "24 25*25cm pictures per site",

   comment = "extracted from Dryad repository 10.5061/dryad.69p8cz91g Methods: 'We used coralligenous assemblage data from five sites located within two marine protected areas (MPAs) in the NW Mediterranean Sea: the Port-Cros National Park and Scandola Natural Reserve[...]To minimise any potential effect of seasonality, only surveys occurring during the same period of the year were considered for each site (end of summer vs. autumn for Port-Cros and Scandola respectively). A total of 24 photographic quadrats of 25 * 25 cm (replicates) were analysed for each site and temporal point resulting in 360 pictures in total. The sampling unit (625 cm2 per replicate) was selected following Kipson et al. (2011) and Casas-Guell et al. (2015). The percent cover of the different macro benthic sessile species was calculated in each quadrat by overimposing 100 stratified random points and identifying the underlying species to the lowest possible taxonomic level, using Photoquad photoquadrat' ",
   comment_standardisation = "absences deleted",
   doi = 'https://doi.org/10.5061/dryad.69p8cz91g'
)]

##save data ----
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

#standardised data ----
# community data ----
## deleting the site in Port-Cros since there is only one site in this region ----
ddata <- ddata[local != "Gabin_cliff"]
## percentage cover to presence-absence ----
ddata[,":="(
   value = 1L,
   metric = "pa",
   unit = "pa"
)]

##meta data ----
meta <- meta[unique(ddata[, .(local, year)]),
             on = .(local, year)]

meta[, ":="(
   effort = 1L,

   gamma_bounding_box = 10L,
   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "administrative",
   gamma_bounding_box_comment = "area of the Scandola Nature Reserve",

   gamma_sum_grains = 0.25 * 0.25 * 24 * 4,
   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of the sampled areas of the 4 sites",

   comment_standardisation = "Port-Cros site deleted because only one site in the region. Percentage cover to presence absence. Plots pooled together."
)]

## save data ----
data.table::fwrite(
   x = ddata,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised.csv"),
   row.names = FALSE
)
data.table::fwrite(
   x = meta,
   file = paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_standardised_metadata.csv"),
   row.names = FALSE
)
