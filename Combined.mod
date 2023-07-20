# This model optimizes the assigning of engineering students to
# DTC project teams - Phase 2 combined
#
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
# Student major -> 1 for the major per student, 0 otherwise
param major{STUDS, MAJORS};
# Minimum number of students per team in IE major combination
param ie_min;
# Student gender -> 1 per gender, 0 otherwise
param gender{STUDS, GENDERS};
# Happiness Parameter
param happiness;
# Combined bounds on gender and major
param major_av{MAJORS};
param m_stretch;
param gender_av{GENDERS};
param g_stretch;

# Binary decision var: 1 if student i is in team t, 0 otherwise
var s{STUDS, PROJ} binary;

# Minimize total conflict of interest
minimize ConflictofInterest: sum{i in STUDS, j in STUDS, p in PROJ} abs(rating[i,p]-rating[j,p]) * s[i,p] * s[j,p];

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
	
# Minimum number of students per team from IE-ECE-ESAM
subject to IEconstraint{p in PROJ}:
	sum{i in STUDS} major[i, 'ie']*s[i,p] >= ie_min;
	
# Major proprotion constraint
subject to majorproportionlower{p in PROJ, j in MAJORS}:
	sum{i in STUDS} major[i,j]*s[i,p] >= (major_av[j] - m_stretch) * sum{i in STUDS} s[i,p];
subject to majorproportionupper{p in PROJ, j in MAJORS}:
	sum{i in STUDS} major[i,j]*s[i,p] <= (major_av[j] + m_stretch) * sum{i in STUDS} s[i,p];

# Gender proprotion constraint
subject to genderproportionlower{p in PROJ, k in GENDERS}:
	sum{i in STUDS} gender[i,k]*s[i,p] >= (gender_av[k] - g_stretch) * sum{i in STUDS} s[i,p];
subject to genderproportionupper{p in PROJ, k in GENDERS}:
	sum{i in STUDS} gender[i,k]*s[i,p] <= (gender_av[k] + g_stretch) * sum{i in STUDS} s[i,p];