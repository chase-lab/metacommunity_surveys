dataset_id <- "jacinto_2022"

ddata <- base::readRDS(file = 'data/raw data/jacinto_2022/rdata.rds')

# pooling fish individuals to get abundances ----
ddata <- ddata[, .(value = .N), by = .(local = SiteID, year = Year, species = FishTypeID)]

# species codes and names ----
species_codes <- c("BBH", "BCR", "BGS", "BLP", "BRB",
                   "CCF", "CHN", "COT", "CRP", "FHM", "GLF", "GSF", "GSH", "ISS",
                   "LEP", "LMB", "MSQ", "PKM", "PLR", "PMK", "RBT", "RCH", "RES",
                   "RSH", "SAP", "SBF", "SBK", "SKR", "SMB", "SPB", "STB", "TUP",
                   "WCF", "WRM", "YFG")
species_names <- c(
   'Black bullhead', 'Black crappie', 'Bluegill', 'Big scale logperch', 'Brown bullhead',
   'Channel catfish', 'Chinook salmon', 'Prickly sculpin', 'Common carp', 'Fathead minnow', 'Goldfish', 'Green sunfish', 'Golden shiner', 'Inland silverside',
   'Sunfish hybrids', 'Largemouth bass', 'Western mosquitofish', 'Sacramento pikeminnow', 'Pacific lamprey', 'Pumpkinseed', 'Rainbow trout', 'California roach', 'Redear sunfish',
   'Red shiner', 'Sacramento perch', 'Sacramento blackfish', 'Three spine stickleback', 'Sacramento sucker', 'Smallmouth bass', 'Spotted bass', 'Striped bass', 'Sacramento tule perch',
   'White catfish', 'Warmouth', 'Yellowfin goby')

# site coordinates ----
coords <- data.frame(matrix(nrow = 6, ncol = 3, c(
   1,  38.49377591,  -121.99758384,
   3,  38.51926836,  -121.96755698,
   5,  38.53649869,  -121.85443701,
   6,  38.52124577,  -121.80472913,
   9,  38.51731116,  -121.75640946,
   10, 38.51876783,  -121.6923622
), dimnames = list(c(), c('local','latitude','longitude')), byrow = TRUE))

# community ----
ddata[, ":="(
   dataset_id = dataset_id,

   regional = "Lower Putah Creek",

   metric = "abundance",
   unit = "count",

   species = species_names[data.table::chmatch(species, species_codes)]
)]

# meta ----
meta <- unique(ddata[, .(dataset_id, year, regional, local)])
meta <- meta[coords, on = 'local']

meta[, ":="(
   realm = "Freshwater",
   taxon = "Fish",

   study_type = "ecological_sampling",

   data_pooled_by_authors = FALSE,

   effort = 1L,

   alpha_grain = NA,
   alpha_grain_unit = "m2",
   alpha_grain_type = "plot",
   alpha_grain_comment = "Electroshocking passes of equal effort by distance were conducted at each sample site across all years",

   gamma_bounding_box_unit = "m2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "area polygon of convex-hull",

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "plot",
   gamma_sum_grains_comment = "sampled area per year",

   comment = "Data extracted from Fish_Query_Clean_R_031120_CSV copy.csv found in the Zenodo repository Jacinto, Emily, Fangue, Nann A., Cocherell, Dennis E., Kiernan, Joseph, Moyle, Peter B., & Rypel, Andrew L. (2022). Increasing stability of a native freshwater fish assemblage following flow rehabilitation [Data set]. Zenodo. https://doi.org/10.5281/zenodo.7822308 associated to the article  Jacinto, Emily, Fangue, Nann A., Cocherell, Dennis E., Kiernan, Joseph D., Moyle, Peter B., and Rypel, Andrew L.. 2023. “ Increasing Stability of a Native Freshwater Fish Assemblage Following Flow Rehabilitation.” Ecological Applications e2868. https://doi.org/10.1002/eap.2868 . METHODS: 'Standardized tote barge electrofishing was used to capture and evaluate species presence and relative abundance (Reynolds & Kolz, 2012). During each sampling event, fish were collected via single-pass electrofishing.'",
   comment_standardisation = "Data provide one sample per site per year. Measured individuals were counted to get abundances.",
   doi = 'https://doi.org/10.1002/eap.2868 | https://doi.org/10.5281/zenodo.7822308'
)]

meta[, ":="(
   gamma_sum_grains = sum(alpha_grain),
   gamma_bounding_box = geosphere::areaPolygon(data.frame(longitude, latitude)[grDevices::chull(longitude, latitude), ]) / 10^6
), by = year]

# saving data ----
dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE)



