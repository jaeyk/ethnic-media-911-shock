# ITS-Text-Classification

<u>A Showcase of How Machine Learning Can Be Used to Provide Essential Data for Causal Inference</u>

The goal of this article is to document how I develop this project from end to end. I intend to share what I succeeded and failed in achieving my research objective with my fellow travelers in computational social science. I will continuously update this article and the associated git repository as I make progress in this project. Any comments on the project are welcome and please send an email to [jaeyeonkim@berkeley.edu](mailto:jaeyeonkim@berkeley.edu) if you would like to get in touch with me.



## Motivation

Hi there. I am Jae Kim, a PhD candidate in Political Science and a data science fellow for [the Data-intensive Social Sciences Lab](https://dlab.berkeley.edu/) (D-Lab) and a data science education program fellow at UC Berkeley. In summer 2019, I was invited to participate in the two-week intensive program on computational social science at Princeton called [the Summer Institute on Computational Social Science](https://compsocialscience.github.io/summer-institute/2019/princeton/people) as one of its 29 participants. It is a cool program that gave a lot of fresh ideas about doing computational social science and fantastic opportunities for networking and other kinds of professional development. 

Through this program, I met [Andrew Thompson](https://sites.northwestern.edu/athompson/), a PhD candidate in political science at Northwestern and a pre-doctoral fellow at MIT. During the two weeks, we became friends and talked about developing a project that uses machine learning to provide data for causal inference. Artificial intelligence, particularly machine learning, has taken over the world in recent years. As Andrew Ng [said](https://www.youtube.com/watch?v=21EiKfQYZXc), it's new electricity. Yet in my field (political science) the impact of machine learning has been marginal. It is to some extent because many scholars still tend to view it as a tool to make a prediction (or association) and have little to do with explaining the causal relationship between X and Y (causal inference). At least, that's the reaction that I received when I taught [an introduction to computational social science](https://github.com/jaeyk/PS239T) for graduate students at UC Berkeley and talked about the use of machine learning in social science research with colleagues at different institutions. Andrew and I wanted to find a way to change this common perception, and we decided to develop **a project that demonstrates how machine learning can help create critical data for causal inference.** 



## Research Design

### Finding a leverage

Before going into more details, let's talk a little bit about why the causal inference is tough. To assess the causal relationship between $X$ and $Y$, we should be able to observe subjects treated (think of users exposed to a certain kind of online advertisement) ($Y^{treated}$) and the same subjects who are not treated ($Y ^{untreated}$) at the same temporal point ($t$). Otherwise, we can't tell how the treatment, the online advertisement makes, a difference in the way the users interact with the product or the service advertised. According to [the Neyman-Rubin potential outcome model](https://en.wikipedia.org/wiki/Rubin_causal_model), the comparison between the real world and the counterfactual world is crucial to define as the average difference between $Y$ treated and $Y$ untreated. However, we are not living in the world of a Sci-Fi fiction (e.g. Philip K. Dick's [*The Man in the High Castle*](https://en.wikipedia.org/wiki/The_Man_in_the_High_Castle_(TV_series))). These two observations can't exist simultaneously. Holland (1986) [called](http://www-stat.wharton.upenn.edu/~hwainer/Readings/Holland_Statistics%20and%20Causal%20Inference.pdf) this challenge as "the fundamental problem of causal inference." 

In experimental studies, randomly assigning treatment to one group but not the others (as used in A/B testing in the tech industry and randomized-controlled experiments in academia) solves this selection bias/confounding/endogeneity problem (again, different names but the same idea). It is because randomization, by definition, creates treatment and control groups only differ in their treatment status on average. 

This is not the case in observational studies. Here, scholars either compare the same groups over time, or compare two groups similar enough to each other but clearly different in their treatment status, or do both of them. Most of these comparisons are, however, limited because we can't observe all the critical differences between treatment and control groups. More precisely, observational studies are vulnerable because we don't know enough about the process under which some subjects receive the treatment, and the others didn't ([Rubin and Imbens 2015](https://www.cambridge.org/core/books/causal-inference-for-statistics-social-and-biomedical-sciences/71126BE90C58F1A431FE9B2DD07938AB)). This missing data problem may cause bias how we assess the causal relationship between X and Y ([Ding and Li 2018](https://arxiv.org/abs/1712.06170v1)).

Nevertheless, on rare occasions, we run into [natural experiments](https://en.wikipedia.org/wiki/Natural_experiment) that allow us infer causality with observational data. These are settings in which first factors (e.g., mostly unexpected big events such as natural disasters and wars), outside the control of subjects and researchers (in technical terms, exogenous shocks), exist. Second, these factors force either subjects to be untreated at $t_{-1}$ but treated at $t$ (e.g., [interrupted time series design](https://en.wikipedia.org/wiki/Interrupted_time_series)) or make some subjects treated, but others left untreated at the same temporal point (e.g., [regression discontinuity design](https://en.wikipedia.org/wiki/Regression_discontinuity_design)). 

### Thinking about the Case and the Theory

We believe that the 9/11 attacks, an unexpected terrorist attack, are qualified as a natural experiment and, thus, provide an opportunity to tackle a difficult causal inference problem. Specifically, we are interested in identifying the causal effects of threats on the political behaviors of immigrant communities leveraging this shock. Immigrants live in a place between the two worlds: their home countries and settled societies. They need to adjust to and thrive in the new world but also maintain social, economic, and political contacts with the old world. The 9/11 attacks, the policy change (i.e., the War on Terrorism), and the accompanying negative public opinion on immigration represented a surging new trend in the political environment: intensified threats. In response, immigrant communities may seek information on U.S. domestic politics in order to reduce uncertainty surrounding the political climate. A previous study ([Valentino et al. 2008](https://onlinelibrary.wiley.com/doi/full/10.1111/j.1467-9221.2008.00625.x?casa_token=mtDyvqeBqPkAAAAA%3A9TXaT1ajvBz0BosqvzoAUrVXy7gO_YacuajBFRrtHLz5I-amUv10k3TYGH0lknRBdeMiJIRXf72KaQ)) shows the causal relationship between anxiety and the quantity and quality of information seeking. We assume that Arab and Indian Americans were likely influenced by these threats and seek political information. Arab Americans were directly targeted by the War on Terrorism policies and the xenophobic attitude in the post-9.11 period because they are "Muslims" and, thus, "potential terrorists." Indian Americans were indirectly targeted because of their physical resemblance to Arab Americans in the eyes of white Americans. 

### Generating a Hypothesis

The proof of the pudding is in the eating. What data can provide evidence for this claim? To use an interrupted time series design, we would like to have enough observations before and after the intervention. Otherwise, we lack statistical power to the null hypothesis. Political scientists usually track political opinions through surveys. However, as these populations were small in the United States, national political opinion polls based on probability sampling could not provide much help. In this context, text data could be seen as an alternative to the survey data. [Ethnic NewsWatch](https://www.proquest.com/products-services/ethnicnewswatch_hist.html) database, created by Proquest, has compiled more than 2.5 million articles published by ethnic media in the U.S in the last four decades. We can take advantage of this vast data by re-framing the question. Like other media, ethnic newspapers publish articles that meet the demands of their readers and, thus, the threats could have changed how Arab and Indian American newspapers report **U.S. political news focused on Muslim populations**. We hypothesize that the number of these articles should **increase** in the post-9.11 period compared to the level in the previous years (**H1**).

### Identifying the Mechanism 

To identify the mechanism, we add more measures. Perhaps, the threats did not only come from the U.S. domestic politics but also elsewhere because the War on Terrorism became the Global War on Terrorism. If that were that case, then we should be able to observe that Arab and Indian American newspapers published more articles on Muslim populations, that are not related to the U.S. domestic politics, in the post-9.11 period vis-à-vis the pre-intervention period (**H2**). Comparing these two outcomes helps identify the origin of the threats. If only H1 were true and H2 were false, then it confirms that the origin of the threats was domestic. The finding is consistent with the theory that threats increase information seeking to reduce uncertainty.



## Research Process

### Overview

After we figured out the research design, we were ready to get our hands dirty. Lucky for me, I was able to get an opportunity to hire three talented UC Berkeley undergraduates (Carlos Ortiz, Sarah Santiago, and Vivek Datta; I listed their names in alphabetical order) as research assistants (RAs) through [the Data Science Discovery Program](https://data.berkeley.edu/research/discovery) in Fall 2019. The program helped and forced me carry out the project because it required me meet with the undergraduate RAs every week and present preliminary findings by the end of the semester at the Data Science Showcase.

- Andrew and I developed the research design together and, currently, we are working on a manuscript which will be presented at the upcoming Western Political Science Association annual meeting. 
- The undergraduate RAs were deeply involved in classifying texts using supervised machine learning.
- I were involved from end (research design) to end (visualizing the preliminary findings) in this project. I wrote a Python script to turn unstructured newspaper articles in HTML format into a single dataset, stratified random sampling these articles for training a machine learning algorithm, read and labeled these sample articles with Andrew and the undergraduate RAs, and estimated the causal effect of the intervention in R and visualized the preliminary findings. 
- If possible, I shared the code I used for each stage in this research process. For instance, you can find the code I used to parse HTML files from the file named 02_parsing in `code` directory in this git repository. The file names are numbered following the related research stages.  



### Primary Data collection (Summer 2019)

#### 01_Collecting Muslims-related Articles from Arab and Indian American Newspapers Using [Ethnic Newswatch Database](https://www.proquest.com/products-services/ethnic_newswatch.html).

- I did not web scrape these articles because I was worried about a potential copyright infringement issue. For the exactly same reason, I am not able to share the text data I used this project because Proquest holds the copyrights. 


	- The text dataset contains two Arab American (The Arab American News and The Arab American View) and three Indian American (New India - Times, India Abroad, and India - West) newspapers. Also, the number of Indian newspaper articles (N = 4,552) is 4 times greater than the number of Arab American newspaper articles (N = 1,132).
- We used a 5-year window for the data collection, from September 1996 through September 2006. I selected and manually downloaded **Muslim populations related articles** from the database during this time period.

#### 02_Parsing Original HTML Files into CSV Files in Python

- I created a function named `parsing_proquest` that takes the print version of the newspaper articles which you can download Proquest and turn them into a single CSV file. 
- They changed their policies from time to time, and so you should check what they allow you to do. In the past, you are able to download 100 articles from Proquest at once as an HTML file. Then, a couple of months ago, the option was to print 100 articles at once and then save them as a HTML file. The old feature provided nicer attributes that you can exploit to turn that file into a CSV dataset.

```
# extracting features of the HTML file using beautiful soup 
 doc_text = soup.findAll("text")
 doc_date = soup.findAll("", {"class": "abstract_Text col-xs-12 col-sm-10 col-md-10 col-lg-10"})
```

- After you figured out how to parse the HTML file using `beautiful soup` and defined a function then you just need to plug the function into a for loop as you can see below.

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

- These sample articles were used to train machine learning algorithms.
- At this stage, I tried to have 1) enough number of sample articles for both the pre- and post-intervention periods and 2) getting these sample articles across different kinds of newspapers. The underlying assumptions are **the variations in these variables matter in training the model and making accurate predictions**.   

`sample_articles <- stratified(articles, c("intervention", "source"), 120)`

#### 04_Labeling the Sample Articles

- We divided the 1,015 sample articles among 5 people me, Andrew, and the 3 RAs. Initially, we were very ambitious and wanted to get fine-grained data on what kinds of political information these newspapers provided to their readers. For instance, whether the focus of these newspapers was on strengthening unity between their readership and the general Muslim populations in the United States or differences between them or stress their American identity (assimilation). When Andrew and I talked about this at the conceptual level, we were excited about this idea as it can give us a chance to talk about group identity. 
- However, as we started reading and labeling the sample articles, we realized that that conceptual framework is not going to work. The main problem is that many articles either fit into any of these three constructs or didn't fit at all. The undergraduate RAs really pushed this as a problem because they felt *they could not be confident how a machine learning algorithm can predict values if they can't*. Consequently, we decided to **keep things simple** and label articles whether they are about U.S. domestic politics or not (a binary choice). Interestingly, most of the non-domestic Muslim articles were about international relations such as the relationship between India and Pakistan.
- If time allowed, I would like to calculate the inter-coder reliability score by assigning same articles at least to two different coders. We couldn't do that because we needed to present the preliminary findings by the end of the semester. When we reached this stage, we have only 1-2 weeks left (excluding the Thanksgiving break).

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

![](<https://github.com/jaeyk/ITS-Text-Classification/blob/master/output/its_adjusted_plot.png>)

