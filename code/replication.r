# This script is for reproducing tables and figures used in the article. If you want to check each research step, please check README.md and associated R markdown files Jupyter notebooks. 
# Please make ITS-Text-Classification as an R project directory. If you use R Studio, you can do that by File > New Project > Existing Directories.

######################## SETUP ######################## 

# Load packages
if (!require(pacman)) install.packages("pacman")

pacman::p_load(tidyverse, # tidyverse 
               tidymodels, # tidymodels
               ggplot2, # ggplot2
               ggpubr, # publication ready theme 
               here, # for computationally reproducible file paths 
               glue, # pasting objects and strings 
               kableExtra, # producing tables 
               patchwork, # putting ggplots 
               yardstick, # model evaluations
               nlme, # GLS
               stargazer, # LaTeX table 
               forecast, # time-series forecasting
               lubridate, # date object manipulation
               estimatr) # estimation

# Custom functions 
source(here("functions/utils.r"))
source(here("functions/reg_analysis.r"))

# Publication ready plots 
# ggplot2::theme_set(ggpubr::theme_classic2())

######################## MANUSCRIPT ######################## 

# Figure 1 ITS design analysis results

load(file = here("processed_data/base_its.RData"))

its_base_dom_plot <- visualize_base(df_domestic) + ggtitle("Arab and Indian Immigrants' Domestic Political Interests") + labs(tag = "A", caption = "")

its_base_nondom_plot <- visualize_base(df_nondomestic) + ggtitle("Arab and Indian Immigrants' International Political Interests") + labs(tag = "B")

its_base_dom_plot / its_base_nondom_plot

ggsave(here("output" ,"its_base_plot.png"), height = 8)

# Table 1 ITS design analysis results (OLS)

dom_output_ols <- lm(count_ts ~ intervention +  date + group, 
                     data = df_domestic) 

nondom_output_ols <- lm(count_ts ~ intervention +  date + group, 
                        data = df_nondomestic)

stargazer(dom_output_ols, nondom_output_ols,
          title = "ITS design analysis results",
          dep.var.labels = c("The publication count for Muslim-related articles on"),
          header = FALSE,
          single.row = TRUE,
          column.labels = c("Domestic politics",
                            "International politics"),
          covariate.labels = c("Intervention",
                               "Date",
                               "Indian Americans"),
          model.numbers = FALSE)

# Table ITS design analysis results (OLS with robust standard errors)

dom_output_robust <- lm_robust(count_ts ~ intervention +  date + group, 
                     data = df_domestic) 

nondom_output_robust <- lm_robust(count_ts ~ intervention +  date + group, 
                        data = df_nondomestic)

bind_rows(tidy(dom_output_ols, conf.int = TRUE) %>% mutate(model = "OLS"),
tidy(dom_output_robust) %>% mutate(model = "OLS with Robust SEs")) %>%
  filter(term != "(Intercept)") %>%
  ggplot(aes(x = term, y = estimate, 
             ymin = conf.low,
             ymax = conf.high)) +
    geom_pointrange() +
    scale_x_discrete(labels = 
      c("date" = "Date",
        "groupIndian Americans" = "Indian Americans",
        "intervention" = "Intervention")) +
    facet_wrap(~model) +
    coord_flip() +
    labs(x = "Term",
         y = "Estimate")

ggsave(here("output/ols_robust_ses.png"))

# Figure 2 NYT Articles (left) and Ethnic Newspaper Articles (right)

load(here("processed_data", "ethnic_NYT.RData"))

its_dom_plot <- visualize_placebo(df_domestic) + 
  ggtitle("NYT Articles on Domestic Politics") + 
  labs(tag = "A", caption = "") +
  ylim(c(0,20))

its_nondom_plot <- visualize_placebo(df_nondomestic) + 
  ggtitle("NYT Articles on International Politics") + 
  labs(tag = "C", 
       caption = "Source: New York Times") +
  ylim(c(0,20))

