## beldade_2015
dataset_id <- "beldade_2015"

ddata <- data.table::fread(paste0("./data/raw data/", dataset_id, "/rdata.csv"), skip = 1, header = TRUE, drop = c("V15", "V16"))
base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
