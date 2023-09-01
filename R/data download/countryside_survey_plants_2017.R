# countryside_survey_plants_2017.R
# Data files were downloaded by hand from links listed here: https://doi.org/10.5194/essd-9-445-2017

if (!file.exists("data/raw data/countryside_survey_plants_2017/rdata.rds")) {
   ddata <- data.table::rbindlist(list(
      `1978` = data.table::fread(
         file = "data/cache/countryside_survey_plants_2017/67bbfabb-d981-4ced-b7e7-225205de9c96/data/Vegetation Plot - Species List 1978.csv",
         stringsAsFactors = TRUE, drop = "BRC_NUMBER"),
      `1990` = data.table::fread(
         file = "data/cache/countryside_survey_plants_2017/26e79792-5ffc-4116-9ac7-72193dd7f191/data/Vegetation Plot - Species List 1990.csv",
         stringsAsFactors = TRUE,
         drop = c("BRC_NUMBER","NEST_LEVEL", "FIRST_COVER")),
      `1998` = data.table::fread(
         file = "data/cache/countryside_survey_plants_2017/07896bb2-7078-468c-b56d-fb8b41d47065/data/Vegetation Plot - Species List 1998.csv",
         stringsAsFactors = TRUE,
         drop = c("BRC_NUMBER","NEST_LEVEL", "FIRST_COVER", "PLOT_TYPE")),
      `2007` = data.table::fread(
         file = "data/cache/countryside_survey_plants_2017/57f97915-8ff1-473b-8c77-2564cbd747bc/data/Vegetation Plot - Species List 2007.csv",
         stringsAsFactors = TRUE,
         drop = c("BRC_NUMBER","NEST_LEVEL", "FIRST_COVER", "ZERO_COVER"))),
      fill = TRUE, use.names = TRUE, idcol = FALSE)

   data.table::setnames(ddata,
                        old = c("YEAR", "SQUARE_ID", "BRC_NAMES", "TOTAL_COVER"),
                        new = c("year", "local", "species", "value"))

   env <- data.table::rbindlist(list(
      `1978` = data.table::fread(file = "data/cache/countryside_survey_plants_2017/67bbfabb-d981-4ced-b7e7-225205de9c96/data/Vegetation Plot - Plot Information 1978.csv", stringsAsFactors = TRUE, select = c("SQUARE_ID", "EZ_DESC_07")),
      `1990` = data.table::fread(file = "data/cache/countryside_survey_plants_2017/26e79792-5ffc-4116-9ac7-72193dd7f191/data/Vegetation Plot - Plot Information 1990.csv", stringsAsFactors = TRUE, select = c("SQUARE_ID", "EZ_DESC_07")),
      `1998` = data.table::fread(file = "data/cache/countryside_survey_plants_2017/07896bb2-7078-468c-b56d-fb8b41d47065/data/Vegetation Plot - Plot Information 1998.csv", stringsAsFactors = TRUE, select = c("SQUARE_ID", "EZ_DESC_07")),
      `2007` = data.table::fread(file = "data/cache/countryside_survey_plants_2017/57f97915-8ff1-473b-8c77-2564cbd747bc/data/Vegetation Plot - Plot Information 2007.csv", stringsAsFactors = TRUE, select = c("SQUARE_ID", "EZ_DESC_07"))),
      use.names = TRUE, idcol = FALSE)

   data.table::setnames(env, "SQUARE_ID", "local")

   env[, regional := stringi::stri_extract_first_regex(str = EZ_DESC_07, pattern = "(?<=\\().*(?=\\))")]

   # ddata[env, regional := i.regional, on = .(local)]
   ddata[, regional := env$regional[match(local, env$local)]]
   # 100x much faster than a data.table join to update regional by reference?

   base::dir.create("data/raw data/countryside_survey_plants_2017", showWarnings = FALSE)
   base::saveRDS(ddata, "data/raw data/countryside_survey_plants_2017/rdata.rds")
}
