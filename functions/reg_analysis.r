
replace_outliers <- function(df, dv){
  
model <- lm({{dv}} ~ intervention + date + group, data = input)

# Detecting outliers 
cooksd <- cooks.distance(model)

# For reproducibility 
set.seed(1234)

influential <- as.numeric(names(cooksd)[(cooksd > 4*mean(cooksd, na.rm = TRUE))])

# Visualizing outliers
cooksd_df <- data.frame(Index = seq(1:nrow(df)),
                        CookD = cooksd)

# Replace with NAs
df$dv[influential] <- NA

# Imputation  
knnOutput <- knnImputation(df)

df$dv <- round(knnOutput$dv, 0)

df$dv <- as.integer(df$dv)

}

ts_df <- function(data){
  
  # Group by
  df_grouped <- data %>%
    group_by(date, domestic) %>% # group by 
    dplyr::summarize(n = n()) %>% # summarize 
    as.data.frame()
  
  # Count ts 
  count_ts <- ts(df_grouped[, c('n')])
  
  df_grouped$count_ts <- as.integer(tsclean(count_ts))
  
  # Get rid of n
  df_grouped %>%
    dplyr::select(-n)
  
  # Add intervention 
  df_grouped$intervention <- ifelse(df_grouped$date < as.Date("2001-09-11"), 0, 1)
  
  df_grouped
}

group_df <- function(data, group_var){
  
# Group by
df_grouped <- data %>%
  group_by(date, domestic, {{group_var}}) %>% # group by 
    dplyr::summarize(n = n()) %>% # summarize 
    as.data.frame()

# Count ts 
count_ts <- ts(df_grouped[, c('n')])

df_grouped$count_ts <- as.integer(tsclean(count_ts))

# Get rid of n
df_grouped %>%
  dplyr::select(-n)
    
# Add intervention 
df_grouped$intervention <- ifelse(df_grouped$date < as.Date("2001-09-11"), 0, 1)

df_grouped
}


group_df_placebo <- function(data, time_var){
  
  # Group by
  df_grouped <- data %>%
    group_by({{time_var}}, domestic) %>% # group by 
    dplyr::summarize(n = n()) %>% # summarize 
    as.data.frame()
  
  # Count ts 
  count_ts <- ts(df_grouped[, c('n')])
  
  df_grouped$count_ts <- as.integer(tsclean(count_ts))
  
  # Get rid of n
  df_grouped %>%
    dplyr::select(-n)

  df_grouped
}

##### Visualize #####

visualize_raw <- function(data){
  
data %>%
  ggplot(aes(x = date, y = count_ts)) +
    geom_line() + # line plot
    geom_vline(xintercept = as.Date("2001-09-11"), linetype = "dashed", size = 1, color = "red") + # vertical line
    scale_y_continuous(breaks = scales::pretty_breaks()) + 
    labs(x = "Date",
         y = "Publication count",
         col = "Issue focus",
         subtitle = "All articles mentioned Muslims",
         caption = "Source: Ethnic Newswatch")
  
}

visualize_adj <- function(input, p.pam, q.pam) {
  model <- gls(count_ts ~ intervention + date + group,
    data = input,
    correlation = corARMA(p = p.pam, q = q.pam, form = ~ date | group),
    na.action = na.omit
  )

  # Make predictions

  input$pred <- predict(model, type = "response", input)

  # Combined prediction outputs

  input <- predictSE.gls(model, input, se.fit = TRUE) %>%
    bind_cols(input) %>%
    mutate(
      upr = fit + (2 * se.fit),
      lwr = fit - (2 * se.fit)
    )

  # Visualize the outcome

  input %>%
    ggplot(aes(x = date, y = count_ts)) +
    geom_point(alpha = 0.2) +
    facet_wrap(~group) +
    geom_line(aes(y = pred), size = 1) +
    geom_vline(xintercept = as.Date("2001-09-11"), linetype = "dashed", size = 1, color = "red") +
    labs(
      x = "Date",
      y = "Publication count",
      subtitle = "All articles mentioned Muslims",
      caption = "Source: Ethnic Newswatch"
    ) +
    scale_y_continuous(breaks = scales::pretty_breaks()) +
    geom_ribbon(aes(ymin = lwr, ymax = upr),
      alpha = 0.3, color = "blue"
    )
}

