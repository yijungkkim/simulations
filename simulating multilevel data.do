**single level simulation
**https://blog.stata.com/2014/07/18/how-to-simulate-multilevellongitudinal-data/
clear
set obs 500
gen e = rnormal(0,5) // error term
gen y = 70 + e
list y e in 1/5
reg y
mixed y, stddev


**two level simulation
/*
Start with the top level of the data hierarchy.
Create variables for the level ID and its random effect.
Expand the data by the number of observations within that level.
Repeat steps 2 and 3 until the bottom level is reached.
*/
clear
set obs 2 // two classrooms
gen classroom = _n
gen u_i = rnormal(0,3) // each classroom's random effect
list
expand 2 // each classroom has two children
list
bysort classroom: gen child = _n
gen e_ij = rnormal(0,5) // each child's residual
list
gen y = 70 + u_i + e_ij
list y classroom u_i child e_ij, sepby(classroom)


**three level
clear
set obs 2
gen school = _n
gen u_i = rnormal(0,2)
list school u_i
expand 2
bysort school: gen classroom = _n
gen u_ij = rnormal(0,3)
list school u_i classroom u_ij, sepby(school)
*now creating unbalanced data
expand 3 if school ==2 & classroom==2
expand 2 if !(school==2 & classroom==2)
*or 16 to 25 students in each classrooms
expand 16+int((25-16+1)*runiform())

bysort school classroom: gen child = _n
gen e_ijk = rnormal(0,5)
gen y = 70 + u_i + u_ij + e_ijk
list y school u_i classroom u_ij child e_ijk, sepby(classroom)


**testing of 3-level data
. clear
. set obs 6
. generate school = _n
. generate u_i = rnormal(0,2)
. expand 10
. bysort school: generate classroom = _n
. generate u_ij = rnormal(0,3)
. expand 16+int((25-16+1)*runiform())
. bysort school classroom: generate child = _n
. generate e_ijk = rnormal(0,5)
. generate y = 70 + u_i + u_ij + e_ijk
mixed y || school: || classroom: , stddev

**generating covariate for 3-level
. clear
. set obs 6
. generate school = _n // level 3
. generate u_i = rnormal(0,2)
. generate urban = runiform()<0.50 // urban, school level var equals 1 if the school is located in an urban area ans equals 0 otherwise. Here we assigned schools to one of the two groups with equal probability (runiform() <0.50)
. expand 10 // level 2
. bysort school: generate classroom = _n
. generate u_ij = rnormal(0,3)
. bysort school: generate teach_exp = 5+int((20-5+1)*runiform()) // teacher's years of experience with a uniform distribution ranging from 5-20 years
. expand 16+int((25-16+1)*runiform()) // level 1
. bysort school classroom: generate child = _n
. generate e_ijk = rnormal(0,5)
. generate temprand = runiform() // uniformly distributed random variable, on the interval [0,1]
. egen mother_educ = cut(temprand), at(0,0.5, 0.9, 1) icodes // children whose value of temprand is in the interval [0,0.5) will be assigned to mother_educ==0, children whose value of temprand is in the interval [0.5,0.9) will be assigned to mother_educ==1, and children whose value of temprand is in the interval [0.9,1) will be assigned to mother_educ==2.
. label define mother_educ 0 "HighSchool" 1 "College" 2 ">College"
. label values mother_educ mother_educ
 tabulate mother_educ, generate(meduc) // created indicator variables for each category of mother_educ
 summarize meduc*
generate score = 70+ (-2)*urban ///
        + 1.5*teach_exp ///
        + 0*meduc1 ///
        + 2*meduc2 ///
        + 5*meduc3 ///
        + u_i + u_ij + e_ijk

mixed score urban teach_exp i.mother_educ  || school: ||  classroom: , stddev baselevel