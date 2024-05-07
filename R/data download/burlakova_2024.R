# burlakova_2024
if (!file.exists("data/raw data/burlakova_2024/rdata.rds")) {
   # rdryad::dryad_download(dois = "10.5061/dryad.47d7wm3m0")
   dir.create(path = "data/cache/burlakova_2024", showWarnings = FALSE)
   curl::curl_download(url = "https://datadryad.org/stash/downloads/file_stream/2930370",
                       destfile = "data/cache/burlakova_2024/ErieBenthosSpeciesDensity.csv")

   dir.create(path = "data/raw data/burlakova_2024", showWarnings = FALSE)
   curl::curl_download(url = "https://datadryad.org/stash/downloads/file_stream/2930369",
                       destfile = "data/raw data/burlakova_2024/ErieBenthosTaxonomy.csv")

   base::saveRDS(
      object = data.table::fread(file = "data/cache/burlakova_2024/ErieBenthosSpeciesDensity.csv"),
      file = "data/raw data/burlakova_2024/rdata.rds"
   )
}