model_adj <- function(input, p.pam, q.pam) {
  model <- gls(count_ts ~ intervention + date + group,
               data = input,
               correlation = corARMA(p = p.pam, q = q.pam, form = ~ date | group),
               na.action = na.omit
  )
  
  # Make predictions
  
  input$pred <- predict(model, type = "response", input)
  
  # Combined prediction outputs
  
  input <- predictSE.gls(model, input, se.fit = TRUE) %>%
    bind_cols(input) %>%
    mutate(
      upr = fit + (2 * se.fit),
      lwr = fit - (2 * se.fit)
    )
  
  # Visualize the outcome
  
  input
}



visualize_base <- function(input) {

  # Apply OLS regression

  model <- lm(count_ts ~ intervention + date + group, data = input)

  # Make predictions

  input$pred <- predict(model, type = "response", input)

  # Create confidence intervals

  ilink <- family(model)$linkinv # Extracting the inverse link from parameter objects

  # Combined prediction outputs

  input <- predict(model, input, se.fit = TRUE)[1:2] %>%
    bind_cols(input) %>%
    mutate(
      upr = ilink(fit + (2 * se.fit)),
      lwr = ilink(fit - (2 * se.fit))
    )

  # Visualize the outcome

  input %>%
    ggplot(aes(x = date, y = count_ts)) +
    geom_point(alpha = 0.2) +
    facet_wrap(~group) +
    geom_line(aes(y = pred), size = 1) +
    geom_vline(xintercept = as.Date("2001-09-11"), linetype = "dashed", size = 1, color = "red") +
    labs(
      x = "Date",
      y = "Publication count",
      subtitle = "All articles mentioned Muslims",
      caption = "Source: Ethnic Newswatch"
    ) +
    scale_y_continuous(breaks = scales::pretty_breaks()) +
    geom_ribbon(aes(ymin = lwr, ymax = upr),
      alpha = 0.3, color = "blue"
    )
}

visualize_placebo <- function(input) {
  
  # Apply OLS regression
  
  model <- lm(n ~ intervention + date, data = input)
  
  # Make predictions
  
  input$pred <- predict(model, type = "response", input)
  
  # Create confidence intervals
  
  ilink <- family(model)$linkinv # Extracting the inverse link from parameter objects
  
  # Combined prediction outputs
  
  input <- predict(model, input, se.fit = TRUE)[1:2] %>%
    bind_cols(input) %>%
    mutate(
      upr = ilink(fit + (2 * se.fit)),
      lwr = ilink(fit - (2 * se.fit))
    )
  
  # Visualize the outcome
  
  input %>%
    ggplot(aes(x = date, y = n)) +
    geom_point(alpha = 0.2) +
    geom_line(aes(y = pred), size = 1) +
    geom_vline(xintercept = as.Date("2001-09-11"), linetype = "dashed", size = 1, color = "red") +
    labs(
      x = "Date",
      y = "Publication count",
      subtitle = "All articles mentioned Muslims",
      caption = "Source: Ethnic Newswatch"
    ) +
    scale_y_continuous(breaks = scales::pretty_breaks()) +
    geom_ribbon(aes(ymin = lwr, ymax = upr),
                alpha = 0.3, color = "blue"
    )
}



