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