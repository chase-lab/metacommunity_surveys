# russel-smith_2017_shrubs
dataset_id <- "russell-smith_2017_shrubs"

# loading data ----
datafiles <- c(
   "./data/raw data/russell-smith_2017/tpsk_shrubs_1994+_p831t1065.csv",
   "./data/raw data/russell-smith_2017/tpsl_shrubs_1994+_p831t1123.csv",
   "./data/raw data/russell-smith_2017/tpsn_shrubs_1994+_p831t1128.csv"
)
datafiles_dates <- c(
   "./data/raw data/russell-smith_2017/tpsk_visit_date_1994+_p831t1067.csv",
   "./data/raw data/russell-smith_2017/tpsl_visit_date_1994+_p831t1125.csv",
   "./data/raw data/russell-smith_2017/tpsn_visit_date_1994+_p831t1153.csv"
)

ddata <- data.table::rbindlist(
   lapply(
      datafiles,
      FUN = function(x)
         data.table::fread(file = x, na.strings = "NA")
   ),
   use.names = TRUE, idcol = FALSE
)

dates <- data.table::rbindlist(
   lapply(
      datafiles_dates,
      FUN = function(x)
         data.table::fread(file = x)
   ),
   use.names = TRUE, idcol = FALSE
)

# merging data.table style ----
ddata <- dates[ddata, on = c("park","plot","visit")]
# unique(ddata[is.na(as.integer(`count_50cm-2m`))]$`count_50cm-2m`)
# unique(ddata[is.na(as.integer(count_less_than_50cm))]$count_less_than_50cm)
# unique(ddata[is.na(as.integer(count_greater_than_2m))]$count_greater_than_2m)
ddata[, ":="(
   count_less_than_50cm = as.integer(count_less_than_50cm),
   `count_50cm-2m` = as.integer(`count_50cm-2m`),
   count_greater_than_2m = as.integer(count_greater_than_2m)
)]

ddata[, value := apply(ddata[, .(count_less_than_50cm, `count_50cm-2m`, count_greater_than_2m)], 1, sum, na.rm = TRUE)]

data.table::setnames(ddata, c("park", "plot","genus_species"), c("regional","local","species"))

# communities ----

ddata[, ":="(
   dataset_id = dataset_id,

   year = format(date, "%Y"),

   visit = NULL,
   date = NULL,
   comments = NULL,
   count_less_than_50cm = NULL,
   `count_50cm-2m` = NULL,
   count_greater_than_2m = NULL
)]
