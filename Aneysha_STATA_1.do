 
//Question 1(a)

global wd "/Users/aneysharoy/Desktop/Georgetown stuff/Spring Semester/Experimental Design Methods/week_03/04_assignment/01_data"
use "$wd/q1_data/student.dta", clear
rename primary_teacher teacher
merge m:1 teacher using "$wd/q1_data/teacher.dta", keepusing(school)
tab _merge
drop if _merge == 1   
drop _merge
merge m:1 school using "$wd/q1_data/school.dta", keepusing(loc)
tab _merge
drop if _merge == 1
drop _merge
keep if loc == "South"
sum attendance

**    Variable |        Obs        Mean    Std. dev.       Min        Max
**-------------+---------------------------------------------------------
**  attendance |      1,181    177.4776    3.140854        158        180


//Question 1(b) 

global wd "/Users/aneysharoy/Desktop/Georgetown stuff/Spring Semester/Experimental Design Methods/week_03/04_assignment/01_data/q1_data"
use "$wd/student.dta", clear
rename primary_teacher teacher
merge m:1 teacher using "$wd/teacher.dta", keepusing(subject school)
tab _merge
drop if _merge == 1    
drop _merge
merge m:1 school using "$wd/school.dta", keepusing(level)
tab _merge
drop if _merge == 1
drop _merge
keep if level == "High"
merge m:1 subject using "$wd/subject.dta", keepusing(tested)
tab _merge
drop if _merge == 1
drop _merge
gen taught_tested = (tested == 1)
sum taught_tested

**    Variable |        Obs        Mean    Std. dev.       Min        Max
**-------------+---------------------------------------------------------
**taught_tes~d |      1,380     .442029     .496808          0          1



//Question 1(c)
global wd "/Users/aneysharoy/Desktop/Georgetown stuff/Spring Semester/Experimental Design Methods/week_03/04_assignment/01_data/q1_data"
use "$wd/student.dta", clear
rename primary_teacher teacher
merge m:1 teacher using "$wd/teacher.dta", keepusing(subject school)
tab _merge
drop if _merge == 1    
drop _merge
merge m:1 school using "$wd/school.dta", keepusing(gpa)
tab _merge
drop if _merge == 1
drop _merge
sum gpa


**    Variable |        Obs        Mean    Std. dev.       Min        Max
**-------------+---------------------------------------------------------
**         gpa |      4,490     3.60144      .23159   2.974333   3.769334



**Question 2(a)

global wd "/Users/aneysharoy/Desktop/Georgetown stuff/Spring Semester/Experimental Design Methods/week_03/04_assignment/01_data"
use "$wd/q2_village_pixel.dta", clear
. bysort pixel: egen min_payout = min(payout)
. bysort pixel: egen max_payout = max(payout)
. gen pixel_consistent = (min_payout == max_payout)
. list pixel payout min_payout max_payout pixel_consistent in 1/20
. tab pixel_consistent
**pixel_consi |
**      stent |      Freq.     Percent        Cum.
**------------+-----------------------------------
**          1 |        958      100.00      100.00
**------------+-----------------------------------
**      Total |        958      100.00

**Question 2(b)
. bysort village pixel: gen pixeltag = _n == 1
. bysort village: egen distinct_pixels = total(pixeltag)
. gen pixel_village = (distinct_pixels > 1)
//pixel_villa |
//         ge |      Freq.     Percent        Cum.
//------------+-----------------------------------
//          0 |        834       87.06       87.06
//          1 |        124       12.94      100.00
//------------+-----------------------------------
//      Total |        958      100.00


**Question 2(c)
. bysort village: egen min_payout_vil = min(payout)
. bysort village: egen max_payout_vil = max(payout)
. gen village_category = 1
. replace village_category = 2 if distinct_pixels > 1 & (min_payout_vil == max_payout_vil)
. replace village_category = 3 if distinct_pixels > 1 & (min_payout_vil != max_payout_vil)
. tab village_category
//village_cat |
//      egory |      Freq.     Percent        Cum.
//------------+-----------------------------------
//          1 |        834       87.06       87.06
//          2 |         50        5.22       92.28
//          3 |         74        7.72      100.00
//------------+-----------------------------------
//      Total |        958      100.00

**Question 3
global wd "/Users/aneysharoy/Desktop/Georgetown stuff/Spring Semester/Experimental Design Methods/week_03/04_assignment"
use "$wd/01_data/q3_proposal_review.dta", clear
. egen r1_mean = mean(Review1Score), by(Rewiewer1)
. egen r1_sd   = sd(Review1Score), by(Rewiewer1)
. gen stand_r1_score = (Review1Score - r1_mean) / r1_sd
. egen r2_mean = mean(Reviewer2Score), by(Reviewer2)
. egen r2_sd   = sd(Reviewer2Score), by(Reviewer2)
. gen stand_r2_score = (Reviewer2Score - r2_mean) / r2_sd
. egen r3_mean = mean(Reviewer3Score), by(Reviewer3)
. egen r3_sd   = sd(Reviewer3Score), by(Reviewer3)
. gen stand_r3_score = (Reviewer3Score - r3_mean) / r3_sd
. gen average_stand_score = (stand_r1_score + stand_r2_score + stand_r3_score) / 3
. egen rank = rank(-average_stand_score)
. drop r1_mean r1_sd r2_mean r2_sd r3_mean r3_sd
. br

//Question 4

global wd "/Users/aneysharoy/Desktop/Georgetown stuff/Spring Semester/Experimental Design Methods/week_03/04_assignment"
global excel_t21 "$wd/01_data/q4_Pakistan_district_table21.xlsx"


tempfile table21
clear
save "`table21'", replace emptyok


