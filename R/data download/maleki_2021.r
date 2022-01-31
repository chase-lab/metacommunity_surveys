# maleki_2021
dataset_id <- "maleki_2021"

if (!file.exists(paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))) {
  archive_path <- rdryad::dryad_download("10.5061/dryad.tqjq2bvwz")[[1]][1]

  comm <- data.table::as.data.table(
    utils::read.csv(
      base::unz(
        description = archive_path,
        filename = "hectare_stems.csv"
      )
    )
  )

  meas <- data.table::as.data.table(
    utils::read.csv(
      base::unz(
        description = archive_path,
        filename = "hectare_stem_meas.csv"
      )
    )
  )

  spec <- data.table::as.data.table(
    utils::read.csv(
      base::unz(
        description = archive_path,
        filename = "code_species.csv"
      )
    )
  )

  env <- data.table::as.data.table(
    utils::read.csv(
      base::unz(
        description = archive_path,
        filename = "hectare_plots.csv"
      )
    )
  )


  ddata <- merge(comm, meas, by = "stem_id")
  ddata <- merge(ddata, spec, by = "species_id")
  ddata <- merge(ddata, env, by = "plot_id")

  dir.create(paste0("./data/raw data/", dataset_id), showWarnings = FALSE)
  base::saveRDS(ddata, file = paste("data/raw data", dataset_id, "ddata.rds", sep = "/"))
}
