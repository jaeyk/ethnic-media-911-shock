
library(tidyverse)
library(here)

devtools::install_github("jaeyk/tidyethnicnews", force = TRUE)

dir_path <- "/home/jae/muslim_newspapers-selected/placebo/"

# Turn HTML files into a single tidy dataframe 
df <- tidyethnicnews::html_to_dataframe_all(dir_path)

df_distinct <- df %>% distinct(text, author, source, date) # No duplicates 
  
df_distinct$date <- lubridate::dmy(df_distinct$date) # Turn character into date variable  

# Find articles met the conditions for the data analysis 

df_distinct <- df_distinct %>%
  filter(between(date, as.Date("1996-09-10"), as.Date("2006-09-12"))) 

# Unit tests 

min(df_distinct$date) > 1995
max(df_distinct$date) < 2007

# Add the intervention variable 

df_distinct$intervention <- ifelse(df_distinct$date < as.Date("2001-09-11"), 0, 1)

write_csv(df_distinct, here("processed_data", "placebo.csv"))
