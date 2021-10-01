## for bootstrapping 95% confidence intervals; Borrowed from Nick Camp's code from Jaren, Nick, and my shared project

theta <- function(x, xdata, na.rm = T) {
  mean(xdata[x], na.rm = na.rm)
}

ci.low <- function(x, na.rm = T) {
  mean(x, na.rm = na.rm) - quantile(bootstrap::bootstrap(1:length(x), 1000, theta, x, na.rm = na.rm)$thetastar, .025, na.rm = na.rm)
}

ci.high <- function(x, na.rm = T) {
  quantile(bootstrap::bootstrap(1:length(x), 1000, theta, x, na.rm = na.rm)$thetastar, .975, na.rm = na.rm) - mean(x, na.rm = na.rm)
}

# preprocessing

get_word_count <- function(data, stem = TRUE) {
  
  tidy_df <- data %>%
    # Tokenize
    unnest_tokens("word", value) %>%
    # Remove stop words
    anti_join(get_stopwords(), by = "word")
  
  if (stem == TRUE) {
    
    # Stemming
    tidy_df <- tidy_df %>% mutate(stem = wordStem(word))
    
    df_words <- tidy_df %>%
      count(date, stem, sort = TRUE)
    
    total_words <- df_words %>%
      group_by(date) %>%
      summarize(total = sum(n))
    
    joined_words <- left_join(df_words, total_words)
    
    tf_idf <- joined_words %>%
      # TF-IDF
      bind_tf_idf(stem, date, n)
    
  } else {
    
    df_words <- tidy_df %>% count(date, word, sort = TRUE)
    
    total_words <- df_words %>%
      group_by(date) %>%
      summarize(total = sum(n))
    
    joined_words <- left_join(df_words, total_words)
    
    tf_idf <- joined_words %>%
      # TF-IDF
      bind_tf_idf(word, date, n)
    
  }
  
  return(tf_idf)
  
}

clean_text <- function(full_text) {
  
  # lower case and remove punctuation 
  vec <- tm::removePunctuation(tolower(full_text))  

  # remove stopwords 
  vec <- tm::removeWords(vec, words = c(stopwords(source = "snowball")))
  
  # replace date with words
  vec <- textclean::replace_date(vec)
  
  # replace number with words
  vec <- textclean::replace_number(vec)
  
  # replace excessive white space
  vec <- textclean::replace_white(vec)
  
  return(vec)
  
}

con2nplot <- function(corpus, keyword, local_glove, local_transform) {
  # Latino context
  contextPre <- get_context(x = corpus$clean_text[corpus$group == 1], target = keyword)
  
  # Asian context
  contextPost <- get_context(x = corpus$clean_text[corpus$group == 0], target = keyword)
  
  # bind contexts
  contexts_corpus <- rbind(cbind(contextPre, group = "Hate speech"), cbind(contextPost, group = "Counterspech"))
  
  # embed each instance using a la carte
  contexts_vectors <- embed_target(
    context = contexts_corpus$context,
    pre_trained = local_glove,
    transform_matrix = local_transform,
    transform = TRUE,
    verbose = TRUE)
  
  # get local vocab
  local_vocab <- get_local_vocab(c(contextPre$context, contextPost$context), pre_trained = local_glove)
  
  # exclude the keyword
  local_vocab <- setdiff(local_vocab, c(keyword))
  
  contrast_target <- contrast_nns(
    context1 = contextPre$context,
    context2 = contextPost$context,
    pre_trained = local_glove,
    transform_matrix = local_transform,
    transform = TRUE,
    bootstrap = TRUE,
    num_bootstraps = 100,
    permute = TRUE,
    num_permutations = 100,
    candidates = local_vocab,
    norm = "l2")
  
  # define top N of interest
  N <- 40
  
  # first get each party's nearest neighbors (output by the contrast_nns function)
  nnsPre <- contrast_target$nns1
  nnsPost <- contrast_target$nns2
  
  # subset to the union of top N nearest neighbors for each party
  top_nns <- union(nnsPre$Term[1:N], nnsPost$Term[1:N])
  
  # identify which of these are shared
  shared_nns <- intersect(nnsPre$Term[1:N], nnsPost$Term[1:N])
  
  # subset nns_ratio (output by contrast_nns) to the union of the top nearest
  # neighbors
  nns_ratio <- contrast_target$nns_ratio %>%
    dplyr::filter(Term %in% top_nns) %>%
    mutate(group = case_when(
      (Term %in% nnsPre$Term[1:N]) & !(Term %in% nnsPost$Term[1:N]) ~ "Hate speech",
      !(Term %in% nnsPre$Term[1:N]) & (Term %in% nnsPost$Term[1:N]) ~ "Counterpspeech",
      (Term %in% shared_nns) ~ "Shared"),
      significant = if_else(Empirical_Pvalue < 0.01, "yes", "no"))
  
  # order Terms by Estimate
  nns_ratio <- nns_ratio %>%
    mutate(absdev = abs(1 - Estimate)) %>%
    arrange(-absdev) %>%
    mutate(tokenID = 1:nrow(.)) %>%
    mutate(Term_Sig = if_else(significant == "yes", paste0(Term, "*"), Term))
  
  # plot
  nns_ratio %>%
    ggplot() +
    geom_point(aes(x = Estimate, y = tokenID, color = group, shape = group), size = 2) +
    geom_vline(xintercept = 1, colour = "black", linetype = "dashed",
               size = 0.5) +
    geom_text(
      aes(x = Estimate, y = tokenID, label = Term_Sig), hjust = if_else(nns_ratio$Estimate > 1, -0.2, 1.2), vjust = 0.25, size = 5) +
    scale_color_brewer(palette = "Dark2") +
    xlim(-30, 30) +
    ylim(0, 50) +
    labs(y = "", x = "cosine similarity ratio \n (Hate speech/Counterspeech)",
         col = "Category", shape = "Category") +
    theme(legend.position = "bottom")
}


