* Logistic Regression on Default on Payment 

*Assign libname; 
libname logreg '/home/u58427903/sasuser.v94/Portfolio Building/Regression';

*import dataset;
proc import 
datafile = "/home/u58427903/sasuser.v94/Portfolio Building/Regression/Default_On_Payment.csv"
out = logreg.Default_On_Payment	dbms = csv replace;
delimiter = ',';
getnames = yes;
run;

proc contents 
data = logreg.Default_On_Payment;
run;

proc means data= logreg.Default_On_Payment
    NMISS;
run;

* Univariate analysis;
* For continuous variables;
%macro univacont(var);
proc univariate data = logreg.Default_On_Payment;
var &var;
histogram;
run;

%mend;

%univacont(Duration_in_Months);
%univacont(Credit_Amount);
%univacont(Inst_Rt_Income);
%univacont(Current_Address_Yrs);
%univacont(Age);
%univacont(Num_CC);
%univacont(Dependents);


* For categorical variables;
%macro univacategor(var);
proc SGPLOT data = logreg.Default_On_Payment;
vbar &var ;
title 'Univariate Analysis';
run;

proc freq data = logreg.Default_On_Payment;
tables (&var);
run;

%mend;

%univacategor(Status_Checking_Acc);
%univacategor(Credit_History);
%univacategor(Purposre_Credit_Taken);
%univacategor(Savings_Acc);
%univacategor(Years_At_Present_Employment);
%univacategor(Marital_Status_Gender);
%univacategor(Other_Debtors_Guarantors);
%univacategor(Property);
%univacategor(Other_Inst_Plans);
%univacategor(Housing);
%univacategor(Job);
%univacategor(Telephone);
%univacategor(Foreign_Worker);
%univacategor(Default_On_Payment);

* Bivariate Analysis;
* Categorical IV;
%macro mBivariateCateg(var);
	proc sql;
	Create table &var._tab as 
	select &var, count(*) as freq,
	sum(Default_On_Payment) as Default_On_Payment 
	from logreg.Default_On_Payment
	group by &var;
	quit;
	
	data &var._tab1;
	set &var._tab;
		Default_Rate = Default_On_Payment/freq;
	run;
	
	proc SGPLOT data = &var._tab1;
	vbar &var/ response=Default_Rate stat=mean;
	title "Default Rate for &var";
	run;

	proc print data = &var._tab1; 
	run;
%mend;
	
%mBivariateCateg(Status_Checking_Acc);
%mBivariateCateg(Credit_History);
%mBivariateCateg(Purposre_Credit_Taken);
%mBivariateCateg(Savings_Acc);
%mBivariateCateg(Years_At_Present_Employment);
%mBivariateCateg(Inst_Rt_Income);
%mBivariateCateg(Marital_Status_Gender);
%mBivariateCateg(Other_Debtors_Guarantors);
%mBivariateCateg(Current_Address_Yrs);
%mBivariateCateg(Property);
%mBivariateCateg(Other_Inst_Plans);
%mBivariateCateg(Housing);
%mBivariateCateg(Num_CC);
%mBivariateCateg(Job);
%mBivariateCateg(Dependents);
%mBivariateCateg(Telephone);
%mBivariateCateg(Foreign_Worker);


* Bivariate for continous IV;

%macro mBivariateCont(var);
	proc sql;
	Create table &var._tab as 
	select Default_On_Payment, avg(&var) as Avg&var
	from logreg.Default_On_Payment
	group by Default_On_Payment;
	quit;
	
	proc SGPLOT data = &var._tab;
	vbar Default_On_Payment/ response=Avg&var stat=mean;
	title "Avg &var across Default Flag";
	run;

	proc print data = &var._tab; 
	run;
%mend;

%mBivariateCont(Duration_in_Months);
%mBivariateCont(Credit_Amount);
%mBivariateCont(Age);


*Creation of dummy variables (0,1) for categorical variables;