model_base <- function(input) {
  
  # Apply OLS regression
  
  model <- lm(count_ts ~ intervention + date + group, data = input)
  
  # Make predictions
  
  input$pred <- predict(model, type = "response", input)
  
  # Create confidence intervals
  
  ilink <- family(model)$linkinv # Extracting the inverse link from parameter objects
  
  # Combined prediction outputs
  
  input <- predict(model, input, se.fit = TRUE)[1:2] %>%
    bind_cols(input) %>%
    mutate(
      upr = ilink(fit + (2 * se.fit)),
      lwr = ilink(fit - (2 * se.fit))
    )
  
  # Visualize the outcome
  
  input
}

# ACF

acf_plot <- function(input) {

  # Model

  model <- lm(count_ts ~ intervention + date + group, data = input)

  # Autocorrelation functions

  pacf <- ggAcf(resid(model))
}


pacf_plot <- function(input) {

  # Model

  model <- lm(count_ts ~ intervention + date + group, data = input)

  # Autocorrelation functions

  pacf <- ggPacf(resid(model))
}

##### Wrangle #####

extract_year <- function(data) {
  substring(data$date, 1, 4) %>% as.numeric()
}

##### For loop #####

boot_ci_ols <- function(i, df) {

  # For reproducibility
  set.seed(1234)

  # Init vars
  stat <- data.frame()
  result <- data.frame()
  year <- data.frame()

  # Model

  m <- Boot(lm(count_ts ~ intervention + date + group,
               data = subset(df, year <= 2000 + i)), R = 1000)

  # Extract bootSE
  stat <- rbind(stat, summary(m) %>% data.frame() %>% select(bootSE))

  # Put them together as a dataframe

  Year <- rep(c(2000 + i), nrow(stat))

  Names <- c("Intercept", "Intervention_SE", "Date_SE", "Indian_SE")

  result <- cbind(stat, Year, Names)

  rownames(result) <- NULL

  result
}

boot_ci_gls <- function(i, df) {

  # For reproducibility
  set.seed(1234)

  # Init vars
  stat <- data.frame()
  result <- data.frame()
  year <- data.frame()

  # Model

  m <- Boot(gls(count_ts ~ intervention + date + group,
               data = subset(df, year <= 2000 + i)), R = 1000)

  # Extract bootSE
  stat <- rbind(stat, summary(m) %>% data.frame() %>% select(bootSE))
  # Put them together as a dataframe

  Year <- rep(c(2000 + i), nrow(stat))

  Names <- c("Intercept", "Intervention_SE", "Date_SE", "Indian_SE")

  result <- cbind(stat, Year, Names)

  rownames(result) <- NULL

  result
}

spread_cis <- function(cis) {
  colnames(cis)[1:2] <- c("SE", "Year")

  cis_spread <- cis %>%
    spread(Names, SE) %>%
    select(-c(Intercept, Date_SE, Indian_SE))

  cis_spread %>% rename("SE" = "Intervention_SE")
}


##### Automating boot analysis work flow #####

model_spec <- function(i){
  
  # OLS
  dom_ols <- lm(count_ts ~ intervention + date + group,
                data = subset(df_domestic, year <= 2000 + i)
  )
  
  nondom_ols <- lm(count_ts ~ intervention + date + group,
                   data = subset(df_nondomestic, year <= 2000 + i)
  )
  
  # GLS
  dom_gls <- gls(count_ts ~ intervention + date + group,
                 data = subset(df_domestic, year <= 2000 + i),
                 correlation = corARMA(p = 1, q = 1, form = ~ date | group )
  )
  
  nondom_gls <- gls(count_ts ~ intervention + date + group,
                    data = subset(df_nondomestic, year <= 2000 + i),
                    correlation = corARMA(p = 3, q = 1, form = ~ date | group)
  )
  
  # Outputs 
  return(list(dom_ols, nondom_ols, dom_gls, nondom_gls))
}

