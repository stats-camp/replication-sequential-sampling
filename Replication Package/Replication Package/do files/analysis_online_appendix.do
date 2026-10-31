********************************************************************************
******************************* Online Appendix ********************************
********************************************************************************


* estout formats regression output for export.
ssc install estout

* cdfplot creates CDF plots of variables.
ssc install cdfplot



************************ Figure 3 and Figure 4 ************************		
cd "C:\Users\Work PC\Desktop\Replication Package\data"
use long_format.dta, clear

*** Figure 3 ***
cd "C:\Users\Work PC\Desktop\Replication Package\output"
twoway (scatter process_v process_time, mcolor(gs14) msize(vsmall)) (scatter v2 process_time, mcolor(edkblue) msize(small)) ///
if process_time<101, ytitle(Posterior) yline(0.19 0.81, lcolor(orange) lwidth(0.1)) ylabel(0.00 0.50 1.00) xtitle(Time in Seconds) ///
xlabel(0 25 50 75 100, nogrid) legend(order(1 "Posterior Probability" 2 "Pivotal Decisions") cols(3)) xsize(12) by(, graphregion(fcolor(none) lcolor(none) ifcolor(none) ilcolor(none))) ///
by(sub_n, cols(5)) subtitle(, nobox) graphregion(fcolor(none) lcolor(none) ifcolor(none) ilcolor(none))
graph export "figure_3_appendix.pdf", as(pdf) replace

*** Figure 4 ***
cd "C:\Users\Work PC\Desktop\Replication Package\output"
twoway (scatter process_v process_time, mcolor(gs14) msize(vsmall)) (scatter v3 process_time, mcolor(edkblue) msize(small)) ///
if process_time<101, ytitle(Posterior) yline(0.19 0.81, lcolor(orange) lwidth(0.1)) ylabel(0.00 0.50 1.00) xtitle(Time in Seconds) ///
xlabel(0 25 50 75 100, nogrid) legend(order(1 "Posterior Probability" 2 "Pivotal Decisions") cols(3)) xsize(12) by(, graphregion(fcolor(none) lcolor(none) ifcolor(none) ilcolor(none))) ///
by(sub_n, cols(5)) subtitle(, nobox) graphregion(fcolor(none) lcolor(none) ifcolor(none) ilcolor(none))
graph export "figure_4_appendix.pdf", as(pdf) replace
*******************************************************************************










************************ Table 1 ************************	
cd "C:\Users\Work PC\Desktop\Replication Package\data"
use group_voting.dta, clear

*Keeping only pivotal votes
gen pivotal_time=max(t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13,t14,t15,t16,t17)

sort s_n sub_n g_id_sub pivotal_time p_id
bysort s_n sub_n g_id_sub: gen g_id=_n

gen keep_these=0
replace keep_these=1 if treatment==1
replace keep_these=1 if treatment==2 & g_id==2 & pivotal_time[_n+1]==.
replace keep_these=1 if treatment==2 & g_id==3 & pivotal_time!=.
replace keep_these=1 if treatment==3 & g_id==3
keep if keep_these==1

gen d_1=0
replace d_1=1 if treatment==1

gen d_2=0
replace d_2=1 if treatment==2

gen d_3=0
replace d_3=1 if treatment==3

gen last_15=0
replace last_15=1 if sub_n>15

gen last_15_1=last_15*d_1
gen last_15_2=last_15*d_2
gen last_15_3=last_15*d_3

gen process=sub_n
replace process=process-15 if process>15
gen slow=0
replace slow=1 if process==1 | process==5 | process==6 | process==7 | process==10 | process==11 | process==12

gen slow_1=slow*d_1
gen slow_2=slow*d_2
gen slow_3=slow*d_3

xtset p_id sub_n

gen s1=t1/5
gen s1_1=s1*d_1
gen s1_2=s1*d_2
gen s1_3=s1*d_3

cd "C:\Users\Work PC\Desktop\Replication Package\output"
eststo clear
eststo: reg p d_2 d_3 last_15_1 last_15_2 last_15_3,   vce(cluster p_id)
eststo: reg p d_2 d_3 slow_1 slow_2 slow_3 last_15_1 last_15_2 last_15_3,  vce(cluster p_id)
eststo: reg p d_2 d_3 slow_1 slow_2 slow_3 if sub_n>15,  vce(cluster p_id)
eststo: xtreg p last_15_1 last_15_2 last_15_3 s1_1 s1_2 s1_3, fe vce(cluster p_id)
eststo: xtreg p s1_1 s1_2 s1_3 if sub_n>15, fe vce(cluster p_id)
esttab using table_1_appendix, order(_cons d_2 d_3 last_15_1 last_15_2 last_15_3) star(* 0.10 ** 0.05 *** 0.01) se addnote("Session-level clustering") replace
*******************************************************************************










