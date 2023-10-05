# quimbayo_2022
# suppdata::suppdata(x = "https://doi.org/10.1002/ecy.3966", si = 2, dir = "data/cache", save.name = "quimbayo_2022_ecy3966-sup-0002-data_s1.zip")
if (!file.exists("data/cache/quimbayo_2022_ecy3966-sup-0002-data_s1.zip"))
   curl::curl_download(
      url = "https://esajournals.onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1002%2Fecy.3966&file=ecy3966-sup-0002-Data_S1.zip",
      desfile = "data/cache/quimbayo_2022_ecy3966-sup-0002-data_s1.zip",
      mode = "wb")

# reading data ----
community <- utils::read.csv(
   file = base::unz(
      description = "data/cache/quimbayo_2022_ecy3966-sup-0002-data_s1.zip",
      filename = "TimeFISH_census_data.csv"),
   header = TRUE, sep = ",", stringsAsFactors = TRUE,
   strip.white = TRUE, blank.lines.skip = TRUE
)
data.table::setDT(community)
community <- community[, .(value = sum(abundance)), by = .(transect_id, species = species_name)]


locations <- utils::read.csv(
   file = base::unz(
      description = "data/cache/quimbayo_2022_ecy3966-sup-0002-data_s1.zip",
      filename = "TimeFISH_location_information.csv"),
   header = TRUE, sep = ",", stringsAsFactors = TRUE,
   strip.white = TRUE, blank.lines.skip = TRUE
)
data.table::setDT(locations)
locations[, location := as.character(location)][location == "gal\xe9_island", location := "galé_island"]


# selecting and merging data ----
ddata <- community[
   locations[, .(transect_id, location, site, longitude, latitude,
                 ntransect, year, month, day)],
   on = "transect_id", nomatch = 0L]

# saving data ----
base::dir.create("data/raw data/quimbayo_2022", showWarnings = FALSE)
base::saveRDS(ddata, "data/raw data/quimbayo_2022/rdata.rds")
