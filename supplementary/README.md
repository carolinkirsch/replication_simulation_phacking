# Supplementary Material

Rendered, self-contained result documents (open the `.html` files in a browser) for the five
replicated *p*-hacking strategies, plus the additional analyses referenced in the thesis. Each
document reports all false-positive-rate (FPR) estimates together with their Monte Carlo standard
errors (MCSE) and, where applicable, the number of tests conducted and the FPRs of the individual analyses.

| File | Strategy / content | Referenced in the thesis for |
|------|--------------------|------------------------------|
| `optstop_results.html` | Optional stopping — full results | FPR estimates + MCSE; number of hypothetical peeks |
| `outlier_results.html` | Outlier exclusion — full results | FPR estimates + MCSE; mechanism (α-accumulation vs. inflated individual FPRs) |
| `discretizing.html` | Discretizing variables — full results | FPR estimates + MCSE; **FPR by mechanism and sample size** (main text points here) |
| `alternative_tests.html` | Alternative hypothesis tests (Yuen via `DescTools`) — main analysis | FPR estimates + MCSE |
| `alternative_tests_WRS2.html` | Alternative hypothesis tests recomputed with `WRS2` - adapted to original implementation | FPR estimates + MCSE |
| `incorrect_rounding.html` | Incorrect rounding — full results | Estimates + MCSE |

**Notes**

- The documents are self-contained (figures are embedded); no additional files are needed to view them.
- The exploratory/additional analyses mentioned in the thesis (e.g. shares of explored analytic options
  among reported false positives) are contained within the corresponding strategy documents above.
