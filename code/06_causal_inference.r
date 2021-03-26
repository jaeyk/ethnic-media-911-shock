## ------------------------------------------------------------------

# Import libraries 

pacman::p_load(
        tidyverse, # the tidyverse framework 
        splitstackshape, # stacking and reshaping datasets 
        tsModel, # specifying time series regression models
        lmtest, # testing linear regression models
        Epi, # statistical analysis in epidemiology 
        splines, # spline regression
        vcd, # visualizing categorical variable 
        nlme, # linear and nonlinear mixed effects models 
        zoo, # S3 infrastructure regular and irregular time series 
        simpleboot, # bootstrapping 
        TTR, # constructing technical trading rules
        ggpmisc, # detecting peaks and valleys 
        broom, # tidying model objects 
        modelr, # modeling 
        forecast, # forecasting 
        ggseas, # seasonal and decomposition on the fly
        itsadug, # interpreting time series and autocorrelated data 
        mgcv, # mixed GAM Computation Vehicle with Automatic Smoothness Estimation
        tseries, # computational financial analysis
        mcp, # regression with multiple change points
        lawstat, # testing stats in biostat, public policy, and law
        sarima, # simulation and prediction with seasonal ARIMA models  
        car, # Durbin Watson test 
        tidyr, # tidying messy daa 
        AICcmodavg, # computing predicted values and standard errors 
        MuMIn, # selecting models
        ggthemes, # fancy ggplot themes
        ggpubr, # arranging plots 
        stargazer, # regression table 
        here, # reproducibility 
        patchwork, # rearranging ggplot 
        purrr, # functional programming 
        testthat, # unit testing 
        install = TRUE, 
        update = TRUE)

# devtools::install_github("jaeyk/makereproducible")
library(makereproducible)

# Import R scripts

script_list <- list.files(paste0(here::here(), "/functions"),
  pattern = "*.r|*.R",
  full.names = TRUE
)

for (i in 1:length(script_list))
{
  source(script_list[[i]])
}


## ----include=FALSE-------------------------------------------------

# Import files 
sample <- readr::read_csv(here("raw_data/sample_articles.csv"))

unlabeled <- readr::read_csv(here("processed_data/predicted.csv"))[,-1]


## ------------------------------------------------------------------
sample <- sample %>% rename(domestic = category)
unlabeled <- unlabeled %>% rename(domestic = category)


## ------------------------------------------------------------------

# Row bind the two dataframes  

df <- bind_rows(sample_selected, labeled_selected)

# Fix the coding error in the intervention variable (reversing values)

df$intervention[df$intervention == "post"] <- "1"
df$intervention[df$intervention == "pre"] <- "0"

df$intervention[df$intervention == "1"] <- "pre"
df$intervention[df$intervention == "0"] <- "post"



## ------------------------------------------------------------------

# df <- read_csv("/home/jae/ITS-Text-Classification/processed_data.df.csv")

# Check date variable 

paste("the class of date is", class(df$date))

# Convert date into date object 

df$date <- as.Date(as.character(df$date), "%Y%m%d") 

# Recode values in domestic variable 

df$domestic <- as.character(df$domestic) 
df$domestic[df$domestic == 1] <- "Domestic"
df$domestic[df$domestic == 0] <- "International"

# Create group variable based on newspaper names 

df$group <- ifelse(str_detect(df$source, "India"), "Indian Americans", "Arab Americans")

# Save the processed data 

write.csv(df, make_here("/home/jae/ITS-Text-Classification/processed_data/df.csv"))



## ------------------------------------------------------------------

# Save plot 
  
cleaned_domestic_plot <- group_df(df, group) %>%
  filter(domestic == "Domestic") %>% visualize_raw() +  
  facet_wrap(~group, scale = "free_y") + # facetting, y scale is free   
  ggtitle("9/11 and Minority Domestic Political Interests") + 
  labs(tag = "A", caption = "")

cleaned_nondomestic_plot <- group_df(df, group) %>%
  filter(domestic != "Domestic") %>% visualize_raw() + 
  ggtitle("9/11 and Minority International Political Interests") + 
  labs(tag = "B") +
  facet_wrap(~group, scale = "free_y") # facetting, y scale is free 

cleaned_domestic_plot / cleaned_nondomestic_plot

ggsave(make_here("/home/jae/ITS-Text-Classification/output/cleaned_data_plot.png"), height = 8)

cleaned_domestic_plot_source <- group_df(df, source) %>%
  filter(domestic == "Domestic") %>% visualize_raw() +  
  facet_wrap(~source, scale = "free_y") + # facetting, y scale is free   
  ggtitle("9/11 and Minority Domestic Political Interests") + 
  labs(tag = "A", caption = "")

cleaned_nondomestic_plot_source <- group_df(df, source) %>%
  filter(domestic != "Domestic") %>% visualize_raw() +
  ggtitle("9/11 and Minority International Political Interests") + 
  labs(tag = "B") +
  facet_wrap(~source, scale = "free_y") # facetting, y scale is free 

cleaned_domestic_plot_source / cleaned_nondomestic_plot_source

ggsave(make_here("/home/jae/ITS-Text-Classification/output/cleaned_data_plot_source.png"), 
       height = 8,
       width = 8)