data logreg.Default_On_Payment_v1;
set logreg.Default_On_Payment;

	/*Status_Checking_Acc*/	
	if Status_Checking_Acc eq 'A11' then Status_Checking_Acc_dummy_1 = 1; 
		else Status_Checking_Acc_dummy_1 = 0;
	if Status_Checking_Acc eq 'A12' then Status_Checking_Acc_dummy_2 = 1; 
		else Status_Checking_Acc_dummy_2 = 0;
	if Status_Checking_Acc eq 'A13' then Status_Checking_Acc_dummy_3 = 1; 
		else Status_Checking_Acc_dummy_3 = 0;
		
	
	/*Credit_History*/
	if Credit_History eq 'A30' then Credit_History_dummy_1 = 1; 
		else Credit_History_dummy_1 = 0;
	if Credit_History eq 'A31' then Credit_History_dummy_2 = 1; 
		else Credit_History_dummy_2 = 0;	
	if Credit_History eq 'A33' then Credit_History_dummy_3 = 1; 
		else Credit_History_dummy_3 = 0;
	if Credit_History eq 'A34' then Credit_History_dummy_4 = 1; 
		else Credit_History_dummy_4 = 0;	
		
	/*Purposre_Credit_Taken*/
	if Purposre_Credit_Taken eq 'A40' then Purposre_Credit_Taken_dummy_1 = 1; 
		else Purposre_Credit_Taken_dummy_1 = 0;
	if Purposre_Credit_Taken eq 'A41' then Purposre_Credit_Taken_dummy_2 = 1; 
		else Purposre_Credit_Taken_dummy_2 = 0;
	if Purposre_Credit_Taken eq 'A410' then Purposre_Credit_Taken_dummy_1 = 1; 
		else Purposre_Credit_Taken_dummy_1 = 0;
	if Purposre_Credit_Taken eq 'A42' then Purposre_Credit_Taken_dummy_3 = 1; 
		else Purposre_Credit_Taken_dummy_3 = 0;	
	if Purposre_Credit_Taken eq 'A45' then Purposre_Credit_Taken_dummy_4 = 1; 
		else Purposre_Credit_Taken_dummy_4 = 0;
	if Purposre_Credit_Taken eq 'A46' then Purposre_Credit_Taken_dummy_5 = 1; 
		else Purposre_Credit_Taken_dummy_5 = 0;	
	if Purposre_Credit_Taken eq 'A49' then Purposre_Credit_Taken_dummy_6 = 1; 
		else Purposre_Credit_Taken_dummy_6 = 0;
	
	/*Savings_Acc*/
	if Savings_Acc eq 'A62' then Savings_Acc_dummy_1 = 1; 
		else Savings_Acc_dummy_1 = 0;
	if Savings_Acc eq 'A63' then Savings_Acc_dummy_2 = 1; 
		else Savings_Acc_dummy_2 = 0;
	if Savings_Acc eq 'A64' then Savings_Acc_dummy_3 = 1; 
		else Savings_Acc_dummy_3 = 0;
	if Savings_Acc eq 'A65' then Savings_Acc_dummy_4 = 1; 
		else Savings_Acc_dummy_4 = 0;
	
	/*Years_At_Present_Employment*/
	if Years_At_Present_Employment eq 'A71' then Yrs_At_Present_Emp_dummy_1 = 1; 
		else Yrs_At_Present_Emp_dummy_1 = 0;
	if Years_At_Present_Employment eq 'A72' then Yrs_At_Present_Emp_dummy_2 = 1; 
		else Yrs_At_Present_Emp_dummy_2 = 0;	
	if Years_At_Present_Employment eq 'A74' then Yrs_At_Present_Emp_dummy_3 = 1; 
		else Yrs_At_Present_Emp_dummy_3 = 0;
	if Years_At_Present_Employment eq 'A75' then Yrs_At_Present_Emp_dummy_4 = 1; 
		else Yrs_At_Present_Emp_dummy_4 = 0;
	
	/*Marital_Status_Gender*/
	if Marital_Status_Gender eq 'A91' then Marital_Status_Gender_dummy_1 = 1; 
		else Marital_Status_Gender_dummy_1 = 0;
	if Marital_Status_Gender eq 'A92' then Marital_Status_Gender_dummy_2 = 1; 
		else Marital_Status_Gender_dummy_2 = 0;	
	if Marital_Status_Gender eq 'A94' then Marital_Status_Gender_dummy_3 = 1; 
		else Marital_Status_Gender_dummy_3 = 0;
		
	/*Other_Debtors_Guarantors*/
	if Other_Debtors_Guarantors eq 'A102' then Other_Debtors_Guarantors_dummy_1 = 1; 
		else Other_Debtors_Guarantors_dummy_1 = 0;
	if Other_Debtors_Guarantors eq 'A103' then Other_Debtors_Guarantors_dummy_2 = 1; 
		else Other_Debtors_Guarantors_dummy_2 = 0;	
	
	/*Property*/
	if Property eq 'A121' then Property_dummy_1 = 1; 
		else Property_dummy_1 = 0;
	if Property eq 'A122' then Property_dummy_2 = 1; 
		else Property_dummy_2 = 0;	
	if Property eq 'A124' then Property_dummy_3 = 1; 
		else Property_dummy_3 = 0;
	
	/*Other_Inst_Plans*/
	if Other_Inst_Plans eq 'A141' then Other_Inst_Plans_dummy_1 = 1; 
		else Other_Inst_Plans_dummy_1 = 0;
	if Other_Inst_Plans eq 'A142' then Other_Inst_Plans_dummy_2 = 1; 
		else Other_Inst_Plans_dummy_2 = 0;
	
	/*Housing*/
	if Housing eq 'A151' then Housing_dummy_1 = 1; 
		else Housing_dummy_1 = 0;	
	if Housing eq 'A153' then Housing_dummy_2 = 1; 
		else Housing_dummy_2 = 0;
	
	/*Job*/
	if Job eq 'A171' then Job_dummy_1 = 1; 
		else Job_dummy_1 = 0;
	if Job eq 'A172' then Job_dummy_2 = 1; 
		else Job_dummy_2 = 0;	
	if Job eq 'A174' then Job_dummy_3 = 1; 
		else Job_dummy_3 = 0;
	
	/*Telephone*/
	if Telephone eq 'A192' then Telephone_dummy_1 = 1; 
		else Telephone_dummy_1 = 0;
	
	/*Foreign_Worker*/
	if Foreign_Worker eq 'A202' then Foreign_Worker_dummy_1 = 1; 
		else Foreign_Worker_dummy_1 = 0;
		
