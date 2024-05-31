# jandt_2022
dataset_id <- "jandt_2022"

ddata <- base::readRDS("data/raw data/jandt_2022/rdata.rds")
data.table::setnames(ddata, tolower(colnames(ddata)))
data.table::setnames(
   x = ddata,
   old = c("project_id", "rs_plot", "surf_area", "taxonname", "cover_perc"),
   new = c("regional", "local", "alpha_grain", "species", "value"))

## Excluding sites where surf_area/alpha_grain is missing as it is needed to assess effort
## Excluding sites that were not precisely resurveyed thanks to stakes or GPS
ddata <- ddata[!is.na(alpha_grain)]

ddata[, ":="(month = as.integer(base::substr(date, 5L, 6L)),
             day = as.integer(base::substr(date, 7L, 8L)))]

# ddata[, .(diff(range(year)) >= 9L), keyby = .(alpha_grain, regional, local)]
# x <- ddata[
#    i  = !ddata[, .(diff(range(year)) < 9L), keyby = .(alpha_grain, regional, local)][(V1)],
#    on = .(alpha_grain, regional, local),
#    j  = .(nsites = data.table::uniqueN(local)),
#    keyby = .(alpha_grain, regional)]

# ddata[, data.table::uniqueN(releve_nr), keyby = .(regional, local, year, date)][, any(V1 != 1L), keyby = .(regional, year)][(V1)]

# Adding treatment information to local
ddata[is.na(manipulate), manipulate := factor("N")]
ddata[j = local := factor(paste0(local, "!", manipulate, "!"))]

# Adding the releve number to local for localities that had several releve number per DATE and RS_OBSERVER. Some of these releves had distinct coordinates from one another.
ddata[j  = local := factor(paste0(local, "_", releve_nr))]

# ddata_standardised <- data.table::copy(ddata)

# Raw data ----
## Community data ----
ddata[, ":="(
   # dataset_id = factor(paste0(dataset_id, "_", alpha_grain, "sqm_", "layer", layer)),
   dataset_id = factor(paste0(dataset_id, "_", alpha_grain, "sqm")),

   # local = factor(paste0(local, "#", layer, "#")),

   metric = "cover",
   unit = "percent",

   rs_site = NULL,
   # project_id = NULL,
   # releve_nr = NULL,
   # layer = NULL,
   manipulate = NULL,
   date = NULL
)]
data.table::setkey(ddata, dataset_id, regional, local,
                   year, month, day, species)

# ddata[, .N, keyby = .(dataset_id, regional, local, year, month, day, species)][N != 1]
# remove two samples with duplicated observations of Brachypodium pinnatum agg.
ddata <- ddata[
   i  = !ddata[j = .N,
               keyby = .(dataset_id, regional, local, layer,
                         year, month, day, species)][N != 1],
   on = .(dataset_id, regional, local, year, month, day)]

## metadata ----
meta <- unique(ddata[j = .(dataset_id, regional, local, releve_nr, alpha_grain,
                           year, month, day, latitude, longitude)])
