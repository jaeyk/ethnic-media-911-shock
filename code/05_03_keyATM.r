## ----setup, include=FALSE----------------------------------
knitr::opts_chunk$set(echo = TRUE)


## ----------------------------------------------------------
pacman::p_load(tidyverse, # for tidyverse 
               ggpubr, # for arranging ggplots   
               ggthemes, # for fancy ggplot themes
               here, # for reproducibility 
               patchwork, # for easy ggarrange
               tm, 
               textclean, 
               textstem, 
               ggsci, # for pubs 
               fastDummies, # to create dummy variables fast
               readtext, # for reading text
               quanteda, # for text preprocessing 
               data.table, # for fast data manipulation
               stm, # for structural topic modeling
               future, # for parallel and distributed computing      
               purrr, # for functional programming 
               keyATM, # keyATM
               latex2exp)

theme_set(theme_clean())

source(here("functions", "embedding.r"))
source(here("functions", "date2index.r"))
source(here("functions", "visualize_diag.r"))

# For keyword based topic modeling (development version)
devtools::install_github("mikajoh/stmprinter")
devtools::install_github("keyATM/keyATM")

library(stmprinter)
library(keyATM)


## ----------------------------------------------------------
# Drop the first column as it's meaningless 
corpus <- read.csv(here("processed_data/cleaned_text.csv"))[,-c(1,7:9)] 

# Create dummy variables 
corpus$intervention <- if_else(corpus$date >= as.Date("2001-09-11"), 1, 0)

corpus$group <- if_else(corpus$group == "Arab", 1, 0)


## ----------------------------------------------------------
corpus$clean_text <- clean_text(corpus$text)

corpus$clean_text <- str_replace_all(corpus$clean_text, "muslims", "muslim")

corpus <- corpus %>% 
  filter(!str_detect(clean_text, "film|cartoon|festival|music|dance"))


## ----eval = FALSE------------------------------------------
## # Build a corpus
## my_corpus <- corpus(corpus$clean_text)
## # Add the document-level covariates
## docvars(my_corpus, "group") <- corpus$group
## docvars(my_corpus, "intervention") <- corpus$intervention
## docvars(my_corpus,
## "source") <- corpus$source
## docvars(my_corpus,
## "date") <- corpus$date
## # Month
## docvars(my_corpus,
## "month") <- lubridate::month(corpus$date)
## 
## # Date into index
## docvars(my_corpus) <- date2index(my_corpus)
## 
## write_rds(my_corpus, here("output", "my_corpus.rds"))
## 
## my_corpus <- read_rds(here("output", "my_corpus.rds"))


## ----eval = FALSE------------------------------------------
## # Tokenize
## data_tokens <- quanteda::tokens(my_corpus)


## ----eval = FALSE------------------------------------------
## # Construct a document-term matrix
## data_dfm <- dfm(data_tokens) %>%
##     dfm_trim(min_termfreq = 100,
##              min_docfreq = 100)


## ----eval = FALSE------------------------------------------
## write_rds(data_dfm, here("processed_data", "data_dfm.rds"))
## data_dfm <- read_rds(here("processed_data", "data_dfm.rds"))


## ----eval = FALSE------------------------------------------
## # Prepare the data for keyATM
## future::plan("multiprocess")
## 
## tictoc::tic()
## keyATM_docs <- keyATM_read(texts = data_dfm)
## tictoc::toc()
## 
## # Export
## write_rds(keyATM_docs, here("processed_data",
##                             "keyATM_docs.rds"))
## 
## keyATM_docs <- read_rds(here("processed_data", "keyATM_docs.rds"))


## ----eval = FALSE------------------------------------------
## keywords <- list(
## 
##     "resistance" = c("civil", "constitutional")
## 
##     )


## ----eval = FALSE------------------------------------------
## key_viz <- visualize_keywords(docs = keyATM_docs,
##                               keywords = keywords)
## 
## save_fig(key_viz, here("output", "keyword.png"))
## 
## vf <- values_fig(key_viz)
## 
## key_viz


## ----eval = FALSE------------------------------------------
## # future::plan(multiprocess)
## 
## set.seed(1234)
## 
## # Run many models
## many_models <- tibble(K = c(10, 20, 30)) %>%
##                mutate(topic_model = furrr::future_map(K, ~stm(data_dfm,
##                                                        K = .,
##                                                        verbose = TRUE)))
## 
## write_rds(many_models, here("processed_data", "many_models.rds"))
## 
## many_models <- read_rds(here("output", "many_models.rds"))


## ----------------------------------------------------------
set.seed(1234L)

processed <- textProcessor(
  documents = corpus$clean_text,
  metadata = corpus %>%
    select(clean_text, date, group, source, intervention)
)

out <- prepDocuments(
  documents = processed$documents,
  vocab = processed$vocab,
  meta = processed$meta
)

set.seed(1234L)

stm_models <- many_models(
  K = 5:30,
  documents = out$documents,
  vocab = out$vocab,
  prevalence = ~ intervention + s(group), 
  data = out$meta,
  N = 4,
  runs = 100
)

write_rds(stm_models, here("processed_data", "stm_models.rds"))

print_models(
  stm_models, corpus$clean_text,
  file = here("output", "stm_runs.pdf"),
  title = "Optimizing k"
)


## ----------------------------------------------------------
# Resolve conflicts 
conflicted::conflict_prefer("purrr", "map")

k_search_diag <- visualize_diag(data_dfm, many_models)

k_search_diag

ggsave(here("output", "k_search_diag.png"))


