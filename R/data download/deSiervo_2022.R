dataset_id <- "deSiervo_2022"

#Data manually downloaded from https://datadryad.org/stash/dataset/doi:10.5061%2Fdryad.9s4mw6mj7
#due too responsive button issues.

datapath <- "data/raw data/deSiervo_2022/doi_10.5061_dryad.9s4mw6mj7__v5.zip"



if (!file.exists("./data/raw data/deSiervo_2022/.rdata.rds")) {
  ddata <- read.csv(unz("data/raw data/deSiervo_2022/doi_10.5061_dryad.9s4mw6mj7__v5.zip", "Klamath_tree_data.csv"))
  dsite <- read.csv(unz("data/raw data/deSiervo_2022/doi_10.5061_dryad.9s4mw6mj7__v5.zip", "Klamath_site_data.csv"))
  data.table::setDT(ddata)
  ddata <- ddata[dsite, on = .(Plot.number)]
  saveRDS(ddata, "./data/raw data/deSiervo_2022/.rdata.rds")
}
