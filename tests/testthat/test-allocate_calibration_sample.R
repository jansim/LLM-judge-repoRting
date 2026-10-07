ref <- read_reference("allocate_calibration_sample.csv")

test_that("allocate_calibration_sample() matches the Python reference values", {
  for (i in seq_len(nrow(ref))) {
    r <- ref[i, ]
    call <- quote(allocate_calibration_sample(
      r$m, r$p, q0_pilot = r$q0_pilot, q1_pilot = r$q1_pilot,
      m_pilot = r$m_pilot
    ))
    if (r$warned) {
      expect_warning(res <- eval(call), "m_pilot' is 0")
    } else {
      expect_no_warning(res <- eval(call))
    }
    expect_identical(c(res$m0, res$m1), c(r$m0, r$m1), label = paste("row", i))
  }
})

test_that("allocate_calibration_sample() is vectorised and returns a data frame", {
  res <- suppressWarnings(allocate_calibration_sample(
    ref$m, ref$p, ref$q0_pilot, ref$q1_pilot, ref$m_pilot
  ))
  expect_s3_class(res, "data.frame")
  expect_named(res, c("m0", "m1"))
  expect_type(res$m0, "integer")
  expect_type(res$m1, "integer")
  expect_identical(res$m0, ref$m0)
  expect_identical(res$m1, ref$m1)
  expect_identical(res$m0 + res$m1, as.integer(ref$m))
})

test_that("allocate_calibration_sample() warns once when m_pilot is 0", {
  expect_warning(allocate_calibration_sample(200, 0.4), "m_pilot' is 0")
  expect_no_warning(allocate_calibration_sample(200, 0, m_pilot = 0))
  expect_warning(
    allocate_calibration_sample(200, c(0.2, 0.4, 0.6)),
    "m_pilot' is 0"
  )
})

test_that("allocate_calibration_sample() validates its inputs", {
  expect_error(allocate_calibration_sample(200, 1.5), "p must be in [0, 1]",
               fixed = TRUE)
  expect_error(allocate_calibration_sample(200, 0.4, q0_pilot = -1, m_pilot = 1),
               "q0_pilot must be in [0, 1]", fixed = TRUE)
  expect_error(allocate_calibration_sample(200, 0.4, q1_pilot = 2, m_pilot = 1),
               "q1_pilot must be in [0, 1]", fixed = TRUE)
  expect_error(allocate_calibration_sample(0, 0.4, m_pilot = 1),
               "m must be a positive integer")
  expect_error(allocate_calibration_sample(200.5, 0.4, m_pilot = 1),
               "m must be a positive integer")
  expect_error(allocate_calibration_sample(200, 0.4, m_pilot = -1),
               "m_pilot must be a non-negative integer")
})
