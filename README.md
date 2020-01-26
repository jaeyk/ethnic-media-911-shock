# ITS-Text-Classification



**A Showcase of How Machine Learning Can Be Used to Provide Essential Data for Causal Inference**



The goal of this article is to document how I have developed this project from end to end. I intend to share what I succeeded and failed in achieving my research objective and what I learned in the process. I will continuously update this article and the associated git repository as I make progress. I hope this article is helpful for fellow travelers in computational social science. Any comments on the project are welcome. Please send an email to [jaeyeonkim@berkeley.edu](mailto:jaeyeonkim@berkeley.edu), in case you would like to get in touch with me.



## Motivation

Hi there. I am Jae Kim, a PhD candidate in Political Science, a data science fellow for [the Data-intensive Social Sciences Lab](https://dlab.berkeley.edu/) (D-Lab), and a data science education program fellow at UC Berkeley. Artificial intelligence, particularly machine learning, has taken over the world in recent years. As Andrew Ng [said](https://www.youtube.com/watch?v=21EiKfQYZXc), it's new electricity. Yet the impact of machine learning has been marginal in many social science disciplines. It is to some extent because many social scientists still view it as a mere prediction tool that has little to do with explaining the causal relationship between X and Y (causal inference). As a way to change this common perception, [Andrew Thompson](https://sites.northwestern.edu/athompson/) (Northwestern and MIT) and I co-developed this project to demonstrate **how machine learning can help create critical data for causal inference.** 



## Research Design

### Causal Inference and Natural Experiments 

Causal inference is hard. To assess the causal relationship between X and Y, we should be able to observe subjects treated (think of users exposed to a certain kind of online advertisement; Y treated) and the same subjects who are not treated (Y untreated) at the same temporal point. According to [the Neyman-Rubin potential outcome model](https://en.wikipedia.org/wiki/Rubin_causal_model), this comparison between the real world and the counterfactual world is key to defining causal effect as the average difference between Y treated and Y untreated. However, we are not living in the world of a Sci-Fi fiction (e.g. Philip K. Dick's [*The Man in the High Castle*](https://en.wikipedia.org/wiki/The_Man_in_the_High_Castle_(TV_series))) and these two observations can't exist simultaneously. As Holland (1986) [called](http://www-stat.wharton.upenn.edu/~hwainer/Readings/Holland_Statistics%20and%20Causal%20Inference.pdf), this challenge is "the fundamental problem of causal inference." In experimental studies, randomly assigning treatment to one group but not the others solves this selection bias/confounding/endogeneity problem. It is because randomization, by definition, creates treatment and control groups who only differ in their treatment status on average. This is not the case in observational studies. Observational studies have weaker designs because here we don't know enough about the process under which some subjects receive the treatment and the others didn't ([Rubin and Imbens 2015](https://www.cambridge.org/core/books/causal-inference-for-statistics-social-and-biomedical-sciences/71126BE90C58F1A431FE9B2DD07938AB)). This missing data problem may bias how we assess the causal relationship between X and Y ([Ding and Li 2018](https://arxiv.org/abs/1712.06170v1)).

Nevertheless, on rare occasions, we are blessed to have [natural experiments](https://en.wikipedia.org/wiki/Natural_experiment). These are settings in which factors, outside the control of subjects and researchers, exist. These unexpected big events such as natural disasters and wars either force subjects to be untreated at t-1 but treated at t (e.g., [interrupted time series design](https://en.wikipedia.org/wiki/Interrupted_time_series)) or make some subjects treated, but others left untreated at the same temporal point (e.g., [regression discontinuity design](https://en.wikipedia.org/wiki/Regression_discontinuity_design)). 

### Theory: Threats and Information Seeking

We believe that the 9/11 attacks, an unexpected terrorist attack, are qualified as such a natural experiment and, thus, provide an opportunity to tackle a difficult causal inference problem. Specifically, we are interested in identifying the causal effects of threats on the political behaviors of immigrant communities using an interrupted time series design. The 9/11 attacks, the policy change (i.e., the War on Terrorism), and the accompanying negative public opinion on immigration intensified threats. In response, immigrant communities may seek information on U.S. domestic politics in order to reduce uncertainty surrounding the political climate. Arab and Indian Americans were good cases to demonstrate the presence of this mechanism. Arab Americans were directly targeted by the War on Terrorism policies and the xenophobic attitude in the post-9.11 period because they are "Muslims" and, thus, "potential terrorists." Indian Americans were indirectly targeted because of their physical resemblance to Arab Americans in the eyes of white Americans. A previous study ([Valentino et al. 2008](https://onlinelibrary.wiley.com/doi/full/10.1111/j.1467-9221.2008.00625.x?casa_token=mtDyvqeBqPkAAAAA%3A9TXaT1ajvBz0BosqvzoAUrVXy7gO_YacuajBFRrtHLz5I-amUv10k3TYGH0lknRBdeMiJIRXf72KaQ)) shows that threats induce anxiety and anxiety encourages information seeking. Therefore, that the terrorism related threats might have influenced Arab and Indian Americans to seek political information more actively. 

### Text Data, Hypotheses, and Mechanism

The proof of the pudding is in the eating. What data can provide evidence for this claim? To use an interrupted time series design, we would like to have enough observations before and after the intervention. Otherwise, we lack statistical power to reject the null hypothesis. Political scientists usually track political opinions through surveys. However, as the population size of these groups were small in the U.S., national political opinion polls based on probability sampling could not provide much help. In this context, text data could be seen as an alternative to the survey data. [Ethnic NewsWatch](https://www.proquest.com/products-services/ethnicnewswatch_hist.html) database, created by Proquest, has compiled more than 2.5 million articles published by ethnic media in the U.S in the last four decades. We can take advantage of this vast data by re-framing the question. Ethnic newspapers publish articles that meet the demands of their readers. The threats enhanced the level of anxiety among the readers. To lower uncertainty about the political climate, these readers may more actively seek political information and that demand would increase the number of articles published about that subject. Therefore, Arab and Indian American newspapers should have published more articles on **U.S. political news that focused on Muslim populations** in the post-9.11 period compared to their level in the previous years (**H1**).

A related question is how we can this measure that the origin of the threat is domestic (the U.S. government and the xenophobic public opinion) not international (the spread of terrorism). If that were that case, then we should be able to observe Arab and Indian American newspapers published more articles on Muslim populations, which are not related to the U.S. domestic politics, in the post-9.11 period vis-à-vis the pre-intervention period (**H2**). Comparing these two outcomes helps identify the origin of the threats. If only H1 were true and H2 were false, then it confirms that the origin of the threats was domestic. 



## Research Process

### Overview

After we figured out the research design, we were ready to get our hands dirty. Lucky for me, I was able to get an opportunity to hire three talented UC Berkeley undergraduates (Carlos Ortiz, Sarah Santiago, and Vivek Datta; I listed their names in alphabetical order) as research assistants (RAs) through [the Data Science Discovery Program](https://data.berkeley.edu/research/discovery) in Fall 2019. The program helped and forced me carry out the project because the program required to meet the undergraduate RAs at least once every week and present preliminary findings by the end of the semester in front of a large and mixed audience.




### Primary Data collection (Summer 2019)

#### 01_Collecting Muslims-related Articles from Arab and Indian American Newspapers Using [Ethnic Newswatch Database](https://www.proquest.com/products-services/ethnic_newswatch.html).

- I did not web scrape these articles because I was worried about violating the copyrights held by Proquest. For the exactly same reason, I do not share the proprietary text data which I used in this project. 
- The text data includes two Arab American (The Arab American News and The Arab American View) and three Indian American (New India - Times, India Abroad, and India - West) newspapers. Note that the number of Indian newspaper articles (N = 4,552) is 4 times greater than the number of Arab American newspaper articles (N = 1,132).


- I used a 5-year window for the data collection, from September 1996 through September 2006. I manually downloaded **Muslim populations related articles** published during this time period from the database.

#### 02_Parsing Original HTML Files into CSV Files in Python

- I created a function named `parsing_proquest` that parse an HTML file into a CSV file. Proquest changes their download policy from time to time. As of summer 2019, users were not allowed to directly download newspaper articles from Ethnic NewsWatch. Instead, I chose to print a bulk of articles and saved them as an HTML file. The function takes this HTML file, extracts key features (see below), such as the text and the publication date, and put them together and save it in a CSV file. 

```
# extracting features of the HTML file using beautiful soup 
 doc_text = soup.findAll("text")
 doc_date = soup.findAll("", {"class": "abstract_Text col-xs-12 col-sm-10 col-md-10 col-lg-10"})
```

- After defining a function to parse HTML files, then you just need to plug that function into a for loop.

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

#### 03_Random Sampling Articles Stratifying on Intervention and Source Variables in R

- I sampled around 1,000 articles to train machine learning algorithms.
- I tried to have 1) a sufficient number of sample articles for both the pre- and post-intervention periods and 2) getting them from across different kinds of newspapers. I did so because I assume **the variations in these variables matter in training the model and making accurate predictions**.   

`sample_articles <- stratified(articles, c("intervention", "source"), 120)`

#### 04_Labeling the Sample Articles

- I distributed the task of labeling 1,015 sample articles between 5 people: me, Andrew, and the 3 RAs. Initially, we were very ambitious and wanted to get fine-grained data on what kinds of political information these newspapers provided to their readers. For instance, whether the focus of these newspapers was on strengthening unity between their readership and the general Muslim populations in the U.S. or differences between them or stressing their American identity. When Andrew and I talked about these constructs, we were excited about this framework because it can give us a chance to discuss group identity in the paper. 
- However, as we started reading and labeling the sample articles, we realized that that conceptual framework is not going to work. The main problem is that many articles either fit into any of these three constructs (overfitting) or didn't fit at all (underfitting). The undergraduate RAs really pushed this as a critical problem because they felt *they could not be confident how a machine learning algorithm can predict values if they can't*. Consequently, we decided to **keep things simple** and label articles whether they are **about U.S. domestic politics** or not (a binary choice). Interestingly, most of the non-domestic Muslim articles were about international relations such as the relationship between India and Pakistan.
- If time allowed, I wanted to calculate the inter-coder reliability score by assigning same articles at least to two different coders. We couldn't do that because we were pressured to present preliminary findings in only 1-2 weeks.

#### 05_Classifying Articles Using Machine Learning in Python



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

#### 06_Estimating the Causal Effect in R



**Raw Data**

![](<https://github.com/jaeyk/ITS-Text-Classification/blob/master/output/cleaned_data_plot.png>)



**Raw Data With Predicted Lines from the Interrupted Time Series Design Analysis**

![](<https://github.com/jaeyk/ITS-Text-Classification/blob/master/output/its_adjusted_plot.png>)