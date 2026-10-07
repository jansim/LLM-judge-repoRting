"""Generate reference values from the Python `llm_judge_reporting` package.

The R test suite compares the R port against these values.

Usage (from the repository root):

    pip install "git+https://github.com/UW-Madison-Lee-Lab/LLM-judge-reporting.git@082884d075188bed2f2645234fa2cc3050a517c5"
    python data-raw/generate_reference_values.py

Writes CSV files to tests/testthat/fixtures/.
"""

import csv
import os
import warnings

from llm_judge_reporting import (
    allocate_calibration_sample,
    confidence_interval,
    point_estimator,
)

OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "tests", "testthat", "fixtures")

# (p, q0, q1)
POINT_CASES = [
    (0.4, 0.7, 0.9),    # README example
    (0.5, 0.8, 0.8),
    (0.62, 0.85, 0.93),
    (0.1, 0.95, 0.6),
    (0.9, 0.6, 0.99),
    (0.05, 0.9, 0.9),   # clipped at 0
    (0.97, 0.9, 0.9),   # clipped at 1
    (0.3333, 0.777, 0.888),
    (0.0, 1.0, 1.0),
    (1.0, 1.0, 1.0),
    (0.25, 0.75, 0.55),
    (0.7, 0.51, 0.52),
]

# (p, q0, q1, n, m0, m1, alpha)
CI_CASES = [
    (0.4, 0.7, 0.9, 1000, 200, 200, 0.05),  # README example
    (0.5, 0.8, 0.8, 500, 100, 100, 0.05),
    (0.62, 0.85, 0.93, 2000, 150, 350, 0.05),
    (0.1, 0.95, 0.6, 300, 50, 80, 0.10),
    (0.9, 0.6, 0.99, 10000, 1000, 1000, 0.01),
    (0.05, 0.9, 0.9, 1000, 200, 200, 0.05),  # lower bound clipped at 0
    (0.97, 0.9, 0.9, 1000, 200, 200, 0.05),  # upper bound clipped at 1
    (0.3333, 0.777, 0.888, 123, 45, 67, 0.2),
    (0.0, 1.0, 1.0, 50, 10, 10, 0.05),
    (1.0, 1.0, 1.0, 50, 10, 10, 0.05),
    (0.4, 0.7, 0.9, 1000, 1, 1, 0.05),
    (0.55, 0.75, 0.85, 1, 30, 40, 0.5),
]

# (m, p, q0_pilot, q1_pilot, m_pilot)
ALLOC_CASES = [
    (200, 0.4, 0.7, 0.9, 10),   # README example
    (200, 0.4, 0.9, 0.9, 0),    # defaults, warns
    (100, 0.5, 0.8, 0.8, 5),
    (1000, 0.1, 0.95, 0.6, 50),
    (1000, 0.9, 0.6, 0.99, 50),
    (500, 0.0, 0.9, 0.9, 20),   # p < eps branch
    (500, 1e-7, 0.9, 0.9, 0),   # p < eps branch, no pilot
    (50, 0.3, 0.7, 1.0, 0),     # q1_pilot capped at 1 - eps
    (50, 1.0, 0.7, 0.8, 5),
    (300, 0.62, 0.85, 0.93, 0),
    (20, 0.02, 0.5, 0.99, 8),   # m1 floored at m_pilot
    (7, 0.5, 0.6, 0.6, 1),     # m1 = 3.5, round half to even -> 4
    (5, 0.5, 0.6, 0.6, 1),     # m1 = 2.5, round half to even -> 2
]


def write(name, header, rows):
    path = os.path.join(OUT_DIR, name)
    with open(path, "w", newline="") as f:
        w = csv.writer(f, lineterminator="\n")
        w.writerow(header)
        for row in rows:
            w.writerow([repr(x) if isinstance(x, float) else x for x in row])
    print(f"wrote {len(rows)} rows to {os.path.normpath(path)}")


def main():
    os.makedirs(OUT_DIR, exist_ok=True)

    write(
        "point_estimator.csv",
        ["p", "q0", "q1", "estimate"],
        [(p, q0, q1, float(point_estimator(p, q0, q1))) for p, q0, q1 in POINT_CASES],
    )

    rows = []
    for p, q0, q1, n, m0, m1, alpha in CI_CASES:
        lo, hi = confidence_interval(p, q0, q1, n, m0, m1, alpha=alpha)
        rows.append((p, q0, q1, n, m0, m1, alpha, float(lo), float(hi)))
    write(
        "confidence_interval.csv",
        ["p", "q0", "q1", "n", "m0", "m1", "alpha", "lower", "upper"],
        rows,
    )

    rows = []
    for m, p, q0, q1, m_pilot in ALLOC_CASES:
        with warnings.catch_warnings(record=True) as caught:
            warnings.simplefilter("always")
            m0, m1 = allocate_calibration_sample(m, p, q0_pilot=q0, q1_pilot=q1, m_pilot=m_pilot)
        rows.append((m, p, q0, q1, m_pilot, int(m0), int(m1), len(caught) > 0))
    write(
        "allocate_calibration_sample.csv",
        ["m", "p", "q0_pilot", "q1_pilot", "m_pilot", "m0", "m1", "warned"],
        rows,
    )


if __name__ == "__main__":
    main()
