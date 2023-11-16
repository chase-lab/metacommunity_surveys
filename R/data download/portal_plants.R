# portal plants data

## Downloading portal data ----
base::dir.create(path = "data/cache/portal", showWarnings = FALSE)
portalr::download_observations(
   path = "data/cache/portal",
   version = "5.20.0", source = "github",
   force = FALSE, quiet = TRUE
)

## Loading portal data ----
rdata <- portalr::load_plant_data(
   path = "data/cache/portal",
   download_if_missing = FALSE,
   quiet = FALSE)

## Extracting individual files from the list ----
plant <- rdata$quadrat_data
data.table::setDT(plant)
plant[j = c("cover", "cf", "notes") := NULL]

taxo <- rdata$species_table
data.table::setDT(taxo)
taxo[j = c("genus", "sp", "altspecies", "subspecies") := lapply(
      X = .SD,
      FUN = \(x) replace(x, is.na(x), "")),
   .SDcols = c("genus", "sp", "altspecies", "subspecies")]

taxo[, species_name := trimws(paste(genus, sp, altspecies, subspecies))]
taxo[
   i = genus == "Unknown" & grepl("annual forb|annual grass", sp),
   j = species_name := species]

effort <- rdata$census_table
data.table::setDT(effort)

treatments <- rdata$plots_table
data.table::setDT(treatments)

coordinates <- data.table::fread(
   file = "data/cache/portal/PortalData/SiteandMethods/Portal_UTMCoords.csv",
   select = c("plot", "east","north"), sep = ",", header = TRUE)
coordinates <- coordinates[plot != "weatherstation",
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
plant[i = taxo,
      j = species := i.species_name,
      on = .(species)]

plant[i = effort,
      j = ":="(alpha_grain = i.area, sampled = i.censused),
      on = .(plot, year, season)]

plant[i = treatments,
      j = treatment := i.treatment,
      on = .(plot, year)]

plant[i = coordinates,
      j = ":="(latitude = i.latitude, longitude = i.longitude),
      on = .(plot)]

## Saving data ----
base::dir.create(path = "data/raw data/portal_plants/", showWarnings = FALSE)
base::saveRDS(object = plant, file = "data/raw data/portal_plants/rdata.rds")
