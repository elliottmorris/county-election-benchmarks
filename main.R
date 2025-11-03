library(tidyverse)


# get pres results --------------------------------------------------------
# the data comes from Matt Stiles: https://github.com/stiles/presidential-elections
pres = read_csv('data/county_pres_2000_2024.csv')

# compute state margins in each year
pres = pres %>%
  group_by(year, state_abb) %>%
  mutate(dem_pct_state = sum(votes_dem) / sum(votes_all),
         rep_pct_state = sum(votes_rep) / sum(votes_all),
         dem_margin_state = dem_pct_state - rep_pct_state) %>%
  ungroup() %>%
  arrange(year, county_fips)

pres

# compute county leans  
pres = pres %>%
  mutate(dem_pct = votes_dem / votes_all,
         rep_pct = votes_rep / votes_all,
         dem_margin = dem_pct - rep_pct,
         dem_lean = dem_margin - dem_margin_state)

# now shift each county by the amount needed to make the statewide election tied
pres = pres %>%
  mutate(dem_benchmark = 
           dem_lean - dem_margin_state)

# that's done! now, compute the avg over the last 2 cycles, as of 2024
pres = pres %>%
  filter(year >= 2020) %>%
  mutate(weight = if_else(year == 2024, 0.8, 0.2)) %>%
  group_by(state_abb, county_name, county_fips,) %>%
  summarise(
    dem_margin_state = weighted.mean(dem_margin_state, weight),
    dem_lean = weighted.mean(dem_lean, weight),
    dem_benchmark = weighted.mean(dem_benchmark, weight)
  )


# add select statewide elex -----------------------------------------------




# output ------------------------------------------------------------------

pres %>%
  # make key fields more readable
  mutate_if(is.numeric, function(x){round(x*100,1)}) %>%
  # write
  write_csv('output/county_benchmarks_2025.csv')
