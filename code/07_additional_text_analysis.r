## --------------------------------------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(
        tidyverse, # the tidyverse framework
        ggpubr, # arranging ggplots
        ggthemes, # fancy ggplot themes
        tidytext, # tidytext
        patchwork, # arranging images,
        purrr, # functional programming
        here, # reproducibility
        httr, # httr connection 
        jsonlite, # parsing JSON
        glue, # gluing objects and strings         
        rio # import and export files  
)


## --------------------------------------------------------------------------------------
#Sys.setenv(nyt_key = "<insert key>")
key <- Sys.getenv("nyt_key")

## --------------------------------------------------------------------------------------
# Parameters 

begin_date <- "19960911"

end_date <- "20060911"

term <- "muslim+muslims"

baseurl <- "http://api.nytimes.com/svc/search/v2/articlesearch.json"

# URL request 

r <- GET(baseurl, 
         query = list('q' = term, 
                      'begin_date' = begin_date, 
                      'end_date' = end_date,
                      'api-key' = key))



## --------------------------------------------------------------------------------------
# Extract function 

extract_nyt_data <- function(i){
  
  # JSON object 
  out <- fromJSON(httr::content(r, "text", encoding = "UTF-8"), simplifyDataFrame = TRUE, flatten = TRUE) 
    
  # Page numbering 
  out$page <- i
  
  message(glue("Scraping {i} page"))
  
  return(out)
  
}


## --------------------------------------------------------------------------------------
# Extract function 

# 6 seconds sleep between calls, max 4000 requests per day 
rate <- rate_delay(pause = 6, max_times = 4000)

slowly_extract <- slowly(extract_nyt_data, rate = rate)
  
extract_all <- function(page_list) {

  df <- map_dfr(page_list, slowly_extract) 
  
  return(df)
  
}


## --------------------------------------------------------------------------------------
# Looping the function over the list
max_pages <- round((fromJSON(httr::content(r, "text"), simplifyDataFrame = TRUE, flatten = TRUE)$response$meta$hits[1] / 10) - 1)

interval <- function(x) {
  
  out <- c(x:(x + 198)) 

  return(out)
  
}

# I created this list of numeric vectors to avoid API rate limit. 

vec_list <- map(seq(0, max_pages, by = 198), interval)


## --------------------------------------------------------------------------------------
extract_all_compact <- function(element) {
  
  df <- map(vec_list %>% pluck(element), safely(extract_all))
  
  return(df)
  
  }


## --------------------------------------------------------------------------------------

#iter <- seq(vec_list)
#glue("df{iter} <- extract_all_compact({iter})")

#df1 <- extract_all_compact(1)
#df2 <- extract_all_compact(2)
df3 <- extract_all_compact(3)
df4 <- extract_all_compact(4)
df5 <- extract_all_compact(5)
df6 <- extract_all_compact(6)
df7 <- extract_all_compact(7)
df8 <- extract_all_compact(8)
df9 <- extract_all_compact(9)
df10 <- extract_all_compact(10)
df11 <- extract_all_compact(11)
df12 <- extract_all_compact(12)
df13 <- extract_all_compact(13)

#glue("export(df{iter}, here('processed_data/nyt_part{iter}.rds'))")

#export(df1, here('processed_data/nyt_part1.rds'))
#export(df2, here('processed_data/nyt_part2.rds'))
export(df3, here('processed_data/nyt_part3.rds'))
export(df4, here('processed_data/nyt_part4.rds'))
export(df5, here('processed_data/nyt_part5.rds'))
export(df6, here('processed_data/nyt_part6.rds'))
export(df7, here('processed_data/nyt_part7.rds'))
export(df8, here('processed_data/nyt_part8.rds'))
export(df9, here('processed_data/nyt_part9.rds'))
export(df10, here('processed_data/nyt_part10.rds'))
export(df11, here('processed_data/nyt_part11.rds'))
export(df12, here('processed_data/nyt_part12.rds'))
export(df13, here('processed_data/nyt_part13.rds'))

#export(combined_df, file = here("processed_data/nyt_articles.rds"))


## ----eval=FALSE------------------------------------------------------------------------
## knitr::purl(input = here("code", "07_additional_text_analysis.Rmd"),
##             output = here("code", "07_additional_text_analysis.r"))

