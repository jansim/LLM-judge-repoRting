#' Bias-adjusted point estimate of accuracy
#'
#' Corrects the proportion of items an LLM judge labels "correct" for the
#' judge's imperfect specificity and sensitivity:
#' \deqn{\hat\theta = \frac{p + q_0 - 1}{q_0 + q_1 - 1},}
#' clipped to \eqn{[0, 1]}.
#'
#' All arguments are vectorised and recycled against each other (each must
#' have length 1 or a common length).
#'
#' @param p Proportion of test items judged "correct",
#'   \eqn{\Pr(\text{Predict} = \text{correct})}.
#' @param q0 Specificity of the judge,
#'   \eqn{\Pr(\text{Predict} = \text{incorrect} \mid \text{True} = \text{incorrect})}.
#' @param q1 Sensitivity of the judge,
#'   \eqn{\Pr(\text{Predict} = \text{correct} \mid \text{True} = \text{correct})}.
#'
#' @return A numeric vector of estimates in \eqn{[0, 1]}.
#'
#' @details The judge is assumed to be better than random, i.e.
#'   `q0 + q1 > 1`; `q0 + q1 == 1` is an error.
#'
#' @seealso [confidence_interval()], [allocate_calibration_sample()]
#' @references Lee, C., Zeng, T., Jeong, J., Sohn, J., & Lee, K. (2025).
#'   How to Correctly Report LLM-as-a-Judge Evaluations. arXiv:2511.21140.
#' @export
#' @examples
#' point_estimator(p = 0.4, q0 = 0.7, q1 = 0.9)
#'
#' # Vectorised over the test-set proportion
#' point_estimator(p = c(0.3, 0.4, 0.5), q0 = 0.7, q1 = 0.9)
point_estimator <- function(p, q0, q1) {
  check_proportion(p, "p")
  check_proportion(q0, "q0")
  check_proportion(q1, "q1")
  common_length(p, q0, q1)

  denom <- check_denominator(q0 + q1 - 1)
  clip((p + q0 - 1) / denom)
}

#' Adjusted confidence interval for accuracy
#'
#' Computes a \eqn{(1 - \alpha)} confidence interval for the bias-adjusted
#' accuracy, using a plug-in approach with smoothing so that the interval
#' reflects uncertainty from both the test set (`p`) and the calibration set
#' (`q0`, `q1`).
#'
#' All arguments are vectorised and recycled against each other (each must
#' have length 1 or a common length).
#'
#' @inheritParams point_estimator
#' @param n Size of the test set (positive integer).
#' @param m0 Number of truly incorrect items in the calibration set, used to
#'   estimate `q0` (positive integer).
#' @param m1 Number of truly correct items in the calibration set, used to
#'   estimate `q1` (positive integer).
#' @param alpha Significance level; the interval has nominal coverage
#'   `1 - alpha`.
#'
#' @return A data frame with one row per set of inputs and columns `lower`
#'   and `upper`, both clipped to \eqn{[0, 1]}.
#'
#' @seealso [point_estimator()], [allocate_calibration_sample()]
#' @inherit point_estimator references
#' @export
#' @examples
#' confidence_interval(p = 0.4, q0 = 0.7, q1 = 0.9, n = 1000, m0 = 200, m1 = 200)
#'
#' # Interval width shrinks as the calibration set grows
#' confidence_interval(
#'   p = 0.4, q0 = 0.7, q1 = 0.9, n = 1000,
#'   m0 = c(50, 100, 200), m1 = c(50, 100, 200)
#' )
confidence_interval <- function(p, q0, q1, n, m0, m1, alpha = 0.05) {
  check_proportion(alpha, "alpha")
  check_proportion(p, "p")
  check_proportion(q0, "q0")
  check_proportion(q1, "q1")
  check_count(n, "n")
  check_count(m0, "m0")
  check_count(m1, "m1")
  common_length(p, q0, q1, n, m0, m1, alpha)

  z <- stats::qnorm(1 - alpha / 2)
  # Smoothed estimates and effective sample sizes
  p <- (n * p + z^2 / 2) / (n + z^2)
  q0 <- (m0 * q0 + 1) / (m0 + 2)
  q1 <- (m1 * q1 + 1) / (m1 + 2)
  n <- n + z^2
  m0 <- m0 + 2
  m1 <- m1 + 2

  denom <- check_denominator(q0 + q1 - 1)
  th <- (p + q0 - 1) / denom
  dth <- 2 * z^2 * (-(1 - th) * q0 * (1 - q0) / m0 + th * q1 * (1 - q1) / m1)
  se <- sqrt(
    p * (1 - p) / n + (1 - th)^2 * q0 * (1 - q0) / m0 + th^2 * q1 * (1 - q1) / m1
  ) / denom

  data.frame(
    lower = clip(th + dth - z * se),
    upper = clip(th + dth + z * se)
  )
}
