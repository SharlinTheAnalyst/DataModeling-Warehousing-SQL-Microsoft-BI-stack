use [Tesca Control Database]

create schema control

--Environment Table
--Staging and EDW


create table control.environment
(
EnvId int,
Environment nvarchar(255),
constraint control_environment_pk primary key (EnvId)
)

insert into Control.environment(Envid,Environment)
Values
(1,'Staging'),
(2, 'EDW')

--Frequency of run---daily, weekly, monthly, quarterly,Yearly

Create table control.RunFrequency
(
FreqID int,
Frequency nvarchar(255),
constraint control_runFrequency_pk primary key (Freqid)
)

insert into control.RunFrequency(freqID, Frequency)
Values(1,'Daily'),
(2, 'Weekly'),
(3, 'Monthly'),
(4, 'Quarterly'),
(5,'Yearly')

--Package Type-- Dimension, Fact


Create table control.PackageType
(
PackageTypeID int,
PackageType nvarchar(255),
constraint control_PackageType_pk primary key (PackageTypeID)
)

insert into control.PackageType(PackageTypeID, PackageType)
Values(1, 'Dimension'),
(2,'Fact')

----Package----


create table control.Package
(
PackageID int,   --no identity, lets make manual
PackageName nvarchar(255),
PackageTypeID int,
sequenceNo int,
EnvId int,
FreqID int,
RunStartDate date,
RunEndDate date,
Active bit,
LastRundate datetime,
constraint control_package_pk primary key(PackageID),
constraint control_package_packageType_fk foreign key(PackageTypeID) references control.PackageType(PackageTypeID),
constraint control_package_environment_fk foreign key(EnvId) references control.environment(EnvId),
constraint control_package_RunFrequency_fk foreign key(FreqId) references control.RunFrequency(FreqId)
)

delete from control.Package where PackageID=16;

update control.Package set PackageName='stgDimEmployee.dtsx' where PackageID=7; ----changed name to dimEmployee
insert into control.Package(PackageID,PackageName,PackageTypeID, sequenceNo, EnvId, FreqID, RunStartDate, Active)
Values

(16,'edwDimProduct.dtsx',1, 3000,1,1,convert(date,getdate()),1)
(3,'stgDimStore.dtsx',1, 3000,1,1,convert(date,getdate()),1)
(14,'stgFactMisconductAnalysis.dtsx',2, 4000,1,1,convert(date,getdate()),1),
(15,'stgFactAbsentAnalysis.dtsx',2, 5000,1,1,convert(date,getdate()),1)
(13,'stgFactOvertimeAnalysis.dtsx',2, 3000,1,1,convert(date,getdate()),1)
(12,'stgFactPurchaseAnalysis.dtsx',2, 2000,1,1,convert(date,getdate()),1)
(11,'stgFactSalesAnalysis.dtsx',2, 1000,1,1,convert(date,getdate()),1)
(10,'stgDimAbsentCategory.dtsx',1, 10000,1,1,convert(date,getdate()),1)
(9,'stgDimDecision.dtsx',1, 9000,1,1,convert(date,getdate()),1)
(8,'stgDimMisConduct.dtsx',1, 8000,1,1,convert(date,getdate()),1)
(7,'stgDimEmployee.dtsx',1, 7000,1,1,convert(date,getdate()),1)
(6,'stgDimVendor.dtsx',1, 6000,1,1,convert(date,getdate()),1)
(5,'stgDimPosChannel.dtsx',1, 5000,1,1,convert(date,getdate()),1)
(4,'stgDimCustomer.dtsx',1, 4000,1,1,convert(date,getdate()),1),
(1,'stgDimProduct.dtsx',1, 1000,1,1,convert(date,getdate()),1),
(2,'stgDimPromotion.dtsx',1, 2000,1,1,convert(date,getdate()),1),



Drop table control.metrics
Create table control.metrics
(
MetricID int identity(1,1),
PackageId int,
stgSourceCount bigint,  ---likely be millions of rows, what are we fetching from OLTP
stgDescCount bigint,    --to Destination
PreCount bigint,   ---What we have in EDW - currently its count is zero
CurrentCount bigint,
Type1Count bigint,  --SCD
Type2Count bigint,
PostCount bigint, -- How many in EDW
Rundate Datetime,
constraint control_metrics_pk Primary Key(MetricID),
constraint control_metrics_pacakge_fk foreign key(PackageID) references Control.Package(PackageId)
)

---Pass values what we get from variables what we declared in SSIS---
---lets create a procedure----
declare @StgSourceCount bigint=?
declare @StgDescCount bigint=?
declare @PackageID int=?

insert into control.metrics(packageID,stgSourceCount, stgDescCount, Rundate)
select @PackageID, @StgSourceCount, @StgDescCount, Getdate()
---Also, we need to understand when last time this package was run--

Update Control.package set LastRundate= Getdate() where packageID= @PackageID


select * from control.metrics
select * from control.Package
select * from control.RunFrequency
----------------------------------------------------
select p.packageId, p.PackageName, p.sequenceNo from control.Package p
where p.EnvId=1 and p.Active=1 and p.RunStartDate<=convert(date, getdate()) 
and (RunEndDate is null or RunEndDate>=convert(date, getdate()))
and p.FreqID=1


IF DATEPART(weekday,getdate())=7 and convert(date,getdate())<>EOMONTH(getdate())
 BEGIN
  select p.packageId, p.PackageName from control.Package p
  where p.EnvId=1 and p.Active=1 and p.RunStartDate<=convert(date, getdate()) 
  and (RunEndDate is null or RunEndDate>=convert(date, getdate()))
  and p.FreqID in (1,2) order by p.sequenceNo asc
 END

