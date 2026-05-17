# Replication of "Big Little Lies": A Compendium and Simulation of P-Hacking Strategies
[WIP] partial replication of simulation studies on p-hacking by Stefan &amp; Schönbrodt (2023)

> Stefan, A. M., & Schönbrodt, F. D. (2023). Big little lies: A compendium and simulation of p-hacking strategies. *Royal Society Open Science*, *10*, 220346. https://doi.org/10.1098/rsos.220346

## Repository Structure

```
phacking-replication/
├── functions.R                # Shared data-generating functions
├── outlier.Rmd                # Strategy: Outlier exclusion
├── optional_stopping.Rmd      # Strategy: Optional stopping
├── alternative_tests.Rmd      # Strategy: Alternative hypothesis tests
├── incorrect_rounding.Rmd     # Strategy: Incorrect rounding
├── discretizing.Rmd           # Strategy: Discretizing continuous variables
└── phacking-replication.Rproj # RStudio project file
```

## Strategies Replicated

| Strategy | File | Status |
|---|---|---|
| Optional stopping | `optional_stopping.Rmd` | 🔄 In progress (full iterations outstanding, MCSE missing) |
| Outlier exclusion | `outlier.Rmd` | 🔄 In progress (full iterations outstanding, MCSE missing) |
| Alternative hypothesis tests | `alternative_tests.Rmd` | 🔄 In progress (MCSE missing) |
| Incorrect rounding | `incorrect_rounding.Rmd` | 🔄 In progress (MCSE missing)|
| Discretizing continuous variables | `discretizing.Rmd` | 🔄 In progress (MCSE missing) |

## Reproducing the Results

1. Open `phacking-replication.Rproj` in RStudio.
2. Open any `.Rmd` file and knit it (`Ctrl/Cmd + Shift + K`).
3. `functions.R` is sourced automatically.

**Required R packages:**

```r
install.packages(c(
  "tidyverse",
  "ggtext",
  "kableExtra",
  "furrr",
  "DescTools",
  "Dict"
))
```