df2cm <- function(corpus, count_min = 10, window_size = 6) {
  
  ############################### Create VOCAB ###############################
  
  # Create iterator over tokens
  tokens <- space_tokenizer(corpus$clean_text)
  
  # Create vocabulary. Terms will be unigrams (simple words).
  it <- itoken(tokens, progressbar = TRUE)
  
  vocab <- create_vocabulary(it)
  
  # Filter words
  vocab_pruned <- prune_vocabulary(vocab, term_count_min = count_min)
  
  # use quanteda's fcm to create an fcm matrix
  fcm_cr <- quanteda::tokens(corpus$clean_text) %>%
    quanteda::fcm(context = "window", count = "frequency",
                  window = window_size, weights = rep(1, window_size), tri = FALSE)
  
  # subset fcm to the vocabulary included in the embeddings
  fcm_cr <- fcm_select(fcm_cr, pattern = vocab_pruned$term, selection = "keep")
  
  return(fcm_cr)
}

df2ltm <- function(corpus, local_glove, count_min = 10, window_size = 6) {
  
  ############################### Create VOCAB ###############################
  
  # Create iterator over tokens
  tokens <- space_tokenizer(corpus$clean_text)
  
  # Create vocabulary. Terms will be unigrams (simple words).
  it <- itoken(tokens, progressbar = TRUE)
  
  vocab <- create_vocabulary(it)
  
  # Filter words
  vocab_pruned <- prune_vocabulary(vocab, term_count_min = count_min)
  
  # use quanteda's fcm to create an fcm matrix
  fcm_cr <- quanteda::tokens(corpus$clean_text) %>%
    quanteda::fcm(context = "window", count = "frequency",
                  window = window_size, weights = rep(1, window_size), tri = FALSE)
  
  # subset fcm to the vocabulary included in the embeddings
  fcm_cr <- fcm_select(fcm_cr, pattern = vocab_pruned$term, selection = "keep")
  
  local_transform <- compute_transform(context_fcm = fcm_cr, pre_trained = local_glove,
                                       vocab = vocab_pruned, weighting = 1000)
  
  return(local_transform)
}

df2vec <- function(corpus, count_min = 10, window_size = 6, dims = 100) {
  
  ############################### Create VOCAB ###############################
  
  # Create iterator over tokens
  tokens <- space_tokenizer(corpus$clean_text)
  
  # Create vocabulary. Terms will be unigrams (simple words).
  it <- itoken(tokens, progressbar = TRUE)
  
  vocab <- create_vocabulary(it)
  
  # Filter words
  vocab_pruned <- prune_vocabulary(vocab, term_count_min = count_min)
  
  ############################### Create Term Co-occurence Matrix ###############################
  
  # Use our filtered vocabulary
  vectorizer <- vocab_vectorizer(vocab_pruned)
  
  # Use window of 10 for context words
  tcm <- create_tcm(it, vectorizer, skip_grams_window = window_size, skip_grams_window_context = "symmetric", weights = rep(1, window_size))
  
  ############################### Set Model Parameters ###############################
  
  glove <- GlobalVectors$new(rank = dims, x_max = 10)
  
  ############################### Fit Model ###############################
  
  wv_main <- glove$fit_transform(tcm, n_iter = 1000, convergence_tol = 0.001, n_threads = RcppParallel::defaultNumThreads())
  
  ############################### Get Output ###############################
  
  wv_context <- glove$components
  
  word_vectors <- wv_main + t(wv_context)
  
  return(word_vectors)
}

