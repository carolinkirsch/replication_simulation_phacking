# data generating functions
## for t-test

generate_data_ttest <- function(n_control,
                                n_intervention = n_control,
                                mean_control = 0,
                                mean_intervention = 0,
                                sd_control = 1 ,
                                sd_intervention = 1) {
  
  data <- 
    bind_rows(
      tibble(condition = "control",
             score = rnorm(n = n_control, mean = mean_control, sd = sd_control)),
      tibble(condition = "intervention",
             score = rnorm(n = n_intervention, mean = mean_intervention, sd = sd_intervention))
    )
  
  return(data)
}

## for univariate regression
### no correlation 
generate_data_univar_linreg <- function(n,
                                       mu = 0,
                                       sd = 1){
  x <- rnorm(n, mu, sd)
  y <- rnorm(n, mu, sd)
  
  data <- tibble(x=x, y=y)
  
  return(data)
}

# analyse data & get p-value

## t-test
get_p_ttest <- function(data){
  p <- t.test(score ~ condition, data, alternative = "two.sided", var.equal = TRUE)$p.value
  
  return(p)
}


## univariate linear regression
get_p_univar_linreg <- function(data){
  model <- lm(y ~ x, data)
  fit <- summary(model)
  p <- fit$coefficients[2,4]
  
  return(p)
}

#return(tibble(data = list(data), p = p))


# reporting strategy
# function to report a p-value based on the chosen strategy

reporting_strategy_tibbles <- function(results_tibble, strategy, alpha = 0.05) {
  
  if (strategy == "smallest") {
    
    reported_tibble <- results_tibble |> 
      slice_min(p_value, n = 1, with_ties = FALSE)
    
  } else if (strategy == "first significant") {
    
    sig <- results_tibble |> filter(p_value < alpha) # attention non-inclusive is a problem if it were to be applied to incorrect rounding!
    
    if (nrow(sig) > 0) {
      reported_tibble <- sig |> slice(1)
    } else {
      reported_tibble <- results_tibble |> slice(1)
    }
    
  } else if (strategy == "smallest significant") {
    
    sig <- results_tibble |> filter(p_value < alpha) # attention non-inclusive is a problem if it were to be applied to incorrect rounding!
    
    if (nrow(sig) > 0) {
      reported_tibble <- sig |> slice_min(p_value, n = 1, with_ties = FALSE)
    } else {
      reported_tibble <- results_tibble |> slice(1)
    }
  }
  
  #if (nrow(reported_tibble) > 1) 
  
  return(reported_tibble)
}