************************ Table 2 ************************	
cd "C:\Users\Work PC\Desktop\Replication Package\data"
use group_voting.dta, clear

*The correct state: 0=A  1=B
gen cs=0
replace cs=1 if sub_n==2 | sub_n==3 | sub_n==6 | sub_n==7 | sub_n==8 | sub_n==9 | sub_n==12 | sub_n==16 | sub_n==19 | sub_n==20 | sub_n==25 | sub_n==26 | sub_n==28 | sub_n==29 | sub_n==30

*Group choices
gen gc=0
replace gc=1 if decision=="B"
gen correct=1-abs(gc-cs)					

xtset p_id sub_n

gen process=sub_n
replace process=process-15 if process>15

gen slow=0
replace slow=1 if process==1 | process==5 | process==6 | process==7 | process==10 | process==11 | process==12

gen s_sub_n=slow*sub_n

gen s1=t1/5

browse s_n sub_n g_id_sub p_id treatment final_sec s1 p1
sort s_n sub_n g_id_sub s1

bysort s_n sub_n g_id_sub: gen n=_n if p1!=.
bysort s_n sub_n g_id_sub: egen max_n=max(n)
bysort s_n sub_n g_id_sub: egen m_p1=mean(p1)
gen other=(m_p1*max_n-p1)/(max_n-1) if p1!=.
replace other=m_p1 if p1==.

gen dif=p1-other

sort p_id sub_n

* Regression

cd "C:\Users\Work PC\Desktop\Replication Package\output"
eststo clear
eststo: xtreg p1 sub_n s_sub_n l.correct slow if treatment==1, vce(cluster p_id) fe
eststo: xtreg p1 sub_n s_sub_n l.correct slow if treatment==1 & sub_n<16, vce(cluster p_id) fe
eststo: xtreg p1 sub_n s_sub_n l.correct slow if treatment==1 & sub_n>15, vce(cluster p_id) fe
eststo: xtreg p1 l.dif sub_n s_sub_n l.correct slow if treatment==2, vce(cluster p_id) fe
eststo: xtreg p1 l.dif sub_n s_sub_n l.correct slow if treatment==2 & sub_n<16, vce(cluster p_id) fe
eststo: xtreg p1 l.dif sub_n s_sub_n l.correct slow if treatment==2 & sub_n>15, vce(cluster p_id) fe
eststo: xtreg p1 l.dif sub_n s_sub_n l.correct slow if treatment==3, vce(cluster p_id) fe
eststo: xtreg p1 l.dif sub_n s_sub_n l.correct slow if treatment==3 & sub_n<16, vce(cluster p_id) fe
eststo: xtreg p1 l.dif sub_n s_sub_n l.correct slow if treatment==3 & sub_n>15, vce(cluster p_id) fe
esttab using table_2_appendix, star(* 0.10 ** 0.05 *** 0.01) se addnote("Individual-level clustering") replace
*******************************************************************************










************************ Figure 5 ************************	
cd "C:\Users\Work PC\Desktop\Replication Package\data"
use group_voting.dta, clear

keep p_id p1 sub_n treatment

sort p_id sub_n

bysort p_id : egen temp=mean(p1)

keep if sub_n==30
drop sub_n

local midgray "168 168 168"
local darkgray "33 33 33"
local blue "69 113 163"
local orange "201 112 56"

*Individual
cd "C:\Users\Work PC\Desktop\Replication Package\output"
histogram temp if treatment==1, width(.05) xtitle(Posterior) color("`blue'") lcolor("`darkgray'")  xlabel(0.5(0.1)1)
graph export "figure_5_appendix_left.pdf", as(pdf) replace

*Majority
cd "C:\Users\Work PC\Desktop\Replication Package\output"
histogram temp if treatment==2, width(.05) xtitle(Posterior) color("`blue'") lcolor("`darkgray'")  xlabel(0.5(0.1)1)
graph export "figure_5_appendix_middle.pdf", as(pdf) replace

