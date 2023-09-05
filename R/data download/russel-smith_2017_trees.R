
###Data manually downloaded from:
### https://datacommons.anu.edu.au/DataCommons/rest/records/anudc:5836/data/
###  Spatial data manually downloaded from:
###  https://datacommons.anu.edu.au/russell-smith_2017/dataCommons/rest/records/anudc:5837/data/
###  Login for Australian National University needed. Data accessible after login without further requests.
if (!file.exists("data/raw data/russel-smith_2017_trees/rdata.rds")) {

   ## Loading data ----
   datafiles <- c(
      "data/raw data/russell-smith_2017/data/tpsk_trees_1994+_p831t1066.csv",
      "data/raw data/russell-smith_2017/data/tpsl_trees_1994+_p831t1124.csv",
      "data/raw data/russell-smith_2017/data/tpsn_trees_1994+_p831t1129.csv"
   )

   datafiles_dates <- c(
      "data/raw data/russell-smith_2017/data/tpsk_visit_date_1994+_p831t1067.csv",
      "data/raw data/russell-smith_2017/data/tpsl_visit_date_1994+_p831t1125.csv",
      "data/raw data/russell-smith_2017/data/tpsn_visit_date_1994+_p831t1153.csv"
   )

   datafiles_spatial <- c(
      "data/raw data/russell-smith_2017/spatial/tpsk_plot_details_spatial_coordinates_p894t1154.csv",
      "data/raw data/russell-smith_2017/spatial/tpsl_plot_details_spatial_coordinates_p894t1155.csv",
      "data/raw data/russell-smith_2017/spatial/tpsn_plot_details_spatial_coordinates_p894t1156.csv"
   )

   ddata <- data.table::rbindlist(
      lapply(datafiles, data.table::fread),
      fill = TRUE,
      use.names = TRUE, idcol = FALSE
   )

   dates <- data.table::rbindlist(
      lapply(datafiles_dates, data.table::fread, drop = "comments"),
      use.names = TRUE, idcol = FALSE
   )

   spatial <- data.table::rbindlist(
      lapply(datafiles_spatial, data.table::fread),
      use.names = TRUE, idcol = FALSE, fill = TRUE
   )

   ## merging data.table style ----
   ddata <- ddata[dates, date := i.date, on = c("park", "plot", "visit")]

   ### format spatial data to have common identifier with species data ----
   spatial[, park := c("Kakadu","Litchfield","Nitmiluk")[data.table::chmatch(substr(plot, 1, 3), c("KAK", "LIT", "NIT"))]]
   spatial[, plot := stringi::stri_extract_all_regex(str = plot, pattern = "[0-9]{2,3}")
   ][, plot := as.integer(sub("^0+(?=[1-9])", "", plot, perl = TRUE))]

   ## merging data.table style ----
   ddata[spatial,
         ":="(latitude = i.latitude, longitude = i.longitude),
         on = .(park, plot)]

   base::dir.create(path = "data/raw data/russel-smith_2017_trees/", showWarnings = FALSE)
   base::saveRDS(object = ddata, file = "data/raw data/russel-smith_2017_trees/rdata.rds")
}
