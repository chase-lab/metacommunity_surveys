# green_2021

if (!file.exists("./data/raw data/green_2021/docx_extraction.rds")) {
  if (!file.exists("./data/cache/green_2021_suplementary.docx")) {
    download.file(
      url = "https://onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1111%2Fddi.13387&file=ddi13387-sup-0001-Supinfo.docx",
      destfile = "./data/cache/green_2021_suplementary.docx",
      mode = "wb"
    )
  }

  ddata <- docxtractr::docx_extract_tbl(
    docx = docxtractr::read_docx(path = "./data/cache/green_2021_suplementary.docx"),
    tbl_number = 7L
  )

  data.table::setDT(ddata)

  dir.create(path = "./data/raw data/green_2021/", showWarnings = FALSE)
  saveRDS(ddata, file = "./data/raw data/green_2021/docx_extraction.rds")
}