forvalues i = 1/135 {
    import excel "$excel_t21", sheet("Table `i'") firstrow clear allstring
    display as error "Processing sheet: `i'"
    
    * Keep only the row(s) where the target variable contains "18 AND"
    keep if regexm(TABLE21PAKISTANICITIZEN1, "18 AND")
    keep in 1  // if there are multiple matches, only keep the first
    rename TABLE21PAKISTANICITIZEN1 table21
    
    * Create a variable to record the sheet (district) number
    gen sheet = `i'
    
    * Append the cleaned observation to the tempfile and save
    append using "`table21'"
    save "`table21'", replace
}


use "`table21'", clear
format %40s table21 B C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC


replace table21 = "18 AND ABOVE"

local colList "B C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC"
local ncols : word count `colList'


forvalues i = 1/`=`ncols' - 1' {
    local cur : word `i' of `colList'
    forvalues j = `=`i' + 1'/`ncols' {
        local nxt : word `j' of `colList'
        replace `cur' = `nxt' if missing(`cur') & !missing(`nxt')
        replace `nxt' = "" if `cur' == `nxt'
    }
}

*--- Drop Unneeded Columns (Keep only up to column M) ---*
drop N O P Q R S T U V W X Y Z AA AB AC

*--- Replace Dashes with Missing in Columns B to M ---*
local cols_BtoM "B C D E F G H I J K L M"
foreach var of local cols_BtoM {
    capture confirm string variable `var'
    if !_rc {
        replace `var' = "" if `var' == "-"
    }
}

gen K_backup = K
gen L_backup = L

gen double K_clean = real(regexs(1)) if regexm(K, "([0-9]+)")
replace K_clean = . if missing(K_clean)
gen double L_clean = real(regexs(1)) if regexm(L, "([0-9]+)")
replace L_clean = . if missing(L_clean)

drop K L
rename K_clean K
rename L_clean L
drop K_backup L_backup

*--- 10. Convert Variables B to M from String to Numeric ---*
foreach var of local cols_BtoM {
    capture confirm string variable `var'
    if !_rc {
        * Create a numeric version only if the string is a valid number
        gen double `var'_num = real(`var') if regexm(`var', "^-?[0-9]+(\.[0-9]+)?")
        
        * Check for any values that failed conversion
        count if missing(`var'_num) & !missing(`var')
        if r(N) > 0 {
            di as error "`var' contains non-numeric values that couldn't be converted."
        }
        
        drop `var'
        rename `var'_num `var'
    }
}

order table21 sheet B C D E F G H I J K L M

* Rename variables for clarity
rename table21 age_group
label variable age_group "Age Group"

rename sheet district_code
label variable district_code "District Code"

rename B overall_total_pop
label variable overall_total_pop "Overall Total Population"

rename C overall_card_obtaianed
label variable overall_card_obtaianed "Overall CNI Card Obtained"

rename D overall_card_notobtaianed
label variable overall_card_notobtaianed "Overall CNI Card Not Obtained"

rename E m_total_pop
label variable m_total_pop "Male Total Population"

rename F m_card_obtaianed
label variable m_card_obtaianed "Male CNI Card Obtained"

rename G m_card_notobtaianed
label variable m_card_notobtaianed "Male CNI Card Not Obtained"

rename H f_total_pop
label variable f_total_pop "Female Total Population"

rename I f_card_obtaianed
label variable f_card_obtaianed "Female CNI Card Obtained"

rename J f_card_notobtaianed
label variable f_card_notobtaianed "Female CNI Card Not Obtained"

rename K t_total_pop
label variable t_total_pop "Transgender Total Population"

rename L t_card_obtaianed
label variable t_card_obtaianed "Transgender CNI Card Obtained"

rename M t_card_notobtaianed
label variable t_card_notobtaianed "Transgender CNI Card Not Obtained"

//Question 5
. global wd "/Users/aneysharoy/Desktop/Georgetown stuff/Spring Semester/Experimental Design Methods/week_03/04_assignment/01_data"
. use "$wd/q5_Tz_student_roster_html.dta", clear
. rename s raw_html
. gen cleaned_html = raw_html
. replace cleaned_html = regexr(cleaned_html, "[ ]+", " ")
. gen num_student = .
. replace num_student = real(regexs(1)) if regexm(cleaned_html, "WALIOFANYA MTIHANI : ([0-9]+)")
. gen school_avg = .
. replace school_avg = real(regexs(1)) if regexm(cleaned_html, "WASTANI WA SHULE   : ([0-9\.]+)")
. gen schl_rank = .
. replace schl_rank = real(regexs(1)) if regexm(cleaned_html, "NAFASI YA SHULE KWENYE KUNDI LAKE KIHALMASHAURI: ([0-9]+)")
. gen schl_reg_rank = .
. replace schl_reg_rank = real(regexs(1)) if regexm(cleaned_html, "NAFASI YA SHULE KWENYE KUNDI LAKE KIMKOA  : ([0-9]+)")
. gen schl_nat_rank = .
. replace schl_nat_rank = real(regexs(1)) if regexm(cleaned_html, "NAFASI YA SHULE KWENYE KUNDI LAKE KITAIFA : ([0-9]+)")
. gen schl_name = ""
. replace schl_name = regexs(1) if regexm(cleaned_html, "([A-Za-z ]+) - PS[0-9]+")
. gen schl_code = ""
. replace schl_code = regexs(1) if regexm(cleaned_html, "(PS[0-9]+)")
. drop raw_html cleaned_html
label variable school_avg "School Average Score"
label variable schl_rank "School Rank in Council"
label variable schl_reg_rank "School Rank in Region"
label variable schl_nat_rank "School Rank at National Level"
label variable schl_name "School Name"
label variable schl_code "School Code"

save "tanzania_schl_dataset.dta", replace

