# jandt_2022
dataset_id <- "jandt_2022"
# library(data.table)

ddata <- base::readRDS("data/raw data/jandt_2022/rdata.rds")
data.table::setnames(ddata, tolower(colnames(ddata)))

# Wubing's comment 1 ----
# How many releve_nr per projeect_id/rs_plot/year?
ddata[j = data.table::uniqueN(releve_nr), by = .(project_id,rs_plot, year)][, summary(V1)]
ddata[j = data.table::uniqueN(releve_nr), by = .(project_id,rs_plot, year)][, stem(V1)]

# Wubing's comment 2 & 4 ----
# How many releves have precision information?
ddata[j = .(percent_NA = sum(is.na(precision)) / .N * 100),
      keyby = .(project_id, rs_plot, releve_nr, year)][, table(percent_NA)]

# What is the distribution of the precision?
ddata[j = unique(precision), keyby = .(project_id, rs_plot, releve_nr)][, table(V1)]
ddata[j = unique(precision), keyby = .(project_id, rs_plot, releve_nr)][, hist(V1)]

# How many releves have loc_method data?
ddata[j = .(percent_NA = sum(is.na(loc_method)) / .N * 100),
      keyby = .(project_id, rs_plot, releve_nr, year)][, table(percent_NA)]
# What is the precision per localisation method?
ddata[j = .(precision = unique(na.omit(precision))),
      keyby = .(project_id, rs_plot, releve_nr, year,loc_method)][
         j = .(mean = mean(precision), sd = sd(precision)),
         keyby = loc_method
      ]

# Wubing's comment 3 ----
# Is the plot area inside a project comparable?
ddata <- ddata[!is.na(surf_area)]
ddata[j = .(N = data.table::uniqueN(surf_area), mean = mean(surf_area), sd = sd(surf_area)),
      keyby = .(project_id)][order(sd, decreasing = FALSE)]

# How many points with design rs_site?
x <- ddata[j = .(dataset_id = surf_area, regional = rs_site,
                 local = rs_plot, local2 = layer, year, date)] |>
   unique()
x <- x[i = x[j = data.table::uniqueN(local),
             by = .(dataset_id, regional, year),
][V1 >= 4L],
on = .(dataset_id, regional, year)]

x <- x[i = x[j = .(diff(range(year))), by = .(dataset_id, regional, local)][V1 > 9L],
       on = .(dataset_id, regional, local)]

x <- x[i = x[j = data.table::uniqueN(local),
             by = .(dataset_id, regional, year),
][V1 >= 4L],
on = .(dataset_id, regional, year)]
x <- x[i = x[j = .(diff(range(year))), by = .(dataset_id, regional, local)][V1 > 9L],
       on = .(dataset_id, regional, local)]

nrow(x)

# How many points with project_id?
y = ddata[i = loc_method == 1,
          j = .(dataset_id = surf_area, regional = project_id,
                local = rs_plot, local2 = releve_nr, local3 = layer, year, date)] |>
   unique()

y <- y[i = y[j = data.table::uniqueN(local),
             by = .(dataset_id, regional, year),
][V1 >= 4L],
on = .(dataset_id, regional, year)]
y <- y[i = y[j = .(diff(range(year))), by = .(dataset_id, regional, local)][V1 > 9L],
       on = .(dataset_id, regional, local)]

y <- y[i = y[j = data.table::uniqueN(local),
             by = .(dataset_id, regional, year),
][V1 >= 4L],
on = .(dataset_id, regional, year)]
y <- y[i = y[j = .(diff(range(year))), by = .(dataset_id, regional, local)][V1 > 9L],
       on = .(dataset_id, regional, local)]
nrow(y)
