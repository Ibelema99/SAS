* Customer Segmentation - Creating Value Segments 

Assign libname to the folder;
LIBNAME SEGMENT '/home/u58427903/sasuser.v94/Portfolio Building/Retail Segmentation';

* Import datasets;
PROC IMPORT DATAFILE = "/home/u58427903/sasuser.v94/Portfolio Building/Retail Segmentation/transactions (1).csv" 
DBMS = CSV OUT = SEGMENT.transactions;
GETNAMES = YES;
RUN;
PROC PRINT DATA = SEGMENT.transactions;
RUN;

PROC IMPORT DATAFILE = "/home/u58427903/sasuser.v94/Portfolio Building/Retail Segmentation/customers (1).csv" 
DBMS = CSV OUT = SEGMENT.customers;
GETNAMES = YES;
RUN;
PROC PRINT DATA = SEGMENT.customers;
RUN;

* data cleaning steps;
proc means data = segment.transactions mean max min;
run;

proc means data= segment.transactions
    NMISS;
run;

* removing NA values; 
Data segment.customers1;
set segment.customers;
if lifestyle = 'NA' then delete;
if gender = 'NA' then delete;
if loyalty = 'NA' then delete;
if preferred_store_format = 'NA' then delete;
run; 

Data segment.customers;
set segment.customers1;
run;

* Sort and join both tables;
Proc sort data = segment.transactions out = SEGMENT.sorted_txns;
by hhid;
run;

Proc sort data = segment.customers out = SEGMENT.sorted_cust;
by hhid;
run;

Data segment.singleview;
Merge SEGMENT.sorted_txns(IN = a) SEGMENT.sorted_cust (IN = b);
By Hhid;
If a = 1;
run;

* Calculate 33 & 66 percentile cutoff for total spend & total visits;
proc univariate data = segment.singleview;
	var totalspend totalvisits totalquantity;
	output out = segment.singleviewPercOut  pctlpts=33 66 pctlpre=Totalspend Totalvisits Totalquantity
              pctlname=P33 P66;	
	run;

proc print data = segment.singleviewPercOut;
run;

* Store the percentile cutoffs in macro variables. 
	P33_spend, p66_spend, p33_visit, p66_visit;

%let P33_spend = 372.76;	
%let p66_spend = 1275.61;	
%let p33_visit = 15; 
%let p66_visit = 39;
%let p33_quantity = 186;
%let p66_quantity = 731;


* Give Score based on spend & visits
	If spend > p66_spend then score = 3
	If spend < p33_spend then score = 1
	else score = 2, same for visits;
	
Data segment.singleview2;
set segment.singleview;
if totalspend > &p66_spend then Spendscore = 3;
else if totalspend < &p33_spend then Spendscore = 1; 
else Spendscore = 2;
run;

Data segment.singleview;
set segment.singleview2;
if totalvisits > &p66_visit then Visitscore = 3;
else if totalvisits < &p33_visit then Visitscore = 1; 
else Visitscore = 2;
run;

Data segment.singleview1;
set segment.singleview;
if totalquantity > &p66_quantity then Quantityscore = 3;
else if totalquantity < &p33_quantity then Quantityscore = 1; 
else Quantityscore = 2;
run;

Data segment.singleview;
set segment.singleview1;
run; 

Proc print data = segment.singleview;
run;

* Calculate total score by adding spend, quantity & visit scores;
Data segment.singleview2;
set segment.singleview;
Total_score = Spendscore + visitscore + quantityscore;
run;

* Create the final segment:
	Segment = Champion if score =9
	Segment = Losers if score <= 4.5
	Segment = Potential for all other scores;
Data segment.singleview;
set segment.singleview2;
If total_score > 6 then ValueSegment = 'Champion';
else if total_score <= 4.5 then ValueSegment = 'Losers';
else ValueSegment = 'Potential';
run;

*
Step 6) Perform the profiling basis numeric variables, by taking the avg of these variables 
	- Total_spend, Total_visit, Instore_spend, Instore_visit, online_spend, Online_visit. 
	Also show Count of each segment.;
proc sql; 
create table segment.Avgvalues as
	select ValueSegment, 
	round(avg(Totalspend), 2) as AverageTotalSpend,
	round(avg(Totalvisits), 2) as AverageTotalvisit,
	round(avg(Totalquantity), 2) as AverageTotalQuantity,
	round(avg(Instorespend), 2) as AverageInstorespend,
	round(avg(Instorevisits), 2) as AverageInstorevisit,
	round(avg(Instorequantity), 2) as AverageInstorequantity,
	round(avg(onlinespend), 2) as Averageonlinespend,
	round(avg(Onlinevisits), 2) as AverageOnlinevisit,
	round(avg(Onlinequantity), 2) as AverageOnlinequantity,
	Count(1) as CountofSegment
	from segment.singleview
	group by ValueSegment;
run;
 
*OR;

PROC MEANS DATA = segment.singleview mean MAXDEC=2 ;
class ValueSegment;
var Totalspend Totalvisits Totalquantity Instorespend Instorevisits Instorequantity onlinespend 
	Onlinevisits Onlinequantity;
RUN;


* Write a macro program to perform profiling of value segments across the 
	following variables - loyalty, preferred_store_format, lifestyle, gender;

%macro valueprofile (var2);
proc freq data=segment.singleview;
tables (Valuesegment)*(&var2) /norow nocol nopercent missing;
run;
%mend;

%valueprofile(Loyalty);
%valueprofile(preferred_store_format);
%valueprofile(lifestyle);
%valueprofile(gender);

