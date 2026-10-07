# Equivalent of the Python helper `clip()`, vectorised.
clip <- function(x, low = 0, high = 1) {
  pmax(low, pmin(high, x))
}

check_proportion <- function(x, name) {
  if (!is.numeric(x) || length(x) == 0L || anyNA(x) || any(x < 0 | x > 1)) {
    stop(name, " must be in [0, 1]", call. = FALSE)
  }
  invisible(x)
}

check_count <- function(x, name, allow_zero = FALSE) {
  ok <- is.numeric(x) && length(x) > 0L && !anyNA(x) && all(is.finite(x)) &&
    all(x == round(x)) && all(if (allow_zero) x >= 0 else x > 0)
  if (!ok) {
    what <- if (allow_zero) "a non-negative integer" else "a positive integer"
    stop(name, " must be ", what, call. = FALSE)
  }
  invisible(x)
}

# Arguments must have length 1 or a common length; returns that length.
common_length <- function(...) {
  lengths <- lengths(list(...))
  n <- max(lengths)
  if (any(lengths != 1L & lengths != n)) {
    stop("Arguments must have length 1 or a common length.", call. = FALSE)
  }
  n
}

check_denominator <- function(denom) {
  if (any(denom == 0)) {
    stop(
      "q0 + q1 - 1 must not be 0 (the judge must be better than random).",
      call. = FALSE
    )
  }
  invisible(denom)
}
