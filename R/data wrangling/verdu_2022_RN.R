# # verdu_2022 - RN
# datset_id <- 'verdu_2022_RN'
#
# ddata <- base::readRDS('data/raw data/verdu_2022/rdata.rds')
# data.table::setnames(ddata, tolower(colnames(ddata)))
# data.table::setnames(
#    ddata,
#    new = c('regional','delete_me','delete_me2','latitude','longitude',
#            'plotdimx','plotdimy','year','local','species_canopy',
#            'species_recruit','value','sampling_method')
# )
#
# # Subsetting data ----
# ddata <- ddata[sampling_method == 'RN'][, sampling_method := NULL]
# ddata[, alpha_grain := plotdimx * plotdimy]
# ddata[
#    ddata[, length(unique(local)), by = regional)[V1 >= 4L][, V1 := NULL],
#    on = `regional`
# ]
