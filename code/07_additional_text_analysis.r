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
Sys.setenv(nyt_key = "lJWFqmFXKLE8yoxN95xLjnyqMFk67a5I")
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

# Looping the function over the list
max_pages <- round((fromJSON(httr::content(r, "text"), simplifyDataFrame = TRUE, flatten = TRUE)$response$meta$hits[1] / 10) - 1)

df <- safely(extract_all(0:max_pages))

export(df, file = here("processed_data/nyt_articles.rds"))


## ----eval=FALSE------------------------------------------------------------------------
## knitr::purl(input = here("code", "07_additional_text_analysis.Rmd"),
##             output = here("code", "07_additional_text_analysis.r"))

