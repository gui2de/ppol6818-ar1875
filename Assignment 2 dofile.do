
**Question1

if c(username) == "jacob" {
    global wd "C:\Users\jacob\OneDrive\Desktop\PPOL_6818"
}

if c(username) == "aneysharoy" { 
    global wd "/Users/aneysharoy/Desktop/Georgetown stuff/Spring Semester/Experimental Design Methods"
}

// Set global variables for dataset locations
global q1_psle_raw "$wd/week_05/03_assignment/01_data/q1_psle_student_raw.dta" 

// Load the dataset (note the quotes around the macro)
use "$q1_psle_raw", clear

//The variable s contains the raw HTML-like data.

//We split it at each "</TD></TR>" tag.

split s, parse("</TD></TR>") generate(seg)
drop s seg1
 
// Reshape: Convert the Split Chunks from Wide to Long Format. This puts each record chunk into its own observation
 
gen rec_index = _n
reshape long seg, i(rec_index) j(chunk_idx)
drop rec_index chunk_idx
drop if seg == ""
split seg, parse("</TD>") generate(col)
drop seg
gen sch_code = ""
replace sch_code = regexs(1) if regexm(col1, "([A-Z0-9]+)-[0-9]+")
drop if sch_code == ""
gen cand_id = regexs(2) if regexm(col1, "([A-Z0-9]+)-([0-9]+)")
replace cand_id = regexs(2) if regexm(col1, "([A-Z0-9]+)-([0-9]+)")
 gen prem_num = ""
 
 quietly forvalues obs = 1/`=_N' {
    if regexm(col2[`obs'], "[0-9]{11}") {
        replace prem_num = regexs(0) in `obs'
    }
}

 gen sex = ""
 
quietly forvalues idx = 1/`=_N' {
    if regexm(col3[`idx'], "(?<=>)(M|F)(?=<)") {
        replace sex = regexs(0) in `idx'
    }
}

gen full_name = ""

quietly forvalues r = 1/`=_N' {
    if regexm(col4[`r'], "(?<=<P>)(.*?)(?=</FONT>)") {
        replace full_name = regexs(0) in `r'
    }
}


 gen subj_line = ""
 
quietly forvalues i = 1/`=_N' {
    if regexm(col5[`i'], "(?<=>K)(.*?)(?=</FONT>)") {
        replace subj_line = regexs(0) in `i'
    }
}

. replace subj_line = "K" + subj_line


