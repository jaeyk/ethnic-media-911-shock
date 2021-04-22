# ITS-Text-Classification

- The preprint version of this project is available at https://osf.io/preprints/socarxiv/y65sd/
- Co-author: [Andrew Thompson](https://sites.northwestern.edu/athompson/) (George Washington University)
- RAs: [Carlos Ortiz](https://www.linkedin.com/in/carlosortizdev/), [Sarah Santiago](https://www.linkedin.com/in/sarah-santiago-7a297b18a/), and [Vivek Datta](https://www.linkedin.com/in/vivek-datta/)

## A single replication file [[R script](https://github.com/jaeyk/ITS-Text-Classification/blob/master/code/replication.r)]

If you intend to reproduce figures and tables appeared in the manuscript and appendix, use this R script. 

## Research Process

If you intend to examine each research process, check the following R markdown files and Jupyter notebooks.

### Data Collection (Summer 2019)

#### 01_Collecting Articles Concerning Muslims from Arab and Indian American Newspapers Using the [Ethnic Newswatch Database](https://www.proquest.com/products-services/ethnic_newswatch.html).

#### 02_Parsing Original HTML Files into a CSV File

**Previous version [[Jupyter notebook](https://github.com/jaeyk/ITS-Text-Classification/blob/master/code/02_html_parsing.ipynb)]**

- As the next step, I created a function named `parsing_proquest` in Python that takes one of these HTML files, extracts key features, puts these features together, and turns them into a data frame. In this case, the key features are the texts and publication dates. The texts are important to train machine learning algorithms and make predictions. The publication dates are critical to creating the time series data based on these texts.

- I then plugged this function into a for loop. The for loop turned 57 HTML newspaper files into a tidy dataset saved in a single CSV file. If we tried to do this manually, assuming that parsing one HTML file (100 newspaper articles) takes 5 hours, this process would take 285 hours compared to the several seconds needed to complete the process using methods explained above.

**Current version [[R package](https://jaeyk.github.io/tidyethnicnews/)]**

I created an R package called [tidyethnicnews](https://jaeyk.github.io/tidyethnicnews/), which turns search results from Ethnic NewsWatch into a cleaned and wrangled dataset. The package takes an average of 0.0005 seconds to turn 100 newspaper articles into a tidy dataframe.

### Machine Learning (Fall 2019-Spring 2021)

#### 03_Random Sampling Articles Stratifying on Intervention and Source Variables in R [[R markdown](https://github.com/jaeyk/ITS-Text-Classification/blob/master/code/03_sampling.Rmd)]

- I sampled 1,015 articles from this dataset to train machine learning algorithms.
- I tried to obtain (1) equal-sized sample articles for the pre- and post-intervention periods (intervention variable) and (2)balanced samples from across different kinds of newspapers (the source variable). I did so because I assume that **the variances in these variables matter in training the model and making accurate predictions**.

`sample_articles <- stratified(articles, c("intervention", "source"), 120)`

#### 04_Labeling the Sample Articles

- We sampled 1,015 articles from this dataset to train machine learning algorithms. We tried to obtain (1) equal-sized sample articles for the pre- and post-intervention periods (intervention variable) and (2) balanced samples from different kinds of newspapers (the source variable). The two co-authors and three undergraduate research assistants labeled these 1,015 sample articles as binary variables depending on whether they were about U.S. domestic politics (coded "1") or not (coded "0").
- Ideally, we would have calculated inter-coder reliability by assigning the same articles to at least two different coders, but due to time restrictions, we could not complete this step. We acknowledge this as one limitation of our study.

#### 05_Classifying Articles Using Machine Learning 

#### Preprocessing [[Jupyter notebook](https://github.com/jaeyk/ITS-Text-Classification/blob/master/code/05_01_preprocessing_text.ipynb)]

#### Classification

1. **Previous version (Fall 2019) [[Jupyter notebook](https://github.com/jaeyk/ITS-Text-Classification/blob/master/code/05_02_classifying_text.ipynb)]**

- We trained a Lasso model in Python using the labeled texts with the added features (i.e., intervention, source, and group variables). The classification accuracy rate (the percentage of results accurately classified) was 73%, the precision rate (the percentage of relevant results) was 75%, and the recall rate (the percentage of relevant total results correctly classified) was 80%.

2. **Current version (Spring 2021) [[R markdown](https://github.com/jaeyk/ITS-Text-Classification/blob/master/code/05_02_classifying_text.Rmd)]**

I re-classified the texts using the tidymodels framework in R. Here are the updates I have made.

- Preprocessed text data a little bit further (e.g., using TF-IDF).
- Expanded algorithms (lasso, random forest, and XGBoost)
- Tuned hyperparameters of all of these classifiers
- Evaluated the classifiers based on their accuracy and F-Score

### Causal Inference (Winter 2019 and Spring 2020)

#### 06_Estimating the Causal Effect in R [[R markdown](https://github.com/jaeyk/ITS-Text-Classification/blob/master/code/06_causal_inference.Rmd)]

### Additional analysis (Spring 2021)

#### 07_Analzing New York Times Articles in R [[R package](https://github.com/jaeyk/rnytapi/)] [[R markdown](https://github.com/jaeyk/ITS-Text-Classification/blob/master/code/07_additional_text_analysis.Rmd)]
