ref <- read_reference("point_estimator.csv")

test_that("point_estimator() matches the Python reference values", {
  for (i in seq_len(nrow(ref))) {
    r <- ref[i, ]
    expect_equal(
      point_estimator(r$p, r$q0, r$q1), r$estimate,
      tolerance = reference_tolerance, label = paste("row", i)
    )
  }
})

test_that("point_estimator() is vectorised", {
  expect_equal(
    point_estimator(ref$p, ref$q0, ref$q1), ref$estimate,
    tolerance = reference_tolerance
  )
  expect_equal(
    point_estimator(c(0.3, 0.4), 0.7, 0.9),
    c(point_estimator(0.3, 0.7, 0.9), point_estimator(0.4, 0.7, 0.9))
  )
})

test_that("point_estimator() validates its inputs", {
  expect_error(point_estimator(1.1, 0.7, 0.9), "p must be in [0, 1]", fixed = TRUE)
  expect_error(point_estimator(0.4, -0.1, 0.9), "q0 must be in [0, 1]", fixed = TRUE)
  expect_error(point_estimator(0.4, 0.7, NA), "q1 must be in [0, 1]", fixed = TRUE)
  expect_error(point_estimator("0.4", 0.7, 0.9), "p must be in [0, 1]", fixed = TRUE)
  expect_error(point_estimator(0.4, 0.5, 0.5), "must not be 0")
  expect_error(point_estimator(c(0.1, 0.2), c(0.7, 0.8, 0.9), 0.9), "common length")
})
