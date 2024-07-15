#!/bin/bash

# Update packages for latest R version Rocker

set -e

docker run \
  --detach \
  --name rocker_latest \
  --volume .:/home/rstudio/ \
  rocker/tidyverse:latest

docker exec rocker_latest /bin/bash -c \
  "cd /home/rstudio/ && \
   Rscript utils/packages-update.R && \
   Rscript utils/run-all.R"

printf "\n\n"
docker exec rocker_latest Rscript -e "R.version.string"
printf "\n🚨 · Update R version Rocker in Dockerfile."
printf "\n💡 · Commit message — Update to R 4.x.x\n\n"

docker rm --force rocker_latest