comp_its_dom_plot <- visualize_placebo(comp_df_domestic) + 
  ggtitle(glue("Ethnic Newspaper Articles on 
               Domestic Politics")) + 
  labs(tag = "B", caption = "", y = "") +
  ylim(c(0,20))

comp_its_nondom_plot <- visualize_placebo(comp_df_nondomestic) + 
  ggtitle(glue("Ethnic Newspaper Articles on 
               International Politics")) + 
  labs(tag = "D", caption = "Source: Ethnic NewsWatch", y = "") +
  ylim(c(0,20))

(its_dom_plot + comp_its_dom_plot) /
  (its_nondom_plot + comp_its_nondom_plot)

ggsave(here("output/nyt_ethnic_its_comp.png"), height = 8)

# Table 2 ITS design analysis results (GLS)

load(here("processed_data", "gls_base.RData"))

stargazer(dom_output_gls, nondom_output_gls,
          title = "ITS design analysis results",
          dep.var.labels = c("The publication count for Muslim-related articles on"),
          header = FALSE,
          single.row = TRUE,
          column.labels = c("Domestic politics",
                            "International politics"),
          covariate.labels = c("Intervention",
                               "Date",
                               "Indian Americans"),
          model.numbers = FALSE)

# Table 3 ITS design analysis results with source fixed effects

load(here("processed_data", "gls_fe.RData"))

stargazer(dom_output_fe, nondom_output_fe,
          title = "ITS design analysis results",
          dep.var.labels = c("The publication count for Muslim-related articles on"),
          header = FALSE,
          single.row = TRUE,
          column.labels = c("Domestic politics",
                            "International politics"),
          covariate.labels = c("Intervention",
                               "Date"),
          model.numbers = FALSE)

######################## APPENDIX ######################## 

# Table A.1 Summary information of the Arab American and Indian American newspapers available
# at the Ethnic NewsWatch Database, 1996-2006. Retrieved on September 28, 2020

tablea1 <- tibble(Source = c("The Arab American News", "The Arab American View", "News India Times", "India Abroad", "India West"),
             N = c(19728, 129, 44244, 49894, 60862),
             start_year = c(1994, 2001, 1993, 1990, 1990),
             last_year = c(2018, 2004, 2018, 2017, 2018)) %>%
  unite("Period", start_year, last_year, sep = "-")

tablea1 %>% 
  select(Source, Period, N) %>% 
  kableExtra::kable(
    format = "latex",
    booktabs = TRUE,
    caption = "Summary information of the Arab American and Indian American newspapers available
at the Ethnic NewsWatch Database, 1996-2006. Retrieved on September 28, 2020.")

# Figure B.1. Machine Learning Outcomes

## Load data
load(here("processed_data/splitted_data.RData")) # splitted processed data
load(here("output/fits.RData")) # model fit data 

## Decide metrics 
metrics <- yardstick::metric_set(accuracy, precision, recall, f_meas)

## Visualize outcomes
(visualize_class_eval(lasso_fit) + labs(title = "Lasso")) /
(visualize_class_eval(rand_fit) + labs(title = "Random forest"))  /
(visualize_class_eval(xg_fit) + labs(title = "XGBoost"))

ggsave(here("output", "ml_eval.png"), height = 10)

# Figure C.1. Duration Effect Analysis

load(here("processed_data", "duration_model.RData"))

model_out %>%
  mutate(Year = rep(2001:2006, each = 4)) %>%
  ggplot(aes(x = Year, y = Estimate)) +
  geom_point() +
  facet_grid(Category ~ Model)

ggsave(here("output", "duration_effect.png"))

# Table D.1. ITS design analysis results

dom_output_ols <- lm(count_ts ~ intervention + date, 
                     data = df_domestic) 

stargazer(dom_output_ols, 
          title = "ITS design analysis results",
          dep.var.labels = c("The publication count for Muslim-related articles on"),
          header = FALSE,
          single.row = TRUE,
          column.labels = c("Domestic politics",
                            "International politics"),
          covariate.labels = c("Intervention",
                               "Date"),
          model.numbers = FALSE)

# Figure E.1. Autocorrelation plot

load(here("processed_data", "acf.RData"))

acf_dom <- acf_plot(df_domestic_ts) + ggtitle("Domestic Political Interests") + labs(tag = "A")

acf_nondom <- acf_plot(df_nondomestic_ts) + ggtitle("International Political Interests") + labs(tag = "B")

acf_dom / acf_nondom

ggsave(here("output", "acf_plot.png"))

# Figure F.1. Line plots of raw data faceted by source variable

df <- read.csv(here("processed_data/df.csv"))[,-1]
df$date <- lubridate::ymd(df$date)

cleaned_domestic_plot_source <- group_df(df, source) %>%
  filter(domestic == "Domestic") %>% 
  visualize_raw() +  
  facet_wrap(~source, scale = "free_y") + # facetting, y scale is free   
  ggtitle("Arab and Indian Immigrants' Domestic Political Interests") + 
  labs(tag = "A", caption = "")

cleaned_nondomestic_plot_source <- group_df(df, source) %>%
  filter(domestic != "Domestic") %>% 
  visualize_raw() +
  ggtitle("Arab and Indian Immigrants' International Political Interests") + 
  labs(tag = "B") +
  facet_wrap(~source, scale = "free_y") # facetting, y scale is free 

cleaned_domestic_plot_source / cleaned_nondomestic_plot_source

ggsave(here("output" ,"cleaned_data_plot_source.png"), 
       height = 8,
       width = 8)