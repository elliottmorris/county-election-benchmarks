library(tidyverse)
library(janitor)

# read in 2024 pres by county
pres = read_csv('output/pres_results_county_2024.csv')


# read in 2025 results (author compiled)
statewide = read_csv('data/2025 statewide elections benchmarks (VA, NJ, GA, PA) - 2025 top of ticket.csv')
statewide = clean_names(statewide)

statewide = statewide %>%
  mutate(percent_of_votes_in_in = as.numeric(gsub("%","",gsub(">95","100",percent_of_votes_in_in ))))

# create dem/rep margin
statewide = statewide %>%
  separate_wider_delim(cols = margin, delim =' ', names = c('leader','margin')) %>%
  mutate(margin = as.numeric(gsub("+","",margin)),
         dem_margin = 
           case_when(leader %in% c("Sherrill","Spanberger","Johnson","Tsai") ~ margin,
                     leader %in% c("Ciattarelli","Earle-Sears","Echols","Wolford") ~ margin*-1,
                     T ~ NA_real_),
         dem_margin = dem_margin / 100
  ) 


statewide = statewide %>%
  mutate(total_votes_2025 = votes/ (percent_of_votes_in_in/100),
         county = toupper(county_elliott)) %>%
  select(state_abb = state, county_name = county, 
         dem_margin_2025 = dem_margin, 
         total_votes_2025) 
         

# merge the data
joint = statewide %>%
  left_join(pres, by = c('state_abb','county_name')) %>%
  mutate(swing = dem_margin_2025 - dem_margin,
         turnout_pfct_of_2024 = total_votes_2025 / votes_all) %>%
  arrange(desc(abs(swing))) %>%
  na.omit

# change in dem %
gg1 = ggplot(joint, aes(x = dem_margin, y= dem_margin_2025, weight = total_votes_2025,
                  col=state_abb)) + 
  geom_point(aes(size = total_votes_2025), shape = 1) + 
  geom_smooth(method='loess',se=F,linetype=1,fullrange=T) +
  theme_minimal() + 
  geom_abline() +
  labs(x = "Democratic margin in 2024 presidential race",
       y = "Democratic margin in 2025 statewide election",
       title = "Almost every county moved toward Democrats in VA, NJ, PA and GA",
       col = 'State',
       size = 'Total votes cast in 2025')  +
  theme(legend.position = 'top',legend.justification = 'left') +
  geom_vline(xintercept = 0,col='gray80') +
  geom_hline(yintercept = 0,col='gray80') +
  scale_color_brewer(palette = 'Set1') +
  coord_cartesian(xlim = c(-1, 1),ylim=c(-1,1)) +
  scale_x_continuous(labels = function(x){x*100},
                     breaks=seq(-1,1,0.25)) +
  scale_y_continuous(labels = function(x){x*100},
                     breaks=seq(-1,1,0.25)) +
  scale_size(range=c(1,10),labels = scales::number_format())

gg1

gg1 + 
  coord_cartesian(xlim = c(-0.5, 0.5),ylim=c(-0.5,0.5)) +
  scale_x_continuous(labels = function(x){x*100},
                     breaks=seq(-1,1,0.1)) +
  scale_y_continuous(labels = function(x){x*100},
                     breaks=seq(-1,1,0.1)) 
  
# change in  turnout
ggplot(joint, aes(x = dem_margin, y= turnout_pfct_of_2024, 
                  col=state_abb, weight = total_votes_2025)) + 
  geom_point(aes(size = total_votes_2025), shape = 1) + 
  geom_smooth(method='loess',se=F,linetype=1,fullrange=T) +
  theme_minimal() +
  theme(legend.position = 'top',legend.justification = 'left',legend) +
  labs(x = "Democratic margin in 2024 presidential race",
       y = "2025 ballots cast / 2024 ballots cast",
       title = "Turnout was higher in gov. elections and Dem-leaning counties",
       col = 'State',
       size = 'Total votes cast in 2025',)+
  geom_vline(xintercept = 0,col='gray80') +
  geom_hline(yintercept = 1,col='gray80') +
  scale_color_brewer(palette = 'Set1')  +
  scale_x_continuous(labels = function(x){x*100}) +
  scale_y_continuous(labels = function(x){paste0(x*100,'%')},
                     breaks=seq(0,1.3,0.1)) +
  scale_size(range=c(1,10),labels = scales::number_format())


joint %>%
  group_by(state_abb) %>%
  summarise(swing = weighted.mean(swing, total_votes_2025)) %>%
  arrange(desc(swing))
