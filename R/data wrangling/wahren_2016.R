#wahren_2016

dataset_id = "wahren_2016"

ddata <- data.table::fread(file = "./data/raw data/wahren_2016/vltm_vegetation_monitoring_1947-2013_p821t990.csv")

ddata[,species := paste(genus,species)]
ddata[,unique(species)]

#exclude unknown lichen, moss, liverwort, rock, bare ground, no data, litter,
ddata <- ddata[!grepl(pattern = "no data|unknown|rock| litter|ground", x = species, ignore.case = TRUE)]

ddata[,unique(site)]
# effort = 44sites per year except: site_out = 1958 - 42, 1951 - 43, site_in = 1979 - 45, 1966 - 42, 1951 - 45
ddata[,length(unique(tr)), by = .(site,year)] #datatable way of gropuing #standartisation
ddata[,length(unique(date)), by = .(site,year,tr)]$V1 %>% summary()#. = list #no need to do standartisation in time
ddata[,unique(tr), by = .(site,year)]
#Two adjacent plots were established, 5 m apart, one fenced and one unfenced, and each approximately 400 m2

#count how many transects per year per site
un <- unique(ddata[, .(site, year, tr)])
# un[, .N, by = tr] # .N is another data.table shortcut that gives the number of rows.

#exclude uneven transects
ddata <- ddata[tr %in% 1:42] #select only data where count of sampling points for transects is equal, in this case its transects 1-42

ddata <- unique(ddata[,.(site, year, species)])
data.table::setnames(x = ddata, old =  "site", new = "local")

## community data ----

ddata[, ":="(
  dataset_id = dataset_id,
  regional = "Pretty Valley",

  value = 1L, #integer not numeric object
  metric = "pa", #pa = presence absence data
  unit = "pa"
)]

## metadata ----
meta <- unique(ddata[, .(dataset_id, local, year, regional)])

meta[, ":="(
  realm = "Terrestrial",
  taxon = "Plants",

  effort = 42L,

  study_type = "ecological_sampling",

  data_pooled_by_authors = FALSE,

  latitude = "36°54'S",
  longitude =  "147°18'E",

  alpha_grain = 900L,
  alpha_grain_unit = "m2",
  alpha_grain_type = "plot",
  alpha_grain_comment = "Approximate Area of Pretty Valley plots in m2 given by the authors",

  gamma_sum_grains = 1800L,
  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "plot",
  gamma_sum_grains_comment = "Sum area of the two plots",

  gamma_bounding_box = 0.2,
  gamma_bounding_box_unit = "ha",
  gamma_bounding_box_type = "ecosystem",
  gamma_bounding_box_comment = "area provided by the authors",

  comment = "Extracted from: https://datacommons.anu.edu.au/DataCommons/rest/display/anudc:5886?layout=def:display, data saved at raw data/wahren_2016, data download only possible with login, download not scripted",
  comment_standardisation = "Only transects sampled in each year at each site were included, unidentified species and rock covers were excluded"
)]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)

