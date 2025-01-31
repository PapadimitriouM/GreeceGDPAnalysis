#' Load the default time series data
#' @param
#' @export
#' @return A time series object
#' @details
#' This function allows the user to load a clean time series for
#' tests or training.
#' @examples
#' get_data()
get_data <- function(){
  TimeSeriesAnalysis::timeseries
}


#' Check if time series is stationary and use growth rates if not
#' @param timeseries A ts object.
#' @importFrom ggplot2 ggplot
#' @importFrom ggpubr ggarrange
#' @importFrom forecast ggAcf ggPacf
#' @importFrom tseries kpps.test
#' @importFrom tis growth.rate
#' @export
#' @return A time series object
#' @details
#' This function allows the user to check if a time series is stationary, both visually
#' through the level plots (ACF and PACF) and statistically through the Augmennted
#' Dicky-Fuller test and KPSS test. Based on the tests, we use growth rates in case of
#' non-stationarity or use the default time series in case of stationarity and plot
#' the updated results.
#' @examples
#' df <- data.frame(
#'         time = c(1996:2016),
#'         CLVMNACSCAB1GQEL_PC1 = runif(n = 21, min = 1, max = 10)
#' )
#' ts <- stats::ts(df[,"CLVMNACSCAB1GQEL_PC1"],start=1996,frequency=1)
#' check_stationary(ts)
check_stationary <- function(timeseries) {

  if (!inherits(timeseries, "ts")) {
    stop("Input must be a time series object (class 'ts')")
  }

  y <- timeseries

  # FIGURE 1 :  level of the series
  plot_y  <- ggplot(data.frame(x = as.numeric(time(y)), y = as.numeric(y)), aes(x = x, y = y)) +
    geom_line() +
    labs(title = "FIG 1 - LEVEL")
  plot_ac  <- ggAcf(y,lag.max = 10) + labs(title="ACF")
  plot_pac <- ggPacf(y, lag.max = 10) + labs(title="PACF")
  # Display plot
  ggpubr::ggarrange(plot_y,plot_ac,plot_pac,ncol = 3)

  #Stationarity tests
  kpss <- tseries::kpss.test(y)

  if(kpss$p.value <= 0.1 | kpss$p.value == "p-value smaller than printed p-value") {
    print("Time series is non-stationary")

    x    <- time(y)
    y_gr <- tis::growth.rate(y, lag = 1, simple = T)
  } else{
    print("Time series is stationary")

    y_gr <- y
    x    <- time(y_gr)
  }

  # FIGURE 2 :  updated level of the series
  plot_y  <- ggplot(data.frame(x = as.numeric(time(y_gr)), y = y_gr), aes(x = x, y = y_gr)) +
    geom_line() +
    labs(title = "FIG 2 - DIFF")
  plot_ac  <- ggAcf(y_gr,lag.max = 10) + labs(title="ACF")
  plot_pac <- ggPacf(y_gr, lag.max = 10) + labs(title="PACF")
  # Display plot
  ggpubr::ggarrange(plot_y,plot_ac,plot_pac,ncol = 3)

  return(y_gr)
}


#' Check if time series has anomalies and smoothes them.
#' @param timeseries A ts object.
#' @importFrom ggplot2 ggplot aes labs geom_histogram geom_density geom_line
#' @importFrom stats quantile
#' @importFrom zoo rollapply
#' @export
#' @return A dataframe
#' @details
#' This function allows the user to check if a time series has anomalies (outliers), both visually
#' also visualizing them. Then a rolling mean smoothing filter is applied to deal
#' with them (smoothed). The result is a smoothed time series. We also
#' visualize the levels, ACF and PACF plots of the comparison before and after
#' smoothing
#' @examples
#' df <- data.frame(
#'         time = c(1996:2016),
#'         CLVMNACSCAB1GQEL_PC1 = runif(n = 21, min = 1, max = 10)
#' )
#' ts <- stats::ts(df[,"CLVMNACSCAB1GQEL_PC1"],start=c(1996,01),frequency=4)
#' anomaly_smoothing(ts)
anomaly_smoothing <- function(timeseries) {
  y_gr <- timeseries
  ind <- seq(1,length(y_gr[[1]]))

  df_n = data.frame(ind, y_gr)

  #Show outliers
  ggplot(df_n, aes(x=y_gr)) +
    geom_histogram(aes(y=after_stat(density)),      # Histogram with density instead of count on y-axis
                   binwidth=30,
                   colour="black", fill="white") +
    geom_density(alpha=.2, fill="#FF6666")  # Overlay with transparent density plot

  # Define the function to smooth outliers
  smooth_outliers <- function(df, k, n) {
    # Copy the dataframe
    out <- df

    # Loop over the columns
    for (col in names(df)) {
      if (is.numeric(df[[col]])) {
        # Calculate quartiles and IQR
        q1 <- quantile(df[[col]], 0.25, na.rm = TRUE)
        q3 <- quantile(df[[col]], 0.75, na.rm = TRUE)
        iqr <- q3 - q1

        # Identify outliers
        lower_bound <- q1 - k * iqr
        upper_bound <- q3 + k * iqr
        outlier_ind <- !(df[[col]] >= lower_bound & df[[col]] <= upper_bound)

        # Calculate the rolling mean
        col_sm <- rollapply(df[[col]], width = n, FUN = mean, align = "center", fill = NA)

        # Replace outliers with the rolling mean
        out[outlier_ind, col] <- col_sm[outlier_ind]
      }
    }

    return(out)
  }

  # Use on data
  df_diff_sm <- smooth_outliers(df_n, 2, 6)

  return(df_diff_sm)
}


