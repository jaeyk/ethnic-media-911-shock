# ITS-Text-Classification

**A Showcase of How Machine Learning Can Be Used to Provide Essential Data for Causal Inference**

- Co-author: [Andrew Thompson](https://sites.northwestern.edu/athompson/) (Notre Dame)
- RAs: [Carlos Ortiz](https://www.linkedin.com/in/carlosortizdev/), [Sarah Santiago](https://www.linkedin.com/in/sarah-santiago-7a297b18a/), and [Vivek Datta](https://www.linkedin.com/in/vivek-datta/)
- [Slides](https://docs.google.com/presentation/d/15IQNQk62wA4hmqkxZuCX3csvi2nc_jNizqurOaQSeEI/edit?usp=sharing) (presented at [the joint PaCSS and PolNet 2020 conference](https://web.northeastern.edu/nulab/pacss/))

## Motivation

Causal inference is no easy task. To assess the causal relationship between X and Y, we should be able to observe subjects treated (Y treated) and the same subjects who are not treated (Y untreated) simultaneously. In experimental studies, random assignment, or assigning treatment to one group but not the others, is the best stategy available to address this selection bias/confounding/endogeneity problem (different names in different fields but essentially a similar idea). Still, on rare occasions, we find [natural experiments](https://en.wikipedia.org/wiki/Natural_experiment). Unexpected big events, such as natural disasters and wars, are good examples. These shocks force subjects to be untreated at t-1 but treated at t (within subjects analysis), or they make some subjects treated, but others leave others untreated at the same temporal point (between subjects analysis).

## Research Design

### Threats and Information Seeking

- **Design**: The 9/11 attacks are an example of a natural experiment. The intervention---the terrorist attacks---was unexpected. Had the 9/11 attacks not occurred, the world would have continued in the way that it had existed before. This counterfactual world helps identify the causal effects of the intervention, as trends in the pre-intervention period can be compared with those in the post-intervention period. This research design is called [an interrupted time series design](https://en.wikipedia.org/wiki/Interrupted_time_series).
- **Treatment**: This research design allows us to identify the causal effects of **threats** on the political behaviors of immigrant communities. The 9/11 attacks mean different things to different people. Defining the meaning of the intervention as precisely as possible helps reduce confusion that can arise from different interpretations. Here, my focus is on the impact of the 9/11 attacks on immigrant communities. For these marginalized populations, the hawkish policy (i.e., the War on Terrorism) and the accompanying xenophobic public opinion were threatening in that they caused this population to suffer increasing uncertainty about their safety.
- **Mechanism**: We hypothesized that **threats** induce **information seeking**. After 9/11, immigrant communities might have been compelled to collect information on the treatment of Muslims in the United States to reduce the uncertainty they felt about their safety in the rapidly changing political climate.
- **Case selection**: Arab and Indian Americans were ideal cases to test this argument for the ways in which they were **associated** with the image of terrorists. Arab Americans were targeted by the War on Terrorism and the xenophobic public opinion in the post-9.11 period because they came from the Muslim-majority countries and, thus, they were often perceived and treated as "potential terrorists." Indian Americans were also targeted because of their physical resemblance to Arab Americans in the eyes of white Americans.
- **Contributions**: Past studies have also looked at how threats induce information seeking ([Valentino et al. 2008](https://onlinelibrary.wiley.com/doi/full/10.1111/j.1467-9221.2008.00625.x?casa_token=AFdpYAvh0rUAAAAA%3AlZ4OrLYGOUc3s-GkdnMusZVZ1d6SDJWSB84H7zu6T7alT3TeAZgR6hx_6M7-QaD-3l2ON1JiaKWyt-A), [Gadarian and Albertson 2013](https://onlinelibrary.wiley.com/doi/full/10.1111/pops.12034?casa_token=jRK3KrzsfR4AAAAA%3AMds8LYY6-Ld62cLOBnXd68_WIitzqqUGX3IvfWajNlfwkU3aUrPGdE1y27Hj8MIcoQgEEilVe5xkCj4) ). Yet, most of these studies were done using associational analyses or survey experiments. Our study contributes to this literature by using novel data (text) and methods (a combination of machine learning and causal inference) that **improve both the internal and external validity of the research design**.

### Text Data and Hypotheses

- Text Data: The proof of the pudding is in the eating. What data can provide evidence for this claim? Ideally, we would like to have a large number of observations before and after the intervention. Otherwise, we lack statistical power to reject the null hypothesis (i.e., that the intervention and the observed change have no statistically significant relationship). Political scientists usually track political opinions through surveys. However, many observations of the targeted populations for this study were unlikely to be captured by most political opinion survey data collected at the national level using probability sampling (e.g., American National Election Studies). In this context, text data could serve as an alternative to the survey data. The [Ethnic NewsWatch](https://www.proquest.com/products-services/ethnicnewswatch_hist.html) database, created by Proquest, has compiled more than 2.5 million articles published by ethnic media in the U.S over the last four decades.
- **H1:** We can take advantage of the text data by re-framing the question. Threats encourage information seeking. Information seeking increases demands for newspaper articles related to these threats. Therefore, the number of articles on threats can be considered as a proxy for measuring the change in information seeking. This is a reasonable assumption, as ethnic newspapers heavily rely on the demands of their ethnic communities. Therefore, the 9/11 attacks would have made Arab and Indian American newspapers publish more articles on **U.S. political news on Muslim communities** in the post-9.11 period compared to the number they had published in previous years (**H1**).
- **H2:** A related question is the origin issue. To what extent can we be confident that this change in the number of articles published on the treatment of the Muslim populations in the U.S. indicates the origin of the threat is *domestic* (the hawkish U.S. policy and the xenophobic public opinion) not *international* (the spread of terrorism)? Collecting additional data could be useful to validate this theoretical assumption. If the international threat was present, then Arab and Indian American newspapers should have published more articles on the Muslim populations **outside of the U.S.** in the post-9.11 period vis-à-vis the pre-intervention period (**H2**). If only H1 were true and H2 were false, then the tests would confirm that the origin of the threats was domestic. If they were both true, then the sources of threats were both domestic and international sources.



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

#### 03_Random Sampling Articles Stratifying on Assignment and Source Variables in R [[Code](https://github.com/jaeyk/ITS-Text-Classification/blob/master/code/03_sampling.Rmd)]

- I sampled 1,015 articles from this dataset to train machine learning algorithms.
- I tried to obtain (1) equal-sized sample articles for the pre- and post-intervention periods (assignment variable) and (2)balanced samples from across different kinds of newspapers (source variable). I did so because I assume that **the variances in these variables matter in training the model and making accurate predictions**.

`sample_articles <- stratified(articles, c("intervention", "source"), 120)`

#### 04_Labeling the Sample Articles

- I distributed the task of labeling 1,015 sample articles between five people: Andrew (co-author), the 3 RAs, and myself. Initially, we were very ambitious. We wanted to get fine-grained data on the specific kinds of political information that these newspapers provided. However, as we started reading and labeling the sample articles, we realized that a multinominal (many categories) conceptual framework was not going to work. The main problem was that either many articles fit into all the measures that we proposed (false positive), or they didn't fit at all (false negative). The RAs raised this as a critical problem because they felt *they could not be confident that a machine learning algorithm can predict values if they---humans---could not*. This was a fair point. Consequently, we decided to keep things simple and label articles as a binary variable depending on whether they were **about U.S. domestic politics (coded 1) or not (coded 0)**. Interestingly, most of the non-domestic Muslim articles were about international affairs such as the disputes between India and Pakistan.
- Ideally, we would have calculated inter-coder reliability by assigning the same articles to at least two different coders, but due to time restrictions, we were not able to complete this step. We acknowledge this as one limitation of our study.

#### 05_Classifying Articles Using Machine Learning in Python [[Code for Preprocessing](https://github.com/jaeyk/ITS-Text-Classification/blob/master/code/05_01_preprocessing_text.ipynb)] [[Code for Classification](https://github.com/jaeyk/ITS-Text-Classification/blob/master/code/05_02_classifying_text.ipynb)]

- The RAs then trained a lasso model in Python using these labeled texts. Initial trials did not deliver a promising result. To improve this, we added features (i.e., stratifying variables -- assignment and source variables) that were used in the sampling process. The classification accuracy rate is **73\%**, precision rate **75\%**, and recall rate **80\%**.

```python
# Get addition features from one hot encoding the source, intervention, and group columns

features_x_train = pd.concat([pd.get_dummies(train[col]) for col in ['source', 'intervention', 'group']], axis=1)

features_x_train = features_x_train.drop(columns = ["The Arab American View"])

features_x_train.head()
```

### Causal Inference (Winter 2019 and Spring 2020)

#### 06_Estimating the Causal Effect in R [[Data](https://github.com/jaeyk/ITS-Text-Classification/blob/master/processed_data/df.csv)] [[Code](https://github.com/jaeyk/ITS-Text-Classification/blob/master/code/06_causal_inference.Rmd)] [[Output](https://github.com/jaeyk/ITS-Text-Classification/tree/master/output)]

- I finally obtained the time series data needed for the interrupted time series design analysis by combining the classified texts and their publication dates.
- In Figure 2, the X-axis indicates the publication date, and the Y-axis shows the number of published articles. In the upper panel, the y-values show the number of articles published on `U.S. domestic politics`. In the lower panel, the y-values show the number of articles published on `non-U.S. domestic politics` (mostly about international relations). Note that I removed outliers from the raw data. This step was necessary to fit an Ordinary Least Squares (OLS) regression model to the data because regression coefficients (slopes) are sensitive to outliers. You can check the raw data plot [here](https://github.com/jaeyk/ITS-Text-Classification/blob/master/output/raw_data_plot.png); note that the difference between the raw and the processed data is marginal.

**Figure 2. Scatted Plot**

<img src="https://github.com/jaeyk/ITS-Text-Classification/blob/master/output/cleaned_data_plot.png" width="600">

- Looking at the changes in the y-values before and after the intervention (the dotted vertical red line) in Figure 2, one can quickly notice that the publication count for Muslim-related articles increased in the post-intervention period for `U.S. domestic political news`, but not for `the international news`. Yet, one should also be cautious not to draw a strong conclusion from this plot alone. The y-values indicate both the treatment effect as well as seasonal changes, trends, and random noises. Comparing two groups (Arab and Indian American newspapers) reassures that the observed pattern is not group-specific, but a naive model cannot address these other factors.

- Therefore, the next step is to build a model that differentiates the treatment effect from these other factors. Before doing so, it is important to acknowledge how an interrupted time series (ITS) design is different from a regression-discontinuity (RD) design in terms of estimation strategy. In both research designs, a cutoff (an interruption or a discontinuity) in the data is essential to qualify them as natural experiments.

- However, the key difference is that ITS is based on time-series, whereas RD is typically based on cross-sectional data.
- In an RD analysis, researchers estimate treatment effects within a bandwidth around a certain cutoff. For instance, the winning and the runner-up candidate in close elections might be not so much different, except that one won the election and the other did not. For this reason, [Lee and Lemieux (2010: 289)](https://www.princeton.edu/~davidlee/wp/RDDEconomics.pdf) called RD a local experiment and the data analysis for RD is similar to the analysis of experimental data.
- In contrast, the main challenge of ITS is time, a variable that is not randomly assigned across the data points. Therefore, researchers need to figure out how they can model time series data and its various components.
- What is particularly problematic is autocorrelation or the linear correlation between time series data and the lagged version of itself. When this occurs, one of the key assumptions of an OLS model is violated: residuals (error terms) are i.i.d. (independent and identically distributed). In this case, this serial correlation does not influence the unbiased consistency of the estimator, but it [affects their efficiency](https://www3.nd.edu/~rwilliam/stats2/l26.pdf), leading to smaller standard errors and narrower confidence intervals than their correct versions. This problem causes Type I errors (false positives).


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

- It is fascinating to see how these different modeling approaches influence the ways we can interpret the statistical results. Figure 4 and 5 are similar to Figure 2 in terms of the X-axis, Y-axis, and raw data points (they are intentionally blurred to stress predicted lines more). The predicted lines come from the naive OLS model in Figure 4 and the GLS model in Figure 5. In terms of slopes, they are close; what makes them different is the size of the confidence intervals (the gray area surrounding the line plots). This observation is consistent with what we discussed earlier. Autocorrelation influences the efficiency of regression estimators, so that when we take that problem in our modeling approach, the confidence intervals become more conservative.


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

- As shown in Table  1, the results confirm H1 (domestic threats induce information seeking) and reject H2 (international threats induce information seeking).
