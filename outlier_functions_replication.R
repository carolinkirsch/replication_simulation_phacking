library(tidyverse)
library(furrr)
#check if aplpack etc. are installed on UBELIX

# NOTE (fixed ):
# - unified no-outlier behavior: if a technique removes nothing, it returns
#   NO p-value (empty tibble). The original p is always present as its own
#   row via get_p_with_original_out_*


# functions
## general helpers

# takes a flat list of cleaned datasets and the original dataset
# deduplicates an drops datasets where
# the cleaning removed no observations (no p-value if no outliers --
# the original p always exists as its own row), returns p-value tibble
get_p_cleaned <- function(cleaned, data) {
  
  cleaned <- unique(cleaned) |>
    keep(\(d) nrow(d) < nrow(data))
  
  # empty tibble preserving column schema if no effective cleanings
  if (length(cleaned) == 0) return(tibble(p_value = double()))
  
  cleaned |>
    map(\(d) tibble(p_value = get_p_univar_linreg(d))) |>
    bind_rows()
}

## outlier detection techniques
### helper single variable outlier detection techniques

# takes logical outlier indicators per observation,
# builds the three cleaned datasets (x only, y only, union)
# no guards needed: all-FALSE indicators produce no-op datasets,
# which get_p_cleaned drops
get_p_single_var_outlier_removed <- function(data, is_out_x, is_out_y) {
  
  cleaned <- list(
    data |> filter(!is_out_x),
    data |> filter(!is_out_y),
    data |> filter(!is_out_x & !is_out_y) # removes union of outliers on x and outliers on y
  )
  
  get_p_cleaned(cleaned, data)
}


### boxplot
remove_out_boxplot <- function(data) {
  
  # defining outliers
  out_x <- graphics::boxplot(data$x, plot = FALSE)$out
  out_y <- graphics::boxplot(data$y, plot = FALSE)$out
  
  get_p_single_var_outlier_removed(
    data,
    is_out_x = data$x %in% out_x,
    is_out_y = data$y %in% out_y
  )
}


### stem-and-leaf plot
extract_out_stemleaf <- function(var) {
  
  # capture textual output of the stem.leaf function
  utils::capture.output(aplpack::stem.leaf(var)) |>
    
    # extract the elements containing "LO:" or "HI:" (indicate outliers)
    ## this will result in maximum two lines that look like something this:
    ## "LO: x_out1 x_out2 ..." "HI: x_outj..."
    str_subset("LO:|HI:") |> 
    
    # remove the "LO:" or "HI:" and only keep values
    str_remove_all("LO:|HI:")|>
    
    # remove whitespace and replacing internal whitespace with a single space
    str_squish() |>
    
    # split so values of outliers are saved individually
    #(still as character vector)
    str_split(" ") |>
    
    unlist() |>
    as.numeric() |>
    na.omit()
}

remove_out_stemleaf <- function(data) {
  
  # rounding the data is necessary for the value-based filtering later:
  # stem.leaf() reports LO/HI outliers only as printed text (max 15 significant digits), 
  # so parsing back via as.numeric() may not match the unrounded data exactly
  # and %in% would silently fail. 6 decimals make the print -> parse -> %in% in extract_out_stemleaf() lossless.
  # in the future should be changed to index-based filtering to make the process more robust
  
  data_rounded <- round(data, 6)
  
  out_x <- extract_out_stemleaf(data_rounded$x)
  out_y <- extract_out_stemleaf(data_rounded$y)
  
  get_p_single_var_outlier_removed(
    data_rounded,
    is_out_x = data_rounded$x %in% out_x,
    is_out_y = data_rounded$y %in% out_y
  )
}

### SD
remove_out_sd <- function(data) {
  
  data_z <- data |>
    mutate(
      x_z = as.numeric(scale(x)),
      y_z = as.numeric(scale(y))
    )
  
  # one pooled threshold sequence, duplicates and no-op datasets get dropped in get_p_cleaned
  ## pooled maximum over both variables
  max_z <- max(abs(c(data_z$x_z, data_z$y_z)))
  
  ## empty sequence -> no outliers -> no p-values (original p exists separately)
  thresholds <- if (max_z >= 2) seq(2, max_z, 0.5) else numeric(0)
  
  cleaned <- c(
    map(thresholds, \(thr) data_z |> filter(abs(x_z) < thr)),
    map(thresholds, \(thr) data_z |> filter(abs(y_z) < thr)),
    map(thresholds, \(thr) data_z |> filter(abs(x_z) < thr & abs(y_z) < thr)) # removes union and uses same thresholds on both variables
  )
  
  get_p_cleaned(cleaned, data_z)
}

### percentage
remove_out_percentage <- function(data) {
  
  n <- nrow(data)
  
  # guard: for potential future application
  if(n < 20) stop("too few observations in dataset (<20)")
  
  # thresholds: number of observations to delete from each end
  # rounding number to delete indicated by percentage down conservatively
  n_delete <-
    seq(from = 1/n, to = 1/20, by = 0.005) |>
    (\(x) floor(x * n))() |>
    unique()
  
  # extracing outliers
  ## sort x and y to easily identify extremes
  x_sorted <- sort(data$x)
  y_sorted <- sort(data$y)
  
  ## for each n_delete: identify extreme values on x and y, then get p-values
  n_delete |>
    map(\(nd) {
      out_x <- x_sorted[c(1:nd, (n - nd + 1):n)]
      out_y <- y_sorted[c(1:nd, (n - nd + 1):n)]
      get_p_single_var_outlier_removed(
        data,
        is_out_x = data$x %in% out_x,
        is_out_y = data$y %in% out_y
      )
    }) |>
    bind_rows()
}