## ------------------------------------------------------------------

# Create assignment variable 

df_grouped <- group_df(df, group)

# Divide data 

df_domestic <- df_grouped %>%
  filter(domestic == "Domestic") 

df_nondomestic <- df_grouped %>%
  filter(domestic != "Domestic") 

# Visualize ITS analysis result for each subset of the data 

its_base_dom_plot <- visualize_base(df_domestic) + ggtitle("9/11 and Minority Domestic Political Interests") + labs(tag = "A", caption = "")

its_base_nondom_plot <- visualize_base(df_nondomestic) + ggtitle("9/11 and Minority International Political Interests") + labs(tag = "B")

its_base_dom_plot / its_base_nondom_plot

ggsave(make_here("/home/jae/ITS-Text-Classification/output/its_base_plot.png"), height = 8)



## ------------------------------------------------------------------

# Create the full date 

all_days <- seq(min(df_grouped$date), max(df_grouped$date), by = "+1 day")

# Turn it into a dataframe 

all_days <- data.frame(date = all_days)

# Filling the missing days 

df_grouped <- all_days %>%
  merge(df_grouped, by = "date", all.x = TRUE)

# Divide data 

df_domestic <- df_grouped %>%
  filter(domestic == "Domestic") 

df_nondomestic <- df_grouped %>%
  filter(domestic != "Domestic") 



## ----echo=FALSE----------------------------------------------------
# Apply to each data
acf_dom <- acf_plot(df_domestic) + ggtitle("Domestic Political Interests") + labs(tag = "A")

acf_nondom <- acf_plot(df_nondomestic) + ggtitle("International Political Interests") + labs(tag = "B")

acf_dom / acf_nondom

ggsave(make_here("/home/jae/ITS-Text-Classification/output/acf_plot.png"))



## ----eval=FALSE, include=FALSE-------------------------------------
## 
## pq_domestic <- mapply(correct_ac_domestic, c(1,2,3), c(1))
## 
## pq_nondomestic <- mapply(correct_ac_nondomestic, c(1,2,3), c(1))
## 
## pq_domestic
## pq_nondomestic


## ------------------------------------------------------------------

# Visualize each result in the scatted plot 

its_adj_dom_plot <- visualize_adj(df_domestic, 3, 1) + ggtitle("9/11 and Minority Domestic Political Interests") + labs(caption = "", tag = "A")

its_adj_nondom_plot <- visualize_adj(df_nondomestic, 3, 1) + ggtitle("9/11 and Minority International Political Interests") + labs(tag = "B")

its_adj_dom_plot / its_adj_nondom_plot

ggsave(here("output", "its_adjusted_plot.png"), height = 8)

install.packages("rjags")



## ------------------------------------------------------------------
df_domestic <- df_domestic %>%
    mutate(year = extract_year(df_domestic))

df_nondomestic <- df_nondomestic %>%
    mutate(year = extract_year(df_nondomestic))

model_out <- map_dfr(c(1:6), model_spec)

model_out %>%
  mutate(Year = rep(2001:2006, each = 4)) %>%
  ggplot(aes(x = Year, y = Estimate)) +
    geom_point() +
    facet_grid(Category ~ Model)

ggsave(here("output", "duration_effect.png"))



## ------------------------------------------------------------------

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



## ------------------------------------------------------------------

dom_output_gls <- gls(count_ts ~ intervention +  date + group, 
               data = df_domestic,
               correlation = corARMA(p= 3, q = 1, form = ~ date | group)) 

nondom_output_gls <- gls(count_ts ~ intervention +  date + group, 
               data = df_nondomestic,
               correlation = corARMA(p= 3, q = 1, form = ~ date | group)) 

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


## ------------------------------------------------------------------

pq_domestic_source <- mapply(correct_ac_domestic_source, c(1,2,3), c(1))

pq_nondomestic_source <- mapply(correct_ac_nondomestic_source, c(1,2,3), c(1))

pq_domestic_source # [1,1]

pq_nondomestic_source # [2,1]



## ------------------------------------------------------------------

dom_output_gls <- gls(count_ts ~ intervention +  date + source, 
               data = group_df(df %>% filter(group == "Indian Americans"), source) %>% filter(domestic == "Domestic"),
               correlation = corARMA(p = 1, q = 1, form = ~ date | source)) 

nondom_output_gls <- gls(count_ts ~ intervention +  date + source, 
               data = group_df(df %>% filter(group == "Indian Americans"), source) %>% filter(domestic != "Domestic"),
               correlation = corARMA(p = 2, q = 1, form = ~ date | source)) 

stargazer(dom_output_gls, nondom_output_gls,
          title = "ITS design analysis results",
          dep.var.labels = c("The publication count for Muslim-related articles on"),
          header = FALSE,
          single.row = TRUE,
          column.labels = c("Domestic politics",
                            "International politics"),
          covariate.labels = c("Intervention",
                               "Date"),
          model.numbers = FALSE)



## ----eval=FALSE----------------------------------------------------
## knitr::purl(input = here("code", "06_causal_inference.Rmd"),
##             output = here("code", "06_causal_inference.r"))

