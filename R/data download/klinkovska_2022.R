# klinkovska_2022
if (!file.exists('data/raw data/klinkovska_2022/rdata.rds')) {
   if (!file.exists('data/cache/klinkovska_2022_species.txt'))
      download.file(url = 'https://zenodo.org/record/7338814/files/Jeseniky_resurvey_species.txt?download=1',
                    destfile = 'data/cache/klinkovska_2022_species.txt')
   if (!file.exists('data/cache/kinklovska_2022_environment.txt'))
      download.file(url = 'https://zenodo.org/record/7338814/files/Jeseniky_resurvey_head.txt?download=1',
                    destfile = 'data/cache/klinkovska_2022_environment.txt')

   rdata <- data.table::fread(file = 'data/cache/klinkovska_2022_species.txt',
                              header = TRUE, sep = '\t', stringsAsFactors = TRUE)

   env <- data.table::fread(file = 'data/cache/klinkovska_2022_environment.txt',
                            header = TRUE, sep = '\t', stringsAsFactors = TRUE,
                            encoding = 'UTF-8')

   data.table::setnames(rdata, 1L, 'Releve.number')
   base::dir.create('data/raw data/klinkovska_2022', showWarnings = FALSE)
   base::saveRDS(
      object = rdata[env[, .(Releve.number, Date..year.month.day., Releve.area..m2., Rs_plot,
                             deg_lat, deg_lon)], on = 'Releve.number'],
      file = 'data/raw data/klinkovska_2022/rdata.rds'
   )
}
