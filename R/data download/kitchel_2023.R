# kitchel_2023
if (!file.exists('data/raw data/kitchel_2023/rdata.rds')) {
   # Manual download from https://github.com/zoekitchel/trawl_gains_losses/blob/ce7c8fc0a2566ead45699a72cc13d5e6b97c6b63/Data/Spp_master/spp_master.RData
   # https://github.com/zoekitchel/trawl_gains_losses/blob/ce7c8fc0a2566ead45699a72cc13d5e6b97c6b63/Data/InputTrawls/trawl2.RData

   base::load('data/cache/kitchel_2023/trawl2.Rdata')

   base::dir.create('data/raw data/kitchel_2023', showWarnings = FALSE)
   base::saveRDS(
      object = trawl2[, .(region, spp, year, lat, lon, wtcpue)],
      file = 'data/raw data/kitchel_2023/rdata.rds'
   )
}
