* Channel Segmentation Analysis

Assign libname to the folder;
libname Segment "/home/u58427903/sasuser.v94/Portfolio Building/Retail Segmentation";

*import datasets; 
PROC IMPORT DATAFILE = "/home/u58427903/sasuser.v94/Portfolio Building/Retail Segmentation/transactions (1).csv" 
DBMS = CSV OUT = segment.transactions;
GETNAMES = YES;
RUN;
PROC PRINT DATA = segment.transactions;
RUN;

PROC IMPORT DATAFILE = "/home/u58427903/sasuser.v94/Portfolio Building/Retail Segmentation/customers (1).csv" 
DBMS = CSV OUT = segment.customers;
GETNAMES = YES;
RUN;
PROC PRINT DATA = segment.customers;
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

* merge the two datasets - need to sort by ID first;
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

* Summary statistics for totalspend, totalvisits, totalquantity;
proc means data=SEGMENT.SINGLEVIEW chartype mean std min max n vardef=df;
	var TotalSpend TotalVisits TotalQuantity;
run;

* Summary statistics across loyalty, preferred_store_format, lifestyle, gender;
proc means data=SEGMENT.SINGLEVIEW chartype mean std min max n vardef=df;
	var TotalVisits TotalSpend TotalQuantity;
	class loyalty;
run;

proc means data=SEGMENT.SINGLEVIEW chartype mean std min max n vardef=df;
	var TotalVisits TotalSpend TotalQuantity;
	class gender;
run;

proc means data=SEGMENT.SINGLEVIEW chartype mean std min max n vardef=df;
	var TotalVisits TotalSpend TotalQuantity;
	class lifestyle;
run;

proc means data=SEGMENT.SINGLEVIEW chartype mean std min max n vardef=df;
	var TotalVisits TotalSpend TotalQuantity;
	class preferred_store_format;
run;
	
* Histograms for TotalSpend, TotalVisit & TotalQuantity;
proc univariate data=SEGMENT.SINGLEVIEW vardef=df noprint;
	var TotalVisits TotalSpend TotalQuantity;
	histogram TotalVisits TotalSpend TotalQuantity;
run;

* Create 'ChannelSegmentation' column giving values of:
	- 'InstoreOnly' if the customers have InstoreVisits > 0 and OnlineVisits = 0.
	- 'OnlineOnly' if the customers have InstoreVisits = 0 and OnlineVisits > 0.
	- 'InstoreAndOnline' if the customers have InstoreVisits > 0 and OnlineVisits > 0;	
Data tb;
set segment.singleview;
If InstoreVisits > 0 and OnlineVisits = 0 then ChannelSegmentation = 'InstoreOnly';
If OnlineVisits > 0 and InstoreVisits = 0 then ChannelSegmentation = 'OnlineOnly';
If InstoreVisits > 0 and OnlineVisits > 0 then ChannelSegmentation = 'InstoreAndOnline';
run;

Data segment.singleview;
set tb;
run;

* Calculate avg of InstoreVisits InstoreSpend InstoreQuantity OnlineVisits OnlineSpend 
	OnlineQuantity TotalVisits TotalSpend TotalQuantity across the values of 
	'ChannelSegmentation';
PROC SQL;
create table SEGMENT.ChannelSegmentationProfile as
select ChannelSegmentation, avg(InstoreVisits) as InstoreVisits,
avg(InstoreSpend) as InstoreSpend,
avg(InstoreQuantity) as InstoreQuantity,
avg(OnlineVisits) as OnlineVisits,
avg(OnlineSpend) as OnlineSpend,
avg(OnlineQuantity) as OnlineQuantity,
avg(TotalVisits) as TotalVisits,
avg(TotalSpend) as TotalSpend,
avg(TotalQuantity) as TotalQuantity
from SEGMENT.SINGLEVIEW
group by ChannelSegmentation;
QUIT;

proc print data = segment.channelsegmentationprofile;
run;

*create 2 bar charts to generate the comparison of
	a) 'ChannelSegmentation' (x axis) and TotalVisits (y axis)
	a) 'ChannelSegmentation' (x axis) and TotalQuantities (y axis);
	
proc sgplot data=SEGMENT.SINGLEVIEW;
vbar ChannelSegmentation / response=TotalVisits stat=mean;
yaxis grid;
run;

proc sgplot data=SEGMENT.SINGLEVIEW;
vbar ChannelSegmentation / response=TotalQuantity stat=mean;
yaxis grid;
run;

proc sgplot data=SEGMENT.SINGLEVIEW;
vbar ChannelSegmentation / response=TotalSpend stat=mean;
yaxis grid;
run;





 
