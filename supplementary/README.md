# Supplementary Material

Rendered, self-contained result documents (open the `.html` files in a browser) for the five
replicated *p*-hacking strategies, plus the additional analyses referenced in the thesis. Each
document reports all false-positive-rate (FPR) estimates together with their Monte Carlo standard
errors (MCSE), the number of tests conducted, and the FPRs of the individual analyses.

| File | Strategy / content | Referenced in the thesis for |
|------|--------------------|------------------------------|
| `optstop_results.html` | Optional stopping — full results | FPR estimates + MCSE; tests conducted; individual-analysis FPRs |
| `outlier_results.html` | Outlier exclusion — full results | FPR estimates + MCSE; mechanism (α-accumulation vs. inflated individual FPRs) |
| `discretizing.html` | Discretizing variables — full results | **FPR by mechanism and sample size** (main text points here); estimates + MCSE |
| `alternative_tests.html` | Alternative hypothesis tests (Yuen via `DescTools`) — main analysis | FPR estimates + MCSE |
| `alternative_tests_WRS2.html` | Alternative hypothesis tests recomputed with `WRS2` | Robustness of the Yuen-test result (highest FPR drops to .079) |
| `yuen_trim_typeI_error.html` | Simulation comparing `WRS2` vs. `DescTools` Winsorized-variance handling | **The "simulation illustrating the consequences of these differences"** cited in the alternative-tests discussion |
| `incorrect_rounding.html` | Incorrect rounding — full results | Estimates + MCSE; comparison to analytic values and to the reproduction |
| `outlier_check_bugfixes.html` | Supporting checks of the outlier implementation | Documentation of the outlier bug-fix / adjusted-implementation checks |
| `outlier_sim_flowchart.html` | Flowchart of the outlier simulation logic | Illustration of the outlier simulation procedure |

**Notes**

- The documents are self-contained (figures are embedded); no additional files are needed to view them.
- The exploratory/additional analyses mentioned in the thesis (e.g. shares of explored analytic options
  among reported false positives) are contained within the corresponding strategy documents above.
- Figures reproduced from Stefan & Schönbrodt (2023) inside these documents are the original authors'
  work (CC BY 4.0) and are attributed at each figure.