forvalues c = 1/5 {
    drop col`c'
}

. split subj_line, parse(", ")

. drop subj_line

. gen row_id = _n

reshape long subj_line, i(row_id) j(subj_id)
split subj_line, parse("- ")
drop subj_line
drop if subj_line1 == ""
replace subj_line1 = trim(subj_line1)
encode subj_line1, gen(subj_label)
drop subj_line1 subj_id
reshape wide subj_line2, i(row_id) j(subj_label)
rename subj_line21 average
rename subj_line22 english
rename subj_line23 hisabati
rename subj_line24 kiswahili
rename subj_line25 maarifa
rename subj_line26 science
rename subj_line27 uraia
drop row_id
order sch_code cand_id sex prem_num full_name kiswahili english maarifa hisabati science uraia average



**Question2

if c(username) == "jacob" {
    global wd "C:\Users\jacob\OneDrive\Desktop\PPOL_6818"
}

if c(username) == "aneysharoy" { 
    global wd "/Users/aneysharoy/Desktop/Georgetown stuff/Spring Semester/Experimental Design Methods"
}

clear all
set more off

* Define File Paths
global q2_pop_density "/Users/aneysharoy/Desktop/Georgetown stuff/Spring Semester/Experimental Design Methods/week_05/03_assignment/01_data/q2_CIV_populationdensity.xlsx"
global q2_CIV_Section_0 "/Users/aneysharoy/Desktop/Georgetown stuff/Spring Semester/Experimental Design Methods/week_05/03_assignment/01_data/q2_CIV_Section_0.dta"

* Import Population Density Data
import excel "$q2_pop_density", firstrow clear
keep if strpos(NOMCIRCONSCRIPTION, "DEPARTEMENT") > 0
drop SUPERFICIEKM2 POPULATION
rename NOMCIRCONSCRIPTION department
rename DENSITEAUKM density

replace department = subinstr(department, "DEPARTEMENT DE", "", .)
replace department = subinstr(department, "DEPARTEMENT DU", "", .)
replace department = subinstr(department, "DEPARTEMENT D'", "", .)

replace department = trim(department)
replace department = lower(department)
drop if department == "gbeleban"
replace department = "arrha" if department == "arrah"

tempfile pop_density
save `pop_density', replace

* Load the Household Survey Data
use "$q2_CIV_Section_0", clear
decode b06_departemen, gen(department)

* Merge with Population Density Data
merge m:1 department using `pop_density'
tab _merge
drop _merge


**Question3

if c(username) == "jacob" {
    global wd "C:\Users\jacob\OneDrive\Desktop\PPOL_6818"
}

if c(username) == "aneysharoy" { 
    global wd "/Users/aneysharoy/Desktop/Georgetown stuff/Spring Semester/Experimental Design Methods"
}

clear
global q3_GPS_Data "/Users/aneysharoy/Desktop/Georgetown stuff/Spring Semester/Experimental Design Methods/week_05/03_assignment/01_data/q3_GPS Data.dta"
ssc install geodist, replace

forvalues i = 1/19 {
	
	if `i' == 1 {
		use "$q3_GPS_Data", clear
		sort latitude
		rename * b_*
		keep in 1
		cross using "$q3_GPS_Data"
	}
	else {
		use "$q3_GPS_Data", clear
		merge 1:1 id using "`enum'"
		keep if _merge == 1
		drop _merge enumerator
		tempfile remaining
		save "`remaining'", replace
		sort latitude 
		rename * b_*
		keep in 1
		cross using "`remaining'"
	}

	geodist b_latitude b_longitude latitude longitude, generate(distance)
	drop b_age b_female b_latitude b_longitude latitude longitude age female
	sort distance 
	
	count 
	if `r(N)' >= 6 {
		keep if _n <= 6
	}
	else if `r(N)' <= 6 {
		keep if _n <= `r(N)'
	}
	
	drop b_id distance
	
	gen enumerator = `i'
	
	if `i' == 1 {
		tempfile enum
		save "`enum'", replace
	}
	else {
		append using "`enum'"
		save "`enum'", replace
	}
}

use "`enum'", clear 
merge 1:1 id using "$q3_GPS_Data"

graph twoway scatter latitude longitude, by(enumerator)


**Question4

if c(username) == "jacob" {
    global wd "C:\Users\jacob\OneDrive\Desktop\PPOL_6818"
}

if c(username) == "aneysharoy" { 
    global wd "/Users/aneysharoy/Desktop/Georgetown stuff/Spring Semester/Experimental Design Methods"
}

clear all
set more off

//Import the dataset
import excel using "/Users/aneysharoy/Desktop/Georgetown stuff/Spring Semester/Experimental Design Methods/week_05/03_assignment/01_data/q4_Tz_election_2010_raw.xls", sheet("Sheet1") cellrange(A5:K7927) firstrow clear

//Drop unwanted column (assuming K is an unnecessary variable)
capture drop K 

//Check the unique values in the POLITICALPARTY variable
tab POLITICALPARTY

//Replace "UN OPPOSSED" with 0 in TTLVOTES
replace TTLVOTES = "0" if TTLVOTES == "UN OPPOSSED"

//Ensure TTLVOTES is numeric
destring TTLVOTES, replace

//Define the list of parties
local parties "AFP APPT CCM CHADEMA CHAUSTA CUF DP JAHAZI MAKIN NCCR NLD NRA SAU TADEA TLP UDP UMD UPDP"

