# Adjusted confidence interval for accuracy

Computes a \\(1 - \alpha)\\ confidence interval for the bias-adjusted
accuracy, using a plug-in approach with smoothing so that the interval
reflects uncertainty from both the test set (`p`) and the calibration
set (`q0`, `q1`).

## Usage

``` r
confidence_interval(p, q0, q1, n, m0, m1, alpha = 0.05)
```

## Arguments

- p:

  Proportion of test items judged "correct", \\\Pr(\text{Predict} =
  \text{correct})\\.

- q0:

  Specificity of the judge, \\\Pr(\text{Predict} = \text{incorrect} \mid
  \text{True} = \text{incorrect})\\.

- q1:

  Sensitivity of the judge, \\\Pr(\text{Predict} = \text{correct} \mid
  \text{True} = \text{correct})\\.

- n:

  Size of the test set (positive integer).

- m0:

  Number of truly incorrect items in the calibration set, used to
  estimate `q0` (positive integer).

- m1:

  Number of truly correct items in the calibration set, used to estimate
  `q1` (positive integer).

- alpha:

  Significance level; the interval has nominal coverage `1 - alpha`.

## Value

A data frame with one row per set of inputs and columns `lower` and
`upper`, both clipped to \\\[0, 1\]\\.

## Details

All arguments are vectorised and recycled against each other (each must
have length 1 or a common length).

## References

Lee, C., Zeng, T., Jeong, J., Sohn, J., & Lee, K. (2025). How to
Correctly Report LLM-as-a-Judge Evaluations. arXiv:2511.21140.

## See also

[`point_estimator()`](https://jansim.github.io/LLM-judge-repoRting/reference/point_estimator.md),
[`allocate_calibration_sample()`](https://jansim.github.io/LLM-judge-repoRting/reference/allocate_calibration_sample.md)

## Examples

``` r
confidence_interval(p = 0.4, q0 = 0.7, q1 = 0.9, n = 1000, m0 = 200, m1 = 200)
#>        lower    upper
#> 1 0.05635072 0.262733

# Interval width shrinks as the calibration set grows
confidence_interval(
  p = 0.4, q0 = 0.7, q1 = 0.9, n = 1000,
  m0 = c(50, 100, 200), m1 = c(50, 100, 200)
)
#>        lower     upper
#> 1 0.00000000 0.3281189
#> 2 0.01390166 0.2897995
#> 3 0.05635072 0.2627330
```
