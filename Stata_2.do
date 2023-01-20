gen roa=ib/at
gen Leverage= dltt/at
gen net_opt_cash_flow=ebit-txt

label variable roa "Retun on Assets"

label variable leverage "Leverage"
gen net_opt_cash_flow=ebit-txt
label variable net_opt_cash_flow "Net operating cash flows"
gen opt_margin = (ni+dp)/sale
label variable opt_margin "Operating Margin"
gen tobin=(at+(csho*prcc_f)-ceq)/at
label variable tobin "Tobin's Q"
gen sic3=int(sic/10 )
label variable sic3 "3-digit SIC"
gen stg_emph =(xrd-xad)/at
label variable stg_emph "Strategic Emphasis"
egen mkt_size_3 = total(sale), by (sic3 year)
label variable mkt_size_3 "Market size for sic3"
gen mkt_share3 = sale/mkt_size_3
label variable mkt_share3 "Market share in sic3"
egen mktshare3_2= total(mkt_share3^2), by(sic3 year)
label variable HHI_sic4 "Herfindahl Index for SIC4"
gen HHI_sic3=1/mktshare3_2
label variable HHI_sic3 " Herfindahl Index for SIC3"
summarize

pwcorr sale xrd xad Leverage chapter7 , sig

sum at,detail

gen size = at >1170.279

*gen size = 1 if at>1170.279
*replace size=0 if size==.

ttest tobin,by(size)

ttest roa, by (size)

ttest stg_emph, by (size)

ttest Leverage, by(size)

regress roa npa Leverage opt_margin tobin chapter7 at xrd xad HHI_sic3, robust

*Chapter 2

gen sic1 = int(sic3/100)

regress roa npa Leverage opt_margin tobin chapter7 at xrd xad HHI_sic3 i.sic1, robust

gen hightech=1 if sic==2833|sic==2836 |sic==2836 |sic== 2835|sic==3661 |sic==2834 |sic== 8731 |sic== 3845|sic==3845 |sic==3826

replace hightech=0 if hightech==.

tab hightech

ttest npa , by(hightech)
ttest xrd, by(hightech)
ttest xad, by(hightech)
ttest mkt_share3, by(hightech)
ttest opt_margin, by(hightech)
ttest tobin, by(hightech)
ttest HHI_sic3, by(hightech)

* Logistic

*gen creative if stg_emph>0
gen creative = stg_emph>0

tab creative

logit creative Leverage roa size opt_margin mkt_share3 hightech, robust
estat ic

predict prob_creative_1, pr

sum prob_creative_1

logit creative Leverage roa size opt_margin mkt_share3 hightech i.sic1, robust
estat ic

predict prob_creative_2, pr

*tab prob_creative_2
sum prob_creative_2

logit creative Leverage roa size opt_margin mkt_share3 hightech i.sic1,or robust

(For leverage: probability of a firm being creative is 0.38 time as probability of the firm being non-creative
(when leverage increases by 1 standard deviation, probability of a firm being Creative is .38 of what it
was before (it becomes much lower))

For market share: probability of a firm being creative is .32 time as probability of the firm being non-
creative (when market share increases by 1 standard deviation, probability of a firm being Creative is .32
of what it was before (it becomes much lower))

Compared to industry 0, industry 3 has a much higher probability of being creative, while industry 6 has a
much lower probability of being creative. The rest have the same odds as industry 0.)

* Panel 

xtset brand

sum

xtreg sale reportcount price review xrd xad i.year qualitycontrol WarrantyAmount, fe

(Brands with less number of recalls and higher review score had larger sales.
Sales was also higher in 2001, 2003, 2004, 2006, 2008, and 2010 compared to year 2000. However, the
rest of the years were similar to 2000.)

estimate store fixed


xtreg sale reportcount price review xrd xad i.year qualitycontrol WarrantyAmount, re

estimate store random

hausman fixed random, sigmamore

(When this test is significant, we have to use Fixed model
Null hypotheses is that random effect is as good as fixed effect.
However, p-value is .019 <.05  we reject this hull hypothesis)

egen zreportcount= std(reportcount), mean(0) std(1)
egen zprice = std(price), mean(0) std(1)
egen zreview = std(review), mean(0) std(1)
egen zxrd = std(xrd), mean(0) std(1)
egen zxad = std(xad), mean(0) std(1)
egen zquality = std(qualitycontrol), mean(0) std(1)
egen zwarranty = std(WarrantyAmount), mean(0) std(1)

xtreg sale zreportcount zprice zreview zxrd zxad zquality zwarranty i.year , fe

(Significant variables are recall and review  the coefficient for review is larger review score has the
largest effect
To explain more, we need to know the standard deviation of these variables (the actual ones not the
unit-less ones))

sum review reportcount

(1 SD increase in recalls decreases sales by 115.64 Million dollars  If recall increases by 4 annually,
sales decreases by 115.64 million dollars
1 SD increase in review scores increases sales by 217.92 Million dollars  If review score on average
goes up by .59 points, sales increases by 217.92 million dollars
)

* Logit in Panel

gen recall = reportcount>0

tab recall

xtlogit recall price review xrd xad qualitycontrol WarrantyAmount i.year,fe

estimate store fixed_logit


xtlogit recall price review xrd xad qualitycontrol WarrantyAmount i.year,re

estimate store random_logit

hausman fixed_logit random_logit

(P-value of Hausman test is larger than .05 (p-value=.1982)  we accept the H0  random effect model
is as good as Fixed effect model  we go with random effect model which has more information and
more degrees of freedom (also, doesn't throw out 114 of our data points due to time-invariant fixed
variables)


* Consulting add variables
(What is the estimated sale turnover for brand 11 in 2019?
b) What is the probability of having recalls for brand 11 in 2019?)
* Linear
sum reportcount if brand==11 & year >=2016

xtreg sale reportcount price review xad xrd qualitycontrol WarrantyAmount i.year, re

predict est_sale_11, xb 
* xb fo predicted value pr for probability

*Logistic

xtlogit recall price review xad xrd qualitycontrol WarrantyAmount i.year, re

predict est_logit_11, pr 



