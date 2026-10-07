# Bias-adjusted point estimate of accuracy

Corrects the proportion of items an LLM judge labels "correct" for the
judge's imperfect specificity and sensitivity: \$\$\hat\theta =
\frac{p + q_0 - 1}{q_0 + q_1 - 1},\$\$ clipped to \\\[0, 1\]\\.

## Usage

``` r
point_estimator(p, q0, q1)
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

## Value

A numeric vector of estimates in \\\[0, 1\]\\.

## Details

All arguments are vectorised and recycled against each other (each must
have length 1 or a common length).

The judge is assumed to be better than random, i.e. `q0 + q1 > 1`;
`q0 + q1 == 1` is an error.

## References

Lee, C., Zeng, T., Jeong, J., Sohn, J., & Lee, K. (2025). How to
Correctly Report LLM-as-a-Judge Evaluations. arXiv:2511.21140.

## See also

[`confidence_interval()`](https://jansim.github.io/LLM-judge-repoRting/reference/confidence_interval.md),
[`allocate_calibration_sample()`](https://jansim.github.io/LLM-judge-repoRting/reference/allocate_calibration_sample.md)

## Examples

``` r
point_estimator(p = 0.4, q0 = 0.7, q1 = 0.9)
#> [1] 0.1666667

# Vectorised over the test-set proportion
point_estimator(p = c(0.3, 0.4, 0.5), q0 = 0.7, q1 = 0.9)
#> [1] 0.0000000 0.1666667 0.3333333
```
