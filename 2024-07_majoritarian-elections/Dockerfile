# parent image — R version specified to pin packages (see 'rocker-versioned2')
# https://cran.r-project.org/doc/manuals/r-release/NEWS.html
FROM rocker/tidyverse:4.4.1

WORKDIR /home/rstudio

# Install R packages with 'pak'
RUN install2.r pak
COPY pkg.lock .
RUN R -e 'pak::lockfile_install()'

# # OPTIONAL — select and customize per project
#
# # Install Python
# RUN apt-get -y update && apt-get install -y --no-install-recommends \
#    python3 python3-dev python3-pip python-is-python3
# RUN python -m pip install --upgrade pip
# RUN python -m pip install jupyterlab
#
# # Install Quarto CLI with specified version
# ARG QUARTO_VERSION=1.4.551
# RUN apt-get -y update && apt-get install -y --no-install-recommends curl gdebi-core
# RUN curl -LO https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb
# RUN gdebi --non-interactive quarto-${QUARTO_VERSION}-linux-amd64.deb

# Install Ubuntu package to suppress R plot warning
RUN apt-get -y update && apt-get install -y --no-install-recommends libxt6