get_bt_terms <- function(period_n, group_n, keyword, word_n) {
  
  contexts <- get_context(x = subset(corpus, intervention == period_n & group == group_n)$clean_text, target = keyword,
                          window = 6, valuetype = "fixed", case_insensitive = TRUE, hard_cut = FALSE, verbose = FALSE)
  
  local_vocab <- get_local_vocab(contexts$context, local_glove)
  
  local_vocab <- setdiff(local_vocab, keyword)
  
  out <- bootstrap_nns(
    context = contexts$context,
    pre_trained = local_glove,
    transform_matrix = local_transform,
    transform = TRUE,
    candidates = local_vocab,
    bootstrap = TRUE,
    num_bootstraps = 100,
    N = word_n,
    norm = "l2")
  
  if (period_n == 1 & group_n == 1) {
    
    out <- out %>%
      mutate(intervention = "After 9/11 attacks",
             label = "Arab Americans")
    
  }
  
  if (period_n == 1 & group_n == 0) {
    
    out <- out %>%
      mutate(intervention = "After 9/11 attacks",
             label = "Indian Americans")
    
  }
  
  if (period_n == 0 & group_n == 1) {
    
    out <- out %>%
      mutate(intervention = "Before 9/11 attacks",
             label = "Arab Americanas")
    
  }
  
  if (period_n == 0 & group_n == 0) {
    
    out <- out %>%
      mutate(intervention = "Before 9/11 attacks",
             label = "Indian Americans")
    
  }
  
  return(out)
}

get_candidates <- function(corpus, keyword, local_glove, local_transform) {
  
  # get contexts
  contexts_corpus <- get_context(x = corpus$clean_text, target = keyword)
  
  # embed each instance using a la carte
  contexts_vectors <- embed_target(
    context = contexts_corpus$context,
    pre_trained = local_glove,
    transform_matrix = local_transform,
    transform = TRUE,
    aggregate = FALSE,
    verbose = TRUE)
  
  # get local vocab
  local_vocab <- get_local_vocab(c(contextL$context, contextA$context), pre_trained = local_glove)
  
  return(local_vocab)
}

get_contexs <- function(group_n, period_n, key_word) {
  
  out <- get_context(x = subset(corpus, latino == group_n & pre == period_n)$clean_text, target = key_word,
                     window = 6, valuetype = "fixed", case_insensitive = TRUE, hard_cut = FALSE, verbose = FALSE)
  
  return(out)
}

get_context_con <- function(group_n, period, period_n, key_word) {
  
  out <- get_context(x = subset(corpus, latino == group_n & get(period) == period_n)$clean_text,
                     target = key_word,
                     window = 6,
                     valuetype = "fixed",
                     case_insensitive = TRUE,
                     hard_cut = FALSE,
                     verbose = FALSE)
  
  return(out)
  
}

get_word_count <- function(data, stem = TRUE) {
  
  tidy_df <- data %>%
    # Tokenize
    unnest_tokens("word", clean_text) %>%
    # Remove stop words
    anti_join(get_stopwords(), by = "word")
  
  if (stem == TRUE) {
    
    # Stemming
    tidy_df <- tidy_df %>% mutate(stem = wordStem(word))
    
    df_words <- tidy_df %>%
      count(date, stem, sort = TRUE)
    
    total_words <- df_words %>%
      group_by(date) %>%
      summarize(total = sum(n))
    
    joined_words <- left_join(df_words, total_words)
    
    tf_idf <- joined_words %>%
      # TF-IDF
      bind_tf_idf(stem, date, n)
    
  } else {
    
    df_words <- tidy_df %>% count(date, word, sort = TRUE)
    
    total_words <- df_words %>%
      group_by(date) %>%
      summarize(total = sum(n))
    
    joined_words <- left_join(df_words, total_words)
    
    tf_idf <- joined_words %>%
      # TF-IDF
      bind_tf_idf(word, date, n)
    
  }
  
  return(tf_idf)
  
}

key2convec <- function(corpus, keyword) {
  
  contexts <- get_context(x = corpus$clean_text, target = keyword, window = 6, valuetype = "fixed", case_insensitive = TRUE, hard_cut = FALSE, verbose = FALSE)
  
  contexts_vectors <- embed_target(context = contexts$context, pre_trained = local_glove, transform_matrix = local_transform, transform = TRUE, aggregate = TRUE, verbose = TRUE)
  
  return(contexts_vectors)
}