*Unanimity
cd "C:\Users\Work PC\Desktop\Replication Package\output"
histogram temp if treatment==3, width(.05) xtitle(Posterior) color("`blue'") lcolor("`darkgray'")  xlabel(0.5(0.1)1)
graph export "figure_5_appendix_right.pdf", as(pdf) replace
*******************************************************************************










************************ Table 3 ************************
*** First Regression: Majority ***	
*Generating pivotal Simulated Majority Votes
cd "C:\Users\Work PC\Desktop\Replication Package\data"
use simulated_groups.dta, clear

sort iter sub_n g_id_sub t1
bysort iter sub_n g_id_sub: gen n=_n

keep if n==2

drop n iter

rename t1 final_tick
rename p1 p
rename g_id_sub group_id

order sub_n p_id final_tick decision v p group_id treatment

replace treatment=12

tempfile majority_simulated
save `majority_simulated', replace

***
cd "C:\Users\Work PC\Desktop\Replication Package\data"
use group_voting.dta, clear

append using `majority_simulated'

drop if treatment==1
replace treatment=1 if treatment==12

gen d_1=0
replace d_1=1 if treatment==1

*Keeping only pivotal votes
gen pivotal_time=max(t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13,t14,t15,t16,t17)

sort s_n sub_n g_id_sub pivotal_time p_id
bysort s_n sub_n g_id_sub: gen g_id=_n

gen keep_these=0
replace keep_these=1 if treatment==1
replace keep_these=1 if treatment==2 & g_id==2 & pivotal_time[_n+1]==.
replace keep_these=1 if treatment==2 & g_id==3 & pivotal_time!=.
replace keep_these=1 if treatment==3 & g_id==3
keep if keep_these==1

cd "C:\Users\Work PC\Desktop\Replication Package\output"
eststo clear
eststo: reg p d_1 if treatment!=3, vce(cluster p_id)
esttab, star(* 0.10 ** 0.05 *** 0.01) se addnote("Individual-level clustering")
esttab using table_3_appendix_left, star(* 0.10 ** 0.05 *** 0.01) se addnote("Individual-level clustering") replace

*** Second Regression: Unanimity ***
*Generating pivotal Simulated Majority Votes
cd "C:\Users\Work PC\Desktop\Replication Package\data"
use simulated_groups.dta, clear

sort iter sub_n g_id_sub t1
bysort iter sub_n g_id_sub: gen n=_n

keep if n==3

drop n iter

rename t1 final_tick
rename p1 p
rename g_id_sub group_id

order sub_n p_id final_tick decision v p group_id treatment

replace treatment=13

tempfile unanimity_simulated
save `unanimity_simulated', replace

***
cd "C:\Users\Work PC\Desktop\Replication Package\data"
use group_voting.dta, clear

append using `unanimity_simulated'

drop if treatment==1
replace treatment=1 if treatment==13

gen d_1=0
replace d_1=1 if treatment==1

*Keeping only pivotal votes
gen pivotal_time=max(t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13,t14,t15,t16,t17)

sort s_n sub_n g_id_sub pivotal_time p_id
bysort s_n sub_n g_id_sub: gen g_id=_n

gen keep_these=0
replace keep_these=1 if treatment==1
replace keep_these=1 if treatment==2 & g_id==2 & pivotal_time[_n+1]==.
replace keep_these=1 if treatment==2 & g_id==3 & pivotal_time!=.
replace keep_these=1 if treatment==3 & g_id==3
keep if keep_these==1

cd "C:\Users\Work PC\Desktop\Replication Package\output"
eststo clear
eststo: reg p d_1 if treatment!=2, vce(cluster p_id)
esttab using table_3_appendix_right, star(* 0.10 ** 0.05 *** 0.01) se addnote("Individual-level clustering") replace

*Table 3 in the appendix combines the outcome of the above two regressions
*******************************************************************************










************************ Table 4, Table 6, and Table 7************************
*** Preparing Data ***
cd "C:\Users\Work PC\Desktop\Replication Package\data"
use group_voting.dta, clear

*Keeping only the necesairy variables
keep s_n sub_n t1 g_id_sub treatment p_id

*Creating a new id variable
sort treatment p_id
by treatment p_id: gen id = 1 if _n==1
replace id = sum(id)
drop p_id

*Reordering the data
order id sub_n t1 treatment
sort id sub_n

*Generating trigger variable
gen trigger=1

