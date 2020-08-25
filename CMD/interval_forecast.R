#########################
# Bootstrapped forecasts
#########################
# Author: Peter Fuleky
# Date: 2/28/2020

# clear memory, load libraries
rm(list = ls(all = TRUE))
library("tidyverse")
library("lubridate")
library("forecast")
library("tsbox")

#########################
# USER INPUT START
#########################

# set workding directory (it needs to exist)
setwd("/Volumes/UHEROwork/forecast/Scenarios/2020")
# set analysis to US or JP
country_id <- "jp"
# choose ARIMA (TRUE) or ETS (FALSE) modeling (each can be fine-tuned below)
fcast_method_arima <- TRUE
# choose the number of bootstrapped history samples
n_boot <- 1000
# choose the number of bootstrapped forecast simulations
n_boot_fcast <- 1000
# set forecast horizon in quarters
fcast_hor <- 31 * 4
# aggregate boostraps via median (TRUE) or mean (FALSE)
bagg_method_median <- TRUE

#########################
# USER INPUT END
#########################

#########################
# FUNCTIONS START
#########################

# Moving Block Bootstrap ----
# source code from *forecast* package - MBB
MBB_pf <- function(x, window_size) {
  bx <- array(0, (floor(length(x) / window_size) + 2) * window_size)
  for (i in 1:(floor(length(x) / window_size) + 2)) {
    c <- sample(1:(length(x) - window_size + 1), 1)
    bx[((i - 1) * window_size + 1):(i * window_size)] <- x[c:(c + window_size - 1)]
  }
  start_from <- sample(0:(window_size - 1), 1) + 1
  bx[start_from:(start_from + length(x) - 1)]
}

# altered source code from *forecast* package - bld.mbb.bootstrap
bld.mbb.bootstrap_pf <- function(x, num, block_size = NULL) {
  if (length(x) <= 1L) {
    return(rep(list(x), num))
  }
  freq <- frequency(x)
  if (length(x) <= 2 * freq) {
    freq <- 1L
  }
  if (is.null(block_size)) {
    block_size <- ifelse(freq > 1, 2 * freq, min(8, floor(length(x) / 2)))
  }
  xs <- list()
  xs[[1]] <- x
  if (num > 1) {
    if (min(x) > 1e-06) {
      lambda <- BoxCox.lambda(x, lower = 0, upper = 1)
    }
    else {
      lambda <- 1
    }
    x.bc <- BoxCox(x, lambda)
    lambda <- attr(x.bc, "lambda")

    # START: modification by PF

    fit_arima <- x.bc %>% auto.arima(
      max.d = 1,
      stepwise = FALSE,
      approximation = FALSE
    )
    seasonal <- rep(0, length(x))
    trend <- fit_arima$fitted
    remainder <- fit_arima$residuals

    # if (freq > 1) {
    #   x.stl <- stl(ts(x.bc, frequency = freq), "per")$time.series
    #   seasonal <- x.stl[, 1]
    #   trend <- x.stl[, 2]
    #   remainder <- x.stl[, 3]
    # }
    # else {
    #   trend <- 1:length(x)
    #   suppressWarnings(x.loess <- loess(ts(x.bc, frequency = 1) ~
    #                                       trend, span = 6/length(x), degree = 1))
    #   seasonal <- rep(0, length(x))
    #   trend <- x.loess$fitted
    #   remainder <- x.loess$residuals
    # }

    # END: modification by PF
  }
  for (i in 2:num) {
    xs[[i]] <- ts(InvBoxCox(trend + seasonal + MBB_pf(
      remainder,
      block_size
    ), lambda))
    tsp(xs[[i]]) <- tsp(x)
  }
  xs
}

# function to produce multiple simulations from a given model
multi_sim <- function(modl, fcast_hor, n_boot_fcast){
  future <- matrix(NA, nrow = fcast_hor, ncol = n_boot_fcast)
  for(i in seq(n_boot_fcast)){
    future[, i] <- simulate(modl, nsim = fcast_hor, bootstrap = TRUE)
  }
  return(future)
}

