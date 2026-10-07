# Reference values produced by the Python package, see
# data-raw/generate_reference_values.py
read_reference <- function(name) {
  utils::read.csv(test_path("fixtures", name), stringsAsFactors = FALSE)
}

# Python and R floating point results may differ in the last few bits
# (e.g. scipy's ndtri vs. R's qnorm).
reference_tolerance <- 1e-12
