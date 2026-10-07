# Allocate a calibration budget

Splits a total calibration budget `m` between truly incorrect items
(`m0`, used to estimate specificity) and truly correct items (`m1`, used
to estimate sensitivity) so as to reduce the uncertainty of the adjusted
accuracy estimate.

## Usage

``` r
allocate_calibration_sample(
  m,
  p,
  q0_pilot = 0.9,
  q1_pilot = 0.9,
  m_pilot = 0,
  eps = 1e-06
)
```

## Arguments

- m:

  Total calibration budget (positive integer).

- p:

  Proportion of test items judged "correct", in \\\[0, 1\]\\.

- q0_pilot, q1_pilot:

  Pilot estimates of (or prior beliefs about) the judge's specificity
  and sensitivity.

- m_pilot:

  Number of pilot calibration samples already collected (non-negative
  integer). If `0`, `q0_pilot` and `q1_pilot` are treated as given
  values and a warning is issued.

- eps:

  Small positive value for numerical stability.

## Value

A data frame with one row per set of inputs and integer columns `m0` and
`m1`, which sum to `m`.

## Details

All arguments except `eps` are vectorised and recycled against each
other (each must have length 1 or a common length).

## References

Lee, C., Zeng, T., Jeong, J., Sohn, J., & Lee, K. (2025). How to
Correctly Report LLM-as-a-Judge Evaluations. arXiv:2511.21140.

## See also

[`point_estimator()`](https://jansim.github.io/LLM-judge-repoRting/reference/point_estimator.md),
[`confidence_interval()`](https://jansim.github.io/LLM-judge-repoRting/reference/confidence_interval.md)

## Examples

``` r
allocate_calibration_sample(m = 200, p = 0.4, q0_pilot = 0.7,
                            q1_pilot = 0.9, m_pilot = 10)
#>    m0 m1
#> 1 136 64

# Allocation across several budgets
allocate_calibration_sample(m = c(100, 200, 400), p = 0.4, q0_pilot = 0.7,
                            q1_pilot = 0.9, m_pilot = 10)
#>    m0  m1
#> 1  68  32
#> 2 136  64
#> 3 272 128
```
