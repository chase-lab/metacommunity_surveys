# countryside_survey_invertebrates_2017

if (!file.exists("data/raw data/countryside_survey_invertebrates_2017/rdata.rds")) {
   ddata <- data.table::rbindlist(list(
      `1990` = data.table::fread(
         file = "data/cache/countryside_survey_invertebrates_2017/b4c17f35-1b50-4ed7-87d2-b63004a96ca2/data/STREAM_INVERT_TAXA_90.csv",
         stringsAsFactors = TRUE),
      `1998` = data.table::fread(
         file = "data/cache/countryside_survey_invertebrates_2017/fd0ce233-3b4d-4a5e-abcb-c0a26dd71c95/data/STREAM_INVERT_TAXA_98.csv",
         stringsAsFactors = TRUE),
      `2007` = data.table::fread(
         file = "data/cache/countryside_survey_invertebrates_2017/18849325-358b-4af1-b20d-d750b1c723a3/data/STREAM_INVERT_TAXA_07.csv",
         stringsAsFactors = TRUE)
   ), fill = TRUE, use.names = TRUE, idcol = FALSE)

   data.table::setnames(ddata,
                        old = c("YEAR", "SQUARE", "EZ_DESC_07", "NAME", "ABUNDANCE"),
                        new = c("year", "local", "regional", "species", "value"))

   base::dir.create("data/raw data/countryside_survey_invertebrates_2017", showWarnings = FALSE)
   base::saveRDS(
      object = ddata,
      file = "data/raw data/countryside_survey_invertebrates_2017/rdata.rds")
}
