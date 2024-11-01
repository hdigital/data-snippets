# Determine metropolitan regions in Germany based on a city center and distance
# with data from the German 2022 census database

library(tidyverse)
library(sf)


deu_raw <- read_rds("data/r-census-gecoding_sf.rds")
pop_raw <- read_csv("data/1000A-0000_de_clean.csv")

pop_max <- 500000
dist_km <- 55

# add gelocation to population data
deu <-
  deu_raw |>
  left_join(select(pop_raw, ags, population), by = c("ags" = "ags")) |>
  select(place, population)

# create metro regions with center ('pop_max') and distance ('dist_km')
reg_dt <-
  deu |>
  filter(population > pop_max) |>
  select(region = place) |>
  st_join(deu, st_is_within_distance, dist = dist_km * 1000) |>
  st_set_geometry(NULL) |>
  arrange(region, desc(population))

# calculate population of regions
reg_pop <-
  reg_dt |>
  summarise(population = sum(population), .by = region) |>
  arrange(desc(population)) |>
  mutate(population = round(population / 1e6, 1) * 1e6)

# determine the three largest places in each region (excluding the center)
reg_next <-
  reg_dt |>
  filter(region != place) |>
  summarise(places = paste(place[1:3], collapse = ", "), .by = region)

# create final regions data (center, population, three largest places)
reg <-
  reg_pop |>
  inner_join(reg_next)

reg
