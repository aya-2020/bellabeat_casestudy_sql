--Number of rowes
select 
COUNT (*)
from PortfolioProject.dbo.dailyactivity 

select 
COUNT (*)
from PortfolioProject.dbo.sleepDay 

select 
COUNT (*)
from PortfolioProject.dbo.weightLogInfo 
-------------------------------------------------------------------------------------
--Number of distinct rows 
select COUNT( distinct id) from PortfolioProject.dbo.dailyactivity 
select COUNT( distinct id) from PortfolioProject.dbo.sleepDay
select COUNT( distinct id) from PortfolioProject.dbo.weightLogInfo
--------------------------------------------------------------------------------------
--View tables 
select *
from PortfolioProject.dbo.sleepDay

select *
from PortfolioProject.dbo.dailyactivity

select *
from PortfolioProject.dbo.weightLogInfo
-------------------------------------------------------------------------------------------------
--Change the time format to unify all the data in the tables to merge them 
alter table PortfolioProject.dbo.sleepDay
add converted_date date;

update PortfolioProject.dbo.sleepDay
set converted_date = CONVERT(date,SleepDay)

select converted_date 
from PortfolioProject.dbo.sleepDay

select converted_date_1 
from PortfolioProject.dbo.weightLogInfo

alter table PortfolioProject.dbo.weightloginfo
add converted_date_1 date;

update PortfolioProject.dbo.weightLogInfo
set converted_date_1 = CONVERT(date,Date)
--------------------------------------------------------------------------------------------------------------
--remove duplicates
with RowNumCTE as (
select *, 
ROW_NUMBER () over(
partition by 
id,
weightkg,
weightpounds,
fat,
bmi,
converted_date_1
order by 
converted_date_1
) row_num
from
PortfolioProject.dbo.weightLogInfo
)
select *
from
RowNumCTE
where row_num > 1
order by
converted_date_1



with RowNumCTE as (
select *, 
ROW_NUMBER () over(
partition by 
id,
activitydate,
totalsteps,
totaldistance,
VeryActiveDistance,
ModeratelyActiveDistance,
LightActiveDistance,
SedentaryActiveDistance,
VeryActiveMinutes,
FairlyActiveMinutes,
LightlyActiveMinutes,
SedentaryMinutes,
Calories
order by 
activitydate
) row_num
from
PortfolioProject.dbo.dailyactivity
)
select *
from
RowNumCTE
where row_num > 1
order by
ActivityDate


with RowNumCTE as (
select *, 
ROW_NUMBER () over(
partition by 
id,
SleepDay,
TotalSleepRecords,
TotalMinutesAsleep,
TotalTimeInBed
order by 
id
) row_num
from
PortfolioProject.dbo.sleepDay
)
DELETE 
from
RowNumCTE
where row_num > 1
---------------------------------------------------------------------------------------------------------
--delete unused coloumns 
select *
from PortfolioProject.dbo.weightLogInfo
ALTER TABLE PortfolioProject.dbo.dailyactivity
drop column totaldistance

ALTER TABLE PortfolioProject.dbo.sleepday
drop column sleepday

ALTER TABLE PortfolioProject.dbo.weightLogInfo
drop column Date 
-----------------------------------------------------------------------------------------------------------------
--extract dayweek from date 

SELECT distinct (activitydate), DATENAME(dw, ActivityDate) DayofWeek
from
portfolioproject..dailyactivity
-------------------------------------------------------------------------------------------------------------------
--join all  tables 
SELECT * 
from portfolioproject..dailyactivity da
left outer join PortfolioProject..sleepDay sl
 on da.id = sl.Id
 and da.ActivityDate = sl.converted_date
 left outer JOIN PortfolioProject..weightLogInfo wl
 on sl.converted_date = wl.converted_date_1
 and da.id = wl.id
 order by da.id
 
 --------------------------------------------------------------------------------------------------------------------
 --Calculate max,min.avg total steps by day of week
SELECT distinct DATENAME(dw, ActivityDate)  DayofWeek, max(da.totalsteps)as maximum_total_steps, min(da.totalsteps)as minimum_total_steps, round(avg(da.totalsteps),1)as average_steps
from portfolioproject..dailyactivity da
 group by ActivityDate

 --Calculate total duration of sleep by day of week
 SELECT distinct DATENAME(dw, ActivityDate)  DayofWeek,round( avg (sl.TotalMinutesAsleep/60),2) as average_number_of_hours_asleep,round( avg (sl.TotalTimeInBed/60),2) as average_number_of_hours_InBed 
from portfolioproject..dailyactivity da
left outer join PortfolioProject..sleepDay sl
 on da.id = sl.Id
 and da.ActivityDate = sl.converted_date
 left outer JOIN PortfolioProject..weightLogInfo wl
 on sl.converted_date = wl.converted_date_1
 and da.id = wl.id
 group by activitydate
 ------------------------------------------------------------------------------------------------------------------------
 --calculate  Total estimated energy expenditure (in kilocalories) for (very,moderately,light,sedentary active distance)
 select 
  calories, veryactivedistance, moderatelyactivedistance, lightactivedistance, sedentaryactivedistance
 from 
 PortfolioProject..dailyactivity
 ---------------------------------------------------------------------------------------------------------------------------------
 --calculate tracker distance for Total estimated energy expenditure (in kilocalories)
  select 
  calories, round (Trackerdistance,1) as Tracker_Distance
 from 
 PortfolioProject..dailyactivity
 -----------------------------------------------------------------------------------------------------------------------------
 --calculate relationship between weight and calories 
 SELECT da.calories, wl.weightkg
 from portfolioproject..dailyactivity da
  left outer JOIN PortfolioProject..weightLogInfo wl
 on da.activitydate = wl.converted_date_1
 and da.id = wl.id
 where wl.weightkg is not null 
 --------------------------------------------------------------------------------------------------------------------------------
 --count how much manual report
select distinct (IsManualReport), COUNT (IsManualReport) as number_of_reports
from PortfolioProject.dbo.weightLogInfo
group by IsManualReport
order by IsManualReport
------------------------------------------------------------------------------------------------------------------------
--calculate total minutesasleep related to weight 
SELECT sl.totalminutesasleep, round (wl.weightkg,1)as weight_kg
from PortfolioProject..sleepDay sl
 JOIN PortfolioProject..weightLogInfo wl
 on sl.converted_date = wl.converted_date_1
 and sl.id = wl.id
 ---------------------------------------------------------------------------------------------------------------------------------
 --calculate (very,fairly,lightly,sedentary active minutes) and total time in bed
 select 
 da.veryactivedistance, da.moderatelyactivedistance, da.lightactivedistance, da.sedentaryactivedistance,sl.totaltimeinbed
 from 
 PortfolioProject..dailyactivity da
 join PortfolioProject..sleepDay sl
 on da.id = sl.Id
 and da.ActivityDate = sl.converted_date 
 ---------------------------------------------------------------------------------------------------------------------------
 --relationship between (very,fairly,lightly,sedentary active minutes) and total minutes a sleep
 select 
  da.veryactivedistance, da.moderatelyactivedistance, da.lightactivedistance, da.sedentaryactivedistance,sl.TotalMinutesAsleep
 from 
 PortfolioProject..dailyactivity da
 join PortfolioProject..sleepDay sl
 on da.id = sl.Id
 and da.ActivityDate = sl.converted_date 



 



 












