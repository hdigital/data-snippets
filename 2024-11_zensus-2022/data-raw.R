library(tidyverse)
library(tidygeocoder)


## Metro data ----

met_raw <- read_csv2(
  "data-raw/met_pjanaggr3__custom_12151542_spreadsheet.csv",
  na = ":"
)

write_csv(met_raw, "data/met_pjanaggr3__custom_12151542_clean.csv")

## Census data ----

cen_raw <- read_csv2("data-raw/1000A-0000_de_flat.csv")
ags_state <- read_csv("data/ags-land.csv")

cen_clean <-
  cen_raw |>
  filter(`1_variable_label` != "Deutschland") |>
  select(
    ags = `1_variable_attribute_code`,
    place = `1_variable_attribute_label`,
    population = value
  ) |>
  mutate(ags_state = substr(ags, 1, 2)) |>
  left_join(ags_state, by = "ags_state") |>
  relocate(state, .before = ags) |>
  select(-ags_state, -state_name)

write_csv(cen_clean, "data/1000A-0000_de_clean.csv")


## States maps ----

ne_deu_raw <- rnaturalearth::ne_states(country = "Germany", returnclass = "sf")

ne_deu <-
  ne_deu_raw |>
  mutate(state = substr(iso_3166_2, 4, 5)) |>
  select(state, state_name = name)

write_rds(ne_deu, "data/r-ne_states-deu.rds")


## Gecoding Census ----

cen_clean <- read_csv("data/1000A-0000_de_clean.csv")
ags_raw <- read_csv("data/ags-land.csv")

cen_geo <-
  cen_clean |>
  filter(population > 10000) |>
  arrange(-population) |>
  left_join(ags_raw, by = "state") |>
  mutate(
    place = str_remove(place, ", .*"),
    country = "Deutschland"
  ) |>
  select(ags, place, state_name, country)

if (FALSE) {
  cen_geo_coded <-
    cen_geo |>
    geocode(city = place, country = country, method = "osm") |>
    st_as_sf(crs = 4326, coords = c("long", "lat"), na.fail = FALSE) |>
    select(-country)

  write_rds(cen_geo_coded, "data/r-census-gecoding_sf.rds")
}


## Gecoding Metro ----

met_raw <- read_csv("data/met_pjanaggr3__custom_12151542_clean.csv")

met_geo <-
  met_raw |>
  mutate(region_search = str_remove(label, "-.*")) |>
  filter(y2023 > 100000) |>
  mutate(country = "Deutschland")

if (FALSE) {
  met_geo_coded <-
    met_geo |>
    geocode(city = region_search, country = country, method = "osm") |>
    st_as_sf(crs = 4326, coords = c("long", "lat"), na.fail = FALSE) |>
    arrange(-y2023) |>
    select(metroreg, region_search)

  write_rds(met_geo_coded, "data/r-metro-region-gecoding_sf.rds")
}
