# Third-party code notice — `reproduction_rounding/`

This folder reproduces the **incorrect-rounding** simulation of the original study and checks it
against the replication.

The reproduction — [`phackR_repro_roundHack.Rmd`](phackR_repro_roundHack.Rmd) — is original work by
Carolin Kirsch (2026), covered by the repository root [`LICENSE`](../LICENSE) (MIT). It:

- loads and inlines snippets of the original authors' **`phackR`** package, and
- inlines the relevant lines of the original `roundHack_simulation.R` and `plots_FPrate.R`,

each with a link to the source at the point of use. It then adds a **corrected** false-positive-rate
computation (inclusive rejection criterion + Monte Carlo standard error).

**Attribution for the inlined original code:**

- **Source:** [`astefan1/phacking_compendium`](https://github.com/astefan1/phacking_compendium)
- **Copyright:** © 2019 Angelika Stefan
- **License:** MIT — full text in [`LICENSE-phacking_compendium`](LICENSE-phacking_compendium)

**Dependency:** reproducing the document requires the `phackR` package, part of the compendium
(`astefan1/phacking_compendium`, subfolder `phackR/`), not on CRAN:
`remotes::install_github("astefan1/phacking_compendium", subdir = "phackR")`.

`simresults_roundHack_repro.rds` is the cached simulation output for this document.
