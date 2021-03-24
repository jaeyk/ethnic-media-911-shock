## ----setup, include=FALSE----------------------------------
knitr::opts_chunk$set(echo = TRUE)


## ----------------------------------------------------------
if (!require(pacman)) install.packages("pacman")

p_load(here, # creating computationally reproducible file paths 
       glue, # gluing strings and objects 
       janitor, # data cleaning tool 
       patchwork, # arranging ggplots 
       tidyverse, # tidyverse framework 
       tidymodels, # ML framework 
       textrecipes, # preprocessing text data 
       parallel, # parallel processing 
       doParallel, # parallel processing
       doFuture, # parallel processing 
       vip, # variable importance plots
       purrr) # functional programming 

# Import R scripts

script_list <- list.files(paste0(here::here(), "/functions"),
  pattern = "*.r|*.R",
  full.names = TRUE
)

for (i in 1:length(script_list))
{
  source(script_list[[i]])
}


## ----------------------------------------------------------
# Drop the first column as it's meaningless 
articles <- read.csv(here("processed_data/cleaned_text.csv"))[,-c(1,7:9)] 

placebo_articles <- read.csv(here("processed_data/placebo.csv"))[,-1]

articles %>%
  janitor::tabyl(category)


## ----------------------------------------------------------
rec_articles <- articles %>% 
  recipe(category ~ text + source + group + intervention) %>%
  # If character or factor variables are included, you should dummify them 
  step_dummy(c(source, group, intervention)) %>%
  # Used bigrams 
  step_tokenize(text, token = "ngrams", options = list(n = 2)) %>%
  # Removed stopwords 
  step_stopwords(text) %>%
  # Filtered tokens 
  step_tokenfilter(text, max_tokens = 1000) %>%
  # Normalized document length 
  step_tfidf(text) %>%
  prep()


## ----------------------------------------------------------
# for reproducibility 
set.seed(1234)
# split (stratified random sampling)
split_class <- initial_split(articles, 
                             mutate(category = as.factor(category)),
                             strata = category,
                             prop = 0.9)
# training set 
raw_train_class <- training(split_class)
raw_test_class <- testing(split_class)

# x features (predictors)
train_x_class <- bake(rec_articles, 
                      raw_train_class, all_predictors())
test_x_class <- bake(rec_articles, 
                     raw_test_class, all_predictors())
# y outcomes (outcomes)
train_y_class <- bake(rec_articles, 
                      raw_train_class, all_outcomes())$category %>% as.factor()
test_y_class <- bake(rec_articles, raw_test_class, all_outcomes())$category %>% as.factor()


## ----------------------------------------------------------
# Lasso spec 
lasso_spec <- logistic_reg(penalty = tune(), # tuning hyperparameter 
                         mixture = 1) %>% # 1 = lasso, 0 = ridge 
  set_engine("glmnet") %>%
  set_mode("classification") 
# Random forest spec
rand_spec <- 
  rand_forest(
           mode = "classification",
           
           # Tuning hyperparameters
           mtry = tune(), 
           min_n = tune()) %>%
  set_engine("ranger",
             seed = 1234, 
             importance = "permutation")
# XGBoost spec 
xg_spec <- boost_tree(
  
           # Mode 
           mode = "classification",
           
           # Tuning hyperparameters
           
           # The number of trees to fit, aka boosting iterations
           trees = tune(),
           # The depth of the decision tree (how many levels of splits).
           tree_depth = tune(), 
           # Learning rate: lower means the ensemble will adapt more slowly.
           learn_rate = tune(),
           # Stop splitting a tree if we only have this many obs in a tree node.
           min_n = tune(),
           loss_reduction = tune(),
           # The number of randomly selected hyperparameters 
           mtry = tune(), 
           # The size of the data set used for modeling within an iteration
           sample_size = tune()
          ) %>% 
  set_engine("xgboost")