meta[, ":="(
   taxon = "Plants",
   realm = "Terrestrial",

   study_type = "resurvey",

   data_pooled_by_authors = FALSE,

   alpha_grain_unit = "m2",
   alpha_grain_type = "sample",
   alpha_grain_comment = "provided by authors",

   comment = factor("Extracted from the Jandt, U., Bruelheide, H., Berg, C., Bernhardt-Römermann, M., Blüml, V., Bode, F., Dengler, J., Diekmann, M., Dierschke, H., Dörfler, I., Döring, U., Dullinger, S., Härdtle, W., Haider, S., Heinken, T., Horchler, P., Jansen, F., Kudernatsch, T., Kuhn, G., Lindner, M., Matesanz, S., Metze, K., Meyer, S., Müller, F., Müller, N., Naaf, T., Peppler- Lisbach, C., Poschlod, P., Roscher, C., Rosenthal, G., Rumpf, S., Schmidt, W., Schrautzer, J., Schwabe, A., Schwartze, P., Sperle, T., Stanik, N., Stroh, H.-G., Storm, C., Voigt, W., von Heßberg, A., Wagner, E.R., von Oheimb, G., Wegener, U., Wesche, K., Wittig, B. & Wulf, M. (2022) ReSurvey Germany: vegetation-plot resurvey data from Germany [Dataset]. iDiv Data Repository. https://doi.org/10.25829/idiv.3514-0qsq70
Data are split by sample size: 118 distinct studies. Studies where the sample size (ie alpha_grain) is missing were excluded."),
   comment_standardisation = factor("The original data provides species cover layer by layer, these layers are added at the end of the local section between # character. Code meaning: '0: No layer, 1: Tree layer (uppermost), 2: Tree layer (middle), 3: Tree layer (lowest), 4: Shrub layer (uppermost), 5: Shrub layer (low), 6: Herb layer, 7: Juveniles, 8: Seedling (< 1 year), 9: Moss layer.'
When available, the authors note whether the plot had a treatment (Y) or not (N). The authors note 'Observations with NA were to our knowledge not part of an experiment, and thus, can be treated as N.' so we replaced NA values with N.
Regional is rs_site
Coordinates: 'Current monitoring programs and data protection of land owners do not allow us to provide location information at the highest available precision. In addition, some records contain occurrence data of rare and protected species. Thus, information on longitude and latitude was rounded to two decimal digits. Compared to the coordinates at highest available precision, rounding resulted in a mean uncertainty of 371 m (±138 m standard deviation), and thus, is within the somewhat limited range of accuracy provided by many custodians in the first place (see field PRECISION).'
Local is built as rs_plot!treatment!#layer#. In cases where there were several releves per rs_plot and date, local is built as rs_plot!treatment!_releve_nr_#layer#."),
   doi = "https://doi.org/10.25829/idiv.3514-0qsq70"
)]

ddata[, c('longitude','latitude','alpha_grain') := NULL]

## Saving raw data ----
data.table::setkey(ddata, dataset_id)
data.table::setkey(meta, dataset_id)
dataset_ids <- unique(meta$dataset_id)

# for (dataset_id_i in dataset_ids) {
#    dir.create(paste0("data/wrangled data/", dataset_id_i), showWarnings = FALSE)
#    data.table::fwrite(
#       x = ddata[dataset_id_i, !"releve_nr"], !"layer"
#       file = paste0("data/wrangled data/", dataset_id_i, "/", dataset_id_i, "_raw.csv"),
#       row.names = FALSE, sep = ","
#    )
#    data.table::fwrite(
#       x = meta[dataset_id_i, !"releve_nr"], !"layer"
#       file = paste0("data/wrangled data/", dataset_id_i, "/", dataset_id_i, "_raw_metadata.csv"),
#       row.names = FALSE, sep = ","
#    )
# }

# Standardised data ----
## data standardisation ----
### Keeping only plots where only one relevé was made ----
# Wubing stresses that several relevés were made when the original could not be
# accurately relocated.
# Removing the releve_nr from local and excluding
ddata[j = local := stringi::stri_replace_first_regex(local, "_[0-9]{1,3}$", "")]
ddata <- ddata[i = !ddata[j = data.table::uniqueN(releve_nr),
                          keyby = .(regional, local, year)][V1 > 1L],
               on = .(regional, local)] # no year here.

### Keeping only sites that were not treated ----
ddata <- ddata[i = base::grepl(pattern = "!N!", x = local, fixed = TRUE)][
   j = local := base::as.factor(base::sub(pattern = "!N!", replacement = "",
                                          x = local, fixed = TRUE))]

# Keeping sites with loc_method = 1 and precision < 1000 ----
ddata <- ddata[i = (is.na(precision) | precision <= 1000) &
                  is.element(loc_method, c(1L, 4L:6L))]

## Community data ----
### Pooling layers ----
#### Creating understory and tree layers ----
# ddata[, layer := as.integer(stringi::stri_extract_first_regex(local, "(?<=#)[0-9](?=#)"))]
# ddata[, layer := factor(c("understory", rep("tree", 3L), rep("understory", 5L)))[match(layer, 0L:8L)]]
# ddata[, local := stringi::stri_replace(local, replacement = "", regex = "#[0-9]#")]
# ddata[, local := stringi::stri_paste(local, layer, sep = "#")]
#
# meta[, layer := as.integer(stringi::stri_extract_first_regex(local, "(?<=#)[0-9](?=#)"))]
# meta[, layer := factor(c("understory", rep("tree", 3L), rep("understory", 5L)))[match(layer, 0L:8L)]]
# meta[, local := stringi::stri_replace(local, replacement = "", regex = "#[0-9]#")]
# meta[, local := stringi::stri_paste(local, layer, sep = "#")]

#### Pooling ----
data.table::setkey(ddata, dataset_id, regional, local,
                   year, month, day, species)
ddata <- ddata[j = .(species = unique(species)),
               keyby = .(dataset_id, regional, local, releve_nr, year, month, day)]

ddata[, ":="(
   value = 1L,
   metric = "pa",
   unit = "pa"
)]


### When a site is sampled several times a year, selecting 1st relevé ----
#### removing releve_nr from the local name ----
# ddata[, local := stringi::stri_replace_first_regex(
#    str = local,
#    pattern = "_[0-9]{1,6}_(?=#)",
#    replacement = "")] # regex checked

data.table::setkey(ddata, dataset_id, regional, local,
                   year, month, day, releve_nr)
# ddata <- ddata[
#    i = ddata[, j = .(releve_nr = releve_nr[1L]),
#              keyby = .(dataset_id, regional, local, year)],
#    on = .(dataset_id, regional, local, year, releve_nr)]
# ddata[, data.table::uniqueN(releve_nr), keyby = .(dataset_id,regional, local, year, month, day)]
ddata[, data.table::uniqueN(day), keyby = .(dataset_id, regional, local, year, month)][, table(V1)]
ddata[, data.table::uniqueN(month), keyby = .(dataset_id, regional, local, year)][, table(V1)]
ddata[, c("month", "day") := NULL]

while (ddata[j = diff(range(year)) < 9L,
             keyby = .(dataset_id, regional, local)][, any(V1)] ||
       ddata[j = data.table::uniqueN(local) < 4L,
             keyby = .(dataset_id, regional, year)][, any(V1)]) {
   ### Excluding sites that were not sampled at least twice 10 years apart ----
   ddata <- ddata[
      i = !ddata[j = diff(range(year)) < 9L,
                 keyby = .(dataset_id, regional, local)][(V1)],
      on = .(dataset_id, regional, local)]

   ### Excluding regions/years that don't have 4 localities ----
   ddata <- ddata[
      i = !ddata[j = data.table::uniqueN(local) < 4L,
                 keyby = .(dataset_id, regional, year)][(V1)],
      on = .(dataset_id, regional, year)]
}
# ddata[, .N, keyby = .(dataset_id, regional, local, year, species)][N != 1]

## Metadata ----
# meta[, local := stringi::stri_replace_first_regex(
#    str = local,
#    pattern = "_[0-9]{1,6}_(?=#)",
#    replacement = "")] # regex checked
meta[j = local := stringi::stri_replace_first_regex(local, "_[0-9]{1,3}$", "") |>
        base::sub(pattern = "!N!", replacement = "", fixed = TRUE) |>
        base::as.factor()]
meta <- unique(meta[, c("month", "day") := NULL])
meta <- meta[
   i = unique(ddata[, .(dataset_id, regional, local, releve_nr, year)]),
   on = .(dataset_id, regional, local, releve_nr, year)]

meta[, ":="(
   effort = 1L,

   gamma_sum_grains_unit = "m2",
   gamma_sum_grains_type = "sample",
   gamma_sum_grains_comment = "sum of sampled areas sampled per year and region",

   gamma_bounding_box_unit = "km2",
   gamma_bounding_box_type = "convex-hull",
   gamma_bounding_box_comment = "coordinates provided by the authors",

   comment_standardisation = factor(
      "The original data provides species cover layer by layer. Code meaning: '0: No layer, 1: Tree layer (uppermost), 2: Tree layer (middle), 3: Tree layer (lowest), 4: Shrub layer (uppermost), 5: Shrub layer (low), 6: Herb layer, 7: Juveniles, 8: Seedling (< 1 year), 9: Moss layer.' In this data set,
When available, the authors note whether the plot had a treatment (Y) or not (N). The authors note 'Observations with NA were to our knowledge not part of an experiment, and thus, can be treated as N.' so we replaced NA values with N. Here we kept only sites without treatment.
In localities that had several relevés a day, a month or a year, we selected the first relevé per year.
Finally, regions/years with less than 4 localities were excluded and localities that were not sampled at least 10 years apart were excluded.
Regional is rs_site
Local is rs_plot_releve_nr"),

   # layer = NULL,
   releve_nr = NULL
)][, ":="(
   gamma_bounding_box = geosphere::areaPolygon(data.frame(na.omit(longitude), na.omit(latitude))[grDevices::chull(na.omit(longitude), na.omit(latitude)), ]) / 10^6,
   gamma_sum_grains = sum(alpha_grain)),
   keyby = .(dataset_id, regional, year)]

ddata[, releve_nr := NULL]

## Saving standardised data ----
data.table::setkey(ddata, dataset_id)
data.table::setkey(meta, dataset_id)
dataset_ids <- unique(meta$dataset_id)

for (dataset_id_i in dataset_ids) {
   # dir.create(paste0("/Users/as80fywe/iDiv Dropbox/Alban Sagouis/BioTimeX/Local-Regional Homogenization/_discuss papers/German_resurvey/", dataset_id_i), showWarnings = FALSE)
   dir.create(paste0("data/wrangled data/", dataset_id_i), showWarnings = FALSE)
   data.table::fwrite(
      x = ddata[dataset_id_i],
      file = paste0("data/wrangled data/", dataset_id_i, "/", dataset_id_i, "_standardised.csv"),
      # file = paste0("/Users/as80fywe/iDiv Dropbox/Alban Sagouis/BioTimeX/Local-Regional Homogenization/_discuss papers/German_resurvey/", dataset_id_i, "/", dataset_id_i, "_standardised.csv"),
      row.names = FALSE, sep = ","
   )
   data.table::fwrite(
      x = meta[dataset_id_i],
      file = paste0("data/wrangled data/", dataset_id_i, "/", dataset_id_i, "_standardised_metadata.csv"),
      # file = paste0("/Users/as80fywe/iDiv Dropbox/Alban Sagouis/BioTimeX/Local-Regional Homogenization/_discuss papers/German_resurvey/", dataset_id_i, "/", dataset_id_i, "_standardised_metadata.csv"),
      row.names = FALSE, sep = ",", bom = TRUE
   )
}

length(unique(meta$dataset_id))
meta[, length(unique(regional)), keyby = .(dataset_id)][, sum(V1)]
meta[, length(unique(local)), keyby = .(dataset_id, regional)][, sum(V1)]
meta[, .N, keyby = .(dataset_id, regional, local, year)][, sum(N)]
ddata[, .N, keyby = .(dataset_id, regional, local, year)][, summary(N)]

