## code to prepare `DATASET` dataset goes here

df_rgdp <- readr::read_csv("C:/Users/manol/Documents/UniLu-MADS/Semester3/Time Series and Re. Pipelines/TimeSeriesProject/Datasets/FRED - Greece/CLVMNACSCAB1GQEL.csv")

library(dplyr)

choose_ts <- function(x){
    stats::ts(x[,"CLVMNACSCAB1GQEL_PC1"],start=c(1996,01),frequency=4)
}

timeseries <- choose_ts(df_rgdp)

usethis::use_data(timeseries, overwrite = TRUE)
