# llmjudgereporting

An R port of the Python package
[`llm_judge_reporting`](https://github.com/UW-Madison-Lee-Lab/LLM-judge-reporting)
accompanying

> Lee, C., Zeng, T., Jeong, J., Sohn, J., & Lee, K. (2025). *How to
> Correctly Report LLM-as-a-Judge Evaluations.*
> [arXiv:2511.21140](https://arxiv.org/abs/2511.21140)

LLM judges have imperfect specificity and sensitivity, so the raw share
of answers they mark as “correct” is a biased estimate of accuracy. This
package corrects that bias, builds confidence intervals that account for
uncertainty in both the test set and the calibration set, and splits a
calibration budget between truly incorrect and truly correct items.

## Installation

``` r

# install.packages("remotes")
remotes::install_github("jansim/LLM-judge-repoRting")
```

## Functions

| R | Python | Returns |
|----|----|----|
| `point_estimator(p, q0, q1)` | `point_estimator(p, q0, q1)` | numeric vector |
| `confidence_interval(p, q0, q1, n, m0, m1, alpha = 0.05)` | `confidence_interval(p, q0, q1, n, m0, m1, alpha=0.05)` | data frame with `lower`, `upper` |
| `allocate_calibration_sample(m, p, q0_pilot = 0.9, q1_pilot = 0.9, m_pilot = 0, eps = 1e-6)` | `allocate_calibration_sample(m, p, q0_pilot=0.9, q1_pilot=0.9, m_pilot=0, eps=1e-6)` | data frame with integer `m0`, `m1` |

Inputs:

- `p`: proportion judged “correct” on the test set, Pr(Predict =
  correct)
- `q0`: specificity, Pr(Predict = incorrect \| True = incorrect)
- `q1`: sensitivity, Pr(Predict = correct \| True = correct)
- `n`: test set size; `m0`, `m1`: calibration subset sizes for truly
  incorrect / truly correct items

The judge must be better than random (`q0 + q1 > 1`).

Differences from the Python package, following R conventions:

- All functions are vectorised: arguments are recycled against each
  other (length 1 or a common length), so you can evaluate many
  scenarios at once.
- Tuples are returned as data frames with named columns (one row per
  input).
- Integer arguments (`n`, `m0`, `m1`, `m`, `m_pilot`) accept any whole
  number, e.g. `200` as well as `200L`.
- Invalid input raises an R error with the same message as the Python
  assertion; `q0 + q1 == 1` raises an error instead of
  `ZeroDivisionError`.

## Usage

Point estimate and confidence interval:

``` r

library(llmjudgereporting)

p <- 0.4; n <- 1000
q0 <- 0.7; q1 <- 0.9; m0 <- 200; m1 <- 200

point_estimator(p, q0, q1)
#> [1] 0.1666667

confidence_interval(p, q0, q1, n, m0, m1, alpha = 0.05)
#>        lower    upper
#> 1 0.05635072 0.262733
```

Allocate calibration samples:

``` r

allocate_calibration_sample(m = 200, p = 0.4, q0_pilot = 0.7, q1_pilot = 0.9,
                            m_pilot = 10)
#>    m0 m1
#> 1 136 64
```

Vectorised use, e.g. how the interval narrows with a growing calibration
set:

``` r

confidence_interval(p = 0.4, q0 = 0.7, q1 = 0.9, n = 1000,
                    m0 = c(50, 100, 200), m1 = c(50, 100, 200))
#>        lower     upper
#> 1 0.00000000 0.3281189
#> 2 0.01390166 0.2897995
#> 3 0.05635072 0.2627330
```

## Parity with the Python package

`tests/testthat/fixtures/` holds reference values computed with the
Python package (pinned to commit
[`082884d`](https://github.com/UW-Madison-Lee-Lab/LLM-judge-reporting/tree/082884d075188bed2f2645234fa2cc3050a517c5)),
and the test suite checks that the R functions reproduce them. To
regenerate them:

``` bash
pip install "git+https://github.com/UW-Madison-Lee-Lab/LLM-judge-reporting.git@082884d075188bed2f2645234fa2cc3050a517c5"
python data-raw/generate_reference_values.py
```

The `python-parity` workflow does this in CI, failing if the committed
values are out of date, and also runs it weekly against the latest
upstream version.

## Citation

    @article{lee2025correctly,
      title         = {How to Correctly Report LLM-as-a-Judge Evaluations},
      author        = {Lee, Chungpa and Zeng, Thomas and Jeong, Jongwon and Sohn, Jy-yong and Lee, Kangwook},
      year          = {2025},
      eprint        = {2511.21140},
      archivePrefix = {arXiv}
    }
