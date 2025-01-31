library(targets)
library(TimeSeriesAnalysis)
library(ggplot2)
library(stats)
library(tis)
library(zoo)
library(forecast)
library(aTSA)
source("functions.R")

list(
  tar_target(
    gdp_data,
    get_data()
  ),

  tar_target(
    stat_ts,
    check_stationary(gdp_data)
  ),

  tar_target(
    sm_data,
    anomaly_smoothing(stat_ts)
  ),

  tar_target(
    forecast_data,
    train_and_forecast_arima(sm_data, "CLVMNACSCAB1GQEL_PC1")
  )
)
