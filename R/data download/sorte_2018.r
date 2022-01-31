## sorte_2018

dataset_id <- "sorte_2018"
if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
  download.file(
    url = "https://onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1111%2Fgcb.13425&file=gcb13425-sup-0002-DataS1-S3.xlsx",
    destfile = "./data/cache/sorte_2018_gcb13425-sup-0002-DataS1-S3.xlsx",
    mode = "wb"
  )

  # historical times ----
  ddatah <- readxl::read_xlsx(
    path = "./data/cache/sorte_2018_gcb13425-sup-0002-DataS1-S3.xlsx",
    sheet = 2, skip = 0
  )
  data.table::setDT(ddatah)


  data.table::setnames(
    ddatah, c("Site", "Year", "Survey date"),
    c("local", "year", "date")
  )

  # selecting data
  ddatah <- ddatah[`Tide Height` != "Very Low" & `Transect #` %in% c("1", "3", "5")]
  # selecting years sampled more than once
  ddatah <- ddatah[ddatah[, .(nyears = length(unique(date))), by = .(local, year)][nyears > 1L], on = .(local, year)] # data.table style join

  # selecting months
  ddatah[, Month := format(date, "%m")]
  month_table <- table(unique(ddatah[, .(local, year, Month, date)])$Month)

  ddatah <- ddatah[unique(ddatah[, .(order_month = order(month_table, decreasing = TRUE)[match(Month, names(month_table))], local, year, Month, date)][order(local, year, order_month)])[, .SD[1:2], by = .(local, year)], on = .(local, year, Month, date)] # data.table style join

  ddatah[, length(unique(Month)), by = .(local, year)]
  # melting species columns
  ddatah <- data.table::melt(ddatah,
    id.vars = c("local", "year", "date"),
    measure.vars = c(13:68, 71:114),
    measure.name = "value",
    variable.name = "species"
  )
  ddatah <- ddatah[!is.na(value) & value > 0]

  ddatah[local == "Canoe Beach Cove, Nahant, MA", local := "Canoe Beach"]

  ddatah[, ":="(
    local = gsub(",.*", "", local),
    period = "historical",

    taxon = "Fixed algae and invertebrates"
  )][, date := NULL]

  ddatah[which(species == "Littorina saxatilis")[1]:nrow(ddatah), taxon := "invertebrates"]




  # Modern times ----
  ddatam <- readxl::read_xlsx(
    path = "./data/cache/sorte_2018_gcb13425-sup-0002-DataS1-S3.xlsx",
    sheet = 3, skip = 0
  )
  data.table::setDT(ddatam)

  data.table::setnames(
    ddatam, c("Site", "Year", "Survey date"),
    c("local", "year", "date")
  )

  # data selection
  ddatam <- ddatam[`Transect #` %in% c(1, 3, 5) & `Tide height (m)` %in% c(0, 1, 2)]

  # melting species columns
  ddatam <- data.table::melt(ddatam,
    id.vars = c("local", "year", "date"),
    measure.vars = c(14:73, 76:98),
    measure.name = "value",
    variable.name = "species"
  )
  ddatam <- ddatam[!is.na(value) & value > 0]

  # site selection
  ddatam <- ddatam[local %in% unique(ddatah$local)]

  ddatam[, ":="(
    period = "modern",

    taxon = "Fixed algae and invertebrates"
  )][, date := NULL]

  ddatam[which(species == "Littorina saxatilis")[1]:nrow(ddatam), taxon := "invertebrates"]



  # Historical and modern times together ----
  ddata <- rbind(ddatah, ddatam, fill = TRUE)
  base::saveRDS(
    ddata,
    file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/")
  )

  # Environmental data ----
  env <- readxl::read_xlsx(
    path = "./data/cache/sorte_2018_gcb13425-sup-0002-DataS1-S3.xlsx",
    sheet = 1, skip = 1
  )
  data.table::setDT(env)
  data.table::setnames(env, c("Location", "Site latitude", "Site longitude"), c("local", "latitude", "longitude"))
  base::saveRDS(
    env,
    file = paste("data/raw data", dataset_id, "env.rds", sep = "/")
  )
}
