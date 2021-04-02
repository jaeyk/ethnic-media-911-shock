## ------------------------------------------------

if (!require("pacman")) install.packages("pacman")
pacman::p_load(
        tidyverse, # the tidyverse framework
        ggpubr, # arranging ggplots
        ggthemes, # fancy ggplot themes
        tidytext, # tidytext
        patchwork, # arranging images,
        purrr, # functional programming
        here, # reproducibility
        nytimes, # NYT analysis 
        jsonlite, # parsing JSON
        glue # gluing objects and strings 
)

## ------------------------------------------------
Sys.setenv(nyt_key = "lJWFqmFXKLE8yoxN95xLjnyqMFk67a5I")
key <- Sys.getenv("nyt_key")


## ------------------------------------------------
# Parameters 

begin_date <- "19960911"

end_date <- "20060911"

term <- "muslim+muslims"

baseurl <- "http://api.nytimes.com/svc/search/v2/articlesearch.json?q="

# URL request 

url_request <- glue("{baseurl}{term}&begin_date={begin_date}&end_date={end_date}&facet_filter=true&api-key={key}")

# Extract function 

extract_nyt_data <- function(i){
  
  # JSON object 
  out <- fromJSON(glue("{url_request}&page={i}"), flatten = TRUE) %>% 
    data.frame() 
  
  # Select fields
  out <- out[,c("response.docs.news_desk", "response.docs.section_name", "response.docs.subsection_name", "response.docs.type_of_material", "response.docs._id", "response.docs.headline.main")]
  
  message(glue("Scraping {i} page"))
  
  return(out)
  
}

# Making the function to process slow 

# 6 seconds sleep is the default requirement
slowly_extract <- slowly(extract_nyt_data,
                         rate = rate_delay(pause = 6))


## ------------------------------------------------
# Extract function 

extract_all <- function(page_list) {

  df <- map_dfr(page_list, slowly_extract) 
  
  return(df)
  
}


## ------------------------------------------------
# Looping the function over the list

max_pages <- round((fromJSON(url_request)$response$meta$hits[1] / 10) - 1)

interval <- function(x) {
  
  out <- c(x:(x + 200)) 

  return(out)
  
}

# I created this list of numeric vectors to avoid API rate limit. 

vec_list <- map(seq(0, max_pages, by = 200), interval)


## ------------------------------------------------

extract_all_compact <- function(element) {
  
  df <- map(vec_list %>% pluck(element), safely(extract_all))
  
  df <- df %>%
    map_dfr("result") %>%
    compact()
  
  }

# iter <- seq(vec_list)
# glue("df{iter} <- extract_all_compact({iter})")

# I am running this list element one by one to avoid the daily API rate limit.
 
df1 <- extract_all_compact(1)
df2 <- extract_all_compact(2)
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

## ------------------------------------------------
# saveRDS(combined_df, file = here("processed_data/nyt_articles.Rdata"))


## ----eval=FALSE----------------------------------
## knitr::purl(input = here("code", "07_additional_text_analysis.Rmd"),
##             output = here("code", "07_additional_text_analysis.r"))
