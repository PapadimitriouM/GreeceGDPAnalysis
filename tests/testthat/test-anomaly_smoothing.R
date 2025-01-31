test_that("anomaly_smoothing() provides ts output", {

  # Valid data.frame but missing target column
  df <- data.frame(
    time = c(1996:2016),
    CLVMNACSCAB1GQEL_PC1 = runif(n = 21, min = 1, max = 10)
  )
  # Valid input test
  expect_s3_class(
    anomaly_smoothing(df),
    "data.frame"
  )
})
