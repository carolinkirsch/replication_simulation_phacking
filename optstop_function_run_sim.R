library(tidyverse)
library(furrr)

plan(multisession, workers = future::availableCores())

source("functions.R")

dir.create("results_UBELIX", showWarnings = FALSE)

n_iterations <- 30000L # since reporting strategy isn't varied
sign_level <- 0.05 

# functions
## optional stopping
optional_stopping <- function(data, n_min, n_max, k, alpha = 0.05){
  
  # define sample sizes at which a peek takes place
  # in case of k > n_max-n_min -> two peeks at (n_min, n_max)
  n_peek_seq <- seq(n_min, n_max,by = k) 
  if(length(n_peek_seq) == 1) { 
    n_peek_seq <- c(n_min, n_max)
  }
  
  count_peeks <- 0L
  p <- NA_real_
  
  # for loop necessary since I need the break criterion
  for(n in n_peek_seq){
    count_peeks <- count_peeks + 1L
    
    p <- data |> # data generated with sample size n_max
      group_by(condition) |> # then out of each condition
      slice(1:n) |> # the currently tested sample of size n gets extracted
      ungroup() |>
      get_p_ttest()
    
    # stopping when significant (-> equivalent to reporting strategy first. sig.)
    if(p < alpha) break 
  }
  
  res <- tibble(
    count_peeks_hypothetical = length(n_peek_seq), #no. hypothetical peeks
    count_peeks_stop = count_peeks, # count_peeks_stop = count_peeks, 
    p_value = p)
  
  return(res)
}

# simulation
set.seed(9348)

## simulation n_max varied
par_grid_optstop_nmax <- expand_grid(
  iteration = 1:n_iterations,
  n_min = 5,
  n_max = c(30,50,100,300),
  k = c(1,5,10,50),
  reporting_strategy = "not applicable",
  alpha = sign_level
)

sim_optstop_nmax <- par_grid_optstop_nmax |>
  mutate(
    generated_data = pmap(
      list(n_max),
      generate_data_ttest
    ),
    reported_result = future_pmap(
      .l = list(generated_data, n_min, n_max, k, alpha), 
      .f = optional_stopping,
      .progress = TRUE,
      .options = furrr_options(seed = TRUE)
    )
  )

sim_optstop_nmax |> 
  select(-generated_data) |> 
  saveRDS(paste0("results_UBELIX/sim_optstop_nmax_",n_iterations,"iterations.rds"))

## simulation n_min varied

saveRDS(.Random.seed, paste0("results_UBELIX/optstop_rng_state_before_nmin_", n_iterations, "iterations.rds"))

# for partial reproduction
# .Random.seed <- readRDS(paste0("results_UBELIX/optstop_rng_state_before_nmin_", n_iterations, "iterations.rds"))

par_grid_optstop_nmin <- expand_grid(
  iteration = 1:n_iterations,
  n_min = c(30, 50, 100), # exclude the 4 conditions at n_min=5 & n_max=300 (bc already in sim_optstop_nmax and computationally heavy)
  n_max = 300,
  k = c(1,5,10,50),
  reporting_strategy = "not applicable",
  alpha = sign_level
)

sim_optstop_nmin <- par_grid_optstop_nmin |>
  mutate(
    generated_data = pmap(
      list(n_max),
      generate_data_ttest
    ),
    reported_result = future_pmap(
      .l = list(generated_data, n_min, n_max, k, alpha),
      .f = optional_stopping,
      .progress = TRUE,
      .options = furrr_options(seed = TRUE)
    )
  )

sim_optstop_nmin |> 
  select(-generated_data) |>
  saveRDS(paste0("results_UBELIX/sim_optstop_nmin_",n_iterations,"iterations.rds"))

writeLines(capture.output(sessionInfo()), paste0("results_UBELIX/optstop_sessionInfo_", n_iterations, "iterations.txt"))
