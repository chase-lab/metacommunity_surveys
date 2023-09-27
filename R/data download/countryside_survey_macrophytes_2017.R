# countryside_survey_macrophytes_2017
if (!file.exists("data/raw data/countryside_survey_macrophytes_2017/rdata.rds")) {
   ddata <- data.table::rbindlist(list(
      `1998` = data.table::fread(
         file = "data/cache/countryside_survey_macrophytes_2017/e0b638d5-8271-4442-97ef-cf46ea220f5d/data/STREAM_MACROPHYTES_98.csv",
         stringsAsFactors = TRUE),
      `2007` = data.table::fread(
         file = "data/cache/countryside_survey_macrophytes_2017/249a90ec-238b-4038-a706-6633c3690d20/data/STREAM_MACROPHYTES_07.csv",
         stringsAsFactors = TRUE)
   ), use.names = TRUE, idcol = TRUE)

   data.table::setnames(ddata,
                        old = c(".id","SURVEY_DATE", "SQUARE", "EZ_DESC_07", "PLANT_NAME"),
                        new = c("year", "date", "local", "regional", "species"))

   base::dir.create("data/raw data/countryside_survey_macrophytes_2017", showWarnings = FALSE)
   base::saveRDS(
      object = ddata,
      file = "data/raw data/countryside_survey_macrophytes_2017/rdata.rds")
}
