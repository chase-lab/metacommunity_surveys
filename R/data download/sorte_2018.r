## sorte_2018

dataset_id <- "sorte_2018"
if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
   if (!file.exists("data/cache/sorte_2018_gcb13425-sup-0002-DataS1-S3.xlsx"))
      curl::curl_download(
         url = "https://onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1111%2Fgcb.13425&file=gcb13425-sup-0002-DataS1-S3.xlsx",
         destfile = "data/cache/sorte_2018_gcb13425-sup-0002-DataS1-S3.xlsx",
         mode = "wb"
      )

   # historical times ----
   ddatah <- readxl::read_xlsx(
      path = "data/cache/sorte_2018_gcb13425-sup-0002-DataS1-S3.xlsx",
      sheet = 2, skip = 0
   )
   data.table::setDT(ddatah)

   data.table::setnames(
      x = ddatah,
      old = c("Site", "Year", "Survey date"),
      new = c("local", "year", "date")
   )

   ddatah <- data.table::melt(
      data = ddatah,
      id.vars = c("local", "year", "date", "Tide Height", "Transect #", "Quadrat #"),
      measure.vars = c(13:68, 71:114),
      measure.name = "value",
      variable.name = "species"
   )

   ddatah[local == "Canoe Beach Cove, Nahant, MA", local := "Canoe Beach"]

   ddatah[, ":="(
      local = base::sub(",.*", "", local),
      period = "historical",

      taxon = "Fixed algae and invertebrates"
   )]

   ddatah[base::which(species == "Littorina saxatilis")[1]:base::nrow(ddatah), taxon := "Invertebrates"]

   # Modern times ----
   ddatam <- readxl::read_xlsx(
      path = "data/cache/sorte_2018_gcb13425-sup-0002-DataS1-S3.xlsx",
      sheet = 3, skip = 0
   )
   data.table::setDT(ddatam)

   data.table::setnames(
      ddatam, c("Site", "Year", "Survey date","Tide height (m)"),
      c("local", "year", "date","Tide Height")
   )

   # data selection
   # melting species columns
   ddatam <- data.table::melt(ddatam,
                              id.vars = c("local", "year", "date", "Tide Height", "Transect #"),
                              measure.vars = c(14:73, 76:98),
                              measure.name = "value",
                              variable.name = "species"
   )

   ddatam[, ":="(
      period = "modern",

      taxon = "Fixed algae and invertebrates"
   )]

   ddatam[base::which(species == "Littorina saxatilis")[1]:base::nrow(ddatam), taxon := "Invertebrates"]

   # Historical and modern times together ----
   ddata <- base::rbind(ddatah, ddatam, fill = TRUE)
   ddata <- ddata[value != 0]

   base::saveRDS(
      object = ddata,
      file = base::paste("data/raw data", dataset_id, "ddata.rds", sep = "/")
   )

   # Environmental data ----
   env <- readxl::read_xlsx(
      path = "data/cache/sorte_2018_gcb13425-sup-0002-DataS1-S3.xlsx",
      sheet = 1, skip = 1
   )
   data.table::setDT(env)
   data.table::setnames(
      x = env,
      old = c("Location", "Site latitude", "Site longitude"),
      new = c("local", "latitude", "longitude"))

   base::saveRDS(
      object = env,
      file = paste("data/raw data", dataset_id, "env.rds", sep = "/")
   )
}