//Generate vote count variables for each party
foreach party of local parties {
    gen Votes_`party' = .
    replace Votes_`party' = TTLVOTES if POLITICALPARTY == "`party'"
}

//Drop the first row if necessary
drop in 1

//Fill in missing values for REGION, DISTRICT, CONSTITUENCY, and WARD
foreach var in REGION DISTRICT COSTITUENCY WARD {
    replace `var' = `var'[_n-1] if missing(`var')
}

//Fix the votes_other variable (if needed)
gen votes_other = 581 + 306 if WARD == "NANGANDO"

//Count the number of candidates per ward
bysort WARD: egen candidate_number = count(CANDIDATENAME)

//Ensure missing values in vote variables are filled correctly
foreach var of varlist Votes_* {
    by WARD (CANDIDATENAME), sort: replace `var' = `var'[_n-1] if missing(`var')
    by WARD (CANDIDATENAME), sort: replace `var' = `var'[_n+1] if missing(`var')
}

//Convert vote variables to numeric
destring Votes_*, replace

//Compute total votes per ward
bysort WARD: egen Total_Votes = sum(TTLVOTES)

//Remove duplicate WARD entries (ensuring only one row per ward)
duplicates drop WARD, force

//Sort the dataset
sort REGION DISTRICT COSTITUENCY WARD

//Drop unnecessary variables
drop CANDIDATENAME SEX G POLITICALPARTY ELECTEDCANDIDATE

//Generate a unique ward ID
gen ward_id = _n


order REGION DISTRICT COSTITUENCY WARD candidate_number Total_Votes ward_id Votes_*


foreach var in REGION DISTRICT COSTITUENCY WARD {
    replace `var' = lower(`var')
    rename `var' `=lower("`var'")'
}


**Question5

if c(username) == "jacob" {
    global wd "C:\Users\jacob\OneDrive\Desktop\PPOL_6818"
}

if c(username) == "aneysharoy" { 
    global wd "/Users/aneysharoy/Desktop/Georgetown stuff/Spring Semester/Experimental Design Methods"
}

clear all
set more off

global ward "/Users/aneysharoy/Desktop/Georgetown stuff/Spring Semester/Experimental Design Methods/week_05/03_assignment/01_data/q5_school_location.dta"
global q5_school "/Users/aneysharoy/Desktop/Georgetown stuff/Spring Semester/Experimental Design Methods/week_05/03_assignment/01_data/q5_psle_2020_data.dta"
global output "/Users/aneysharoy/Desktop/Georgetown stuff/Spring Semester/Experimental Design Methods/week_05/03_assignment/01_data/q5_PSLE_with_wards.dta"

use "$ward", clear  
foreach var in NECTACentreNo region_name district_name schoolname {
    replace `var' = trim(lower(`var'))
}
duplicates tag NECTACentreNo, gen(dup)
drop if NECTACentreNo == "n/a" | dup > 0  
drop dup  

tempfile loc
save `loc'

use "$q5_school", clear  
foreach var in schoolname region_name district_name {
    replace `var' = trim(lower(`var'))
}

* Extract NECTACentreNo if it exists in schoolname
gen NECTACentreNo = regexs(0) if regexm(schoolname, "[A-Z0-9]+$")
replace NECTACentreNo = trim(lower(NECTACentreNo))

* If no NECTACentreNo extracted, keep schoolname for fuzzy matching
gen school_match_name = schoolname

tempfile school_temp
save `school_temp'

merge 1:1 NECTACentreNo using `loc'
tab _merge  

* If some matches are found, keep matched data
keep if _merge == 3  
drop _merge

* If no matches found, fallback to fuzzy matching
count
if r(N) == 0 {
    use `school_temp', clear
    merge m:1 school_match_name using `loc'
    tab _merge
    keep if _merge == 3
    drop _merge
}

save "$output", replace  





