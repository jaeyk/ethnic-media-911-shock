# ITS-Text-Classification



**A Showcase of How Machine Learning Can Be Used to Provide Essential Data for Causal Inference**



- The goal of this article is to document how I have developed this machine learning + causal inference project from end to end. I intend to share what I succeeded and failed throughout this project and what I learned along the journey. What particularly was challenging or exciting about this project is I need to apply a wide range of skills (e.g., parsing HTML pages, sampling, classifying texts, and inferring causality in time series data) at the different stages of the project. However, that's also what made working on this project so fun! 
- Many people helped me to push this project forward. [Andrew Thompson](https://sites.northwestern.edu/athompson/) was essential in getting this project started in the summer 2019. He's a co-author of the paper version of this project. We plan to present the findings at the upcoming Western Political Science Association annual meeting (Please come and give us comments). My amazing RAs --- [Carlos Ortiz](https://www.linkedin.com/in/carlosortizdev/), [Sarah Santiago](https://www.linkedin.com/in/sarah-santiago-7a297b18a/), and [Vivek Datta](https://www.linkedin.com/in/vivek-datta/) --- made it possible to complete most of the data analysis in Fall 2019. 
- I will keep this git repository and the article updated as I make progress. I hope this article is helpful for fellow travelers in computational social science. Any comments or questions on the project are warmly welcome. 

## Motivation

As Andrew Ng [said](https://www.youtube.com/watch?v=21EiKfQYZXc), artificial intelligence, especially machine learning, is new electricity. Yet the impact of machine learning has been relatively marginal in many social science disciplines. One of the reasons is still most machine learning applications focus on prediction tools and have little to do with explaining the causal relationship between X and Y (causal inference). However, social scientists need to know the causal effect of an intervention they care about to make sound recommendations for policy or behavioral changes. In this context, I co-developed this project with Andrew Thompson to demonstrate **how machine learning can help create critical data for causal inference**. 



## Research Design

### Causal Inference and Natural Experiments 

Causal inference is hard. To assess the causal relationship between X and Y, we should be able to observe subjects treated (Y treated) and the same subjects who are not treated (Y untreated) at the same temporal point. The subjects could be patients and the treatment could be a new standard of medical care. The comparison between them would reveal the true effect of the treatment. However, we are not living in the world of a Sci-Fi fiction (e.g. Philip K. Dick's [*The Man in the High Castle*](https://en.wikipedia.org/wiki/The_Man_in_the_High_Castle_(TV_series))) and we cannot observe these two groups simultaneously. As Holland (1986) [called](http://www-stat.wharton.upenn.edu/~hwainer/Readings/Holland_Statistics%20and%20Causal%20Inference.pdf), this challenge is "the fundamental problem of causal inference." In experimental studies, randomly assigning treatment to one group but not the others solve this selection bias/confounding/endogeneity problem (different names but same idea). It is because randomization, by definition, creates treatment and control groups who only differ in their treatment status on average. This is not the case in observational studies. Observational studies have weaker designs because here, we don't know enough about the process under which some subjects receive the treatment, and the others didn't ([Rubin and Imbens 2015](https://www.cambridge.org/core/books/causal-inference-for-statistics-social-and-biomedical-sciences/71126BE90C58F1A431FE9B2DD07938AB)). For that reason, the statistical models we build to estimate the relationship between X and Y are often poor approximations of the underlying data generating process. 

Nevertheless, on rare occasions, we find [natural experiments](https://en.wikipedia.org/wiki/Natural_experiment) where exogenous factors, or things outside the control of subjects, carried out experiments on a large number of subjects in the real world. Unexpected big events, such as natural disasters and wars, are good examples. These shocks force subjects to be untreated at t-1 but treated at t (within subjects), or they make some subjects treated, but others left untreated at the same temporal point (between subjects). 

### Threats and Information Seeking

- Design: The 9/11 attacks, an unexpected terrorist attack, is a natural experiment. The intervention, the terrorist attacks, was mostly unexpected. Had the 9/11 attacks not occurred, the world would have continued in the way it existed before. This counterfactual world helped estimate the causal effect of the intervention by comparing the trend in the pre-intervention period with that in the post-intervention period. This research design is called [interrupted time series design](https://en.wikipedia.org/wiki/Interrupted_time_series). 
-  Treatment: Using this research design, we are particularly interested in identifying the causal effects of threats on the political behaviors of immigrant communities. The 9/11 attacks mean different things to different people. Defining the meaning of the intervention as precisely as possible helped reduce confusion. Here my focus is the impact of the 9/11 attacks on immigrant communities. For these groups, the hawkish policy (i.e., the War on Terrorism) and the accompanying xenophobic public opinion emerged in the post-9.11 period are important because these changes intensified the level of threats imposed on them.
- Mechanism: We hypothesize that threats induce information seeking. Immigrants communities might have felt stronger needs to collect information on the treatment of Muslim populations in the United States because something happened to them can happen to their communities as well. More information can reduce the uncertainty they felt about the rapidly changing political climate. Arab and Indian Americans were ideal cases to test this argument. Arab Americans were targeted by the War on Terrorism and the xenophobic public opinion in the post-9.11 period because they came from the Muslim-majority countries and, thus, they were often perceived and treated as "potential terrorists." Indian Americans were also targeted because of their physical resemblance to Arab Americans in the eyes of white Americans. 
- Contributions: Past studies have also looked at how threats induce information seeking ([Valentino et al. 2008](https://onlinelibrary.wiley.com/doi/full/10.1111/j.1467-9221.2008.00625.x?casa_token=AFdpYAvh0rUAAAAA%3AlZ4OrLYGOUc3s-GkdnMusZVZ1d6SDJWSB84H7zu6T7alT3TeAZgR6hx_6M7-QaD-3l2ON1JiaKWyt-A), [Gadarian and Albertson 2013](https://onlinelibrary.wiley.com/doi/full/10.1111/pops.12034?casa_token=jRK3KrzsfR4AAAAA%3AMds8LYY6-Ld62cLOBnXd68_WIitzqqUGX3IvfWajNlfwkU3aUrPGdE1y27Hj8MIcoQgEEilVe5xkCj4) ). Yet, most of these studies are done using associational analyses or survey experiments. Our study contributes to this literature by using novel data (text) and methods (text classification and interrupted time series design) that improve both the internal and external validity of the research design. 

### Text Data and Hypotheses

- Text Data: The proof of the pudding is in the eating. What data can provide evidence for this claim? Ideally, we would like to have a large number of observations before and after the intervention. Otherwise, we lack statistical power to reject the null hypothesis (the null effect). Political scientists usually track political opinions through surveys. However, a large number of observations on these groups were unlikely to exist in most political opinion survey data collected at the national level using probability sampling (e.g., American National Election Studies). In this context, text data could be seen as an alternative to the survey data. [Ethnic NewsWatch](https://www.proquest.com/products-services/ethnicnewswatch_hist.html) database, created by Proquest, has compiled more than 2.5 million articles published by ethnic media in the U.S in the last four decades. 
- **H1:** We can take advantage of this data by re-framing the question. Threats encourage information seeking. Information seeking increases demands for newspaper articles related to threats. The number of articles published articles on threats, therefore, can be considered as a proxy for information seeking. If this reasoning were plausible, then the 9/11 attacks would have made Arab and Indian American newspapers publish more articles on **U.S. political news that focused on Muslim populations** in the post-9.11 period compared to the number of them issued in the previous years (**H1**).
- **H2:** A related question is how we can be confident that this change in the number of the articles published on the treatment of the Muslim populations in the U.S. indicates that the origin of the threat is *domestic* (the hawkish U.S. policy and the xenophobic public opinion) not *international* (the spread of terrorism). Collecting additional data could be useful to clarify the mechanism. If the international threat was present, then Arab and Indian American newspapers should have published more articles on the Muslim populations but *not* related to the U.S. domestic politics in the post-9.11 period vis-à-vis the pre-intervention period (**H2**). If only H1 were true and H2 were false, then the tests confirm that the origin of the threats was domestic. If they were both true, then the threats originated from both domestic and international sources.



## Research Process

In this section, I document how I implemented the research design step-by-step. If possible, I also provided the Python or R code in each step. Aside from the text classification, all of the Python and R code was written by me.


### Data collection (Summer 2019)

#### 01_Collecting Muslims-related Articles from Arab and Indian American Newspapers Using [Ethnic Newswatch Database](https://www.proquest.com/products-services/ethnic_newswatch.html).

- The text data includes two Arab American (The Arab American News and The Arab American View) and three Indian American (New India - Times, India Abroad, and India - West) newspapers. The number of Indian newspaper articles is 4,552, and the number of Arab American newspaper articles is 1,132.
- I used a 5-year window for the data collection: from September 1996 through September 2006. I manually downloaded **Muslim populations related articles** published during this time period from the database. These newspaper articles were then saved in HTML format to utilize the metadata. I did not web scrape these articles from the database because I was worried about violating the copyrights held by Proquest. For the exact same reason, I do not share the proprietary text data which I used in this project.


#### 02_Parsing Original HTML Files into a CSV File in Python [[Code](https://github.com/jaeyk/ITS-Text-Classification/blob/master/code/02_html_parsing.ipynb)]

- As the next step, I created a function named `parsing_proquest` in Python that takes one of these HTML files, extracts key features, puts these features together, and turns them in a data frame. In this case, the key features are the text and the publication date. The texts are important to train machine learning algorithms and make predictions. The publication dates are critical to creating the time series data based on the texts. 

```
# extracting features of the HTML file using beautiful soup 
 doc_text = soup.findAll("text")
 doc_date = soup.findAll("", {"class": "abstract_Text col-xs-12 col-sm-10 col-md-10 col-lg-10"})
```

- I then plugged this function into a for loop. The for loop turned the HTML newspaper files into a tidy dataset saved in a single CSV file.

```
# plugging the function into a for loop over entire page results 

n = 0

temp_dataset = []
for filename in os.listdir(os.getcwd()):
    if filename.endswith(".html"):
        n  = n + 1
        print("file",n, filename)
        temp_dataset.append(parsing_proquest(filename))
```



### Machine Learning (Fall 2019)

#### 03_Random Sampling Articles Stratifying on Assignment and Source Variables in R [[Code](https://github.com/jaeyk/ITS-Text-Classification/blob/master/code/03_sampling.Rmd)]

- I sampled 1,015 articles from this dataset to train machine learning algorithms.
- I tried to get 1) an equal number of sample articles for both the pre- and post-intervention periods (assignment variable) and 2) also from across different kinds of newspapers (source variable). I did so because I assume that **the variances in these variables matter in training the model and making accurate predictions**.  

`sample_articles <- stratified(articles, c("intervention", "source"), 120)`

#### 04_Labeling the Sample Articles

- I distributed the task of labeling 1,015 sample articles between 5 people: me, Andrew, and the 3 RAs. Initially, we were very ambitious. We wanted to get fine-grained data on particularly what kinds of political information these newspapers provided to their readers. However, as we started reading and labeling the sample articles, we realized that a multinominal conceptual framework is not going to work. The main problem is that either many articles fit into all of the measures that we proposed (false positive), or they didn't fit at all (false negative). The undergraduate RAs pushed this as a critical problem because they felt *they could not be confident how a machine learning algorithm can predict values if they --- humans --- can't*. This was a fair point. Consequently, we decided to keep things simple and label articles, whether they are **about U.S. domestic politics or not** **(binary)**. Interestingly, most of the non-domestic Muslim articles were about international relations such as the disputes between India and Pakistan.
- If time allowed, I wanted to calculate the inter-coder reliability score by assigning the same articles at least to two different coders. We couldn't do that because my team was pressured to present preliminary findings in only 1-2 weeks at [the Fall 2019 Data Science Showcase at UC Berkeley](https://bids.berkeley.edu/events/fall-2019-data-science-showcase).

#### 05_Classifying Articles Using Machine Learning in Python [[Code](https://github.com/jaeyk/ITS-Text-Classification/blob/master/code/05_classification.ipynb)]

- My undergraduate RAs then trained logistic regression models using these labeled texts. Initial tries did not deliver a promising result. What worked is adding features that were used in the sampling process. Note that the sample articles were selected through random sampling stratified on intervention and source variables. Including these features increased the classification accuracy score of U.S. domestic politics articles up to `79%` and non-U.S. domestic politics articles up to `75%`. Given the complexity of the classification task (low baseline), I assumed that these scores were acceptable. 

```
# Get addition features from one hot encoding the source, intervention, and group columns
features_x_train = pd.concat([pd.get_dummies(train[col]) for col in ['source', 'intervention', 'group']], axis=1)
features_x_train = features_x_train.drop(columns = ["The Arab American View"])
features_x_train
```

```
# Fit our Logistic Regression model with L1 regularization and determine the training accuracy
yy_train = train['category']
NA_model = LogisticRegressionCV(fit_intercept = True, penalty = 'l1', solver = 'saga')
NA_model.fit(xx_train, yy_train)

accuracy = NA_model.score(xx_train, yy_train)
print("Training Accuracy: ", accuracy)

Training Accuracy:  0.7897042716319824
```



### Causal Inference (Winter 2019 and Spring 2020)

#### 06_Estimating the Causal Effect in R [[Code](https://github.com/jaeyk/ITS-Text-Classification/blob/master/code/06_causal_inference.Rmd)], [[Output](https://github.com/jaeyk/ITS-Text-Classification/tree/master/output)] 

- After spending one semester, I finally obtained the time series data needed for the interrupted time series design analysis. 
- In both Figures 1 and 2, the X-axis indicates the publication date, and the Y-axis shows the number of published articles (count). In the upper panel, the y-values show the number of the articles published on `U.S. domestic politics`. In the lower panel, the y-values show the number of the articles published on `non-U.S. domestic politics` (mostly about international relations). Note that I removed outliers from the raw date. You can check the raw data plot [here](https://github.com/jaeyk/ITS-Text-Classification/blob/master/output/raw_data_plot.png).
- Looking at the changes in the y-values before and after the intervention (the dotted vertical red line) in Figure 1, one can easily notice that the publication count increased in the post-intervention period for `U.S. domestic political news` but not for `the international ones`. Yet, one also should be cautious not to draw a strong conclusion from this plot alone. The y-values indicate both the treatment effect as well as seasonal changes and trends. In addition, there is no measure of uncertainty. 
- Therefore, the next step is to build a model that differentiates the treatment effect from these other factors. Before doing so, it is important to remind how interrupted time series design (ITS) is different from regression-discontinuity (RDD) design in terms of estimation strategy. In both designs, a cutoff (an interruption or a discontinuity) in the data is important to estimate treatment effects.
- However, whereas ITS is based on time-series, RDD is typically based on cross-sectional data. 
  - In a regression-discontinuity analysis, researchers estimate treatment effects within bandwidth around a certain cutoff. In close elections, the winning and the runner-up candidate might be not so much different except that one won the election and the other did not. For this reason, [Lee and Lemieux (2010: 289)](https://www.princeton.edu/~davidlee/wp/RDDEconomics.pdf) called RDD as a local experiment.
  - In contrast, the main challenge in ITS is time. Time is not randomly assigned across the data points. This condition raises some important challenges. Consider the issue of autocorrelation: the linear correlation between a time series data and a lagged version of itself.
- Autocorrelation (trend and seasonality)
  -  
- ​

**Figure 1. Scatted Plot**

![](<https://github.com/jaeyk/ITS-Text-Classification/blob/master/output/cleaned_data_plot.png>)

**Figure 2. Scatted Plot With Predicted Lines from the Interrupted Time Series Design Analysis**

![](<https://github.com/jaeyk/ITS-Text-Classification/blob/master/output/its_adjusted_plot.png>)