#########################
# FUNCTIONS END
#########################

#########################
# MAIN START
#########################

# load history and make sure the date is formatted correctly
y_data <- read_csv(paste0(country_id, "_hist.csv")) %>%
  mutate(DATE = mdy(DATE))

# get start and end date from history
y_data_start <- y_data %>%
  head(1) %>%
  pull(DATE)
y_data_end <- y_data %>%
  tail(1) %>%
  pull(DATE)

# convert history into time series (ts object)
y_data_ts <- ts(
  data = y_data %>% pull(2),
  start = c(year(y_data_start), quarter(y_data_start)),
  end = c(year(y_data_end), quarter(y_data_end)),
  frequency = 4
)

# run an ARIMA model, plot fit and residuals
fit_arima <- y_data_ts %>% auto.arima(
  max.d = 1,
  # stepwise = FALSE,
  # approximation = FALSE,
  lambda = "auto",
  biasadj = TRUE
)
autoplot(y_data_ts) +
  autolayer(fit_arima$fitted)
autoplot(fit_arima$residuals)

# produce corresponding forecasts and bootstrqp prediction intervals
fcast_arima <- forecast(fit_arima, h = fcast_hor, bootstrap = TRUE, npaths = 1000)
autoplot(fcast_arima)

# fit an automatically selected model to bootstrapped samples
# https://robjhyndman.com/papers/BaggedETSForIJF_rev1.pdf
# https://otexts.com/fpp2/bootstrap.html
# consider ets or arima estimation
# https://otexts.com/fpp2/arima-ets.html
set.seed(1)
if (fcast_method_arima) {
  fit <- baggedModel(
    y = y_data_ts,
    bootstrapped_series = bld.mbb.bootstrap_pf(y_data_ts, n_boot),
    fn = auto.arima,
    max.d = 1,
    # stepwise = FALSE,
    # approximation = FALSE,
    lambda = "auto",
    biasadj = TRUE
  )
} else {
  fit <- baggedModel(
    y = y_data_ts,
    bootstrapped_series = bld.mbb.bootstrap(y_data_ts, n_boot),
    fn = ets,
    lambda = "auto",
    biasadj = TRUE
  )
}

# look at selected models for each bootstrap sample
# fit$models

# collect the bootstrap samples in a multivariate time series object
samples_boot_ts <- reduce(fit$bootstrapped_series, ts.union) %>%
  ts_tbl() %>%
  ts_wide() %>%
  rename_all(~ c("time", paste0("B", 1:n_boot))) %>%
  ts_long() %>%
  ts_ts()

# look at the plot of bootstrap samples
boot_smpl_plot <- autoplot(y_data_ts) +
  autolayer(samples_boot_ts, colour = TRUE) +
  autolayer(y_data_ts, colour = FALSE) +
  xlab("Time") +
  ylab(paste0("GDP_R@", str_to_upper(country_id), ".Q")) +
  ggtitle("Bootstrap samples") +
  guides(colour = "none") +
  theme_light()
ggsave(filename = paste0(country_id, "_boot_smpl_plot.pdf"), plot = boot_smpl_plot, width = 10, height = 8)

# calculate addfactors as differences between the original and bootstrapped series in the last period
add_factor <- last(y_data_ts) - fit$bootstrapped_series %>% map_dbl(last)

# produce one forecast for each bootstrap sample (model uncertainty)
fcast <- forecast(fit, h = fcast_hor)

# apply the addfactor to the bagged forecast (for bagging use median or mean of forecasts)
if (bagg_method_median) {
  forecasts_bagg_ts <- fcast$median + median(add_factor)
} else {
  forecasts_bagg_ts <- fcast$mean + mean(add_factor)
}

# simulate n_boot_fcast forecasts for each bootstrap sample (model uncertainty + historical forecast error)
sim <- fit$models %>% 
  map(multi_sim, fcast_hor = fcast_hor, n_boot_fcast = n_boot_fcast)

