# # Maureaud_2023 - FishGlob
# if (!file.exists('data/cache/maureaud_2023_fish_communities.Rdata')) {
#    utils::download.file(
#       url = 'https://github.com/AquaAuma/FishGlob_data/raw/main/outputs/Compiled_data/FishGlob_public_std_clean.RData',
#       destfile = 'data/cache/maureaud_2023_fish_communities.Rdata', mode = 'wb'
#    )
# }
#
# load('data/cache/maureaud_2023_fish_communities.Rdata')
#
# data.table::setDT(data)
#
# data
# data[, c('stat_rec', 'stratum', 'sbt', 'sst', 'num', 'wgt', 'verbatim_name',
#           'verbatim_aphia_id', 'aphia_id', 'SpecCode', 'kingdom', 'phylum',
#           grep('flag', colnames(data), value = TRUE)) := NULL]
#
# base::dir.create(path = 'data/raw data/mauread_2023/', showWarnings = FALSE)
# base::saveRDS(data, 'data/raw data/mauread_2023/rdata.rds')
