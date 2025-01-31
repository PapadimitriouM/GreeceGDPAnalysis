FROM rocker/r-ver:4.2.1

WORKDIR /app

COPY . /app

RUN R -e "install.packages('devtools')"

RUN R -e "devtools::install_github('PapadimitriouM/greece_gdp_analysis', ref = '8425bd33d7aabc3194e4edc80bd58f25cfbe3e6f')"

RUN R -e "renv::restore()"

RUN R -e "renv::snapshot()"

RUN R -e "renv::restore()"

RUN R -e "library(TimeSeriesAnalysis)"

RUN R -e "devtools::load_all(".")"

RUN R -e "targets::tar_make()"
