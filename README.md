# ITS-Text-Classification

**A showcase of how machine learning can create essential data for causally identifying the long-term effects of threats on marginalized populations**

- Co-author: [Andrew Thompson](https://sites.northwestern.edu/athompson/) (Notre Dame)
- RAs: [Carlos Ortiz](https://www.linkedin.com/in/carlosortizdev/), [Sarah Santiago](https://www.linkedin.com/in/sarah-santiago-7a297b18a/), and [Vivek Datta](https://www.linkedin.com/in/vivek-datta/)
- [Slides](https://docs.google.com/presentation/d/15IQNQk62wA4hmqkxZuCX3csvi2nc_jNizqurOaQSeEI/edit?usp=sharing) (presented at [the joint PaCSS and PolNet 2020 conference](https://web.northeastern.edu/nulab/pacss/))

## Motivation

Although threat has long been considered a central concept in the social sciences, the quantitative scholarship on threat has been limited in its scope. Previous studies have mainly focused on how threats influence majority group members because existing opinion data, such as the American National Election Studies or the General Social Survey, contain only small fractions of observations of minority populations. This study provides a solution to this long-standing problem in the literature by combining a natural experiment with machine learning.

## Research Design

### Threats and Information Seeking

- **Design**: The 9/11 attacks are an example of a natural experiment. The intervention---the terrorist attacks---was unexpected. Had the 9/11 attacks not occurred, the world would have continued in the way that it had existed before. This counterfactual world helps identify the causal effects of the intervention, as trends in the pre-intervention period can be compared with those in the post-intervention period. This research design is called [an interrupted time series design](https://en.wikipedia.org/wiki/Interrupted_time_series).
- **Treatment**: This research design allows us to identify the causal effects of **threats** on the political behaviors of immigrant communities. The 9/11 attacks mean different things to different people. Defining the meaning of the intervention as precisely as possible helps reduce confusion that can arise from different interpretations. Here, my focus is on the impact of the 9/11 attacks on immigrant communities. For these marginalized populations, the hawkish policy (i.e., the War on Terrorism) and the accompanying xenophobic public opinion were threatening in that they caused this population to suffer increasing uncertainty about their safety.
- **Mechanism**: We hypothesized that **threats** induce **information seeking**. After 9/11, immigrant communities might have been compelled to collect information on the treatment of Muslims in the United States to reduce the uncertainty they felt about their safety in the rapidly changing political climate.
- **Case selection**: Arabs and South Asians became subject to U.S. state surveillance and negative media reporting due to their associations with Muslims. These perceived threats would have caused them to experience increasing uncertainty about their safety and compelled them to collect information on the political treatment of Muslims in the U.S.

### Text Data and Hypotheses

- Text Data: The proof of the pudding is in the eating. What data can provide evidence for this claim? Ideally, we would like to have a large number of observations before and after the intervention. Otherwise, we lack statistical power to reject the null hypothesis (i.e., that the intervention and the observed change have no statistically significant relationship). Political scientists usually track political opinions through surveys. However, many observations of the targeted populations for this study were unlikely to be captured by most political opinion survey data collected at the national level using probability sampling (e.g., American National Election Studies). In this context, text data could serve as an alternative to the survey data. The [Ethnic NewsWatch](https://www.proquest.com/products-services/ethnicnewswatch_hist.html) database, created by Proquest, has compiled more than 2.5 million articles published by ethnic media in the U.S over the last four decades.
- **H1:** The September 11 attacks made Arab American and Indian American newspapers publish more articles on U.S. political news related to Muslim communities in the post-9/11 period than in previous years.
- **H2:** Arab American and Indian American newspapers published more articles on Muslim populations outside than inside the U.S. in the post-9/11 period than in the pre-intervention period.



## Research Process

In this section, I document how I implemented the research design step-by-step. If possible, I also provide the Python or R code used in each step. Aside from the text classification, all the Python and R code was written by me.


### Data Collection (Summer 2019)

#### 01_Collecting Articles Concerning Muslims from Arab and Indian American Newspapers Using the [Ethnic Newswatch Database](https://www.proquest.com/products-services/ethnic_newswatch.html).

- I used a 5-year window for the data collection from September 1996 to September 2006. I downloaded **Muslim populations related articles** published during this period from the database. These newspaper articles were then saved in HTML format to utilize the metadata (e.g., publication dates). I did this **manually** instead of using web scraping because I did not want to violate the copyrights held by Proquest.
- The text data included two Arab American (The Arab American News and The Arab American View) and three Indian American (New India Times, India Abroad, and India West) newspapers. The number of Indian newspaper articles was 4,552, and the number of Arab American newspaper articles was 1,132. For copyright reasons, I cannot share the proprietary text data that I collected for this project.

**Figure 1. The original HTML file**

<img src="https://github.com/jaeyk/ITS-Text-Classification/blob/master/misc/screenshot.png" width="600">

#### 02_Parsing Original HTML Files into a CSV File in Python [[Code](https://github.com/jaeyk/ITS-Text-Classification/blob/master/code/02_html_parsing.ipynb)]

- As the next step, I created a function named `parsing_proquest` in Python that takes one of these HTML files, extracts key features, puts these features together, and turns them in a data frame. In this case, the key features are the texts and publication dates. The texts are important to train machine learning algorithms and make predictions. The publication dates are critical to creating the time series data based on these texts.

```python
# extracting features of the HTML file using beautiful soup
 doc_text = soup.findAll("text")
 doc_date = soup.findAll("", {"class": "abstract_Text col-xs-12 col-sm-10 col-md-10 col-lg-10"})
```

- I then plugged this function into a for loop. The for loop turned 57 HTML newspaper files into a tidy dataset saved in a single CSV file. If we tried to do this manually, assuming that parsing one HTML file (100 newspaper articles) takes 5 hours, then this process would take 285 hours in comparison to the several seconds needed to complete the process using methods explained above.

```python
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

#### 03_Random Sampling Articles Stratifying on Intervention and Source Variables in R [[Code](https://github.com/jaeyk/ITS-Text-Classification/blob/master/code/03_sampling.Rmd)]

- I sampled 1,015 articles from this dataset to train machine learning algorithms.
- I tried to obtain (1) equal-sized sample articles for the pre- and post-intervention periods (intervention variable) and (2)balanced samples from across different kinds of newspapers (source variable). I did so because I assume that **the variances in these variables matter in training the model and making accurate predictions**.

`sample_articles <- stratified(articles, c("intervention", "source"), 120)`

#### 04_Labeling the Sample Articles

- We sampled 1,015 articles from this dataset to train machine learning algorithms. We tried to obtain (1) equal-sized sample articles for the pre- and post-intervention periods (intervention variable) and (2) balanced samples from different kinds of newspapers (source variable). The two coauthors and three undergraduate research assistants labeled these 1,015 sample articles as binary variables depending on whether they were about U.S. domestic politics (coded "1") or not (coded "0").
- Ideally, we would have calculated inter-coder reliability by assigning the same articles to at least two different coders, but due to time restrictions, we were not able to complete this step. We acknowledge this as one limitation of our study.

#### 05_Classifying Articles Using Machine Learning in Python [[Code for Preprocessing](https://github.com/jaeyk/ITS-Text-Classification/blob/master/code/05_01_preprocessing_text.ipynb)] [[Code for Classification](https://github.com/jaeyk/ITS-Text-Classification/blob/master/code/05_02_classifying_text.ipynb)]

- Then we trained a Lasso model in Python using the labeled texts with the added features (i.e., intervention, source, and group variables). The classification accuracy rate (the percentage of results accurately classified) was 73%, precision rate (the percentage of relevant results) was 75%, and recall rate (the percentage of total relevant results correctly classified) was 80%.

```python
# Get addition features from one hot encoding the source, intervention, and group columns

features_x_train = pd.concat([pd.get_dummies(train[col]) for col in ['source', 'intervention', 'group']], axis=1)

features_x_train = features_x_train.drop(columns = ["The Arab American View"])

features_x_train.head()
```

### Causal Inference (Winter 2019 and Spring 2020)

#### 06_Estimating the Causal Effect in R  [[Code](https://github.com/jaeyk/ITS-Text-Classification/blob/master/code/06_causal_inference.Rmd)]

- I finally obtained the time series data needed for the interrupted time series design analysis by combining the classified texts and their publication dates.
- In Figure 2, the X-axis indicates the publication date, and the Y-axis shows the number of published articles. In the upper panel, the y-values show the number of articles published on `U.S. domestic politics`. In the lower panel, the y-values show the number of articles published on `international politics` (mostly about international relations). Note that I removed outliers from the raw data. This step was necessary to fit an Ordinary Least Squares (OLS) regression model to the data because regression coefficients (slopes) are sensitive to outliers. You can check the raw data plot [here](https://github.com/jaeyk/ITS-Text-Classification/blob/master/output/raw_data_plot.png); note that the difference between the raw and the processed data is marginal.

**Figure 2. Scatted Plot**

<img src="https://github.com/jaeyk/ITS-Text-Classification/blob/master/output/cleaned_data_plot.png" width="600">

- Looking at the changes in the y-values before and after the intervention (the dotted vertical red line) in Figure 2, one can quickly notice that the publication count for Muslim-related articles increased in the post-intervention period for `U.S. domestic political news`, but not for `the international news`. Yet, one should also be cautious not to draw a strong conclusion from this plot alone. The y-values indicate both the treatment effect as well as seasonal changes, trends, and random noises. Comparing two groups (Arab and Indian American newspapers) reassures that the observed pattern is not group-specific, but a naive model cannot address these other factors.

- Therefore, the next step is to build a model that differentiates the treatment effect from these other factors. What is particularly problematic is autocorrelation or the linear correlation between time series data and the lagged version of itself. When this occurs, one of the key assumptions of an OLS model is violated: residuals (error terms) are i.i.d. (independent and identically distributed). In this case, this serial correlation does not influence the unbiased consistency of the estimator, but it [affects their efficiency](https://www3.nd.edu/~rwilliam/stats2/l26.pdf), leading to smaller standard errors and narrower confidence intervals than their correct versions. This problem causes Type I errors (false positives).


**Figure 3. Scattered Plot with Predicted Lines from the OLS Model**

<img src="https://github.com/jaeyk/ITS-Text-Classification/blob/master/output/its_base_plot.png" width="600">

- To check whether autocorrelation exists in the data, I applied the `acf() function` to it. One technically tricky thing about this is the function assumes that there are no gaps in the time lags. Therefore, if you have gaps in your time variable (e.g., missing days or months), you should fill them before running the `acf() function`. This can be done easily by creating the complete time sequence using `seq(start_date, end_date, by = 'the time interval') function`. In Figure 3, the Y-axis indicates the degree of the correlation associated with increasing time lags and the X-axis indicates time lags. The plot (called correlogram) shows the presence of a weak seasonal trend, especially for the upper panel (the U.S. domestic politics news).


**Figure 4. ACF Plot**

<img src="https://github.com/jaeyk/ITS-Text-Classification/blob/master/output/acf_plot.png" width="600">

- After getting this result, I shifted from OLS to [Generalized Least Squares](https://en.wikipedia.org/wiki/Generalized_least_squares) (GLS) for statistical modeling to parametrize autocorrelation. Unlike OLS, GLS relaxes the i.i.d. assumption and instead assumes a certain degree of correlation between the residuals and a regression model. Specifically, two key parameters define the correlation structure: `the autoregressive (AR) order` and `the moving average (MA) order`. AR specifies the ways in which earlier lags predict later ones. MA determines the ways we average and reduce the degree of random noise.
- Which combination of `p` and `q` creates the best fitting model is an empirical question. In `R`, we can build a GLS model using the `gls package` and specify AR and MR as arguments in  the`corARMA() function` inside the `gls() function`.
- I created a function for testing different GLS models and ran for loops to extract AIC (Akaike Information Criterion) from these models. Essentially, AIC [penalizes](https://www.quantstart.com/articles/Autoregressive-Moving-Average-ARMA-p-q-Models-for-Time-Series-Analysis-Part-1/) overfitting models and, thus, the lower AIC score indicates a better model fit. To do that, you need to set the `method` argument inside the `gls() function` to `ML (Maximum Likelihood Estimation)`. The default method is faster, but it does not provide AIC scores.
- The optimal combination that I found from the for loops is `p = 3` and `q = 1`.


**Figure 5. Scattered Plot with Predicted Lines from the GLS Model**

<img src="https://github.com/jaeyk/ITS-Text-Classification/blob/master/output/its_adjusted_plot.png" width="600">

- Compared to the OLS results, the GLS results showed much larger standard errors. This change affected the statistical significance of key regression coefficients. For instance, Table 1 shows that the treatment effect for the increase in the number of published articles on international politics was no longer statistically significant even when we lowered the level of significance to p < 0.1. Also, the new modeling approach made effect sizes slightly smaller. The fine-tuned result confirmed H1 (domestic threats prompted information seeking) and rejected H2 (international threats prompted information seeking).


<table style="text-align:center"><tr><td colspan="3" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left"></td><td colspan="2"><em>Dependent variable:</em></td></tr>
<tr><td></td><td colspan="2" style="border-bottom: 1px solid black"></td></tr>
<tr><td style="text-align:left"></td><td>Domestic</td><td>Non-domestic</td></tr>
<tr><td colspan="3" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left">Intervention</td><td>2.507<sup>***</sup></td><td>0.601</td></tr>
<tr><td style="text-align:left"></td><td>(0.693)</td><td>(0.579)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td></tr>
<tr><td style="text-align:left">Date</td><td>-0.0002</td><td>-0.001<sup>**</sup></td></tr>
<tr><td style="text-align:left"></td><td>(0.0004)</td><td>(0.0003)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td></tr>
<tr><td style="text-align:left">Indian Americans</td><td>2.291<sup>***</sup></td><td>2.316<sup>***</sup></td></tr>
<tr><td style="text-align:left"></td><td>(0.488)</td><td>(0.339)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td></tr>
<tr><td style="text-align:left">Constant</td><td>3.656</td><td>8.197<sup>***</sup></td></tr>
<tr><td style="text-align:left"></td><td>(3.818)</td><td>(2.982)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td></tr>
<tr><td colspan="3" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left">Observations</td><td>818</td><td>681</td></tr>
<tr><td style="text-align:left">Log Likelihood</td><td>-1,829.846</td><td>-1,528.902</td></tr>
<tr><td style="text-align:left">Akaike Inf. Crit.</td><td>3,677.691</td><td>3,075.804</td></tr>
<tr><td style="text-align:left">Bayesian Inf. Crit.</td><td>3,720.009</td><td>3,116.463</td></tr>
<tr><td colspan="3" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left"><em>Note:</em></td><td colspan="2" style="text-align:right"><sup>*</sup>p<0.1; <sup>**</sup>p<0.05; <sup>***</sup>p<0.01</td></tr>
</table>

Table 1. GLS analysis resuls

### Additional text analysis for construct validity test (Summer 2020)

#### 07_Additional Text Analysis in R [[Code](https://github.com/jaeyk/ITS-Text-Classification/blob/master/code/06_topic_modeling.Rmd)]

**Figure 6. Relative Word Frequencies**

<img src="https://github.com/jaeyk/ITS-Text-Classification/blob/master/output/relative_word_freq.png" width="600">
