LIBNAME ABUSE'/home/u58427903/sasuser.v94/Portfolio Building/Drug Abuse';


PROC IMPORT DATAFILE = '/home/u58427903/sasuser.v94/Portfolio Building/Drug Abuse/Death from Drug Abuse.csv'
DBMS = CSV OUT = Abuse.DRUGABUSE;
GETNAMES = YES;
RUN;

PROC PRINT DATA = Abuse.Drugabuse;
RUN;

*Total number of deaths caused by drug abuse;
proc sql;
    select count(*) as CountofDeaths
    from abuse.Drugabuse;
quit;


*number of deaths across different age groups;
DATA ABUSE2;
SET ABUSE.DRUGABUSE;
IF AGE < 20 THEN AGE_GROUP = 'Lessthan20';
IF AGE >= 20 AND AGE <30 THEN AGE_GROUP = '20-30';
IF AGE >= 30 AND AGE <40 THEN AGE_GROUP = '30-40';
IF AGE >= 40 AND AGE <50 THEN AGE_GROUP = '40-50';
IF AGE >= 50 AND AGE <60 THEN AGE_GROUP = '50-60';
IF AGE >= 60 AND AGE <70 THEN AGE_GROUP = '60-70';
IF AGE >= 70 THEN AGE_GROUP = '>70';
RUN;

DATA ABUSE.DRUGABUSE;
SET ABUSE2;
RUN;

Proc Print data= abuse.drugabuse;
run;

proc sql;
    select AGE_GROUP, count(distinct ID) as N
    from abuse.Drugabuse
    group BY AGE_GROUP;
quit;

*OR;

proc means data=abuse.drugabuse n noobs ;
var Age;
class age_group;
run;

* show frequency, percent, cumm perc & freq;
proc freq data=abuse.drugabuse;
tables (age_group sex) ;
run;

* number of deaths across gender & race;
proc sql;
    select Sex, Race, count(distinct ID) as N
    from abuse.Drugabuse
    group BY Sex, race;
quit;

*OR;

proc freq data=abuse.drugabuse;
tables (Sex) *(Race) / nocum nopercent norow nocol;
run;


* number of deaths across location;
proc sql;
    select Location, count(distinct ID) as N
    from abuse.Drugabuse
    group BY Location;
quit;

*OR;
proc freq data=abuse.drugabuse;
tables (location) ;
run;

* number of deaths across manner of death;
proc sql;
    select MannerofDeath, count(distinct ID) as N
    from abuse.Drugabuse
    group BY MannerofDeath;
quit;

*OR;
proc freq data=abuse.drugabuse;
tables (mannerofdeath) ;
run;

* top 5 combinations of location & manner of death;
proc sql outobs= 5;
    select 
    Location, MannerofDeath, count(distinct ID) as N
    from abuse.Drugabuse 
    group BY Location, MannerofDeath
    order by N desc;
quit;

*OR;

proc freq data=abuse.drugabuse;
tables (location) *(mannerofdeath);
run;

* percentage of deaths caused by different type of drugs;
DATA ABUSE2;
SET ABUSE.DRUGABUSE;
IF Heroin = 'Y' THEN HeroinUse = 1; else HeroinUse = 0;
IF Cocaine = 'Y' THEN CocaineUse = 1; else CocaineUse = 0;
IF Fentanyl = 'Y' THEN FentanylUse = 1; else FentanylUse = 0;
IF FentanylAnalogue = 'Y' THEN FentanylAnalogueUse = 1; else FentanylAnalogueUse = 0;
IF Oxycodone = 'Y' THEN OxycodoneUse = 1; else OxycodoneUse = 0;
IF Oxymorphone = 'Y' THEN OxymorphoneUse = 1; else OxymorphoneUse = 0;
IF Hydrocodone = 'Y' THEN HydrocodoneUse = 1; else HydrocodoneUse = 0;
IF Benzodiazepine = 'Y' THEN BenzodiazepineUse = 1; else BenzodiazepineUse = 0;
IF Methadone = 'Y' THEN MethadoneUse = 1; else MethadoneUse = 0;
IF Amphet = 'Y' THEN AmphetUse = 1; else AmphetUse = 0;
IF Tramad = 'Y' THEN TramadUse = 1; else TramadUse = 0;
IF Morphine_NotHeroin = 'Y' THEN Morphine_NotHeroinUse = 1; else Morphine_NotHeroinUse = 0;
IF Hydromorphone = 'Y' THEN HydromorphoneUse = 1; else HydromorphoneUse = 0;
IF OpiateNOS = 'Y' THEN OpiateNOSUse = 1; else OpiateNOSUse = 0;
IF AnyOpioid = 'Y' THEN AnyOpioidUse = 1; else AnyOpioidUse = 0; 
run;

proc sql; 
	create table abuse.abuse1 as 
	select 100*(sum(HeroinUse)/count(distinct ID)) as HeroinUseperc, 
			100*(sum(CocaineUse)/count(distinct ID)) as CocaineUseperc,
			100*(sum(FentanylUse)/count(distinct ID)) as FentanylUseperc, 
			100*(sum(FentanylAnalogueUse)/count(distinct ID)) as FentanylAnalogueUseperc, 
			100*(sum(OxycodoneUse)/count(distinct ID)) as OxycodoneUseperc, 
			100*(sum(OxymorphoneUse)/count(distinct ID)) as OxymorphoneUseperc, 
			100*(sum(HydrocodoneUse)/count(distinct ID)) as HydrocodoneUseperc, 
			100*(sum(BenzodiazepineUse)/count(distinct ID)) as BenzodiazepineUseperc, 
			100*(sum(MethadoneUse)/count(distinct ID)) as MethadoneUseperc, 
			100*(sum(AmphetUse)/count(distinct ID)) as AmphetUseperc, 
			100*(sum(TramadUse)/count(distinct ID)) as TramadUseperc, 
			100*(sum(Morphine_NotHeroinUse)/count(distinct ID)) as Morphine_NotHeroinUseperc,
			100*(sum(HydromorphoneUse)/count(distinct ID)) as HydromorphoneUseperc, 
			100*(sum(OpiateNOSUse)/count(distinct ID)) as OpiateNOSUseperc, 
			100*(sum(AnyOpioidUse)/count(distinct ID)) as AnyOpioidUseperc
	from ABUSE2;
quit;

Proc print data = abuse.abuse1;
run;

PROC FREQ Data = abuse2;
tables(Heroin Cocaine Fentanyl FentanylAnalogue Oxycodone Oxymorphone Ethanol Hydrocodone Benzodiazepine 
	Methadone Amphet Tramad Morphine_NotHeroin Hydromorphone OpiateNOS AnyOpioid);
run;