run;

proc contents data = logreg.Default_On_Payment_v1; 
run;

*Splitting data into Training and Validation (80:20);
data logreg.Default_On_Payment_Train_v1 logreg.Default_On_Payment_Test_v1;
set logreg.Default_On_Payment_v1;
	if ranuni(123) LE 0.80 then output logreg.Default_On_Payment_Train_v1;
	else output logreg.Default_On_Payment_Test_v1;
run;

*List of variables to be used in Logistic Regression;
%Let Varlist = 	Inst_Rt_Income Current_Address_Yrs 
				Age Num_CC Dependents 
				Status_Checking_Acc_dummy_1 Status_Checking_Acc_dummy_2 Status_Checking_Acc_dummy_3 
				Duration_in_Months Credit_History_dummy_1 
				Credit_History_dummy_2 Credit_History_dummy_3 Credit_History_dummy_4 
				Purposre_Credit_Taken_dummy_1 Purposre_Credit_Taken_dummy_2 
				Purposre_Credit_Taken_dummy_3 Purposre_Credit_Taken_dummy_4 
				Purposre_Credit_Taken_dummy_5 Purposre_Credit_Taken_dummy_6 
				Credit_Amount Savings_Acc_dummy_1 Savings_Acc_dummy_2 
				Savings_Acc_dummy_3 Savings_Acc_dummy_4 
				Yrs_At_Present_Emp_dummy_1 Yrs_At_Present_Emp_dummy_2 
				Yrs_At_Present_Emp_dummy_3 Yrs_At_Present_Emp_dummy_4 
				Marital_Status_Gender_dummy_1 Marital_Status_Gender_dummy_2 
				Marital_Status_Gender_dummy_3 
				Other_Debtors_Guarantors_dummy_1 Other_Debtors_Guarantors_dummy_2 
				Property_dummy_1 Property_dummy_2 Property_dummy_3 
				Other_Inst_Plans_dummy_1 Other_Inst_Plans_dummy_2 
				Housing_dummy_1 Housing_dummy_2 Job_dummy_1 Job_dummy_2 Job_dummy_3 
				Telephone_dummy_1 Foreign_Worker_dummy_1;

