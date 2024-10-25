library(sf) # plot maps and gespatial tools
library(tidyverse)


## Election results ----

csv_source <- "data-raw/w-btw21_kerg.csv"


### Read data ----

party_raw <- read_csv("data/btw-party.csv")


bw_raw <-
  read_delim(
    csv_source,
    delim = ";",
    col_names = FALSE,
    skip = 2
  )

bw_w <-
  bw_raw |>
  mutate(
    source = str_remove(csv_source, fixed(".csv")),
    level = case_when(
      X2 == "Bundesgebiet" ~ "federal",
      X3 == "99" ~ "state",
      TRUE ~ "district",
    )
  ) |>
  relocate(c(source, level), .before = X1)


### Fix variable names ----

var_names <-
  t(bw_w[1:3, ]) |>
  as_tibble(.name_repair = "universal") |>
  mutate(...3 = if_else(is.na(...3), "Endgültig", ...3)) |> # for 1953 election
  fill(everything()) |>
  unite("variable", sep = "__")

bw_w <- bw_w |> slice(4:n())
names(bw_w) <- var_names |> pull(variable)
names(bw_w)[1:2] <- c("source", "level")
names(bw_w)[3:5] <- c("wkr_nr", "wkr_name", "land_nr")


### Clean long data ----

bw_l <-
  bw_w |>
  pivot_longer(!source:land_nr,
    names_to = "unit", values_to = "votes"
  )

bw_l <-
  bw_l |>
  separate(unit, c("unit", "votes_type", "votes_status"), sep = "__") |>
  mutate(across(c("wkr_nr", "land_nr", "votes"), as.integer))


### Votes ----

votes_valid <-
  bw_l |>
  filter(unit == "Gültige Stimmen", votes_status == "Endgültig", !is.na(votes)) |>
  select(wkr_nr, level, votes_type, votes_valid = votes)

bw_out <-
  bw_l |>
  filter(votes_status == "Endgültig", votes > 0, !is.na(votes)) |>
  left_join(votes_valid) |>
  mutate(
    wkr_nr = if_else(level == "district", wkr_nr, NA_integer_),
    land_nr = if_else(level == "district", land_nr, NA_integer_)
  ) |>
  select(-votes_status)

write_csv(bw_out, "data/btw21-results.csv")


### Party share ----

bw_party <-
  bw_out |>
  left_join(party_raw |> select(-party)) |>
  group_by(votes, short, votes_type) |>
  mutate(share = round(100 * votes / votes_valid, 2)) |>
  rename(party = short) |>
  filter(!is.na(party)) |>
  relocate(party:share, .before = votes) |>
  relocate(votes_type, .before = share) |>
  select(-unit)

write_csv(bw_party, "data/btw21-results-party.csv")


## MP data ----

mp_raw <-
  read_delim("data-raw/w-btw21_gewaehlte_utf8/w-btw21_gewaehlte_utf8.csv",
    delim = ";", skip = 9
  ) |>
  janitor::clean_names()

mp <-
  mp_raw |>
  filter(gebietsart == "Wahlkreis") |>
  mutate(
    sex = str_replace(geschlecht, "w", "f"),
    region = if_else(
      gebiet_land_abk %in% c("BB", "MV", "SN", "ST", "TH"), # "BE"
      "east", "west"
    ),
    region = factor(region) |> fct_relevel("west")
  ) |>
  select(
    state = gebiet_land_abk,
    region,
    wkr_nr = gebietsnummer,
    district_name = gebietsname,
    party = gruppenname,
    sex
  )

write_csv(mp, "data/btw21-gewaehlte-wahlkreis.csv")


## Geo data districts ----

wk_shp_raw <-
  st_read("data-raw/btw21_geometrie_wahlkreise_geo_shp/", quiet = TRUE) |>
  mutate(geometry = st_make_valid(geometry)) |>
  janitor::clean_names()

wk_shp <-
  wk_shp_raw |>
  mutate(
    area = st_area(geometry),
    area_km2 = (sqrt(area) / 1000) |> as.integer() |> round(),
    coord_y = wk_shp_raw |> st_centroid() |> st_coordinates() |> as_tibble() |> pull(Y),
    land_nr = as.integer(land_nr)
  )

write_rds(wk_shp, "data/btw21-districts-geometry.rds")
wk_ctr <- st_centroid(wk_shp)
write_rds(wk_ctr, "data/btw21-districts-centroid.rds")
