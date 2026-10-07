ref <- read_reference("confidence_interval.csv")

test_that("confidence_interval() matches the Python reference values", {
  for (i in seq_len(nrow(ref))) {
    r <- ref[i, ]
    ci <- confidence_interval(r$p, r$q0, r$q1, r$n, r$m0, r$m1, alpha = r$alpha)
    expect_equal(
      c(ci$lower, ci$upper), c(r$lower, r$upper),
      tolerance = reference_tolerance, label = paste("row", i)
    )
  }
})

test_that("confidence_interval() is vectorised and returns a data frame", {
  ci <- confidence_interval(
    ref$p, ref$q0, ref$q1, ref$n, ref$m0, ref$m1, alpha = ref$alpha
  )
  expect_s3_class(ci, "data.frame")
  expect_named(ci, c("lower", "upper"))
  expect_equal(ci$lower, ref$lower, tolerance = reference_tolerance)
  expect_equal(ci$upper, ref$upper, tolerance = reference_tolerance)

  ci <- confidence_interval(0.4, 0.7, 0.9, 1000, c(50, 200), c(50, 200))
  expect_equal(nrow(ci), 2)
  expect_true(all(diff(ci$upper - ci$lower) < 0))
})

test_that("confidence_interval() uses alpha = 0.05 by default", {
  expect_identical(
    confidence_interval(0.4, 0.7, 0.9, 1000, 200, 200),
    confidence_interval(0.4, 0.7, 0.9, 1000, 200, 200, alpha = 0.05)
  )
})

test_that("confidence_interval() validates its inputs", {
  expect_error(confidence_interval(0.4, 0.7, 0.9, 1000, 200, 200, alpha = 2),
               "alpha must be in [0, 1]", fixed = TRUE)
  expect_error(confidence_interval(0.4, 0.7, 0.9, 0, 200, 200),
               "n must be a positive integer")
  expect_error(confidence_interval(0.4, 0.7, 0.9, 1000, 2.5, 200),
               "m0 must be a positive integer")
  expect_error(confidence_interval(0.4, 0.7, 0.9, 1000, 200, -1),
               "m1 must be a positive integer")
  expect_error(confidence_interval(0.4, 0.7, 0.9, 1000, 200, NA),
               "m1 must be a positive integer")
})
