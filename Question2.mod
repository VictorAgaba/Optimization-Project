# This model optimizes the assigning of engineering students to
# DTC project teams question 2
# Phase 2 -> major distribution

# Group: Jessie Lanin, Victor Agaba, Emily Wei

# Set of students
set STUDS;
# Set of project teams
set PROJ;
# Set of major combinations
set MAJORS;
# Set of genders
set GENDERS;

# Number of students per team project
param num;
# Rating per student per team project
param rating{STUDS, PROJ};
# GPA per student
param gpa{STUDS};
# GPA bounds
param gpa_lower;
param gpa_upper;
# Student major - 1 for the major per student, 0 otherwise
param major{STUDS, MAJORS};
# Minimum number of students per team in IE major combination
param ie_min;
# Student gender - 1 per gender, 0 otherwise
param gender{STUDS, GENDERS};
# Gender limit per group
param gender_limit;
# Happiness parameter
param happiness;

# Binary decision var: 1 if student i is in team t, 0 otherwise
var s{STUDS, PROJ} binary;

# By minimizing the second part of the gini equation -> maximizing gini index
minimize major_proportion: sum{p in PROJ} sum{j in MAJORS} (sum{i in STUDS} major[i,j]*s[i,p])^2;

# These are the constraints

# Happiness constraint
subject to happinessconstraint:
	sum{i in STUDS, p in PROJ} rating[i,p]*s[i,p] >= happiness;

# Number of students per team
subject to studentnumberconstraint{p in PROJ}:
	sum{i in STUDS} s[i,p] = num;
	
# Number of teams per student
subject to teamnumberconstraint{i in STUDS}:
	sum{p in PROJ} s[i,p] = 1;

# Average GPA constraint
subject to lowergpaconstraint{p in PROJ}:
	sum{i in STUDS} gpa[i]*s[i,p] >= gpa_lower * sum{i in STUDS} s[i,p];
subject to uppergpaconstraint{p in PROJ}:
	sum{i in STUDS} gpa[i]*s[i,p] <= gpa_upper * sum{i in STUDS} s[i,p];

# Gender proportion constraint
subject to genderproportionconstraint{p in PROJ, j in GENDERS}:
	sum{i in STUDS} gender[i,j]*s[i,p] <= gender_limit * sum{i in STUDS} s[i,p];
