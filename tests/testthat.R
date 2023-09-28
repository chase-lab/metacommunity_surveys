data.table::setDTthreads(4)
testthat::test_dir(path = "tests/testthat/", reporter = "list",
                   stop_on_warning = TRUE)
data.table::setDTthreads(8)
