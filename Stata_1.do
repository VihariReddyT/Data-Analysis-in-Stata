
gen roa = ib/at
label variable roa "Retun on Assets"
gen Leverage = dltt/at
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
sum
pwcorr sale xrd xad Leverage chapter7 ,sig
sum at, detail
gen size = 1 if at>= 1170.279
replace size = 0 if size==


ttest npa, by(hightech)
ttest xrd, by(hightech)
ttest xad, by(hightech)
ttest mkt_share3, by(hightech)
ttest opt_margin, by(hightech)
ttest tobin, by(hightech)
ttest mkt_share3, by(hightech)
ttest hhi_sic3, by(hightech)

gen sic1 = int(sic3/100)
reg roa npa leverage opt_margin tobin chapter7 at xrd xad hhi_sic3 i.sic1, beta robust
reg roa hightech npa leverage opt_margin tobin chapter7 at xrd xad hhi_sic3 i.sic1, beta robust

estat ic

logit chapter7 xrd xad sale ebit dp npa, vce(robust)
logit chapter7 xrd xad sale ebit dp npa, or vce(robust)
logit chapter7 sale ebit dp npa stg_emp leverage tobin size, or vce(robust)
predict prob_log , pr

sum prob_log
sort prob_log

gen creative = stg_emph >0
tab creative
logit creative leverage roa size opt_margin mkt_share3 hightech, robust
estat ic
predict prob_creative_1, pr
sum prob_creative_1
logit creative leverage roa size opt_margin mkt_share3 hightech i.sic1, robust
estat ic
predict prob_creative_2, pr
sum prob_creative_2
logit creative leverage roa size opt_margin mkt_share3 hightech i.sic1, or robust
sum prob_creative_2, detail
corr creative stg_emph
corr xad xrd stg_emph


xad, xrd, size, hightech, hhi_sic3, leverage, npa and sic1
sum hhi_sic3 if sic3==737