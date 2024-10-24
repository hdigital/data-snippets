library(tidyverse)

vdem_raw <- read_rds("data-raw/Country_Year_V-Dem_Full-11.1.rds")


## Electoral Systems (V-Dem) ----

# see Kasuya and Mori (2021) for democracy classification threshold

elec_sys <-
  vdem_raw |>
  select(country = country_text_id, year, elec_sys = v2elloelsy, v2x_polyarchy) |>
  filter(year >= 1900, elec_sys %in% c(0, 1), v2x_polyarchy > 0.39) |>
  mutate(elec_sys = case_when(
    elec_sys == 0 ~ "First-past-post",
    elec_sys == 1 ~ "Two-round"
  )) |>
  select(-v2x_polyarchy)

write_csv(elec_sys, "data/majoritarian-elections_vdem.csv")


## V-Party data ----

vparty_raw <- read_rds("data-raw/V-Dem-CPD-Party-V2.rds")

vparty_elec <-
  vparty_raw |>
  select(
    country = country_text_id,
    country_name,
    year,
    party = v2pashname,
    vote_share = v2pavote,
    seat_share = v2paseatshare,
    seats = v2panumbseat,
    seats_total = v2patotalseat
  ) |>
  left_join(elec_sys, by = c("country", "year")) |>
  filter(!is.na(elec_sys)) |>
  mutate(share_diff = round(seat_share - vote_share, 1)) |>
  relocate(share_diff, .after = seat_share) |>
  arrange(year, country, vote_share)

write_csv(vparty_elec, "data/majoritarian-elections_vparty.csv")


## UK · Top 3 ----

party_select <- c("Con", "Lab", "Lib")

uk_2024 <-
  read_csv("data/uk-election-2024_bbc.csv") |>
  mutate(
    year = 2024,
    seats_total = 650,
    seat_share = round(100 * seats / seats_total, 1),
    share_diff = round(seat_share - vote_share, 1)
  ) |>
  filter(party %in% party_select) |>
  select(-party_name)

uk_3 <-
  vparty_elec |>
  filter(country == "GBR", party %in% party_select) |>
  bind_rows(uk_2024) |>
  mutate(
    vote_change = round(vote_share - dplyr::lag(vote_share), 1),
    seats_change = round(seat_share - dplyr::lag(seat_share), 1),
    .by = party
  ) |>
  select(-country, -country_name, -elec_sys) |>
  arrange(year, party)

write_csv(uk_3, "data/uk-elections_top-3_vparty.csv")


## Majoritarian · Top 2 ----

top_2 <- vparty_elec %>%
  group_by(country, year) %>%
  slice_max(order_by = seat_share, n = 2) %>%
  mutate(rank = paste0("Top ", row_number())) %>%
  ungroup() |>
  filter(!is.na(vote_share)) |>
  relocate(rank, .after = party)

write_csv(top_2, "data/majoritarian-elections_top-2_vparty.csv")