#' Selects best ARIMA model and trains it based on our time series data, then does one-step ahead forecast.
#' @param dataframe A pandas dataframe containing at least one ts object.
#' @param ts A ts object to be selected from the dataframe
#' @importFrom ggplot2 ggplot aes labs scale_color_manual theme_minimal geom_line
#' @importFrom forecast forecast Arima auto.arima
#' @importFrom dplyr select
#' @export
#' @return A dataframe
#' @details
#' This function allows the user to fit an ARIMA (Auto Regression Integral Moving Average)
#' to a time series (training subset) using an automated function. This model is then used to do one step ahead
#' forecasts of the available time series (test subset). The forecast results are saved and displayed
#' compared to the original.
#' @examples
#' df <- data.frame(
#'         time = c(1996:2016),
#'         CLVMNACSCAB1GQEL_PC1 = runif(n = 21, min = 1, max = 10)
#' )
#' name <- "CLVMNACSCAB1GQEL_PC1"
#' train_and_forecast_arima(df, name)
train_and_forecast_arima <- function(dataframe, ts) {

  if (!is.data.frame(dataframe)) {
    stop("Input must be a data.frame")
  }

  if (!ts %in% names(dataframe)) {
    stop("Specified column name not found in data.frame")
  }

  df_diff_sm <- dataframe

  # Our updated data
  y_sm <- df_diff_sm[[ts]]
  x <- time(y_sm)

  # Determine the split index for 80% training data
  split_index <- floor(0.8 * length(y_sm))

  # Split the data into training and test sets
  train_data <- y_sm[1:split_index]
  test_data <- y_sm[(split_index + 1):length(y_sm)]
  train_time <- x[1:split_index]
  test_time <- x[(split_index + 1):length(y_sm)]

  # Print the length of the training and test sets
  cat("Training data length:", length(train_data), "\n")
  cat("Test data length:", length(test_data), "\n")

  # Automatic ARIMA model selection and fitting
  auto_arima_model <- auto.arima(train_data)

  # Print the summary of the automatically selected ARIMA model
  summary(auto_arima_model)

  # Function to perform one-step-ahead forecasts with expanding window
  expanding_window_forecast <- function(train_data, test_data, best_model) {
    n_test <- length(test_data)
    forecasts <- numeric(n_test)

    for (i in 1:n_test) {
      # Fit the model on the combined training data and the expanding test data
      expanded_train_data <- c(train_data, test_data[1:(i-1)])
      fit <- Arima(expanded_train_data, model = best_model)

      # Perform one-step-ahead forecast
      forecasts[i] <- forecast::forecast(fit, h = 1)$mean
    }

    return(forecasts)
  }

  # Perform the one-step-ahead forecasts
  one_step_forecasts <- expanding_window_forecast(train_data, test_data, auto_arima_model)

  #For RMSE and plot
  rmse <- sqrt(mean((one_step_forecasts - test_data)^2))

  # Create a data frame with true values and forecasts
  forecast_df <- data.frame(
    Time = test_time,
    True_Values = test_data,
    Forecasted_Values = one_step_forecasts
  )

  # Plot the true values and forecasts using ggplot2
  ggplot(forecast_df, aes(x = Time)) +
    geom_line(aes(y = True_Values, color = "True Values")) +
    geom_line(aes(y = Forecasted_Values, color = "Forecasted Values")) +
    labs(title = paste("One-Step-Ahead Forecasts vs True Values\nRMSE:", round(rmse, 2)),
         x = "Time",
         y = "Values") +
    scale_color_manual(values = c("True Values" = "blue", "Forecasted Values" = "red")) +
    theme_minimal()

  return(forecast_df)
}