*Generating a new id following the session, round and group id
gen zero=0
egen g_id=concat(s_n zero zero sub_n zero zero g_id_sub)
destring,replace

order g_id
sort g_id t1

*Generating, first, second, third vote indicators
bysort g_id: gen n=_n

*Generating time of first vote
gen first=t1 if n==1
bysort g_id: replace first=first[_n-1] if first==.

*Generating time of second vote
gen second=t1 if n==2
bysort g_id: replace second=second[_n-1] if second==.
bysort g_id: replace second=second[_n+1] if second==.

*Modifying the trigger variable
*We do not want to drop the "third voter" in Majority, as they hold relevant information.
*They see the process, and others votes, and yet, they decide not to vast a vote.
*trigger=2 will indicate "third voters" in Majority.
replace trigger=2 if n==3 & treatment==2
*We replace their "vote casting time" with the one cast from the second voter.
*The data will be relevant only up to that point.
replace t1=t1[_n-1] if n==3 & treatment==2

drop  g_id_sub zero n 

tempfile temp_dynamic
save `temp_dynamic', replace


*** Merging Data ***
cd "C:\Users\Work PC\Desktop\Replication Package\data"
use long_format.dta, clear

*Replacing roudns from 1 to 15, to, 1 to 30.
replace sub_n=sub_n+15 if _n>22515

*Renaming variables
rename process_time t1
replace t1=t1*5
rename process_p p
rename process_slope slope
rename process_std p_std
drop process_v v1 v2 v3

tempfile new_long_format
save `new_long_format', replace

*The code below merges the individual voting data with the features of the processes
gen id=1

*Creating 130 copies of the processes dataset, all 30 processes, for each participant
 local i = 1
 while `i' <130{
      append using `new_long_format'
	  local i = `i' + 1
	  replace id=`i' if id==.
 }

order id sub_n t1

*Adding the information revealing in each round, when the participant cast the vote
merge m:m id sub_n t1 using `temp_dynamic'
drop _merge
replace trigger=0 if trigger==.

*Dropping Observations after the Trigger has been Pulled*
sort id sub_n t1
bysort id sub_n: gen trigger_temp=sum(trigger)
replace trigger_temp=trigger_temp-trigger
drop if trigger_temp>0
drop trigger_temp

*Recall that trigger=2 indicates the "third voters" in Majority
*We want to make sure that we do not count these as "votes cast"
replace trigger=0 if trigger==2

*Polishint Treatment Variable
bysort id: egen temp=max(treatment)
replace treatment=temp
drop temp

*Creating Others Voted Variable
bysort id sub_n: egen temp=max(first)
replace first=temp
drop temp

bysort id sub_n: egen temp=max(second)
replace second=temp
drop temp

gen others_voted=0
replace others_voted=1 if t1>first
replace others_voted=2 if t1>second

drop first second

*Polishint s_n (session) variable
bysort id: egen temp=max(s_n)
replace s_n=temp
drop temp

*Polishing g_id variable
bysort id sub_n: egen temp=max(g_id)
replace g_id=temp
drop temp

tempfile probit_data2
save `probit_data2', replace