key2sim <- function(vectors, key_word, n = 30) {
  
  out <- vectors %>%
    nearest_neighbors(key_word) %>%
    filter(item1 != key_word) %>%
    top_n(n, abs(clean_text)) %>%
    mutate(clean_text = round(clean_text,2)) %>%
    rename(word = item1,
           similarity = clean_text) %>%
    mutate(keyword = key_word)
  
  return(out)
  
}

keyword2plot <- function(word_vector, keywords, n, custom_title = NULL){
  
  out <- purrr::map_dfr(keywords,
                        possibly(~vec2sim(word_vector, ., n),
                                 # This sorts out the keyword not in the word embedding
                                 otherwise =
                                   data.frame(word = NA,
                                              similarity = NA,
                                              keyword = NA)))
  
  if (is.null(custom_title)) {
    
    out <- plot_embed(out)
    
    return(out)
    
  }
  
  else {
    
    out <- plot_embed(out) + labs(title = custom_title)
    
    return(out)
    
  }
}

models2df <- function(models) {
  
  plot_tibble <- lapply(models, '[[', 'normed_betas') %>%
    do.call(rbind, .) %>%
    mutate(year = factor(unique(corpus$year), levels = unique(corpus$year)))
  
  return(plot_tibble)
}

models2plot_seq <- function(models, key_word) {
  
  # combine results
  plot_tibble <- lapply(models, '[[', 'normed_betas') %>%
    do.call(rbind, .) %>%
    mutate(year = factor(unique(corpus$year), levels = unique(corpus$year)))
  
  plot <- ggplot(plot_tibble,
                 aes(x = year, y = Normed_Estimate, group = 1)) +
    geom_line(color = 'blue', size = 0.5) +
    geom_pointrange(aes(
      x = year,
      y = Normed_Estimate,
      ymin = Normed_Estimate - 1.96*Std.Error,
      ymax = Normed_Estimate + 1.96*Std.Error),
      lwd = 0.5,
      position = position_dodge(width = 1/2)) +
    labs(x = "",
         y = "Norm of beta hat",
         title = glue("Keyword = {key_word}")) +
    scale_color_manual(values = c('no' = 'grey', 'yes' = 'blue')) +
    theme(axis.text.x = element_text(size = 10, angle = 90, vjust = 0.5, hjust = 1),
          axis.text.y = element_text(size = 10))
  
  return(plot)
}

nearest_neighbors <- function(df, token) {
  df %>%
    widely(
      ~ {
        y <- .[rep(token, nrow(.)), ]
        res <- rowSums(. * y) /
          (sqrt(rowSums(. ^ 2)) * sqrt(sum(.[token, ] ^ 2)))
        
        matrix(res, ncol = 1, dimnames = list(x = names(res)))
      },
      sort = TRUE
    )(item1, dimension, clean_text) %>%
    select(-item2)
}

plot_embed <- function(embed) {
  
  out <- embed %>%
    filter(!is.na(keyword)) %>%
    group_by(keyword) %>%
    slice_max(similarity, n = 10) %>%
    mutate(word = factor(word, levels = rev(unique(word)))) %>%
    ggplot(aes(similarity, word, fill = keyword)) +
    geom_col(show.legend = FALSE) +
    facet_wrap(~keyword, ncol = 5, scales = "free") +
    labs(x = "Cosine similiarity",
         y = "")
  
  return(out)
}

terms2plot <- function(df1, df2, keyword, year) {
  
  bind_rows(df1, df2) %>%
    group_by(Term) %>%
    filter(n() > 1) %>%
    ggplot(aes(x = fct_reorder(Term, Estimate), y = Estimate,
               ymax = Estimate + 1.96*Std.Error,
               ymin = Estimate - 1.96*Std.Error, col = label)) +
    geom_pointrange() +
    facet_wrap(~intervention) +
    coord_flip() +
    labs(subtitle = glue("Keyword: {keyword}"),
         title = glue("{year}"),
         x = "",
         y = "Bootstrapped estimate",
         col = "Group") +
    theme(legend.position = "bottom") +
    scale_color_brewer(palette = "Dark2")
  
}

terms2plot_sep <- function(df1, df2, keyword, year) {
  
  bind_rows(df1, df2) %>%
    group_by(label) %>%
    top_n(25, Estimate) %>%
    ggplot(aes(x = fct_reorder(Term, Estimate), y = Estimate,
               ymax = Estimate + 1.96*Std.Error,
               ymin = Estimate - 1.96*Std.Error, col = label)) +
    geom_pointrange() +
    facet_wrap(~intervention) +
    coord_flip() +
    labs(subtitle = glue("Keyword: {keyword}"),
         title = glue("{year}"),
         x = "",
         y = "Bootstrapped estimate",
         col = "Group") +
    theme(legend.position = "bottom") +
    scale_color_brewer(palette = "Dark2")
  
}