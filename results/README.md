# `results/` and `results_UBELIX/`

These folders hold the **small, distributed outputs** of the simulations. The large raw simulation
objects are **not** included (they are regenerable — see the repository README); only aggregated
summaries, session information, and RNG state are shipped.

## File-name taxonomy

| Prefix / pattern | Meaning | Distributed? |
|---|---|---|
| `sim_*` (e.g. `sim_discretizing_10000iterations.rds`) | **raw** per-iteration simulation object | No — regenerable, exceeds GitHub's file-size limit |
| `sim_summary_*` | **aggregated summary** (FPRs, MCSEs, etc.) read by the results documents | Yes |
| `*_sessionInfo*` | `sessionInfo()` for a study (package versions, BLAS/LAPACK) | Yes |
| `*_rng_state_before_*` | saved RNG state for partial reproduction of the HPC studies | Yes |

## What is where

- **`results/`** — summaries + session info for the studies run locally: discretizing, alternative
  hypothesis tests (incl. the `WRS2` and no-Welch variants), and incorrect rounding.
- **`results_UBELIX/`** — session info, RNG state, and summaries for the two studies run on **UBELIX**,
  the University of Bern HPC cluster: optional stopping and outlier exclusion.

To regenerate a study's raw objects, run its `*_run_sim.R` script (or the simulation chunk of its
`.Rmd`); the summaries here then let the corresponding `*_results.Rmd` render its tables and figures.

## Naming note

Some summary files do not yet follow a single uniform scheme — for example the word order in
`sim_optstop_nmax_summary_*` / `sim_out_seq_summary_*` (summary at the end rather than
`sim_summary_optstop_nmax_*`), the derived tables `technique_lasttest_summary_*` and
`out_seq_technique_per_strategy_*`, and a typo in `altttests_test_per_strategy_*` (three t's).
The current names are kept because the analysis code references them as-is. They may be standardized
to a consistent `sim_summary_*` convention in a future update for easier navigation.
