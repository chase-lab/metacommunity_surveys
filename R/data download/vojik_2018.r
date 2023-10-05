## vojik_2018
dataset_id <- "vojik_2018"
#
# curl::curl_download(
#    url = "https://static-content.springer.com/esm/art%3A10.1007%2Fs11258-018-0831-5/MediaObjects/11258_2018_831_MOESM1_ESM.docx",
#    destfile = "./data/cache/vojik_2018_11258_2018_831_MOESM1_ESM.docx", mode = "wb"
# )
#
# tb1 <- docxtractr::docx_extract_tbl(
#    docx = docxtractr::read_docx(path = "./data/cache/vojik_2018_11258_2018_831_MOESM1_ESM.docx"),
#    tbl_number = 1L
# )
# tb2 <- docxtractr::docx_extract_tbl(
#    docx = docxtractr::read_docx(path = "./data/cache/vojik_2018_11258_2018_831_MOESM1_ESM.docx"),
#    tbl_number = 2L
# )
# data.table::setDT(tb1)
# data.table::setDT(tb2)
# data.table(rbindlist)
ddata <- data.table::rbindlist(
  lapply(
    c("rdata.csv", "rdata2.csv"),
    function(filename) data.table::fread(paste0("data/raw data/", dataset_id, "/", filename))
  ),
  fill = TRUE
)

base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
