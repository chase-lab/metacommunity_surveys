# larson_2023
## Manual download here: https://umesc.usgs.gov/data_library/vegetation/srs/veg_srs_1_query.shtml
# Check if the RDS file already exists in the specified directory
if (!file.exists('data/raw data/larson_2023/rdata.rds')) {

   # If the ZIP file is not downloaded, display a message for the user to manually download it
   if (!file.exists('data/cache/larson_2023_macrophytes.zip'))
      base::message("Data for larson_2023 has to be manually downloaded here: https://umesc.usgs.gov/data_library/vegetation/srs/veg_srs_1_query.shtml
                    You should be using these criteria:
                     (1) select “Field Station” 1, 2, and 3;
                     (2) select “Date Range” January 01, 1998 to January 01, 2019;
                     (3) select “Map Stratum” BWC, IMP, MCB, and SC;
                     (4) select “Vegetation Species” All Species;
                     (5) select “Submit Query” button at bottom of page.
                    ")

   # If the CSV file is not extracted from the ZIP file, extract it
   if (!file.exists('data/cache/larson_2023_macrophytes/ltrm_vegsrs_data.csv'))
      utils::unzip('data/cache/larson_2023_macrophytes.zip')

   # Read the CSV file using data.table package
   rdata <- data.table::fread(
      file = 'data/cache/larson_2023_macrophytes/ltrm_vegsrs_data.csv',
      header = TRUE, sep = ',', stringsAsFactors = TRUE,
      # Select specific columns to read
      select = c('FLDNUM','PROJCD','POOL','SITECD','RIVMILE','DATE',
                 'EAST1','NORTH1','ZONE','EAST2','NORTH2','EAST_15','NORTH_15',
                 'SPPCD','VOUCHER',
                 'VISUAL1', 'VISUAL2', 'VISUAL3', 'VISUAL4', 'VISUAL5', 'VISUAL6'))

   # Create the directory if it does not exist
   base::dir.create(path = 'data/raw data/larson_2023/', showWarnings = FALSE)

   # Save the data table in RDS format in the specified directory
   base::saveRDS(
      object = rdata,
      file = 'data/raw data/larson_2023/rdata.rds'
   )
}
