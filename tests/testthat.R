data.table::setDTthreads(4)
require(withr)
testthat::test_dir(path = "tests/testthat/")
data.table::setDTthreads(8)
