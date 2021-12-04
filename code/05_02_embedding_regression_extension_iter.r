## ----setup, include=FALSE----------------
knitr::opts_chunk$set(echo = TRUE)

## ----------------------------------------

# Import pkgs
pacman::p_load(
  tidyverse,
  lubridate, 
  purrr,
  furrr,
  tm,
  quanteda, 
  here,
  tidytext, # text analysis 
  textclean,
  textstem, 
  ggthemes,
  text2vec, # word embedding 
  widyr,
  patchwork, # arranging ggplots
  glue,
  # deep learning 
  text2vec,
  # network graph
  igraph,
  ggraph,
  # structural breakpoint
  strucchange,
  pbapply,
  kableExtra
)

devtools::install_github("prodriguezsosa/conText")

library(conText)

theme_set(theme_clean())

source(here("functions", "embedding.r"))

corpus <- read.csv(here("processed_data", "corpus.csv"))

## ----------------------------------------
corpus$clean_text <- clean_text(corpus$text)

corpus <- corpus %>% 
  filter(!str_detect(clean_text, "film|cartoon|festival|music|dance"))

corpus_copy <- corpus

get_mean_mod <- function(corpus_copy) {

  corpus <- corpus_copy %>%
    filter(group %in% c("Arab", "Indian")) %>%
    mutate(group = if_else(str_detect(group, "Arab"), 1, 0))

  quant_corpus <- quanteda::corpus(
    corpus, 
    text_field = "clean_text")
  
  # remove unncessary elements 
  toks <- quanteda::tokens(quant_corpus,  
                           remove_punct = T, 
                           remove_symbols = T, 
                           remove_numbers = T, 
                           remove_separators = T)
  
  # only use features that appear at least 5 times in the corpus
  feats <- dfm(toks, verbose = TRUE) %>% 
    dfm_trim(min_termfreq = 5) %>% 
    featnames()
  
  # leave the pads 
  toks <- tokens_select(toks, feats, padding = TRUE)
  
    ## ----------------------------------------
  load(file = here("processed_data/context_bg_ai.Rdata"))
       
  mod1 <- conText(formula = terror ~ pattern.intervention + pattern.group, 
                  data = toks, 
                  pre_trained = local_glove,
                  transform = TRUE, 
                  transform_matrix = local_transform, 
                  bootstrap = TRUE, 
                  num_bootstraps = 20, 
                  stratify = TRUE,
                  permute = TRUE, 
                  num_permutations = 200, 
                  window = 6, 
                  valuetype = 'fixed', 
                  case_insensitive = TRUE, 
                  hard_cut = FALSE,
                  verbose = FALSE)

  ## ----------------------------------------
  corpus <- corpus_copy %>%
    filter(group %in% c("Arab", "Filipino")) %>%
    mutate(group = if_else(str_detect(group, "Arab"), 1, 0))
  
  quant_corpus <- quanteda::corpus(
    corpus, 
    text_field = "clean_text")
  
  # remove unncessary elements 
  toks <- quanteda::tokens(quant_corpus,  
                           remove_punct = T, 
                           remove_symbols = T, 
                           remove_numbers = T, 
                           remove_separators = T)
  
  # only use features that appear at least 5 times in the corpus
  feats <- dfm(toks, verbose = TRUE) %>% 
    dfm_trim(min_termfreq = 5) %>% 
    featnames()
  
  # leave the pads 
  toks <- tokens_select(toks, feats, padding = TRUE)
  
  ## ----------------------------------------
  load(file = here("processed_data/context_bg_af.Rdata"))
  
  quant_corpus <- quanteda::corpus(
    corpus, 
    text_field = "clean_text")
  
  # remove unncessary elements 
  toks <- quanteda::tokens(quant_corpus,  
                           remove_punct = T, 
                           remove_symbols = T, 
                           remove_numbers = T, 
                           remove_separators = T)
  
  # only use features that appear at least 5 times in the corpus
  feats <- dfm(toks, verbose = TRUE) %>% 
    dfm_trim(min_termfreq = 5) %>% 
    featnames()
  
  # leave the pads 
  toks <- tokens_select(toks, feats, padding = TRUE)
  
  mod2 <- conText(formula = terror ~ pattern.intervention + pattern.group, 
                  data = toks, 
                  pre_trained = local_glove,
                  transform = TRUE, 
                  transform_matrix = local_transform, 
                  bootstrap = TRUE, 
                  num_bootstraps = 20, 
                  stratify = TRUE,
                  permute = TRUE, 
                  num_permutations = 200, 
                  window = 6, 
                  valuetype = 'fixed', 
                  case_insensitive = TRUE, 
                  hard_cut = FALSE,
                  verbose = FALSE)
  
  ## ----------------------------------------
  corpus <- corpus_copy %>%
    filter(group %in% c("Arab", "AAPI")) %>%
    mutate(group = if_else(str_detect(group, "Arab"), 1, 0))
  
  ## ----------------------------------------
  load(here("processed_data/context_bg_aa.Rdata"))
  
  quant_corpus <- quanteda::corpus(
    corpus, 
    text_field = "clean_text")
  
  # remove unncessary elements 
  toks <- quanteda::tokens(quant_corpus,  
                           remove_punct = T, 
                           remove_symbols = T, 
                           remove_numbers = T, 
                           remove_separators = T)
  
  # only use features that appear at least 5 times in the corpus
  feats <- dfm(toks, verbose = TRUE) %>% 
    dfm_trim(min_termfreq = 5) %>% 
    featnames()
  
  # leave the pads 
  toks <- tokens_select(toks, feats, padding = TRUE)
  
  mod3 <- conText(formula = terror ~ pattern.intervention + pattern.group, 
                  data = toks, 
                  pre_trained = local_glove,
                  transform = TRUE, 
                  transform_matrix = local_transform, 
                  bootstrap = TRUE, 
                  num_bootstraps = 20, 
                  stratify = TRUE,
                  permute = TRUE, 
                  num_permutations = 200, 
                  window = 6, 
                  valuetype = 'fixed', 
                  case_insensitive = TRUE, 
                  hard_cut = FALSE,
                  verbose = FALSE)
  
  out <- mean(mod1@normed_cofficients$normed.estimate[1]/mod1@normed_cofficients$normed.estimate[2],
              mod2@normed_cofficients$normed.estimate[1]/mod2@normed_cofficients$normed.estimate[2],
              mod3@normed_cofficients$normed.estimate[1]/mod3@normed_cofficients$normed.estimate[2])
  
  return(out)
}

res <- rerun(1000, get_mean_mod(corpus_copy))

write_rds(res, here("processed_data", "iter.rds"))

res_df <- data.frame(out = unlist(res),
                     num = 1:1000)

res_df %>%
  ggplot(aes(x = num, y = out)) +
  geom_point() +
  geom_hline(yintercept = mean(res_df$out), linetype = "dashed", col = "red", size = 1) +
  ggplot2::annotate("text", x = 500, 
                y = 1.43, label = glue("Mean = {round(mean(res_df$out),2)}"), col = "red", size = 5) +
  labs(x = "Iteration #", y = "Ratio (Overtime/Between group)")

ggsave(here("outpus", "iter_mean.png"))
  