# apply the addfactor to each bootstrap forecast and convert to time series
forecasts_boot_ts <- map2(add_factor, sim, `+`) %>%
  reduce(cbind) %>% 
  ts(start = start(forecasts_bagg_ts), frequency = 4)

# compare the bagged forecast to the simulation median/average
boot_comp_plot <- autoplot(y_data_ts) +
  autolayer(forecasts_boot_ts %>% 
              ts_tbl %>% 
              group_by(time) %>% 
              summarize(agg = if(bagg_method_median) median(value) else mean(value)) %>% 
              ts_ts(), 
            colour = TRUE) +
  autolayer(forecasts_bagg_ts, colour = FALSE) +
  autolayer(y_data_ts, colour = FALSE) +
  xlab("Time") +
  ylab(paste0("GDP_R@", str_to_upper(country_id), ".Q")) +
  ggtitle("Bootstrap forecasts") +
  guides(colour = "none") +
  theme_light()
ggsave(filename = paste0(country_id, "_boot_comp_plot.pdf"), plot = boot_comp_plot, width = 10, height = 8)

# get the ratio of bootsrap forecasts to bagged forecast
fcast_ratio <- forecasts_boot_ts / forecasts_bagg_ts

# for each date get the quantiles of the ratios
quantile_ratio <- fcast_ratio %>%
  ts_tbl() %>%
  spread(key = time, value = value) %>%
  select(-id) %>%
  map_dfc(quantile, probs = seq(0, 1, 0.01)) %>%
  mutate(quantiles = paste0(str_to_upper(country_id), "per", seq(0, 1, 0.01) * 100)) %>%
  mutate(quantiles = factor(quantiles, levels = unique(quantiles))) %>%
  gather(key = time, value = value, -quantiles) %>%
  spread(key = quantiles, value = value) %>%
  rename(!!paste0(str_to_upper(country_id), "per00") := paste0(str_to_upper(country_id), "per100")) %>%
  mutate(time = as_date(time))

# additional adjustment to widen near term (can applied to ratios below)
# mult_factor <- seq(from = 3, to = 1, length.out = nrow(quantile_ratio))
# quantile_ratio_mult <- quantile_ratio %>% 
#   select(-time) %>% 
#   map_dfc(~ (.x - 1) * mult_factor + 1) %>% 
#   bind_cols(quantile_ratio %>% select(time)) %>% 
#   select(time, everything())

# add history to the ratios (they are all equal to 1 in history)
quantile_ratio_hist <- matrix(1, nrow = length(y_data_ts), ncol = 101) %>%
  as_tibble() %>%
  bind_cols(time = seq.Date(from = y_data_start, to = y_data_end, by = "quarter")) %>%
  select(time, everything()) %>%
  rename_all(~ colnames(quantile_ratio)) %>%
  bind_rows(quantile_ratio)
  # bind_rows(quantile_ratio_mult)

# save the quantile ratios in csv format
write_csv(quantile_ratio_hist, paste0("quantile_ratio_", country_id, "_newmodel.csv"))
write_csv(select(quantile_ratio_hist, time, matches("per10|per90")), paste0(country_id, "_hilo.csv"))

# look at the forecast quantile plot
quant_plot <- autoplot(y_data_ts) +
  autolayer(map(quantile_ratio %>% select(-time), ~.x*forecasts_bagg_ts) %>% reduce(ts.union), colour = TRUE) +
  autolayer(forecasts_bagg_ts, colour = FALSE) +
  autolayer(y_data_ts, colour = FALSE) +
  xlab("Time") +
  ylab(paste0("GDP_R@", str_to_upper(country_id), ".Q")) +
  ggtitle("Bootstrap forecast quantiles") +
  guides(colour = "none") +
  theme_light()
ggsave(filename = paste0(country_id, "_quant_plot.pdf"), plot = quant_plot, width = 10, height = 8)

#########################
# MAIN END
#########################
