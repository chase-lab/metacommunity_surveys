#' Resampling individuals in a site
#'
#' @param species a character vector of species names or codes
#' @param value an integer vector of abundances
#' @param min_sample_size the total abundance in the site with the smallest effort.
#' If several sites share this smallest effort, then this is the minimal value.
#' @param replace If the submitted site has a smaller total abundance than the
#' min_sample_size despite having a greater effort, replace has to be TRUE
#'
#' @return an integer vector of same length and order as species. If a species got
#' extinct in the process, it was returned as a NA.
#' @export
#'

resampling <- function(species, value, min_sample_size, replace = FALSE) {
   stopifnot(is.character(species))
   stopifnot(is.integer(value))
   comm <- table(sample(x = rep(species, times = value), min_sample_size, replace = replace))
   if (length(comm) < length(value)) {
      comm <- comm[data.table::chmatch(species, names(comm), nomatch = NA)]
   }
   return(comm)
}
