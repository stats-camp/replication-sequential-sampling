********************************************************************************
******************************* Main Analysis **********************************
********************************************************************************


* estout formats regression output for export.
ssc install estout

* cdfplot creates CDF plots of variables.
ssc install cdfplot



************************ Table 1: Aggregate Behavior ************************
cd "C:\Users\Work PC\Desktop\Replication Package\data"
use group_voting.dta, clear

*** Individual Treatment ***
reg p if treatment==1
reg p if treatment==1 & sub_n>15

reg final_sec if treatment==1
reg final_sec if treatment==1 & sub_n>15

*** Majority Treatment ***
reg p if treatment==2
reg p if treatment==2 & sub_n>15

reg final_sec if treatment==2
reg final_sec if treatment==2 & sub_n>15

*** Unanimity Treatment ***
reg p if treatment==3
reg p if treatment==3 & sub_n>15

reg final_sec if treatment==3
reg final_sec if treatment==3 & sub_n>15
*Table 1 reports the results of all above regressions, which we collect manually
*******************************************************************************









************************ Figure 1: Pulling the Trigger ************************
cd "C:\Users\Work PC\Desktop\Replication Package\data"
use long_format.dta, clear

cd "C:\Users\Work PC\Desktop\Replication Package\output"
twoway (scatter process_v process_time, mcolor(gs14) msize(vsmall)) (scatter v1 process_time, mcolor(edkblue) msize(small)) ///
if process_time<101, ytitle(Posterior) yline(0.19 0.81, lcolor(orange) lwidth(0.1)) ylabel(0.00 0.50 1.00) xtitle(Time in Seconds) ///
xlabel(0 25 50 75 100, nogrid) legend(order(1 "Posterior Probability" 2 "Pivotal Decisions") cols(3)) xsize(12) by(, graphregion(fcolor(none) lcolor(none) ifcolor(none) ilcolor(none))) ///
by(sub_n, cols(5)) subtitle(, nobox) graphregion(fcolor(none) lcolor(none) ifcolor(none) ilcolor(none))
graph export "figure_1.pdf", as(pdf) replace
*******************************************************************************









************************ Table 2: Probability of Voting - Probit Regression ************************
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


cd "C:\Users\Work PC\Desktop\Replication Package\output"
eststo clear
eststo: probit trigger p t1 if treatment==1,  vce(cluster id)
eststo: probit trigger p t1 if treatment==2,  vce(cluster id)
eststo: probit trigger p t1 if treatment==3,  vce(cluster id)
eststo: probit trigger p t1 slope p_std if treatment==1,  vce(cluster id)
eststo: probit trigger p t1 slope p_std if treatment==2,  vce(cluster id)
eststo: probit trigger p t1 slope p_std if treatment==3,  vce(cluster id)
esttab  using table_2, star(* 0.10 ** 0.05 *** 0.01) se addnote("Individual-level clustering") replace
*******************************************************************************










************************ Figure 2: Posterior CDFs and Vote Order the Trigger ************************
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

append using `majority_simulated'
append using `unanimity_simulated'


****** Left Graph ******
cd "C:\Users\Work PC\Desktop\Replication Package\output"
cdfplot p, ///
by(treatment) ///
opt1(legend(cols(3) label(1 "Individual") label(2 "Majority") label(3 "Unanimity") label(4 "Majority Simulated") label(5 "Unanimity Simulated")) ///
graphregion(fcolor(none) lcolor(none) lwidth(none) ifcolor(none) ilcolor(none))) 
graph export "figure_2_left.pdf", as(pdf) replace
******

cd "C:\Users\Work PC\Desktop\Replication Package\data"
use group_voting.dta, clear
append using simulated_groups.dta

sort iter s_n sub_n g_id_sub t1
bysort iter s_n sub_n g_id_sub: gen g_id=_n

gen zero=0
egen new_id=concat(treatment zero zero g_id)
destring,replace
drop zero

drop if treatment==1

replace new_id=1001 if new_id==111001
replace new_id=1002 if new_id==111002
replace new_id=1003 if new_id==111003

drop if new_id==2003


****** Middle Graph ******
cd "C:\Users\Work PC\Desktop\Replication Package\output"
cdfplot p1 if treatment!=3, ///
by(new_id) ///
opt1(legend(cols(3) label(1 "Individual I") label(2 "Individual II") label(3 "Individual III") label(4 "Majority I") label(5 "Majority II")) ///
graphregion(fcolor(none) lcolor(none) lwidth(none) ifcolor(none) ilcolor(none))) 
graph export "figure_2_middle.pdf", as(pdf) replace

****** Right Graph ******
cd "C:\Users\Work PC\Desktop\Replication Package\output"
cdfplot p1 if treatment!=2, ///
by(new_id) ///
opt1(legend(cols(3) label(1 "Individual I") label(2 "Individual II") label(3 "Individual III") label(4 "Unanimity I") label(5 "Unanimity II") label(6 "Unanimity III")) ///
graphregion(fcolor(none) lcolor(none) lwidth(none) ifcolor(none) ilcolor(none))) 
graph export "figure_2_right.pdf", as(pdf) replace
*******************************************************************************










************************ Footnote 16: Kolmogorov-Smirnov test ************************
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

append using `majority_simulated'
append using `unanimity_simulated'


*Keeping only pivotal votes
gen pivotal_time=max(t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13,t14,t15,t16,t17)

sort s_n sub_n g_id_sub pivotal_time p_id
bysort s_n sub_n g_id_sub: gen g_id=_n

gen keep_these=0
replace keep_these=1 if treatment==1
replace keep_these=1 if treatment==2 & g_id==2
replace keep_these=1 if treatment==3 & g_id==3
replace keep_these=1 if treatment==12
replace keep_these=1 if treatment==13

keep if keep_these==1

*Majority vs Simulated Majority
ksmirnov p if treatment==2 | treatment==12, by(treatment)

*Unanimity vs Simulated Unanimity
ksmirnov p if treatment==3 | treatment==13, by(treatment)
*******************************************************************************










************************ Footnote 18 and 20: Performance ************************
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

*Performance Measures
gen g_p_1=p-0.2*(final_sec/60)

gen e_t=((2*p-1)/1.4)*log(p/(1-p))

gen g_p_2=p-0.2*e_t


*Regressions
cd "C:\Users\Work PC\Desktop\Replication Package\output"
eststo clear
eststo: reg g_p_1 ibn.treatment, nocons vce(cluster p_id)
eststo: reg g_p_2 ibn.treatment, nocons  vce(cluster p_id)
esttab using footnote_18_and_20, nostar se addnote("Individual-level clustering") replace
*******************************************************************************










************************ Table 3: Difference in Posterior: Second vs First Voter ************************
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

gen dp21=p2-p1

gen d2=0
replace d2=1 if treatment==2
gen d3=0
replace d3=1 if treatment==3

gen p1_2=p1*d2
gen p1_3=p1*d3

replace p1=p1-0.5

gen process=sub_n
replace process=process-15 if process>15

* Regression
cd "C:\Users\Work PC\Desktop\Replication Package\output"
eststo clear
eststo: reg dp21 d2 d3 p1 p1_2 p1_3, vce(cluster process)
esttab using table_3, order(_cons d2 d3 p1 p1_2 p1_3) star(* 0.10 ** 0.05 *** 0.01) se addnote("Process-level clustering") replace
*******************************************************************************