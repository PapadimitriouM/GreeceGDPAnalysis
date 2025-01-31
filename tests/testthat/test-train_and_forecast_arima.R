test_that("train_and_forecast_arima() outputs df", {

  # Valid data.frame but missing target column
  df <- data.frame(
    time = c(1996:2016),
    CLVMNACSCAB1GQEL_PC1 = runif(n = 21, min = 1, max = 10)
  )
  # Valid input test
  expect_s3_class(
    train_and_forecast_arima(df, "CLVMNACSCAB1GQEL_PC1"),
    "data.frame"
  )
})

