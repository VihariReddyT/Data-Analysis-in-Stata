* Class practice 4

* Let Stata know you are using panel data

xtset brand

sum

* Run a regression model with fixed effects

xtreg sale reportcount price review xrd xad i.year qualitycontrol WarrantyAmount, fe

estimate store fixed 

* Run a regression model with random effects

xtreg sale reportcount price review xrd xad i.year qualitycontrol WarrantyAmount, re

estimate store random

* run hausman test to check if random effects model can be used

hausman fixed random, sigmamore

* create zscores [standardized variables with mean of 0 and std of 1) for all the variables (except year dummies) 

egen  zreportcount= std(reportcount), mean(0) std(1)
egen  zprice = std(price), mean(0) std(1)
egen  zreview = std(review), mean(0) std(1)
egen  zxrd = std(xrd), mean(0) std(1)
egen  zxad = std(xad), mean(0) std(1)
egen  zquality = std(qualitycontrol), mean(0) std(1)
egen  zwarranty = std(WarrantyAmount), mean(0) std(1)

* run the model on zscores 

xtreg sale zreportcount zprice zreview zxrd zxad zquality zwarranty i.year, fe

* Significant variables are recall and review, we need to know their standard deviation 

sum reportcount review

* Create a dummy (named Recall) showing whether a brand had a recall incident =1 or not at all=0, get a tabulate of the variable 

gen recall = reportcount > 0

tab recall

* Run a panel analysis that shows the likelihood of having recall (=1) compared to not having recall (=0) based on all other variable
* Exclude report count because it is highly correlated with dummy recall, exclude sale because ______

xtlogit recall price review xad xrd qualitycontrol WarrantyAmount i.year, fe

estimate store fixed_logit

* Run the regression model with random effects

xtlogit recall price review xad xrd qualitycontrol WarrantyAmount i.year, re

estimate store random_logit

* run hausman test to check if random effects model can be used

hausman fixed_logit random_logit

* 