*Checking for multicollinearity;				
proc reg data= logreg.Default_On_Payment_Train_v1;
  model Default_On_Payment = &VarList/ vif tol collin;
quit;				

*cutoff (3) - sticking with original list;

proc logistic data=logreg.Default_On_Payment_Train_v1  descending outest=betas covout outmodel=mg1;
  model Default_On_Payment= &VarList
               / selection=stepwise
                 slentry=0.01
                 slstay=0.005
                 details
                 lackfit;
  output out=Pred_Default_On_Payment_Train_v1 p=phat lower=lcl upper=ucl
         predprobs=(individual);
run;	

* Confusion matrix;
proc freq data=Pred_Default_On_Payment_Train_v1;
table _FROM_*_INTO_ / out=ConfusionMatrix nocol norow;
run;

proc sql;
select count into : tp from ConfusionMatrix where _FROM_ eq '1' and _INTO_ eq '1';
select count into : fp from ConfusionMatrix where _FROM_ eq '0' and _INTO_ eq '1';
select count into : tn from ConfusionMatrix where _FROM_ eq '0' and _INTO_ eq '0';
select count into : fn from ConfusionMatrix where _FROM_ eq '1' and _INTO_ eq '0';
quit;

data performance;
Accuracy = (&tp. + &tn.) /(&tp. + &tn. + &fp. + &fn.);
Precision = (&tp.) /(&tp. + &fp.); 
Recall = (&tp.) /(&tp. + &fn.); 
F1 = (2 * Precision * Recall) / (Precision + Recall);
run;

* Lift Chart on training data;
* Generating Gains Curve and Calculating Gini Coeff & KS on Training records;

* Sort the records by predicted probabilities in descending order;
proc sort data = Pred_Default_On_Payment_Train_v1; by descending phat;
run;

*Create a variable that will store cumulative number of observations;
*Divide the data in 10 equal observation bins;
%Let NoOfRecords = 32238;
%Let NoOfBins = 10;
data Pred_Default_On_Payment_Train_v2;
set Pred_Default_On_Payment_Train_v1;
retain Cumulative_Count;
Count = 1;
Cumulative_Count = sum(Cumulative_Count, Count);
Bin = round(Cumulative_Count/(&NoOfRecords/&NoOfBins) - 0.5) + 1;
if Bin GT &NoOfBins then Bin = &NoOfBins;
run;


proc sql;
create table Gains_v1 as
select Bin as CustomerGroup, count(*) as CountOfCustomers, sum(Default_On_Payment) as CountOfDefaulters
from Pred_Default_On_Payment_Train_v2
group by Bin;
quit;

proc sql;
select count(1) into :TrainingDefaulterCount
from Pred_Default_On_Payment_Train_v2
where Default_On_Payment=1;
quit;

data Gains_v1;
set Gains_v1;
ModelPercOfDefaulters = CountOfDefaulters*100/&TrainingDefaulterCount;
RandomPercOfDefaulters = 100/&NoOfBins;
retain ModelCummPercOfDefaulters RandomCummPercOfDefaulters;
ModelCummPercOfDefaulters = sum(ModelCummPercOfDefaulters,ModelPercOfDefaulters);
RandomCummPercOfDefaulters = sum(RandomCummPercOfDefaulters,RandomPercOfDefaulters);
KS = ModelCummPercOfDefaulters-RandomCummPercOfDefaulters;
run;

proc sql;
insert into Gains_v1
set CountOfCustomers=0, CountOfDefaulters = 0, CustomerGroup=0,
KS=0, ModelCummPercOfDefaulters=0, ModelPercOfDefaulters=0,
RandomCummPercOfDefaulters=0, RandomPercOfDefaulters=0;
quit;

