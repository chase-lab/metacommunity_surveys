# verdu_2022 - pCO
# datset_id <- 'verdu_2022_pCO'

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
# ddata <- ddata[sampling_method == 'pCO'][, sampling_method := NULL]
# ddata[, alpha_grain := plotdimx * plotdimy]
# ddata[
#    ddata[, length(unique(local)), by = regional][V1 >= 4L][, V1 := NULL],
#    on = `regional`
# ]

# "METHODS: 'The paired Canopy-Open (pCO) protocol (26 networks) consists in locating a potential canopy individual and identifying individual plants recruiting beneath it and in a nearby open space of the same area (see for example Rey et al. 2016). Here, each sampled pair is a replicate of the possible links involving a given canopy species or the open node, so all potential canopy plants in the plot must be sampled in order to obtain the full network of the studied community. This protocol is typically used in studies specifically designed to determine the importance of facilitation for recruitment, when canopy species are previously identified (Navarro-Cano et al., 2019)'"
