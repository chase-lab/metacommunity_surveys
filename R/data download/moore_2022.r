dataset_id <- "moore_2022"

if (!file.exists("./data/raw data/moore_2022/rdata.rds")) {
   curl::curl_download(url = "https://www.fs.usda.gov/rds/archive/products/RDS-2021-0092/RDS-2021-0092_Data.zip", destfile = "./data/cache/moore_2022_RDS-2021-0092_Data.zip", mode = "wb")

   ddata <- read.csv(
      unz(
         description =  "./data/cache/moore_2022_RDS-2021-0092_Data.zip",
         filename =  "Data/Ancillary_Data_CSVs/Density_Species_Tabular_Version.csv"
      )
   )
   data.table::setDT(ddata)
   ddata[, c("Easting_NAD83_UTM_Zone_12", "Northing_NAD83_UTM_Zone_12", "X_Coord_In_Quadrat", "Y_Coord_In_Quadrat", "Sq_Cm") := NULL]

   coords <- read.csv(
      unz(
         description =  "./data/cache/moore_2022_RDS-2021-0092_Data.zip",
         filename =  "Data/Ancillary_Data_CSVs/Quadrat_Locations_and_Data.csv"
      )
   )
   data.table::setDT(coords)

   dir.create("./data/raw data/moore_2022", showWarnings = FALSE)
   saveRDS(ddata, "./data/raw data/moore_2022/rdata.rds")
   saveRDS(coords, "./data/raw data/moore_2022/coords.rds")
}
