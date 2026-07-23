library(tidyverse)
library(furrr)
#check if aplpack etc. are installed on UBELIX

source("functions.R")
source("outlier_functions_replication.R")

plan(multisession, workers = future::availableCores())

set.seed(12345)

# general setting
n_iterations <-  10000L
sign_level <- 0.05

# simulation
## sequentially
par_grid_out_seq <- expand_grid(
  n                  = c(30, 50, 100, 300),
  iteration          = 1:n_iterations,
  number_techniques  = c(3, 5, 12),
  reporting_strategy = c("first significant", "smallest", "smallest significant"),
  alpha = sign_level
)

sim_out_seq <- par_grid_out_seq |>
  mutate(
    generated_data = pmap(
      list(n),
      generate_data_univar_linreg
    ),
    # OPEN (possible optimisation): pre-compute model in simulation? and not each time in the technique that need it
    # original_analysis = pmap(
    #   list(generated_data),
    # ),
    techniques_sample = pmap(
      list(number_techniques),
      sample_techniques
    ), 
    analysis_result = future_pmap(
      .l = list(generated_data, techniques_sample),
      .f = get_p_with_original_out_seq,
      .progress = TRUE,
      .options = furrr_options(seed = TRUE)
    ),
    reported_result = pmap(
      list(analysis_result, reporting_strategy, alpha),
      reporting_strategy_tibbles
    )
  )

sim_out_seq |>
  select(-generated_data) |>
  saveRDS(paste0("results/sim_out_seq_", n_iterations, "iterations.rds"))

saveRDS(.Random.seed, paste0("results/out_rng_state_before_single_", n_iterations,"iterations.rds"))

# for partial reproduction
#.Random.seed <- readRDS(paste0("results/out_rng_state_before_single_", n_iterations,"iterations.rds"))

## single
par_grid_out_single <- expand_grid(
  n                  = c(30, 50, 100, 300),
  iteration          = 1:n_iterations,
  outlier_technique  = ALL_TECHNIQUES,
  reporting_strategy = c("first significant", "smallest", "smallest significant"),
  alpha = sign_level
)

sim_out_single <- par_grid_out_single |>
  mutate(
    generated_data = pmap(
      list(n),
      generate_data_univar_linreg
    ),
    # OPEN (possible optimisation): pre-compute model in simulation? and not each time in the technique that need it
    # original_analysis = pmap(
    #   list(generated_data),
    # ),
    analysis_result = future_pmap(   # parallelising
      .l = list(generated_data, outlier_technique),
      .f = get_p_with_original_out_single,
      .progress = TRUE,
      .options = furrr_options(seed = TRUE)
    ),
    reported_result = pmap(
      list(analysis_result, reporting_strategy, alpha),
      reporting_strategy_tibbles
    )
  )

sim_out_single |>
  select(-generated_data) |>
  saveRDS(paste0("results/sim_out_single_", n_iterations, "iterations.rds"))

writeLines(capture.output(sessionInfo()), paste0("results/out_sessionInfo_", n_iterations, "iterations.rds"))