## ----------------------------------------------------------
all_cores <- parallel::detectCores(logical = FALSE)
registerDoFuture()

cl <- makeCluster(all_cores[1] - 1)

registerDoParallel(cl)


## ----------------------------------------------------------
# penalty() searches 50 possible combinations 

lambda_grid <- grid_regular(penalty(), levels = 50)

rand_grid <- grid_regular(mtry(range = c(1, 10)),
                          min_n(range = c(2, 10)),
                          levels = 5)
  
xg_grid <- grid_latin_hypercube(
  trees(),
  tree_depth(),
  learn_rate(),
  min_n(),
  loss_reduction(), 
  sample_size = sample_prop(),
  finalize(mtry(), train_x_class),
  size = 30
  )

# 10-fold cross-validation

set.seed(1234) # for reproducibility 

rec_folds <- vfold_cv(train_x_class %>% bind_cols(tibble(category = train_y_class)),
                      strata = category)

save(lambda_grid, rand_grid, xg_grid, file = here("output/grids.RData"))
          
save(rec_folds, file = here("output", glue("folds.RData")))


## ----------------------------------------------------------
# Lasso 
lasso_wf <- workflow() %>%
  add_model(lasso_spec) %>%
  add_formula(category ~ . )

# Random forest
rand_wf <- lasso_wf %>%
  update_model(rand_spec)

# XGBoost 
xg_wf <- lasso_wf %>%
  update_model(xg_spec)


## ----------------------------------------------------------
metrics <- yardstick::metric_set(accuracy, precision, recall, f_meas)

# Lasso
lasso_res <- lasso_wf %>%
  tune_grid(
    resamples = rec_folds, 
    grid = lambda_grid, 
    metrics = metrics 
  )

# Random forest
rand_res <- rand_wf %>%
  tune_grid(
    resamples = rec_folds, 
    grid = rand_grid,
    control = control_grid(save_pred = TRUE),
    metrics = metrics
  )

# XGBoost 
xg_res <- xg_wf %>%
  tune_grid(
    resamples = rec_folds, 
    grid = xg_grid,
    control = control_grid(save_pred = TRUE),
    metrics = metrics
  )

save(lasso_res, rand_res, xg_res, file = here("output/res.RData"))


## ----------------------------------------------------------
best_lasso <- select_best(lasso_res, metric = "accuracy")
best_rand <- select_best(rand_res, metric = "accuracy")
best_xg <- select_best(xg_res, metric = "accuracy")


## ----------------------------------------------------------
# Lasso
lasso_wf <- lasso_wf %>% finalize_workflow(best_lasso) 

# Random forest 
rand_wf <- rand_wf %>% finalize_workflow(best_rand)

# XGBoost 
xg_wf <- xg_wf %>% finalize_workflow(best_xg)


## ----------------------------------------------------------
# Lasso 
lasso_fit <- lasso_wf %>%
  fit(train_x_class %>% bind_cols(tibble(category = train_y_class)))

# Random forest 
rand_fit <- rand_wf %>%
  fit(train_x_class %>% bind_cols(tibble(category = train_y_class)))

# XGBoost 
xg_fit <- xg_wf %>%
  fit(train_x_class %>% bind_cols(tibble(category = train_y_class)))

write_rds(lasso_fit, here("output", "lasso_fit.rds"))
write_rds(rand_fit, here("output", "rand_fit.rds"))
write_rds(xg_fit, here("output", "xg_fit.rds"))


## ----------------------------------------------------------
(visualize_class_eval(lasso_fit) + labs(title = "Lasso")) /

(visualize_class_eval(rand_fit) + labs(title = "Random forest"))  /
(visualize_class_eval(xg_fit) + labs(title = "XGBoost"))

ggsave(here("output", "ml_eval.png"), height = 10)


## ----eval = FALSE------------------------------------------
## knitr::purl(input = here("code/05_02_classifying_text.Rmd"),
##             output = here("code/05_02_classifying_text.r"))

