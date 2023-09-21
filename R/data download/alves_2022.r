# alves_2022

if (!file.exists("data/raw data/alves_2022/rdata.rds")) {
   download.file(
      url = "https://github.com/calves06/Belizean_Barrier_Reef_Change/raw/main/Data/Processed/Long.Master.Species.Groups.csv",
      destfile = "data/cache/alves_2021_Long.Master.Species.Groups.csv"
   )

   dir.create("data/raw data/alves_2022")
   base::saveRDS(
      object = unique(
         data.table::fread(
            file = "data/cache/alves_2021_Long.Master.Species.Groups.csv",
            drop = c("V1","File.Name","Image.Code"),
            sep = ",", header = TRUE, colClasses = list(factor = c("Site", "ID"))
         )
      ),
      file = "data/raw data/alves_2022/rdata.rds"
   )
}
