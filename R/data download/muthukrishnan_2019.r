## muthukrishnan_2019
dataset_id <- "muthukrishnan_2019"

rdata <- read.csv(unz(
   description = rdryad::dryad_download("10.5061/dryad.15dv41nt2")[[1]][1],
   filename = "Lake_plant_diversity_data.csv")
)
data.table::setDT(rdata)

coords <- data.table::fread(
   file = "data/raw data/muthukrishnan_2019/coordinates.csv",
   header = TRUE, sep = ",", encoding = "UTF-8")

coords <- coords[j = .(
   county = gsub(x = `Area covered`, pattern = " County", replacement = ""),
   latitude = rowMeans(data.frame(`South bounding coordinate`, `North bounding coordinate`)),
   longitude = rowMeans(data.frame(`West bounding coordinate`, `East bounding coordinate`))
)][county == "Lac qui Parle", county := "Lac Qui Parle"]

rdata[i = coords,
      on = "county",
      j = ":="(
         latitude = i.latitude,
         longitude = i.longitude)]

base::saveRDS(object = rdata,
              file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))

