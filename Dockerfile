FROM rocker/r-ver:4.2.1

RUN R -e "install.packages(c('devtools', 'targets'))"

RUN R -e "devtools::install_github('PapadimitriouM/GreeceGDPAnalysis', ref = 'e9d9129de3047c1ecce26d09dff429ec078d4dae')"

RUN R -e "renv::restore()"

RUN R -e "library(TimeSeriesAnalysis)"

RUN R -e "devtools::load_all(".")"

RUN R -e "targets::tar_make()"