## ----eval = FALSE------------------------------------------
## future::plan("multiprocess")
## 
## out <- keyATM(docs = keyATM_docs,       # text input
##               no_keyword_topics = 1,    # number of topics without keywords
##               keywords = keywords,      # keywords
##               model = "base",           # select the model
##               options = list(seed = 250,
##               store_theta = TRUE))
## 
## write_rds(out, here("output", "keyATM_out.rds"))
## 
## out <- read_rds(here("output", "keyATM_out.rds"))
## 
## # theta = document-topic distribution
## out$theta <- round(out$theta, 0)


## ----eval = FALSE------------------------------------------
## # sum
## sums <- c(sum(out$theta[,1]), sum(out$theta[,2]),
##           sum(out$theta[,3]))


## ----eval = FALSE------------------------------------------
## topic_out <- tibble(topic_sums = sums,
##                     names = c("Anti-Asian", "Anti-racism","Others")) %>%
##            mutate(prop = topic_sums / sum(topic_sums),
##            prop = round(prop,2))
## 
## topic_out %>%
##     ggplot(aes(x = names, y = prop)) +
##     geom_col(position = "dodge") +
##     scale_y_continuous(labels =
##     scales::percent_format(accuracy = 1)) +
##     labs(x = "Topic name",
##          y = "Topic proportion",
##          title = "Topic-document distributions",
##           subtitle = "Tweets mentioned COVID-19 and either Asian, Chinese, or Wuhan related words")
## 
## ggsave(here("output", "topic_modeling_static.png"))


## ----eval = FALSE------------------------------------------
## # Extract covariates
## vars <- docvars(my_corpus)
## 
## vars_selected <- vars %>% select(intervention) %>%
##     mutate(intervention = ifelse(intervention == 1, "Post-Trump speech", "Pre-Trump speech"))
## 
## # Topic modeling
## 
## covariate_out <- keyATM(docs = keyATM_docs,       # text input
##               no_keyword_topics = 1,    # number of topics without keywords
##               keywords = keywords,      # keywords
##               model = "covariate",           # select the model
##               model_settings = list(covariates_data = vars_selected,
##                                     covariates_formula = ~ intervention),
##               options = list(seed = 250,
##               store_theta = TRUE))


## ----eval = FALSE------------------------------------------
## # Predicted mean of the document-term distribution for intervention
## 
## strata_topic <- by_strata_DocTopic(out, by_var = "intervention",
##                                    labels = c("Post-Trump speech", "Pre-Trump speech"))
## est <- summary(strata_topic)
## 
## # Baseline
## new_data <- covariates_get(covariate_out)
## 
## new_data[, "intervention"] <- 0
## 
## pred <- predict(covariate_out, new_data, label = "Others")
## 
## # Bind them together
## res <- bind_rows(est, pred)
## 
## labels <- unique(res$label)
## 
## ggplot(res, aes(x = label, ymin = Lower, ymax = Upper, group = Topic)) +
##   geom_errorbar(width = 0.1) +
##   coord_flip() +
##   facet_wrap(~Topic) +
##   geom_point(aes(x = label, y = Point)) +
##   scale_x_discrete(limits = rev(labels)) +
##   xlab("Intervention") +
##   scale_y_continuous(labels =
##   scales::percent_format(accuracy = 1))


## ----eval = FALSE------------------------------------------
## tictoc::tic()
## dynamic_out_day <- keyATM(docs = keyATM_docs,    # text input
##                       no_keyword_topics = 1,              # number of topics without keywords
##                       keywords = keywords,       # keywords
##                       model = "dynamic",         # select the model
##                       model_settings = list(time_index = docvars(my_corpus)$index,                                          num_states = 5),
##                       options = list(seed = 250, store_theta = TRUE, thinning = 5))
## tictoc::toc()
## # Save
## write_rds(dynamic_out_day, here("outputs", "dynamic_out_day.rds"))

## ----------------------------------------------------------
dynamic_out_day <- read_rds(here("outputs", "dynamic_out_day.rds"))
# Visualize 
fig_timetrend_day <- plot_timetrend(dynamic_out_day, time_index_label = as.Date(docvars(my_corpus)$date), xlab = "Date", width = 5) 
keyATM::save_fig(fig_timetrend_day, here("outputs", "dynamic_topic_day.png"))
# Alt visualize 
df <- data.frame(date = fig_timetrend_day$values$time_index,
                mean = fig_timetrend_day$values$Point,
                upper = fig_timetrend_day$values$Upper,
                lower = fig_timetrend_day$values$Lower,
                topic = fig_timetrend_day$values$Topic)

## ----------------------------------------------------------
df %>% ggplot() +
    geom_line(aes(x = date, y = mean),
              alpha = 0.5, size = 1.2) +
    geom_ribbon(aes(x = date, y = mean, ymax = upper, ymin = lower),
                alpha = 0.3) +
    geom_smooth(aes(x = date, y = mean, ymax = upper, ymin = lower),
                method = "loess", 
                size = 1.5, 
                span = 0.3) + # for given x, loess will use the 0.3 * N closet poitns to x to fit. source: https://rafalab.github.io/dsbook/smoothing.html
    labs(title = "Topic trends over time",
         subtitle = "Tweets mentioned COVID-19 and either Asian, Chinese, or Wuhan",
         x = "Date", 
         y = "Topic proportion") +
    facet_wrap(~topic) +
    geom_vline(xintercept = as.Date(c("2020-03-16")),
               linetype = "dashed",
               size = 1.2,
               color = "black") +
    scale_y_continuous(labels =    
    scales::percent_format(accuracy = 1)) 
ggsave(here("outputs", "anti_asian_topic_dynamic_trend.png"))


## ----eval = FALSE------------------------------------------
## knitr::purl(input = here("code", "05_03_keyATM.Rmd"),
##             output = here("code", "05_03_keyATM.r"))

