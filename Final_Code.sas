data Proj1SC.merged;
	set Proj1SC.faa1 Proj1SC.faa2;
run;

proc means data = proj1sc.merged N Nmiss;
run;

data proj1sc.remove_empty_rows;
	set proj1sc.merged;
	if aircraft = "" then delete;
run;

proc print data = proj1sc.remove_empty_rows;
run;

proc sort data = proj1sc.remove_empty_rows out= proj1sc.final nodupkey;
	by aircraft no_pasg speed_ground speed_air height pitch distance;
run;

proc univariate data = proj1sc.final ;
var speed_air speed_ground;
histogram ;
run;

proc sgplot data = proj1sc.final;
histogram speed_air /transparency=0.5;
histogram speed_ground /transparency=0.5;
run;


proc print data = proj1sc.final;
run;

proc means data = proj1sc.final N NMISS;
run;

proc freq data = proj1sc.final ;
table aircraft /nocum nopercent nofreq;
where aircraft is missing;
run;

proc freq data = proj1sc.final;
table duration /nocum nopercent nofreq;
where duration < 40 or duration is missing ;
run;

proc freq data = proj1sc.final ;
table speed_ground /nocum nopercent nofreq;
where speed_ground < 30 or speed_ground >140 or speed_ground is missing;
run;

proc freq data = proj1sc.final ;
table speed_air /nocum nopercent nofreq;
where speed_air < 30 or speed_ground >140 or speed_air is missing;
run;

proc freq data = proj1sc.final ;
table height /nocum nopercent nofreq;
where height < 6 or height is missing;
run;


proc freq data = proj1sc.final ;
table distance /nocum nopercent nofreq;
where distance >6000 or distance is missing or distance < 0;
run;

proc print data= proj1sc.final;
run;


/* Removing observations where we have abnormal values */
data proj1sc.clean_1;
set proj1sc.final;
where duration > 40 or duration is missing;
run;

data proj1sc.clean_2;
set proj1sc.clean_1;
where speed_ground > 30 and speed_ground < 140 or speed_ground is missing;
run;


data proj1sc.clean_3;
set proj1sc.clean_2;
where speed_air > 30 and speed_air < 140 or speed_air is missing;
run;


data proj1sc.clean_4;
set proj1sc.clean_3;
where height > 6 or height is missing;
run;

data proj1sc.clean_5;
set proj1sc.clean_4;
where distance < 6000 or distance is missing or distance < 0;
run;

/* Cleaned File without abnormal values */
data proj1sc.FlightCleaned;
set proj1sc.clean_5;
run;


proc contents data = proj1sc.FlightCleaned;
run;

/* Creating a Separate file with Abnormal Values alone */
data proj1sc.ab1;
set proj1sc.final;
where duration < 40 and duration is NOT missing;
run;

data proj1sc.ab2;
set proj1sc.final;
where speed_ground < 30 or speed_ground > 140 and Speed_ground is NOT missing;
run;

data proj1sc.ab3;
set proj1sc.final;
where speed_air < 30 or speed_air > 140;
run;


data proj1sc.ab6;
set proj1sc.ab3;
where Speed_air is NOT missing;
run;
/*data proj1sc.ab3;
set proj1sc.final;
where speed_air < 30 or speed_air > 140 and Speed_air is NOT missing;
run;*/


data proj1sc.ab4;
set proj1sc.final;
where height < 6 and height is NOT missing;
run;

data proj1sc.ab5;
set proj1sc.final;
where distance > 6000 and distance is NOT missing;
run;

data proj1sc.Abnormal;
set proj1sc.ab1 proj1sc.ab2 proj1sc.ab4 proj1sc.ab5 proj1sc.ab6;
run;


proc sort data = proj1sc.Abnormal out= proj1sc.Abnormal_Flight nodupkey;
	by aircraft no_pasg speed_ground speed_air height pitch distance;
run;

/* Summarizing the values*/

proc means data= proj1sc.FLIGHTCLEANED N NMISS;
RUN;

proc freq data = proj1sc.clean_5 NLevels;
	table aircraft /plots = freqplot;
run;


proc univariate data = proj1sc.clean_5;
by aircraft;
histogram ;
run;

proc means data= proj1sc.FLIGHTCLEANED mean stddev median q1 q3 min max;
var no_pasg speed_ground speed_air height pitch distance duration;
run;


proc univariate data = proj1sc.FLIGHTCLEANED;
var distance;
Histogram distance;
run;


/*Analysis*/
proc plot data = proj1sc.FLIGHTCLEANED;
plot distance*speed_air  = "$" distance*speed_ground = "*" / overlay;
run;

proc plot data = proj1sc.FLIGHTCLEANED;
plot distance*height;
run;

proc plot data = proj1sc.FLIGHTCLEANED;
plot distance*pitch;
run;


proc plot data = proj1sc.FLIGHTCLEANED;
plot distance*aircraft;
run;

proc univariate data = proj1sc.FLIGHTCLEANED;
class aircraft;
histogram distance /overlay;
run;

/* Convert the categorical variable into a numerical condition */
data proj1sc.Flight;
set proj1sc.flightcleaned;
if (aircraft = "boeing") then type = 0;
else type = 1;
drop aircraft;
run;

/* Correlation Matrix */
proc corr data = proj1sc.flight;
var distance type no_pasg Speed_air Speed_ground height pitch duration;
title "Pairwise Correlation";
run;

proc corr data = proj1sc.flight;
var speed_air speed_ground;
with distance;
run;

proc corr data = proj1sc.flight;
var type no_pasg Speed_air Speed_ground height pitch duration;
with distance;
title "Correlation with Distance";
run;

/* Regression Model: Removing Duration */ 

proc reg data = proj1sc.flight;
model distance = type no_pasg Speed_air Speed_ground height pitch;
title "Regression Analysis of the Flight Dataset";
run;

/* Analysis of variables */

proc reg data = proj1sc.flight;
model distance = type no_pasg Speed_air Speed_ground height pitch /vif tol;
title "Regression Analysis of the Flight Dataset";
run;

/* Final Model */

proc reg data = proj1sc.flight;
model distance = type no_pasg Speed_ground height pitch /vif tol;
title "Regression Analysis of the Flight Dataset";
run;

proc sort data = proj1sc.flight;
by type;
run;

proc means data = proj1sc.flight;
by type;
var Speed_ground height pitch distance;
run;
