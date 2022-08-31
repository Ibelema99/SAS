* Linear Regression on Insurance Loss Dataset 

*Assign libname; 
libname Linreg '/home/u58427903/sasuser.v94/Portfolio Building/Regression';

*import dataset;
proc import 
datafile = "/home/u58427903/sasuser.v94/Portfolio Building/Regression/Default_On_Payment.csv"
	out = linreg.insurance
	dbms=csv;
	delimiter = ',';
	getnames = yes;
run;

data linreg.insurance1;
set linreg.insurance;
rec_no = _n_;
run;

* univariate analysis of DV;
proc sgscatter data = linreg.insurance1; 
compare y = Losses  x = rec_no / ellipse =(alpha = 0.01 type = predicted); 
title 'Losses - Scatter Plot'; 
title2 '-- with 99% prediction ellipse --'; 
run;


PROC SGPLOT  DATA = linreg.insurance1;
   VBOX Losses;
   title 'Losses - Box Plot';
RUN; 

* Find percentile values on losses to treat for outliers;
proc univariate data=linreg.insurance1 ;
   var Losses;
   histogram;
   output out=Losses_Ptile pctlpts  = 90 95 97.5 99 99.5 99.6 99.7 99.8 99.9 100 pctlpre  = P_;
run;

proc print data = Losses_Ptile; 
run;

* The jump between the percentiles are pretty consistent so we will move on without removing any outliers;

* Create dummy variables for character variables;
data linreg.insurance;
set linreg.insurance1 (rename = ('Years Of Driving Experience'n = yrs_drv_exp   
		'Number of Vehicles'n = Number_of_Vehicles  'Vehicle Age'n = Vehicle_Age));

if gender="M" then gender_dummy=1;
else gender_dummy=0;

if married="Married" then married_dummy=0;
else married_dummy=1;

if 'fuel type'n="P" then fuel_type_dummy=0;
else fuel_type_dummy=1;

run;

* Perform univariate analysis on all the independent variables;
* For continuous variables;
%macro univacont(var);
proc univariate data = linreg.insurance;
var &var;
histogram;
run;

%mend;

%univacont(age);
%univacont(yrs_drv_exp);
%univacont(Number_of_Vehicles);
%univacont(Vehicle_Age);

* For categorical variables;
%macro univacategor(var);
proc SGPLOT data =  linreg.insurance;
vbar &var ;
title 'Univariate Analysis';
run;

proc freq data = linreg.insurance;
tables (&var);
run;

%mend;

%univacategor(gender_dummy);
%univacategor(married_dummy);
%univacategor(fuel_type_dummy);

* Bivariate profiling for categorical vars;
options mprint;
%macro eff(attr,title);

proc sql;
create table distr_&attr as select &attr, avg(Losses) as avg_loss from linreg.insurance 
group by &attr;
quit;

proc SGPLOT data = distr_&attr;
vbar &attr/ response=avg_loss stat=mean;
title "&title";
run;

%mend;

%eff(Gender_Dummy, Gender);
%eff(Married_Dummy, Marital Status);
%eff(Fuel_Type_Dummy, Fuel Type);

* Bivariate profiling for continuous vars;
proc corr data = linreg.insurance plots = matrix ;
VAR Losses Age Number_of_Vehicles Vehicle_Age yrs_drv_exp ;
run;

*choosing between driving experience in years and age;
proc reg data=linreg.insurance outest=pred1;
model Losses = Age;
Output Out= linreg.LINREG;
run;


proc reg data=linreg.insurance outest=pred2;
model Losses = yrs_drv_exp;
Output Out= linreg.LINREG;
run;

* Create test & train groups (20:80);
proc sql outobs = 3000;
create table test as
select * from linreg.insurance
order by ranuni(1234);
quit;

* Selecting in train what is not in test;
proc sql;
create table train as
select * from linreg.insurance
except
select * from test;
quit;

* Run Regression model;
proc reg data=train outest=pred3;
model Losses = age Number_Of_Vehicles Vehicle_Age
Gender_Dummy Married_Dummy Fuel_Type_Dummy;
Output Out= TrainOut;
run;

* remove no. of vehicles and run again; 
proc reg data=train outest=pred4;
model Losses = age Vehicle_Age Gender_Dummy Married_Dummy Fuel_Type_Dummy;
Output Out= TrainOut P= predicted R = residual; 
store out = ModelOut; 
run;

* Check residual plots;
proc means data = TrainOut;
var residual;
run;

*plotting residuals;
PROC sgscatter DATA = TrainOut;
PLOT residual*rec_no;
title 'residual - Scatter Plot';
RUN;

proc univariate data = TrainOut;
var residual;
histogram;
run;

PROC sgscatter DATA = TrainOut;
PLOT residual*predicted; 
title 'residual - predicted Scatter Plot';
RUN;

/* checking with age */
PROC sgscatter DATA = TrainOut;
PLOT residual*age;
title 'residual vs age- Scatter Plot';
RUN;

/* 11. check residual metrics */
*Residual metrics;
proc sql;
create table residual_metrics_train as
select mean(abs(residual/losses))*100 as mape , sqrt(mean(residual**2)) as rmse
from TrainOut;
quit;

proc print data = work.residual_metrics_train;
run;

* run model on test data;
proc reg data=test outest=pred5;
model Losses = age Vehicle_Age Gender_Dummy Married_Dummy Fuel_Type_Dummy;
Output Out= TestOut P= predicted R = residual; 
store out = ModelOut; 
run;

* Check residual plots;
proc means data = TestOut;
var residual;
run;

*plotting residuals;
PROC sgscatter DATA = TestOut;
PLOT residual*rec_no;
title 'residual - Scatter Plot';
RUN;

proc univariate data = TestOut;
var residual;
histogram;
run;

PROC sgscatter DATA = TestOut;
PLOT residual*predicted; 
title 'residual - predicted Scatter Plot';
RUN;

/* checking with age */
PROC sgscatter DATA = TestOut;
PLOT residual*age;
title 'residual vs age- Scatter Plot';
RUN;

* check residual metrics on test data; 
proc sql;
create table residual_metrics_test as
select round(mean(abs(residual/losses))*100,1) as mape, round(sqrt(mean(residual**2)),1) as rmse
from TestOut;
quit;

proc print data = work.residual_metrics_test;
run;