ELSE IF DATEPART(weekday,getdate())=7 and convert(date,getdate())=EOMONTH (getdate())
 
 BEGIN
  select p.packageId, p.PackageName from control.Package p
  where p.EnvId=1 and p.Active=1 and p.RunStartDate<=convert(date, getdate()) 
  and (RunEndDate is null or RunEndDate>=convert(date, getdate()))
  and p.FreqID in (1,2,3) order by p.sequenceNo asc
 END

ELSE

 BEGIN
  select p.packageId, p.PackageName from control.Package p
  where p.EnvId=1 and p.Active=1 and p.RunStartDate<=convert(date, getdate()) 
  and (RunEndDate is null or RunEndDate>=convert(date, getdate()))
  and p.FreqID=1 order by p.sequenceNo
 END

 ---control package is package that will call rest of the package. 


 ---Edw Control Package---
select * from control.Package
update control.Package set PackageName='edwDimCustomer.dtsx' where PackageID=19; 
insert into control.Package(PackageID,PackageName,PackageTypeID, sequenceNo, EnvId, FreqID, RunStartDate, Active)
Values
(16,'edwDimProduct.dtsx',1, 1000,2,1,convert(date,getdate()),1)
(30,'edwFactAbsenceAnalysis.dtsx',2, 60000,2,1,convert(date,getdate()),1)
(29,'edwFactMisConductAnalysis.dtsx',2, 50000,2,1,convert(date,getdate()),1)
(28,'edwFactOvertimeAnalysis.dtsx',2, 40000,2,1,convert(date,getdate()),1)
(27,'edwFactPurchaseAnalysis.dtsx',2, 30000,2,1,convert(date,getdate()),1)
(26,'edwFactSalesAnalysis.dtsx',2, 20000,2,1,convert(date,getdate()),1)
(25,'edwDimAbsentCategory.dtsx',1, 10000,2,1,convert(date,getdate()),1)
(24,'edwDimDecision.dtsx',1, 9000,2,1,convert(date,getdate()),1)
(23,'edwDimMisconduct.dtsx',1, 8000,2,1,convert(date,getdate()),1)
(22,'edwDimEmployee.dtsx',1, 7000,2,1,convert(date,getdate()),1)
(21,'edwDimVendor.dtsx',1, 6000,2,1,convert(date,getdate()),1)
(20,'edwDimPosChannel.dtsx',1, 5000,2,1,convert(date,getdate()),1)
(19,'edwDimCustomer.dtsx',1, 4000,2,1,convert(date,getdate()),1)
(18,'edwDimPromotion.dtsx',1, 3000,2,1,convert(date,getdate()),1)
(17,'edwDimStore.dtsx',1, 2000,2,1,convert(date,getdate()),1)







 ---EDW Metrics Dimension---------------
 declare @Precount bigint=?
 declare @CurrentCount bigint=?
 declare @Type1Count bigint=?
 declare @Type2Count bigint=?
 declare @PostCount bigint=?
 declare @PackageID bigint=?

 insert into control.metrics(PackageId, PreCount, CurrentCount, Type1Count,Type2Count,PostCount,RunDate)
 select @PackageID, @PreCount,@CurrentCount,@PostCount,@Type1Count,@Type2Count,GETDATE()

 Update control.Package set LastRundate=GETDATE() Where PackageId=@PackageID

 -------------(pre+Current+Type 2= Post)-------------------------

 Create table control.anomalies
 (
 AnomaliesID bigint identity(1,1),
 PackageID int,
 Dimension nvarchar(255),
 AttributeName nvarchar(255),
 TransID bigint,
 RunDate datetime default getdate(),
 constraint control_anomalies_pk primary key(AnomaliesID),
 constraint control_anomalies_Package_fk foreign key(PackageID) references control.package(PackageID)
 )

 Select a.RunDate, a.PackageID, p.PackageName, pt.PackageType, e.Environment, p.RunStartDate, p.RunEndDate, a.Dimension, a.AttributeName, 
 a.TransID from control.Anomalies a
 inner join control.PackageTypeID= pt.PackageTypeID
 inner join control.environment e on p.EnvID=e.EnvID
 where a. PackageID=29
 ----------------

 IF DATEPART(weekday,getdate())=7 and convert(date,getdate())<>EOMONTH(getdate())
 BEGIN
  select p.packageId, p.PackageName from control.Package p
  where p.EnvId=2 and p.Active=1 and p.RunStartDate<=convert(date, getdate()) 
  and (RunEndDate is null or RunEndDate>=convert(date, getdate()))
  and p.FreqID in (1,2) order by p.sequenceNo asc
 END
ELSE IF DATEPART(weekday,getdate())=7 and convert(date,getdate())=EOMONTH (getdate())
 BEGIN
  select p.packageId, p.PackageName from control.Package p
  where p.EnvId=2 and p.Active=1 and p.RunStartDate<=convert(date, getdate()) 
  and (RunEndDate is null or RunEndDate>=convert(date, getdate()))
  and p.FreqID in (1,2,3) order by p.sequenceNo asc
 END
ELSE
 BEGIN
  select p.packageId, p.PackageName from control.Package p
  where p.EnvId=2 and p.Active=1 and p.RunStartDate<=convert(date, getdate()) 
  and (RunEndDate is null or RunEndDate>=convert(date, getdate()))
  and p.FreqID=1 order by p.sequenceNo
 END



 
 -------EDW Metrics Fact---------------
 declare @PreCount bigint=?
 declare @CurrentCount bigint=?
 declare @PostCount bigint=?
 declare @PackageID bigint=?

 insert into control.metrics(PackageId, PreCount, CurrentCount,PostCount,RunDate)
 select @PackageID, @PreCount,@CurrentCount,@PostCount,GETDATE()

 Update control.Package set LastRundate=GETDATE() Where PackageId=@PackageID
