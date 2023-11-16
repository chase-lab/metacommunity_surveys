# portal traps data

## Downloading portal data ----
base::dir.create(path = "data/cache/portal", showWarnings = FALSE)
portalr::download_observations(
   path = "data/cache/portal",
   version = "5.20.0", source = "github",
   force = FALSE, quiet = TRUE
)

## Loading portal data ----
rdata <- portalr::load_rodent_data(
   path = "data/cache/portal",
   download_if_missing = FALSE,
   clean = TRUE,
   quiet = FALSE)

## Extracting individual files from the list ----
trap <- rdata$rodent_data
data.table::setDT(trap)
trap[j = setdiff(x = colnames(trap),
                 y = c("plot", "stake",
                       "year", "month", "day", "species")) := NULL]
### Pooling and counting all individuals from a species/sample ----
trap <- trap[j = .(value = .N),
             keyby = .(plot, stake, year, month, day, species)]

taxo <- rdata$species_table
data.table::setDT(taxo)

effort <- rdata$trapping_table
data.table::setDT(effort)

treatments <- rdata$plots_table
data.table::setDT(treatments)

coordinates <- data.table::fread(
   file = "data/cache/portal/PortalData/SiteandMethods/Portal_UTMCoords.csv",
   select = c("plot", "east","north"), sep = ",", header = TRUE)
coordinates <- coordinates[i = plot != "weatherstation",
                           j = .(latitude = mean(north),
                                 longitude = mean(east)),
                           keyby = .(plot)][, plot := as.integer(plot)]
coords_sf <- sf::st_as_sf(x = coordinates,
                          coords = c('longitude', 'latitude'),
                          crs = sf::st_crs("EPSG:26913")) # NAD83 / UTM zone 13N
coords_sf <- sf::st_transform(x = coords_sf,
                              crs = sf::st_crs("EPSG:4326"))
coordinates[j = longitude := sf::st_coordinates(coords_sf)[, 1]]
coordinates[j = latitude  := sf::st_coordinates(coords_sf)[, 2]]

## Merging tables with data.table joins ----
trap[i = taxo,
     j = ":="(species = i.scientificname, taxon = i.taxa),
     on = .(species)]

trap[i = effort,
     j = ":="(effort = i.effort, sampled = i.sampled),
     on = .(plot, year, month, day)]

trap[i = treatments,
     j = treatment := i.treatment,
     on = .(plot, year, month)]

trap[i = coordinates,
     j = ":="(latitude = i.latitude, longitude = i.longitude),
     on = .(plot)]

## Saving data ----
base::dir.create(path = "data/raw data/portal_traps/", showWarnings = FALSE)
base::saveRDS(object = trap, file = "data/raw data/portal_traps/rdata.rds")