### residuals
remove_out_residuals_base <- function(data, res) {
  
  data_res <- data |>
    mutate(res_abs = abs( {{ res }} ))
  
  max_res_abs <- max(data_res$res_abs)
  
  # case 1: no absolute residuals larger than 2 -> remove 3 largest
  if(max_res_abs <= 2) {
    cleaned <- data_res |>
      arrange(desc(res_abs)) |>
      slice(-(1:3))
    
    p_tibble <- get_p_cleaned(list(cleaned), data_res)
    
    return(p_tibble)
  }
  
  # case 2: subjective threshold setting from 2 upwards in 0.5 steps
  thresholds <- seq(from = 2, to = max_res_abs, by = 0.5)
  
  cleaned <- thresholds |>
    map(\(thr) data_res |> filter(res_abs < thr))
  
  get_p_cleaned(cleaned, data_res)
}

#### studentized residuals
remove_out_stures <- function(data) {
  model <- lm(y ~ x, data)
  remove_out_residuals_base(data, res = as.numeric(stats::rstudent(model)))
}

#### standardized residuals
remove_out_stdres <- function(data) {
  model <- lm(y ~ x, data)
  remove_out_residuals_base(data, res = as.numeric(stats::rstandard(model)))
}

### DFBETA 
remove_out_dfbeta <- function(data) {
  model <- lm(y ~ x, data)
  
  cleaned <- data |>
    mutate(dfbeta_x = stats::dfbeta(model)[, 2]) |>
    arrange(desc(abs(dfbeta_x))) |>
    slice(-(1:3))
  
  get_p_cleaned(list(cleaned), data)
} 

### DFFITS
remove_out_dffits <- function(data){
  
  model <- lm(y ~ x, data)
  n <- nrow(data)
  
  cleaned <- data |>
    mutate(dffits_abs = abs(stats::dffits(model))) |>
    filter(dffits_abs <= 2 * sqrt(2/n))
  
  get_p_cleaned(list(cleaned), data)
}

### cook's distance
remove_out_cook <- function(data) {
  model    <- lm(y ~ x, data)
  n        <- nrow(data)
  f_median <- qf(p = 0.5, df1 = 2, df2 = n - 2)
  
  data_cook <- data |>
    mutate(cooksd = stats::cooks.distance(model))
  
  cleaned <- c(f_median, 1) |>
    map(\(thr) data_cook |> filter(cooksd <= thr))
  
  get_p_cleaned(cleaned, data_cook)
}

### mahalanobis distance
remove_out_mahalanobis <- function(data) {
  
  # currently mvoutlier::uniplot() seems unable to handle tibbles
  # so transform data to matrix
  data_matrix <- matrix(c(data$x, data$y), ncol=2)
  
  # extract outliers (logical indices) and suppress plot generation
  out <- R.devices::suppressGraphics(mvoutlier::uni.plot(data_matrix))
  
  cleaned <- data |>
    filter(!out$outliers)
  
  get_p_cleaned(list(cleaned), data) # function needs a list as input!
}

### leverage values
remove_out_leverage <- function(data) {
  model <- lm(y ~ x, data)
  n     <- nrow(data)
  
  cleaned <- data |>
    mutate(leverage = stats::hatvalues(model)) |>
    filter(leverage <= 3 * (2 / n))
  
  get_p_cleaned(list(cleaned), data)
}

### covariance ratio
remove_out_covratio <- function(data) {
  model <- lm(y ~ x, data)
  
  cleaned <- data |>
    mutate(covr = stats::influence.measures(model)[["is.inf"]][, "cov.r"]) |>
    filter(!covr)
  
  get_p_cleaned(list(cleaned), data)
}

## p-hacking
ALL_TECHNIQUES <- c(
  "boxplot", "stemleaf", "SD",
  "percentage", "student", "standardized",
  "DFBETA", "DFFITS", "cook",
  "mahalanobis", "leverage", "covratio"
)

### single techniques
remove_out_single <- function(data, technique) {
  switch(technique,
         "boxplot"      = remove_out_boxplot(data),
         "stemleaf"     = remove_out_stemleaf(data),
         "SD"           = remove_out_sd(data),
         "percentage"   = remove_out_percentage(data),
         "student"      = remove_out_stures(data),
         "standardized" = remove_out_stdres(data),
         "DFBETA"       = remove_out_dfbeta(data),
         "DFFITS"       = remove_out_dffits(data),
         "cook"         = remove_out_cook(data),
         "mahalanobis"  = remove_out_mahalanobis(data),
         "leverage"     = remove_out_leverage(data),
         "covratio"     = remove_out_covratio(data),
         stop(paste("unkown technique:", technique))
  )
}

get_p_with_original_out_single <- function(data, tech_label) {
  
  # the "original" row must remain the first row for the reporting strategies
  # reporting_strategy_tibbles() (functions.R) falls back to slice(1) 
  # for "first significant" and in case of no significant p-values
  bind_rows(
    tibble(
      technique = "original",
      p_value = get_p_univar_linreg(data)
    ),
    remove_out_single(data, tech_label) |>
      mutate(technique = tech_label)
  )
}

### sequential techniques
sample_techniques <- function(k) {
  sample(ALL_TECHNIQUES, size = k, replace = FALSE)
}

remove_out_seq <- function(data, technique_vec) {
  technique_vec |>
    map(\(tech) remove_out_single(data, tech) |>
          mutate(technique = tech)) |>
    bind_rows()
}

get_p_with_original_out_seq <- function(data, technique_vec) {
  
  # the "original" row must remain the first row for the reporting strategies
  # reporting_strategy_tibbles() (functions.R) falls back to slice(1) 
  # for "first significant" and in case of no significant p-values
  bind_rows(
    tibble(
      technique = "original",
      p_value = get_p_univar_linreg(data)
    ),
    remove_out_seq(data, technique_vec)
  )
}
