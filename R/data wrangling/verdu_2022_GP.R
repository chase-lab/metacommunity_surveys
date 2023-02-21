# # verdu_2022 - GP
# datset_id <- 'verdu_2022_GP'
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
# ddata <- ddata[sampling_method == 'GP'][, sampling_method := NULL]
# ddata[, alpha_grain := plotdimx * plotdimy]
# ddata[
#    ddata[, length(unique(local)), by = .(regional)][V1 >= 4L][, V1 := NULL],
#    on = .(regional)
# ]
#
# comment = 'METHOD: "The Georeferenced plot (GP) protocol (11 networks) takes advantage of available information from mapped individual plants in large plots. To transform this type of data into canopy-recruit interactions we made a series of assumptions regarding the size of recruits of each species and the maximum distance between canopy and recruited plant. Basically, we considered as a recruit any individual with DBH lower than 10% that of the largest conspecific present in the plot. Besides, we considered that a recruit was interacting with the nearest adult plant located less than 2 m away, and considered that it was recruiting in an open interspace if there were no adult plants less than 2 m from the recruit. In all protocols, the network corresponding to the studied community should be built by aggregating the information from all the sampled plots or pairs. Nevertheless, we provide the information disaggregated because it reflects the actual sampling scheme and because it can be useful, for example, in studies exploring network properties at different spatial scales or the spatial variability of the interactions within communities." '
