# Replication of *p*-hacking simulation studies

Independent replication of five *p*-hacking strategies from **Stefan & Schönbrodt (2023),
*Big Little Lies: A Compendium and Simulation of p-Hacking Strategies*, *Royal Society Open
Science*, 10(2), 220346** (https://doi.org/10.1098/rsos.220346).

This repository accompanies the Master's thesis of **Carolin Kirsch** (University of Bern, 2026)
and contains **all simulation code, per-study session information, and the Supplementary Material**
promised in the thesis.

The five strategies replicated:

1. **Optional stopping** (run on the UBELIX HPC cluster)
2. **Outlier exclusion** (run on the UBELIX HPC cluster)
3. **Discretizing continuous variables**
4. **Exploiting alternative hypothesis tests**
5. **Incorrect rounding**

The simulations were re-implemented from scratch based on the published description
(article + Appendix A), following Luijken et al. (2024) recommendations for independent
replication. For each condition the false-positive rate (FPR) under a true null effect was
estimated (up to 30,000 iterations per condition), reporting Monte Carlo standard errors
(MCSE) following the ADEMP framework (Siepe et al. 2024; Morris et al. 2019).

## Repository structure

```
├── functions.R                     # shared simulation helper functions
│
│   # --- Optional stopping (HPC) ---
├── optstop_function_run_sim.R      # runs the simulation
├── optstop_results.Rmd             # analysis + figures/tables
│
│   # --- Outlier exclusion (HPC) ---
├── outlier_functions_replication.R # outlier-detection technique functions
├── outlier_run_sim.R               # runs the simulation
├── outlier_results.Rmd             # analysis + figures/tables
│
│   # --- Discretizing ---
├── discretizing.Rmd                # simulation + analysis
│
│   # --- Alternative hypothesis tests ---
├── alternative_tests.Rmd           # Yuen test via DescTools (main analysis)
├── alternative_tests_WRS2.Rmd      # Yuen test via WRS2 (robustness)
├── alttests_wrs2_nowelch.Rmd       # WRS2 variant, Welch excluded
│
│   # --- Incorrect rounding ---
├── incorrect_rounding.Rmd          # replication simulation + analysis
├── reproduction_rounding/          # reproduction via the original authors' phackR package;
│                                   #   phackR_repro_roundHack.Rmd = reproduction + corrected FPR
│                                   #   (inlines/links original code — third-party MIT, see NOTICE.md)
│
├── results/                        # session info + small aggregated summaries (local studies); see results/README.md
├── results_UBELIX/                 # session info, RNG state + summaries for the two HPC studies
│
├── supplementary/                  # Supplementary Material (rendered HTML) + index
│
├── phacking-replication.Rproj      # RStudio project
├── LICENSE                         # MIT (code)
└── LICENSE-text-CC-BY-4.0.md       # CC BY 4.0 (Supplementary Material / text)
```

## Reproducibility

This project follows recommended practice for simulation studies (Morris et al. 2019;
Siepe et al. 2024): reproducibility is guaranteed by **code + fixed random seeds + full session
information**, so the raw simulated data does not need to be distributed.

- **Random seeds.** A single seed is set at the start of each simulation study
  (`optstop_function_run_sim.R`, `outlier_run_sim.R`, `discretizing.Rmd`,
  `alternative_tests*.Rmd`, `incorrect_rounding.Rmd`).
- **Parallelisation.** The two HPC studies draw independent, statistically sound RNG streams
  via `furrr_options(seed = TRUE)` (L'Ecuyer-CMRG). The state of the RNG between sub-simulations
  is stored in `results*/…_rng_state_before_*.rds` to allow partial reproduction.
- **Session information.** Full `sessionInfo()` for each study — package versions and auxiliary
  dependencies (BLAS/LAPACK) — is in `results/…_sessionInfo*` and `results_UBELIX/…_sessionInfo*`.

### How to reproduce

1. Install **R** (R 4.4.1 was used for discretizing, alternative tests, and incorrect rounding;
   R 4.5.1 for the HPC-run optional stopping and outlier exclusion) and RStudio.
2. Open `phacking-replication.Rproj` so that all relative paths resolve.
3. Install the required packages (see exact versions in the `*sessionInfo*` files):
   `tidyverse` (2.0.0), `furrr` (0.3.1), `DescTools` (0.99.60), `WRS2` (1.1-7),
   `ggtext`, `kableExtra`, `flextable`, plus their dependencies.
4. **Run a simulation:** source the corresponding `*_run_sim.R` (or run the sim chunk of the
   `.Rmd`). This regenerates the raw `sim_*.rds` locally (these are large and intentionally
   git-ignored — see *Data availability*).
5. **Reproduce the analysis:** knit the corresponding `*_results.Rmd` / strategy `.Rmd`.
   The small aggregated summaries needed for most tables/figures are included in `results/`.

> The incorrect-rounding **reproduction** (`reproduction_rounding/phackR_repro_roundHack.Rmd`) additionally
> requires the original authors' **`phackR`** package (from `astefan1/phacking_compendium`, not on CRAN):
> `remotes::install_github("astefan1/phacking_compendium", subdir = "phackR")`.

> Optional stopping and outlier exclusion were run on **UBELIX**, the University of Bern HPC
> cluster (https://www.id.unibe.ch/hpc), at 30,000 / 10,000 iterations. Reproducing them locally
> is possible but computationally intensive.

## Supplementary Material

The [`supplementary/`](supplementary/) folder holds the rendered result documents and the
additional analyses referenced in the thesis (FPR by mechanism and sample size, all estimates
with MCSE, exploratory analyses, and the WRS2-vs-DescTools comparison for the Yuen test).
See [`supplementary/README.md`](supplementary/README.md) for an index mapping each document to
the thesis sections it supports.

## Data availability

Raw simulated data objects (`sim_*.rds`, several hundred MB each) are **not** distributed:
they are regenerable outputs, fully determined by the code and the fixed seeds documented above,
and exceed GitHub's 100 MB file limit. Only the small aggregated summaries, RNG-state files, and
session-info files are included.

## License

- **Code** (`*.R`, `*.Rmd` authored here): MIT License — see [`LICENSE`](LICENSE).
- **Supplementary Material / written content**: CC BY 4.0 — see
  [`LICENSE-text-CC-BY-4.0.md`](LICENSE-text-CC-BY-4.0.md).
- **Third-party code** inlined in `reproduction_rounding/phackR_repro_roundHack.Rmd` (snippets of the
  `phackR` package and two original scripts, each linked to its source) is from
  [`astefan1/phacking_compendium`](https://github.com/astefan1/phacking_compendium) and remains under its
  original MIT License, © 2019 Angelika Stefan — see
  [`reproduction_rounding/NOTICE.md`](reproduction_rounding/NOTICE.md).

## Citation

If you use this material, please cite the thesis and the original study:

Stefan & Schönbrodt (2023), *Big Little Lies: A Compendium and Simulation of p-Hacking Strategies*

- Kirsch, C. (2026). _Replicating and Extending Stefan & Schönbrodt (2023) "Big Little Lies: A Compendium and Simulation of p-Hacking Strategies"_ [Master's thesis, University of Bern].
- Stefan, A. M., & Schönbrodt, F. D. (2023). Big little lies: A compendium and simulation of p-hacking strategies. _Royal Society Open Science, 10_(2), 220346. https://doi.org/10.1098/rsos.220346

## References

- Luijken, K., Lohmann, A., Alter, U., Claramunt Gonzalez, J., Clouth, F. J., Fossum, J. L., Hesen, L., Huizing, A. H. J., Ketelaar, J., Montoya, A. K., Nab, L., Nijman, R. C. C., Penning De Vries, B. B. L., Tibbe, T. D., Wang, Y. A., & Groenwold, R. H. H. (2024). Replicability of simulation studies for the investigation of statistical methods: The RepliSims project. _Royal Society Open Science, 11_(1), 231003. https://doi.org/10.1098/rsos.231003
- Morris, T. P., White, I. R., & Crowther, M. J. (2019). Using simulation studies to evaluate statistical methods. _Statistics in Medicine, 38_(11), 2074–2102. https://doi.org/10.1002/sim.8086
- Siepe, B. S., Bartoš, F., Morris, T. P., Boulesteix, A.-L., Heck, D. W., & Pawel, S. (2024). Simulation studies for methodological research in psychology: A standardized template for planning, preregistration, and reporting. _Psychological Methods_. Advance online publication. https://doi.org/10.1037/met0000695
