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
#    !ddata[, data.table::uniqueN(local) < 4, by = .(regional, year)][(V1)L],
#    on = .(regional, year)
# ]

# doi = 'https://doi.org/10.1002/ecy.3923 | https://doi.org/10.5281/zenodo.6567608'
