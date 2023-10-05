## schuch_2011
dataset_id <- "schuch_2011"

if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
   curl::curl_download(
      url = "https://onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1111%2Fj.1439-0418.2011.01645.x&file=JEN_1645_sm_AppendixS1.xls",
      destfile = "./data/cache/schuch_2011_JEN_1645_sm_AppendixS1.xls", mode = "wb"
   )
   ddata <- readxl::read_xls("./data/cache/schuch_2011_jen_1645_sm_appendixs1.xls", sheet = 1L)
   data.table::setDT(ddata)

   data.table::set(ddata,
                   j = c("...11", "Over-wintering stage", "Feeding type",
                         "Dispersal ability", "Generations per year"),
                   value = NULL)

   base::saveRDS(ddata,
                 file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/")
   )
}
