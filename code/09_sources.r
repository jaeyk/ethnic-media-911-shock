pacman::p_load(tidyverse, 
               glue,
               kableExtra)

#### Main ####
main <- tibble(Source = c("The Arab American News", "The Arab American View", "News India Times", "India Abroad", "India West"),
             N = c(19728, 129, 44244, 49894, 60862),
             start_year = c(1994, 2001, 1993, 1990, 1990),
             last_year = c(2018, 2004, 2018, 2017, 2018)) %>%
  unite("Period", start_year, last_year, sep = "-")

main %>% select(Source, Period, N) %>% kableExtra::kable(format = "latex",
                         booktabs = TRUE)

#### Placebo ####
placebo <- tibble(Source = 
c("Armenian Reporter International", 
  "Polish American Journal",
  "The Boston Irish Reporter", 
  "Irish Voice",
  "Ukrainian Weekly",
  "Italian Voice",
  "An Scathan",
  "The Hellenic Times",
  "Armenian Reporter",
  "The Finnish American Reporter"),
N = c(16685, 8417, 7840, 49699, 24310, 13712, 740, 1907, 2986, 9462),
start_year = c(1991, 1990, 1994, 1991, 1993, 1990, 1995, 2002, 2006, 1992), 
last_year = c(2006, 2019, 2019, 2019, 2018, 2019, 1998, 2013, 2010, 2019)) %>%
  unite("Period", start_year, last_year, sep = "-")

placebo %>% select(Source, Period, N) %>% kableExtra::kable(format = "latex",
                           booktabs = TRUE)