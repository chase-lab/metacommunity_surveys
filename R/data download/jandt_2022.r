# jandt_2022
if (!base::file.exists("data/raw data/jandt_2022/rdata.rds")) {
   if (!base::file.exists("data/cache/jandt_2022.zip")) {
      curl::curl_download(
         url = "https://idata.idiv.de/ddm/Data/DownloadZip/3514?version=5513",
         destfile = "data/cache/jandt_2022.zip", mode = "wb")
   }

   utils::unzip(zipfile = "data/cache/jandt_2022.zip",
                files = "ReSurveyGermany.zip",
                exdir = "data/cache/jandt_2022")
   utils::unzip(zipfile = "data/cache/jandt_2022/ReSurveyGermany.zip",
                files = "ReSurveyGermany.csv",
                exdir = "data/cache/jandt_2022")
   utils::unzip(zipfile = "data/cache/jandt_2022/ReSurveyGermany.zip",
                files = "Header_ReSurveyGermany.csv",
                exdir = "data/cache/jandt_2022")

   rdata <- data.table::fread(
      file = "data/cache/jandt_2022/ReSurveyGermany.csv",
      sep = ",", header = TRUE, stringsAsFactors = TRUE,
      drop = "PROJECT_ID_RELEVE_NR",
      encoding = "UTF-8")

   env <- data.table::fread(
      file = "data/cache/jandt_2022/Header_ReSurveyGermany.csv",
      sep = ",", header = TRUE, stringsAsFactors = TRUE,
      select = c("PROJECT_ID", "RELEVE_NR", "RS_SITE", "RS_PLOT", "MANIPULATE",
      "YEAR", "DATE", "SURF_AREA", "LONGITUDE", "LATITUDE"),
      encoding = "UTF-8")

   base::dir.create(path = "data/raw data/jandt_2022/", showWarnings = FALSE)
   base::saveRDS(object = rdata[env, on = .(PROJECT_ID, RELEVE_NR)],
                 file = "data/raw data/jandt_2022/rdata.rds")
}