plot_boot_analysis <- function(df_domestic, df_nondomestic) {
  
  ### Coefficients

  # Initialize vars
  dom_ols_effect <- NA
  nondom_ols_effect <- NA
  dom_gls_effect <- NA
  nondom_gls_effect <- NA

  # For loop
  for (i in c(1:6)) {

    # Model

    ## OLS
    dom_ols <- lm(count_ts ~ intervention + date + group,
      data = subset(df_domestic, year <= 2000 + i)
    )

    nondom_ols <- lm(count_ts ~ intervention + date + group,
      data = subset(df_nondomestic, year <= 2000 + i)
    )

    ## GLS
    dom_gls <- gls(count_ts ~ intervention + date + group,
      data = subset(df_domestic, year <= 2000 + i),
      correlation = corARMA(p = 3, q = 1, form = ~ date | group )
    )

    nondom_gls <- gls(count_ts ~ intervention + date + group,
      data = subset(df_nondomestic, year <= 2000 + i),
      correlation = corARMA(p = 3, q = 1, form = ~ date | group)
    )

    # Save iterations
    dom_ols_effect[i] <- dom_ols$coefficients[2] %>% as.numeric()
    nondom_ols_effect[i] <- nondom_ols$coefficients[2] %>% as.numeric()
    dom_gls_effect[i] <- dom_gls$coefficients[2] %>% as.numeric()
    nondom_gls_effect[i] <- nondom_gls$coefficients[2] %>% as.numeric()

    message(paste0("Running loop no:", i))
  }

  # Put these results as a data frame
  for_loop <- tibble(
    "Domestic OLS" = dom_ols_effect,
    "International OLS" = nondom_gls_effect,
    "Domestic GLS" = dom_gls_effect,
    "International GLS" = nondom_gls_effect
  )

  # Wrangle the data
  for_loop <- for_loop %>%
    mutate(Year = c(2001:2006)) %>%
    pivot_longer(
      cols = c("Domestic OLS", "International OLS", "Domestic GLS", "International GLS"),
      names_to = "Model",
      values_to = "Coefficients"
    ) %>%
    separate(
      col = Model,
      into = c("DV", "Model"), sep = " "
    )

  ### CIs

  # Initialize
  dom_ols_cis <- data.frame()
  nondom_ols_cis <- data.frame()
  dom_gls_cis <- data.frame()
  nondom_gls_cis <- data.frame()

  # For loop
  for (i in c(1:6)) {
    print(paste(i, "iteration completed"))
    dom_ols_cis <- rbind(dom_ols_cis, boot_ci_ols(i, df_domestic))
  }

  for (i in c(1:6)) {
    print(paste(i, "iteration completed"))
    nondom_ols_cis <- rbind(nondom_ols_cis, boot_ci_ols(i, df_nondomestic))
  }


  for (i in c(1:6)) {
    print(paste(i, "iteration completed"))
    dom_gls_cis <- rbind(dom_gls_cis, boot_ci_ols(i, df_domestic))
  }

  for (i in c(1:6)) {
    print(paste(i, "iteration completed"))
    nondom_gls_cis <- rbind(nondom_gls_cis, boot_ci_ols(i, df_nondomestic))
  }

  # Spread

  cis <- bind_rows(
    spread_cis(dom_ols_cis) %>%
      mutate(DV = "Domestic", Model = "OLS"),

    spread_cis(nondom_ols_cis) %>%
      mutate(DV = "International", Model = "OLS"),

    spread_cis(dom_gls_cis) %>%
      mutate(DV = "Domestic", Model = "GLS"),

    spread_cis(nondom_gls_cis) %>%
      mutate(DV = "International", Model = "GLS")
  )

  merge(for_loop, cis) %>%
    ggplot(aes(
      x = Year, y = Coefficients,
      ymax = Coefficients + 2 * SE,
      ymin = Coefficients - 2 * SE
    )) +
    geom_pointrange() +
    geom_line(col = "blue") +
    labs(
      x = "Year", y = "Coefficients",
      title = "Treatment effect",
      subtitle = "With bootstrapped CIs"
    ) +
    facet_grid(DV ~ Model)
}

