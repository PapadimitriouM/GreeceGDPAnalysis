test_that("check_stationary() outputs ts", {

  # Generate time series sample data
  ts_input <- ts(c(1, 2, 3, 4, 5), start = 2000, frequency = 1)

  # Expect the function to accept ts class without error
  expect_s3_class(
    check_stationary(ts_input),
    "tis"
  )
})
