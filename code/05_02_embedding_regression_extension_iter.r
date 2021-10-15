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

    ## ----------------------------------------
  load(file = here("processed_data/context_bg_ai.Rdata"))
       
  mod1 <- conText(formula = terror ~ intervention + group, 
            data = corpus, 
            text_var = 'clean_text', 
            pre_trained = local_glove,
            transform = TRUE, 
            transform_matrix = local_transform, 
            bootstrap = TRUE, 
            num_bootstraps = 200, 
            stratify_by = c('intervention', 'group'),
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
  
  
  ## ----eval = FALSE------------------------
  ## set.seed(20201008L)
  ## local_glove <- df2vec(corpus)
  ## local_transform <- df2ltm(corpus, local_glove)
  ## 
  ## save(local_glove, local_transform,
  ##      file = here("processed_data/context_bg_af.Rdata"))
  
  
  ## ----------------------------------------
  load(file = here("processed_data/context_bg_af.Rdata"))
  
  mod2 <- conText(formula = terror ~ intervention + group, 
            data = corpus, 
            text_var = 'clean_text', 
            pre_trained = local_glove,
            transform = TRUE, 
            transform_matrix = local_transform, 
            bootstrap = TRUE, 
            num_bootstraps = 200, 
            stratify_by = c('intervention', 'group'),
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
  
  mod3 <- conText(formula = terror ~ intervention + group, 
            data = corpus, 
            text_var = 'clean_text', 
            pre_trained = local_glove,
            transform = TRUE, 
            transform_matrix = local_transform, 
            bootstrap = TRUE, 
            num_bootstraps = 200, 
            stratify_by = c('intervention', 'group'),
            permute = TRUE, 
            num_permutations = 200, 
            window = 6, 
            valuetype = 'fixed', 
            case_insensitive = TRUE, 
            hard_cut = FALSE, 
            verbose = FALSE)
  
  out <- mean(mod1$normed_betas$Normed_Estimate[1]/mod1$normed_betas$Normed_Estimate[2],
  mod2$normed_betas$Normed_Estimate[1]/mod2$normed_betas$Normed_Estimate[2],
  mod3$normed_betas$Normed_Estimate[1]/mod3$normed_betas$Normed_Estimate[2])
  
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
  