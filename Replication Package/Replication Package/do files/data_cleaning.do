********************************************************************************
******************************* Data Cleaning **********************************
********************************************************************************





******************* Initial *******************
cd "C:\Users\Work PC\Desktop\Replication Package\data"
set more off

import excel "group_voting.xlsx", sheet("Sheet1") clear

* Dropping Variables
drop C O D E F G H I J K L M P Q R T U V Z AA AB AC AD AG AH AM AJ AN AO AP AR AS AT AU AV AW AX AY S X N

* Renaming Variables
rename A p_id_s
rename B p_code
rename W p_decision
rename Y g_id_sub
rename AE g_decision
rename AF final_tick
rename AI sub_n
rename AK state
rename AL treatment
rename AQ static
rename AZ s_n
rename (BA BB BC BD BE BF BG BH BI BJ BK BL BM BN BO BP BQ) (t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17)
rename (BR BS BT BU BV BW BX BY BZ CA CB CC CD CE CF CG CH) (m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 m11 m12 m13 m14 m15 m16 m17)
drop in 1

destring, replace

* Dropping testing data or inactive participants (given the code design, we had to have multiples of 3 even in the individual case)
drop if s_n==1
drop if p_code=="8tt0fzh6"
drop if p_code=="p21hi9lw"
drop if p_code=="8bfnhtsc"
drop if p_code=="4ub1dnyq"
drop if p_code=="y30vug1y"
drop if p_code=="b75t7lhf"
drop if p_code=="fgjxkrb6"

* Dropping Practice Rounds
drop if sub_n==1
drop if sub_n==2
replace sub_n=sub_n-2

* Generating new IDs
gen mid=0
egen p_id=concat(s_n mid mid p_id_s)
drop p_id_s
destring,replace

drop mid

* Generating the Decision Variable, A or B
gen decision=g_decision
replace decision=p_decision if treatment==1
drop p_decision g_decision

* Droping Static Treatments
drop if static==1
drop static

replace final_tick=t1 if treatment==1
gen final_sec=final_tick/5

order s_n sub_n g_id_sub p_id treatment final_sec decision state p_code final_tick
sort s_n sub_n g_id_s p_id

save group_voting.dta, replace





******************* Incorporating Processes Data *******************
cd "C:\Users\Work PC\Desktop\Replication Package\data"

import excel "processes.xlsx", sheet("Sheet1") firstrow clear

reshape long v, i(A) j(final_tick)
rename A sub_n

gen p_static_tick=final_tick
gen g_static_final_tick=final_tick

gen p_static=v

gen g_static=v


forvalues i=1(1)17{
gen t`i'=final_tick
gen v`i'=v
}

drop if sub_n==1
drop if sub_n==2

replace sub_n=sub_n-2

save processes_reshaped.dta, replace

*** Merging with Processes***

cd "C:\Users\Work PC\Desktop\Replication Package\data"
use group_voting.dta, clear

*We temporarily shift final_tick by +1 because in our processes data, time starts at row 1.
replace final_tick=final_tick+1
forvalues i = 1(1)17 {
replace t`i' =t`i'+1
}

merge m:1 sub_n final_tick using processes_reshaped.dta, keepusing(v)
keep if _merge==3
drop _merge

forvalues i=1(1)17{
merge m:1 sub_n t`i' using processes_reshaped.dta, keepusing(v`i')
drop if _merge==2
drop _merge
}

replace final_tick=final_tick-1
forvalues i = 1(1)17 {
replace t`i' =t`i'-1
}

***Back to Group Voting***
gen p=v
replace p=1-v if v<0.5

forvalues i=1(1)17{
gen p`i'=v`i'
replace p`i'=1-v`i' if v`i'<0.5
}


order s_n sub_n g_id_sub p_id treatment final_sec v p final_tick decision state p_code final_tick
sort s_n sub_n g_id_s p_id

save, replace





******************* Merging with Dictator Data *******************
cd "C:\Users\Work PC\Desktop\Replication Package\data"

import excel "dictator_game.xlsx", sheet("Sheet1") firstrow clear

order participantcode playerkept playerrec subsessionround_number

rename participantcode p_code
rename playerkept p_kept
rename playerreceived p_rec
rename subsessionround_number n

keep p_code p_kept p_re n

reshape wide p_kept p_rec, i(p_code) j(n)

save dictator_data.dta, replace

cd "C:\Users\Work PC\Desktop\Replication Package\data"
use group_voting.dta, clear

merge m:m p_code using dictator_data.dta, keepusing(p_kept1 p_kept2 p_rec1 p_rec2)
keep if _merge==3
drop _merge

save group_voting.dta, replace





******************* Merging with Investment Data *******************
cd "C:\Users\Work PC\Desktop\Replication Package\data"

import excel "risk_elicitation.xlsx", sheet("Sheet1") firstrow clear

order sessioncode participantcode playerinvested playerinvestment_paid subsessionround_number

rename participantcode p_code
rename playerinvested p_inv
rename playerinvestment_paid paid
rename subsessionround_number n

order p_code p_inv paid n

keep p_code p_inv paid n

reshape wide p_inv paid, i(p_code) j(n)

save investment_data.dta, replace


cd "C:\Users\Work PC\Desktop\Replication Package\data"
use group_voting.dta, clear

merge m:m p_code using investment_data.dta, keepusing(p_inv1 paid1 p_inv2 paid2)
keep if _merge==3
drop _merge

sort s_n sub_n g_id_s p_id

drop final_tick p_code

*Renormalizing session numbering
replace s_n = s_n - 1

save group_voting.dta, replace







