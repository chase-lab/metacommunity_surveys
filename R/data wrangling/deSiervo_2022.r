dataset_id <- "deSiervo_2022"
datapath <- "data/raw data/deSiervo_2022/.rdata.rds"

ddata <- base::readRDS(datapath)

#sum canopy, seedling and sapling

prefixes =  sub("[CAN|SAP]{3}[1-9]{4}", "", colnames(ddata))[-c(1,37,38,39,40)]

ddata <- cbind(ddata, sapply(unique(sub("[SEED]{4}[1-9]{4}", "", prefixes)),function(i){
        rowSums(ddata[, grepl(i, colnames(ddata)), with = FALSE])
      }))

ddata <- ddata[, grep("[CAN|SAP|SEED]{3}[1-9]{4}", colnames(ddata)) := NULL]
ddata <- ddata[, c("Elev.dem.", "heatload") := NULL]

data.table::setnames(ddata, c("Plot.number", "Year"), c("local", "year"))

# wide to long format
ddata <- data.table::melt(data = ddata,
                          id.vars = c("local", "year"),
                          variable.name = "species"
                          )
ddata[, value := data.table::fifelse(value > 0, 1L, NA_integer_)]
ddata <- ddata[!is.na(value)]

ddata[, ":="(
  dataset_id = dataset_id,

  metric = "pa",
  unit = "pa",

  regional = "russian wilderness"
)]



# meta ----
meta <- unique(ddata[, .(dataset_id, year, regional, local)])
meta[, ":="(
  realm = "Terrestrial",
  taxon = "Plants",

  latitude =  "41° 19′ 12″ N",
  longitude = "122° 28′ 44.4″ W", #coordinates from wikipedia klamath mountains

  study_type = "ecological_sampling", #two possible values, or NA if not sure

  data_pooled_by_authors = FALSE,

  effort = 1L, #one observation in 1969 and 2015

  alpha_grain =  804.25,
  alpha_grain_unit = "m2", #"acres", "ha", "km2", "m2", "cm2"
  alpha_grain_type = "plot",
  alpha_grain_comment = "16 m radius circular plot (804.25 m 2 ) and used this size and shape for plots. not certain that this was the exact plot size used in 1969, estimates of cover would be robust to slight differences in plot size, especially because the plots were located within larger, compositionally homogenous stands",

  gamma_bounding_box = 5000L,
  gamma_bounding_box_unit = "ha",
  gamma_bounding_box_type = "box",
  gamma_bounding_box_comment = "Russian Wilderness, a 5000 ha landscape within the east-central Klamath Mountain",

  gamma_sum_grains_unit = "m2",
  gamma_sum_grains_type = "plot",
  gamma_sum_grains_comment = "sampled area per year",

  comment = "Data manually downloaded via https://datadryad.org/stash/dataset/doi:10.5061%2Fdryad.9s4mw6mj7. The authors estimated percent coverage in 16m radius circular plots. The authors surveyed this area once in 2014 and compare this data to historical data of the same plots in 1969.  Regional in this dataset is the russian wilderness area in klamath mountains, local is defined as plot. Sum of percent coverage of seedlings, saplings and canope of species.",
  comment_standardisation = "all life stages included, cover turned into presence absence"
)]

meta[, ":="(
  gamma_sum_grains = sum(alpha_grain)
),
by = .(regional, year)
]

dir.create(paste0("data/wrangled data/", dataset_id), showWarnings = FALSE)
data.table::fwrite(ddata, paste0("data/wrangled data/", dataset_id, "/", dataset_id, ".csv"),
                   row.names = FALSE
)
data.table::fwrite(meta, paste0("data/wrangled data/", dataset_id, "/", dataset_id, "_metadata.csv"),
                   row.names = FALSE
)