proc sort data = Gains_v1; by CustomerGroup;
run;

PROC sgplot DATA=Gains_v1;
series x=CustomerGroup y=ModelCummPercOfDefaulters;
series x=CustomerGroup y=RandomCummPercOfDefaulters;
run;


* Lift chart on test data;

* Scoring on test data;
proc logistic inmodel=mg1;
score data = logreg.Default_On_Payment_Test_v1 out=Pred_Default_On_Payment_Test_v1 ;
run;


*Sort the records by predicted probabilities in descending order;
proc sort data = Pred_Default_On_Payment_Test_v1; by descending p_1;
run;

*Create a variable that will store cumulative number of observations;
*Divide the data in 10 equal obseration bins;
%Let NoOfRecords = 7881;
%Let NoOfBins = 10;
data Pred_Default_On_Payment_Test_v2;
set Pred_Default_On_Payment_Test_v1;
retain Cumulative_Count;
Count = 1;
Cumulative_Count = sum(Cumulative_Count, Count);
Bin = round(Cumulative_Count/(&NoOfRecords/&NoOfBins) - 0.5) + 1;
if Bin GT &NoOfBins then Bin = &NoOfBins;
run;

proc sql;
create table Gains_v2 as
select Bin as CustomerGroup, count(*) as CountOfCustomers, sum(Default_On_Payment) as CountOfDefaulters,
max(p_1) as MaxPredProb from Pred_Default_On_Payment_Test_v2
group by Bin;
quit;

proc sql;
select count(1) into :TestingDefaulterCount
from Pred_Default_On_Payment_Test_v2
where Default_On_Payment=1;
quit;

data Gains_v2;
set Gains_v2;
ModelPercOfDefaulters = CountOfDefaulters*100/&TestingDefaulterCount;
RandomPercOfDefaulters = 100/&NoOfBins;
retain ModelCummPercOfDefaulters RandomCummPercOfDefaulters;
ModelCummPercOfDefaulters = sum(ModelCummPercOfDefaulters,ModelPercOfDefaulters);
RandomCummPercOfDefaulters = sum(RandomCummPercOfDefaulters,RandomPercOfDefaulters);
KS = ModelCummPercOfDefaulters-RandomCummPercOfDefaulters;
run;

proc sql;
insert into Gains_v2
set CountOfCustomers=0, CountOfDefaulters = 0, CustomerGroup=0,
KS=0, MaxPredProb=0, ModelCummPercOfDefaulters=0, ModelPercOfDefaulters=0,
RandomCummPercOfDefaulters=0, RandomPercOfDefaulters=0;
quit;

proc sql;
create table Gains_v3 as
select a.*, b.ModelCummPercOfDefaulters as TestModelCummPercOfDefaulters
from Gains_v1 a, Gains_v2 b
where a.CustomerGroup= b.CustomerGroup;
quit;

PROC sgplot DATA=Gains_v3;
series x=CustomerGroup y=ModelCummPercOfDefaulters;
series x=CustomerGroup y=TestModelCummPercOfDefaulters;
series x=CustomerGroup y=RandomCummPercOfDefaulters;
run;

* Confusion matrix on test data;
proc freq data=Pred_Default_On_Payment_Test_v1;
table F_Default_on_payment *I_Default_on_payment / out=ConfusionMatrix nocol norow;
run;

proc sql;
select count into : tp from ConfusionMatrix where F_Default_on_payment eq '1' and I_Default_on_payment eq '1';
select count into : fp from ConfusionMatrix where F_Default_on_payment eq '0' and I_Default_on_payment eq '1';
select count into : tn from ConfusionMatrix where F_Default_on_payment eq '0' and I_Default_on_payment eq '0';
select count into : fn from ConfusionMatrix where F_Default_on_payment eq '1' and I_Default_on_payment eq '0';
quit;

data performance_test;
Accuracy = (&tp. + &tn.) /(&tp. + &tn. + &fp. + &fn.);
Precision = (&tp.) /(&tp. + &fp.);
Recall = (&tp.) /(&tp. + &fn.);
F1 = (2 * Precision * Recall) / (Precision + Recall);
run;

 				
