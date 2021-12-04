## ----setup, include=FALSE----------------
knitr::opts_chunk$set(echo = TRUE)

## ----------------------------------------

# Import pkgs
pacman::p_load(
  tidyverse,
  zeallot, 
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

terror_res <- get_terror_mod(corpus_copy)
immigrant_res <- get_immigrant_mod(corpus_copy)
criminal_res <- get_criminal_mod(corpus_copy)
hate_res <- get_hate_mod(corpus_copy)

df <- bind_rows(mutate(parse_embed_out(terror_res), keyword = "Terror"),
mutate(parse_embed_out(immigrant_res), keyword = "Immigrant"),
mutate(parse_embed_out(criminal_res), keyword = "Criminal"),
mutate(parse_embed_out(hate_res), keyword = "Hate"))

df %>%
  ggplot(aes(x = fct_reorder(group, estimate), y = estimate, ymax = estimate + 1.96*std.error, ymin = estimate - 1.96*std.error, col = type)) +
  geom_pointrange() +
  labs(title = "Overall context comparison",
       x = "Comparison group",
       y = "Norm of beta hats",
       col = "Covavriate") +
  geom_text(label = round(df$estimate, 2),
            position = position_dodge(width = 0.9),
            vjust = -0.5) +
  facet_wrap(~keyword) +
  scale_color_colorblind()

ggsave(here("output", "embedreg_all_ext.png"))