********* Regressions *********
use `probit_data2', clear

*Renormalizing Values
*Time
replace t1=t1/(5*60)
*Slope
replace slope=slope*(5*60)
*Variance
replace p_std=p_std*(5)

*Aggregation level*
local tick_aggregation_level=25
egen d = seq(), f(1) t(`tick_aggregation_level')
keep if d==`tick_aggregation_level' | trigger==1
drop d

*** Table 4: Probit Regression: Last 15 Rounds ***
cd "C:\Users\Work PC\Desktop\Replication Package\output"
eststo clear
eststo: probit trigger p t1 if treatment==1 & sub_n>15,  vce(cluster id)
eststo: probit trigger p t1 if treatment==2 & sub_n>15,  vce(cluster id)
eststo: probit trigger p t1 if treatment==3 & sub_n>15,  vce(cluster id)
eststo: probit trigger p t1 slope p_std if treatment==1 & sub_n>15,  vce(cluster id)
eststo: probit trigger p t1 slope p_std if treatment==2 & sub_n>15,  vce(cluster id)
eststo: probit trigger p t1 slope p_std if treatment==3 & sub_n>15,  vce(cluster id)
esttab using table_4_appendix, star(* 0.10 ** 0.05 *** 0.01) se addnote("Individual-level clustering") replace

*** Table 6: Probit Regression (Session-level Clustering) ***
cd "C:\Users\Work PC\Desktop\Replication Package\output"
eststo clear
eststo: probit trigger p t1 if treatment==1,  vce(cluster s_n)
eststo: probit trigger p t1 if treatment==2,  vce(cluster s_n)
eststo: probit trigger p t1 if treatment==3,  vce(cluster s_n)
eststo: probit trigger p t1 slope p_std if treatment==1,  vce(cluster s_n)
eststo: probit trigger p t1 slope p_std if treatment==2,  vce(cluster s_n)
eststo: probit trigger p t1 slope p_std if treatment==3,  vce(cluster s_n)
esttab using table_6_appendix, star(* 0.10 ** 0.05 *** 0.01) se addnote("Individual-level clustering") replace

*Generating variables for Table 7
gen d_2=0
replace d_2=1 if treatment==2

gen p_d_2=p*d_2
gen t1_d_2=t1*d_2
gen slope_d_2=slope*d_2
gen p_std_d_2=p_std*d_2

*** Table 7: Probit Regression (Session-level Clustering) ***
cd "C:\Users\Work PC\Desktop\Replication Package\output"
eststo clear
eststo: probit trigger p t1 p_d_2 t1_d_2 d_2 if treatment!=1,  vce(cluster s_n)
eststo: probit trigger p t1 slope p_std p_d_2 t1_d_2 slope_d_2 p_std_d_2 d_2 if treatment!=1,  vce(cluster s_n)
esttab using table_7_appendix, order(p t1 slope p_std _cons p_d_2 p1_2 t1_d_2 slope_d_2 p_std_d_2 d_2) star(* 0.10 ** 0.05 *** 0.01) se addnote("Individual-level clustering") replace
*******************************************************************************










************************ Table 5 ************************	
*** Regressions ***
*Dynamic Group Level Regressions*
cd "C:\Users\Work PC\Desktop\Replication Package\data"
use group_voting.dta, clear

bysort s_n sub_n g_id_sub: egen a_p_kept1=mean(p_kept1)
bysort s_n sub_n g_id_sub: egen a_p_kept2=mean(p_kept2)
replace a_p_kept1=p_kept1 if treatment==1
replace a_p_kept2=p_kept2 if treatment==1

gen a_p_sent1=200-a_p_kept1
gen a_p_sent2=100-a_p_kept2

bysort s_n sub_n g_id_sub: egen a_p_inv1=mean(p_inv1)
bysort s_n sub_n g_id_sub: egen a_p_inv2=mean(p_inv2)
replace a_p_inv1=p_inv1 if treatment==1
replace a_p_inv2=p_inv2 if treatment==1

gen a_p_not_inv1=200-a_p_inv1
gen a_p_not_inv2=200-a_p_inv2

*Keeping only pivotal votes
gen pivotal_time=max(t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13,t14,t15,t16,t17)

sort s_n sub_n g_id_sub pivotal_time p_id
bysort s_n sub_n g_id_sub: gen g_id=_n

gen keep_these=0
replace keep_these=1 if treatment==1
replace keep_these=1 if treatment==2 & g_id==2 & pivotal_time[_n+1]==.
replace keep_these=1 if treatment==2 & g_id==3 & pivotal_time!=.
replace keep_these=1 if treatment==3 & g_id==3
keep if keep_these==1

gen d_1=0
replace d_1=1 if treatment==1

gen d_2=0
replace d_2=1 if treatment==2

gen d_3=0
replace d_3=1 if treatment==3


gen last_15=0
replace last_15=1 if sub_n>15

gen last_15_1=last_15*d_1
gen last_15_2=last_15*d_2
gen last_15_3=last_15*d_3


*Making both a_p_sent1 and a_p_sent2 have the same (0,200) range
replace a_p_sent2=a_p_sent2*2

gen process=sub_n
replace process=process-15 if process>15

xtset p_id sub_n

gen s1=t1/5
gen s1_1=s1*d_1
gen s1_2=s1*d_2
gen s1_3=s1*d_3

*Alternative Specifications*
cd "C:\Users\Work PC\Desktop\Replication Package\output"
eststo clear
eststo: ivregress 2sls p d_2 d_3 last_15_1 last_15_2 last_15_3 (a_p_sent2 a_p_not_inv2 = a_p_sent1 a_p_not_inv1),  vce(cluster p_id)
eststo: reg p d_2 d_3
eststo: reg p d_2 d_3 last_15_1 last_15_2 last_15_3
eststo: ivregress 2sls p d_2 d_3 last_15_1 last_15_2 last_15_3 (a_p_sent2 a_p_not_inv2 = a_p_sent1 a_p_not_inv1)
eststo: reg p d_2 d_3,  vce(cluster process)
eststo: reg p d_2 d_3 last_15_1 last_15_2 last_15_3,  vce(cluster process)
eststo: ivregress 2sls p d_2 d_3 last_15_1 last_15_2 last_15_3 (a_p_sent2 a_p_not_inv2 = a_p_sent1 a_p_not_inv1),  vce(cluster process)
esttab using table_5_appendix, order(_cons d_2 d_3 last_15_1 last_15_2 last_15_3) star(* 0.10 ** 0.05 *** 0.01) se replace
*******************************************************************************










************************ Figure 6 ************************	
cd "C:\Users\Work PC\Desktop\Replication Package\data"
use group_voting.dta, clear

graph drop _all
cd "C:\Users\Work PC\Desktop\Replication Package\output"
cdfplot p1 if sub_n<=5, by(treatment) legend(order(1 "Individual" 2 "Majority" 3 "Unanimity")) xtitle(Posterior) title("First 5 Rounds", size(medium)) name(graph1)
cdfplot p1 if sub_n<=10, by(treatment) legend(order(1 "Individual" 2 "Majority" 3 "Unanimity")) xtitle(Posterior) title("First 10 Rounds", size(medium)) name(graph2)
cdfplot p1 if sub_n<=15, by(treatment) legend(order(1 "Individual" 2 "Majority" 3 "Unanimity")) xtitle(Posterior) title("First 15 Rounds", size(medium)) name(graph3)
cdfplot p1, by(treatment) legend(order(1 "Individual" 2 "Majority" 3 "Unanimity")) xtitle(Posterior) title("All 30 Rounds", size(medium)) name(graph4)
graph combine graph1 graph2 graph3 graph4, rows(2) cols(2)
graph export "figure_6_appendix.pdf", as(pdf) replace
*******************************************************************************










************************ Table 8 ************************	
cd "C:\Users\Work PC\Desktop\Replication Package\data"
use group_voting.dta, clear

gen d_2=0
replace d_2=1 if treatment==2

cd "C:\Users\Work PC\Desktop\Replication Package\output"
eststo clear
eststo: reg p1 d_2 if sub_n<2,  vce(cluster p_id)
eststo: reg p1 d_2 if sub_n<3,  vce(cluster p_id)
eststo: reg p1 d_2 if sub_n<4,  vce(cluster p_id)
eststo: reg p1 d_2 if sub_n<5,  vce(cluster p_id)
eststo: reg p1 d_2 if sub_n<6,  vce(cluster p_id)
eststo: reg p1 d_2 if sub_n<2,  vce(cluster s_n)
eststo: reg p1 d_2 if sub_n<3,  vce(cluster s_n)
eststo: reg p1 d_2 if sub_n<4,  vce(cluster s_n)
eststo: reg p1 d_2 if sub_n<5,  vce(cluster s_n)
eststo: reg p1 d_2 if sub_n<6,  vce(cluster s_n)
esttab using table_8_appendix, order(d_2 _cons) star(* 0.10 ** 0.05 *** 0.01) se replace
*******************************************************************************











************************ Figure 7 ************************	
cd "C:\Users\Work PC\Desktop\Replication Package\data"
use group_voting.dta, clear
drop p2 t2

sort s_n p_id sub_n

replace t1=t1/5

gen p2=p1[_n+15]
gen t2=t1[_n+15]

keep sub_n p_id p1 t1 t2 p2 treatment

gen dp=p2-p1
gen dt=t2-t1
keep if sub_n<16

gen zero=3
egen new_id=concat(treatment zero zero sub_n)
destring, replace

egen m_dp=mean(dp), by(new_id)
egen m_dt=mean(dt), by(new_id)
egen m_p1=mean(p1), by(new_id)
egen m_p2=mean(p2), by(new_id)
egen m_t1=mean(t1), by(new_id)
egen m_t2=mean(t2), by(new_id)

keep if p_id==2001 | p_id==7003 | p_id==24002

order sub_n

* Graph of Posteriors
cd "C:\Users\Work PC\Desktop\Replication Package\output"
twoway (connected m_p1 sub_n) (connected m_p2 sub_n), by(treatment, cols(3)) ysize(1.5) legend(order(1 "First 15 Rounds" 2 "Last 15 Rounds")) xtitle(Round) ytitle(Posterior)  title("Learning: Posteriors", size(medium))
graph export "figure_7_appendix_top.pdf", as(pdf) replace

*Graph of Time
cd "C:\Users\Work PC\Desktop\Replication Package\output"
twoway (connected m_t1 sub_n) (connected m_t2 sub_n), by(treatment, cols(3)) ysize(1.5) legend(order(1 "First 15 Rounds" 2 "Last 15 Rounds")) xtitle(Round) ytitle(Time) title("Learning: Time", size(medium))
graph export "figure_7_appendix_bottom.pdf", as(pdf) replace
*******************************************************************************










************************ Table 9 ************************	
cd "C:\Users\Work PC\Desktop\Replication Package\data"
use group_voting.dta, clear
	
xtset p_id sub_n

browse s_n sub_n g_id_sub p_id treatment  final_sec t1 p1
sort s_n sub_n g_id_sub t1

bysort s_n sub_n g_id_sub: gen n=_n if p1!=.
bysort s_n sub_n g_id_sub: egen max_n=max(n)
bysort s_n sub_n g_id_sub: egen m_p1=mean(p1)
gen other=(m_p1*max_n-p1)/(max_n-1) if p1!=.
replace other=m_p1 if p1==.

gen dif=p1-other

sort p_id sub_n

cd "C:\Users\Work PC\Desktop\Replication Package\output"
eststo clear
eststo: xtreg p1 sub_n if treatment==1, vce(cluster p_id) fe
eststo: xtreg p1 sub_n if treatment==1 & sub_n<=15, vce(cluster p_id) fe
eststo: xtreg p1 sub_n if treatment==1 & sub_n>15, vce(cluster p_id) fe
eststo: xtreg p1 l.dif sub_n if treatment==2, vce(cluster p_id) fe
eststo: xtreg p1 l.dif sub_n if treatment==2 & sub_n<=15, vce(cluster p_id) fe
eststo: xtreg p1 l.dif sub_n if treatment==2 & sub_n>15, vce(cluster p_id) fe
eststo: xtreg p1 l.dif sub_n if treatment==3, vce(cluster p_id) fe
eststo: xtreg p1 l.dif sub_n if treatment==3 & sub_n<=15, vce(cluster p_id) fe
eststo: xtreg p1 l.dif sub_n if treatment==3 & sub_n>15, vce(cluster p_id) fe
esttab, star(* 0.10 ** 0.05 *** 0.01) se addnote("Individual-level clustering")
esttab using table_9_appendix, star(* 0.10 ** 0.05 *** 0.01) se addnote("Individual-level clustering") replace
*******************************************************************************










************************ Table 10 ************************		
cd "C:\Users\Work PC\Desktop\Replication Package\data"
use group_voting.dta, clear

append using simulated_groups.dta

drop if treatment==1
replace treatment=1 if treatment==111
replace t1=t1/5

replace s_n=iter+100 if s_n==.

keep s_n sub_n g_id_sub p_id treatment t1 p1
sort s_n sub_n g_id_sub t1

bysort s_n sub_n g_id_sub: gen n=_n

gen t2=t1[_n+1]
gen t3=t1[_n+2]
gen p2=p1[_n+1]
gen p3=p1[_n+2]

order s_n sub_n g_id_sub p_id treatment t1 t2 t3 p1 p2 p3

keep if n==1
drop n

gen dp32=p3-p2

gen d3=0
replace d3=1 if treatment==3

gen p2_3=p2*d3

gen last=0
replace last=1 if sub_n>15

gen last_3=last*d3


gen process=sub_n
replace process=process-15 if process>15
gen slow=0
replace slow=1 if process==1 | process==5 | process==6 | process==7 | process==10 | process==11 | process==12
gen slow_3=slow*d3

replace p2=p2-0.5

cd "C:\Users\Work PC\Desktop\Replication Package\output"
eststo clear
eststo: reg dp32 d3 p2 p2_3 last last_3 slow slow_3 if treatment!=2, vce(cluster process)
esttab using table_10_appendix, order(_cons d3 p2 p2_3 last last_3 slow slow_3) star(* 0.10 ** 0.05 *** 0.01) se addnote("Process-level clustering") replace
*******************************************************************************