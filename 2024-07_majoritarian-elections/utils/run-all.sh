#!/bin/bash

# Run and render all project R scripts in Rocker container

set -e

docker compose up -d

docker exec rocker-starter \
  /bin/bash -c \
  "cd /home/rstudio/ && \
   Rscript utils/run-all.R > 'utils/run-all.log'"

docker compose down
