FROM rocker/r-ver:4.2.1

WORKDIR /app

COPY . /app

RUN R -e "renv::snapshot()"

RUN R -e "renv::restore()"

RUN R -e "install.packages(c('devtools', 'targets'))"

RUN R -e "devtools::load_all(".")"

RUN R -e "library(TimeSeriesAnalysis)"

RUN R -e "targets::tar_make()"