##### Tuning ####

correct_ac_domestic <- function(a, b) {
  model <- gls(count_ts ~ intervention + date + group,
    data = df_domestic,
    correlation = corARMA(p = a, q = b, form = ~ date | group),
    method = "ML",
    verbose = TRUE
  )

  results <- data.frame(
    "P" = a,
    "Q" = b,
    "AIC" = AIC(model),
    "BIC" = BIC(model),
    "AICc" = AICc(model)
  ) # data.frame is better than rbind to keep heterogeneous data type

  return(results)
}

model_spec <- function(i){
  ## OLS
  dom_ols <- lm(count_ts ~ intervention + date + group,
                data = subset(df_domestic, year <= 2000 + i)
  )
  
  nondom_ols <- lm(count_ts ~ intervention + date + group,
                   data = subset(df_nondomestic, year <= 2000 + i)
  )
  
  ## GLS
  dom_gls <- gls(count_ts ~ intervention + date + group,
                 data = subset(df_domestic, year <= 2000 + i),
                 correlation = corARMA(p = 3, q = 1, form = ~ date | group )
  )
  
  nondom_gls <- gls(count_ts ~ intervention + date + group,
                    data = subset(df_nondomestic, year <= 2000 + i),
                    correlation = corARMA(p = 3, q = 1, form = ~ date | group)
  )
  
  # Save iterations
  dom_ols_effect <- dom_ols$coefficients[2] %>% as.numeric()
  nondom_ols_effect <- nondom_ols$coefficients[2] %>% as.numeric()
  dom_gls_effect <- dom_gls$coefficients[2] %>% as.numeric()
  nondom_gls_effect <- nondom_gls$coefficients[2] %>% as.numeric()
  
  # Outputs 
  tribble(
    ~Category, ~Model, ~Estimate, 
    "Domestic", "OLS", dom_ols_effect,
    "International", "OLS", nondom_gls_effect,
    "Domestic", "GLS", dom_gls_effect,
    "International", "GLS", nondom_gls_effect
  )
}

correct_ac_nondomestic <- function(a, b) {
  model <- gls(count_ts ~ intervention + date + group,
    data = df_nondomestic,
    correlation = corARMA(p = a, q = b, form = ~ date | group),
    method = "ML",
    verbose = TRUE
  )

  results <- data.frame(
    "P" = a,
    "Q" = b,
    "AIC" = AIC(model),
    "BIC" = BIC(model),
    "AICc" = AICc(model)
  ) # data.frame is better than rbind to keep heterogeneous data type

  return(results)
}


correct_ac_domestic_source <- function(a, b) {
  model <- gls(count_ts ~ intervention + date + source,
               data = group_df(df %>% filter(group == "Indian Americans"), source) %>% filter(domestic == "Domestic"),
               correlation = corARMA(p = a, q = b, form = ~ date | source),
               method = "ML",
               verbose = TRUE
  )
  
  results <- data.frame(
    "P" = a,
    "Q" = b,
    "AIC" = AIC(model),
    "BIC" = BIC(model),
    "AICc" = AICc(model)
  ) # data.frame is better than rbind to keep heterogeneous data type
  
  return(results)
}

correct_ac_nondomestic_source <- function(a, b) {
  model <- gls(count_ts ~ intervention + date + source,
               data = group_df(df %>% filter(group == "Indian Americans"), source) %>% filter(domestic != "Domestic"),
               correlation = corARMA(p = a, q = b, form = ~ date | source),
               method = "ML",
               verbose = TRUE
  )
  
  results <- data.frame(
    "P" = a,
    "Q" = b,
    "AIC" = AIC(model),
    "BIC" = BIC(model),
    "AICc" = AICc(model)
  ) # data.frame is better than rbind to keep heterogeneous data type
  
  return(results)
}
