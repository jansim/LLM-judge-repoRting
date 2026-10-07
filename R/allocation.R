#' Allocate a calibration budget
#'
#' Splits a total calibration budget `m` between truly incorrect items
#' (`m0`, used to estimate specificity) and truly correct items (`m1`, used to
#' estimate sensitivity) so as to reduce the uncertainty of the adjusted
#' accuracy estimate.
#'
#' All arguments except `eps` are vectorised and recycled against each other
#' (each must have length 1 or a common length).
#'
#' @param m Total calibration budget (positive integer).
#' @param p Proportion of test items judged "correct", in \eqn{[0, 1]}.
#' @param q0_pilot,q1_pilot Pilot estimates of (or prior beliefs about) the
#'   judge's specificity and sensitivity.
#' @param m_pilot Number of pilot calibration samples already collected
#'   (non-negative integer). If `0`, `q0_pilot` and `q1_pilot` are treated as
#'   given values and a warning is issued.
#' @param eps Small positive value for numerical stability.
#'
#' @return A data frame with one row per set of inputs and integer columns
#'   `m0` and `m1`, which sum to `m`.
#'
#' @seealso [point_estimator()], [confidence_interval()]
#' @inherit point_estimator references
#' @export
#' @examples
#' allocate_calibration_sample(m = 200, p = 0.4, q0_pilot = 0.7,
#'                             q1_pilot = 0.9, m_pilot = 10)
#'
#' # Allocation across several budgets
#' allocate_calibration_sample(m = c(100, 200, 400), p = 0.4, q0_pilot = 0.7,
#'                             q1_pilot = 0.9, m_pilot = 10)
allocate_calibration_sample <- function(m, p, q0_pilot = 0.9, q1_pilot = 0.9,
                                        m_pilot = 0, eps = 1e-6) {
  check_proportion(p, "p")
  check_proportion(q0_pilot, "q0_pilot")
  check_proportion(q1_pilot, "q1_pilot")
  check_count(m, "m")
  check_count(m_pilot, "m_pilot", allow_zero = TRUE)
  len <- common_length(m, p, q0_pilot, q1_pilot, m_pilot)

  m <- rep_len(m, len)
  p <- rep_len(p, len)
  m_pilot <- rep_len(m_pilot, len)

  given <- m_pilot == 0
  if (any(given & p >= eps)) {
    warning(
      "If 'm_pilot' is 0, compute kappa using q0 and q1 as given values.",
      call. = FALSE
    )
  }

  kappa <- ifelse(
    given,
    (1 - q0_pilot) / (1 - pmin(q1_pilot, 1 - eps)),
    (m_pilot * (1 - q0_pilot) + 1) / (m_pilot * (1 - q1_pilot) + 1)
  )
  m1 <- m / (1 + (1 / p - 1) * sqrt(kappa))
  # round() in R, like Python's round(), rounds half to even
  m1 <- pmax(m_pilot, round(pmin(m - m_pilot, m1)))
  m1 <- ifelse(p < eps, m - m_pilot, m1)

  data.frame(
    m0 = as.integer(m - m1),
    m1 = as.integer(m1)
  )
}
