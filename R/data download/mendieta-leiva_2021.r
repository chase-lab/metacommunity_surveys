dataset_id <- "mendieta-leiva_2021"
if (!file.exists("./data/raw data/mendieta-leiva_2021/rdata.rds")) {
   # Downloading data
   file1 <- "data/cache/Sherman_firstcensus_Mendietaetal2022.csv"
   file2 <- "data/cache/Sherman_secondcensus_Mendietaetal2022.csv"

   download.file(
      url = "https://zenodo.org/record/5645775/files/Sherman_firstcensus_Mendietaetal2022.csv?download=1",
      destfile = file1, mode = "wb"
   )
   download.file(
      url = "https://zenodo.org/record/5645775/files/Sherman_secondcensus_Mendietaetal2022.csv?download=1",
      destfile = file2, mode = "wb"
   )

   # estimating tree crown area from literature
   alpha_grain <- mean(
      data.table::fread(file = rdryad::dryad_download(dois = "10.5061/dryad.85k53v8")[[1]][1],
                        sep = ",", dec = ".", select = "CrownArea")$CrownArea,
      na.rm = TRUE
   )


   # building rdata
   rdata <- data.table::rbindlist(
      l = lapply(c(file1, file2),
                 data.table::fread),
      idcol = TRUE
   )
   rdata[, alpha_grain := alpha_grain]


   dir.create("./data/raw data/mendieta-leiva_2021", showWarnings = FALSE)
   saveRDS(rdata, "./data/raw data/mendieta-leiva_2021/rdata.rds")
}
