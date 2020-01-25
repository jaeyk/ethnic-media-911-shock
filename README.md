# ITS-Text-Classification

## Purpose 

Combining Interrupted Time Series (ITS) Design and Text Classification to Examine How Threats Increase Immigrant Communities' Interest in US Domestic Politics. The intent of the project is to demonstrate how machine learning can be used to provide data for causal inference. 

## Abstract 

The goal of this project was to showcase how machine learning could help infer a causal relationship. Many scholars have argued that threats activate the political interests of immigrant groups in the politics of their settled society. Yet, it is challenging to confirm a causal relationship between these two variables due to many other potential variables that also influence an outcome. We addressed this problem by leveraging an exogenous shock (i.e., 9/11 attacks) and using multiple group comparisons. Specifically, we traced how this unexpected event increased the interests of Arab Americans, a direct target of xenophobia, and Indian Americans, an indirect target of xenophobia, in U.S. domestic politics. We classified many Arab- and Indian-American newspapers using machine learning to demonstrate the substantial size of the change in the outcome between pre- and post-intervention periods. While the natural experiment design identifies the causal relationship between the intervention and the outcome variation, the multiple group comparison reassures the reliability of the observations. This project proposes one way to combine natural experiments and machine learning to identify a causal effect of an intervention. This research design can be easily transferred to other policy and business settings.



## Workflow 

### Data collection 

1. Collecting Muslim-related articles from Arab- and Indian-American newspapers using [Ethnic Newswatch database](https://www.proquest.com/products-services/ethnic_newswatch.html) (manually done due to legal restrictions) 
2. Parsing original HTML files into CSV files in Python (e.g., beautiful soup) 

### Machine learning 

3. Randomly sampling articles from the corpus in R 
4. Labeling the sample articles (manually done) 
5. Classifying articles in Python (e.g., scikit-learn) 

### Causal inference 

6. Estimating the causal effect in R 

## Collaborators 
I worked with three highly competent UC Berkeley ungergraduates for this project (Sarah Santiago, Vivek Datta, and Carlos Ortiz). 

I am project lead and Andrew Thompson (a predoctoral fellow in Political Science at MIT and a PhD candidate in Political Science at Northwestern) is co-author of the paper based on this project. The paper is scheduled to present at the upcoming Western Political Science Association annual meeting. 

## Institutional support 
This project was supported by [the Data Science Discovery Program](https://data.berkeley.edu/research/discovery) at UC Berkley (Fall 2019).
