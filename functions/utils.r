clean_text <- function(text) {
  
  vec <- tolower(text) %>%
    tm::removeWords(words = c(stopwords::stopwords(source = "snowball"))) %>%
    replace_html() %>%
    replace_white()
  
  vec <- tm::removePunctuation(vec)
  
  return(vec)
  
}

############# REGRESSION #############

visualize_fit <- function(model, names){
  
  # Bind ground truth and predicted values  
  bind_cols(tibble(truth = test_y_reg), # Ground truth 
            predict(model, test_x_reg)) %>% # Predicted values 
    
    # Visualize the residuals 
    ggplot(aes(x = truth, y = .pred)) +
    # Diagonal line 
    geom_abline(lty = 2) +
    geom_point(alpha = 0.5) +
    # Make X- and Y- scale uniform 
    coord_obs_pred() +
    labs(title = glue::glue("{names}"))
  
}

# Build an evaluation function 
evaluate_reg <- function(model){
  
  # Bind ground truth and predicted values  
  bind_cols(tibble(truth = test_y_reg), # Ground truth 
            predict(model, test_x_reg)) %>% # Predicted values 
    
    # Calculate root mean-squared error
    metrics(truth = truth, estimate = .pred) 
}


############# CLASSIFICATION #############

evaluate_class <- function(model){
  
  metrics <- yardstick::metric_set(accuracy, precision, recall, f_meas)
  
  # Bind ground truth and predicted values  
  df <- bind_cols(tibble(truth = test_y_class), # Ground truth 
                  predict(model, test_x_class)) # Predicted values 
  
  # Calculate metrics 
  df %>% metrics(truth = truth, estimate = .pred_class) 
  
}

# The following visualization code draws on [Diego Usai's medium post](https://towardsdatascience.com/modelling-with-tidymodels-and-parsnip-bae2c01c131c).

visualize_class_eval <- function(model){
  
  evaluate_class(model) %>%
    ggplot(aes(x = glue("{toupper(.metric)}"), y = .estimate)) +
    geom_col() +
    labs(x = "Metrics",
         y = "Estimate") +
    ylim(c(0,1)) +
    geom_text(aes(label = round(.estimate, 2)), 
              size = 10, 
              color = "red")
}

visualize_class_conf <- function(model){
  bind_cols(tibble(truth = test_y_class), # Ground truth 
            predict(model, test_x_class)) %>%
    conf_mat(truth, .pred_class) %>%
    pluck(1) %>% # Select index 
    as_tibble() %>% # Vector -> data.frame 
    ggplot(aes(Prediction, Truth, alpha = n)) +
    geom_tile(show.legend = FALSE) +
    geom_text(aes(label = n), 
              color = "red", 
              alpha = 1, 
              size = 13) 
}

############# Variable importance #############

# The following function is adapted from https://juliasilge.com/blog/animal-crossing/

topn_vip <- function(df) {
  df %>%
  top_n(20, wt = abs(Importance)) %>%
  ungroup() %>%
  mutate(
    Importance = abs(Importance),
    Variable = str_remove(Variable, "tfidf_text_"),
    # str_remove only removed one of the two `
    Variable = gsub("`", "", Variable),
    Variable = fct_reorder(Variable, Importance)
  ) %>%
  ggplot(aes(x = Importance, y = Variable)) +
  geom_col(show.legend = FALSE) +
  labs(y = NULL) +
  theme(text = element_text(size = 20))
}

vi_plot_else <- function(fit, title) {

  pos <- pull_workflow_fit(fit) %>%
    vi() %>%
    filter(Importance > 0) %>%
    topn_vip() +
    labs(title = title,
         subtitle = "Positive")

  nev <- pull_workflow_fit(fit) %>%
    vi() %>%
    filter(Importance < 0) %>%
    topn_vip() +
    labs(subtitle = "Negative")
  
  out <- pos + nev
  
  return(out)
}

vi_plot_lasso <- function(fit, title) {
  
  pos <- pull_workflow_fit(fit) %>%
    vi() %>%
    filter(Sign == "POS") %>%
    topn_vip() +
    labs(title = title,
         subtitle = "Positive")
  
  nev <- pull_workflow_fit(fit) %>%
    vi() %>%
    filter(Sign != "POS") %>%
    topn_vip() +
    labs(subtitle = "Negative")
  
  out <- pos + nev
  
  return(out)
 
}