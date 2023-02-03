
 --LOAD PRODUCT DIMENSION--

use[Tesca Staging Database]
Drop schema tescaDb;
create schema tescaDb;
create schema HROvertime;
create schema HRAbsence;
create schema HRMisconduct;

use[Tesca EDW Database]
drop schema tesca;
create schema tesca;


--------------------------------------------DimProduct---------------------------------------------------------------
--OLTP--to-- Staging--
use [Tesca OLTPDatabase]
select p.ProductID, p.Product, P.ProductNumber, p.UnitPrice,d.Department from Product p inner join Department d
on p.DepartmentID = d.DepartmentID

select count(*) as StgSourceCount from Product p inner join Department d
on p.DepartmentID = d.DepartmentID

---note: no loaddate please check

use [Tesca Staging Database]
create table tescaDb.product
(
 productID int,
 product nvarchar(50) not null,
 ProductNumber nvarchar(50),
 UnitPrice float,
 Department nvarchar(50),
 LoadDate datetime default getdate(),
 constraint tescaDb_product_pk primary key(productid)
 )

Select count(*) as StgDescCount from tescaDb.product

Truncate Table tescaDb.Product

--Staging--to--EDW

use [Tesca Staging Database]
select productID, product, ProductNumber, UnitPrice, department, getdate() as StartDate from tescaDb.Product

use[Tesca EDW Database]

create table tesca.dimProduct
(
 productSK int identity(1,1),
 productID int,
 product nvarchar(50) not null,
 ProductNumber nvarchar(50),
 UnitPrice float,
 Department nvarchar(50),
 StartDate datetime,
 EndDate datetime,
 constraint tesca_dimProduct_sk primary key(productSK)
)
Select count(*) as CurrentCount from tescaDb.Product
select count(*) as PreCount from tesca.dimProduct

select count(*) as PostCount from tesca.dimProduct

select * from tesca.dimProduct

-----------------------------------Load Store Dimension-------------------------------------------------------------
use [Tesca OLTPDatabase]

Select s.StoreID, s.StoreName, s.StreetAddress, c.CityName, st.State, getdate() as LoadDate from Store s
inner join City c on s.CityID=c.CityID
inner join State st on c.StateID=st.StateID

Select count(*) as StgSourceCount from Store s
inner join City c on s.CityID=c.CityID
inner join State st on c.StateID=st.StateID

--Staging--
use [Tesca Staging Database]

----changed to city name because of SSIS
drop table tescaDb.Store

create table tescaDb.Store
(
 StoreID int,
 StoreName nvarchar(50),
 StreetAddress nvarchar(50),
 Cityname nvarchar(50),
 [State] nvarchar(50),
 LoadDate datetime default getdate(),
 constraint tesca_store_pk primary key(StoreId)
 )

 Truncate table tescaDb.Store;

 Select count(*) as StgDescCount from tescaDB.Store 
 Select s.StoreID,s.StoreName, s.StreetAddress,s.Cityname,s.state from tescaDb.Store s

 use [Tesca EDW Database]

 Alter table tesca.DimStore alter column City nvarchar(50);
 create table tesca.DimStore
 (
 StoreSK int identity(1,1),
 StoreID int,
 StoreName nvarchar(50),
 StreetAddress nvarchar(50),
 City nvarchar(50),
 [State] nvarchar(50),
 StartDate datetime,
 constraint tescaDb_product_sk primary key(storeSK)
 )

Select count(*) as CurrentCount from tescaDB.Store
select count(*) as PreCount from tesca.DimStore
select count(*) as PostCount from tesca.DimStore
------------------------------------------------------Promotion------------------------------------------------------------
use [Tesca OLTPDatabase]
select p.PromotionID, p.StartDate As PromotionStartDate, p.EndDate as PromotionEndDate, p.DiscountPercent, t.Promotion, getdate() as LoadDate from Promotion P
inner join PromotionType t on p.PromotionTypeID=t.PromotionTypeID

select count(*) as StgSourceCount from Promotion P
inner join PromotionType t on p.PromotionTypeID=t.PromotionTypeID

use [Tesca Staging Database]

create table tescaDb.Promotion
(
 PromotionID int,
 promotionStartDate date,
 promotionEndDate date,
 DiscountPercent float,
 Promotion nvarchar(50),
 LoadDate Datetime default getdate(),
 constraint tescaDb_promotion_pk primary key(Promotionid)
 )

 select count(*) as StgDescCount from tescaDB.Promotion

 Truncate table tescaDB.Promotion

 ----Promotion EDW----
 select p.PromotionID, p.promotionStartDate, p. promotionEndDate, p.DiscountPercent, p.Promotion from tescaDb.Promotion p

 use [Tesca EDW Database]

 Create table Tesca.dimPromotion
 (
 promotionSK int identity(1,1),
 PromotionID int,
 promotionStartDate date,
 promotionEndDate date,
 DiscountPercent float,
 Promotion nvarchar(50),
 StartDate Datetime,
 constraint tesca_dimPromotion_sk primary key(promotionSK)
 )
 Select count(*) as CurrentCount from tescaDb.Promotion
select count(*) as PreCount from Tesca.dimPromotion
select count(*) as PostCount from Tesca.dimPromotion
select * from Tesca.dimPromotion
 ----------------------------------------------------------Customer--------------------------------------------------------------
 use [Tesca OLTPDatabase]

 select c.CustomerID, Upper(c.LastName) + ','+ c.LastName as CustomerName, c.CustomerAddress, ct.CityName as City, s.State, getdate() as LoadDate from Customer c
 inner join city ct on c.CityId= ct.CityID
 inner join State s on ct.StateID=s.StateID

 select count(*) as StgSourceCount from Customer c
 inner join city ct on c.CityId= ct.CityID
 inner join State s on ct.StateID=s.StateID

--Customer Staging--
use [Tesca Staging Database]

select count(*) as StgDescCount from tescaDb.Customer

 Create Table tescaDb.Customer
(
CustomerID int,
CustomerName nvarchar(250),
CustomerAddress nvarchar(50),
City nvarchar(50),
State nvarchar(50),
Loaddate datetime default getdate(),
constraint tescadb_customer_pk primary key(CustomerID)
)

truncate Table  tescaDb.Customer
--Type 2 on custoemr anme and type 1 on other
select c.CustomerID, c.CustomerName, c.CustomerAddress, c.city, c.state from tescaDb.Customer c

--EDW Customer---
use [Tesca EDW Database]
alter table tesca.dimCustomer alter column CustomerName nvarchar(250); 
create Table tesca.dimCustomer
(
CustomerSK int identity(1,1),
CustomerID int,
CustomerName nvarchar(250),
CustomerAddress nvarchar(50),
City nvarchar(50),
State nvarchar(50),
StartDate datetime,
EndDate datetime,
constraint tesca_customer_sk primary key(CustomerSK)
)
Select count(*) as CurrentCount from tescaDb.Customer
select count(*) as PreCount from tesca.dimCustomer
select count(*) as PostCount from tesca.dimCustomer
--------------------------------------------------------POS Channel----------------------------------------------------------------
 use [Tesca OLTPDatabase]
 select p.ChannelID, p.ChannelNo, p.DeviceModel, p.InstallationDate, p.SerialNo, getdate() as LoadDate from POSChannel p

 select count(*) as StgSourceCount from POSChannel p

 --POS Channel Staging--

 use [Tesca Staging Database]
 create table tescaDb.PosChannel
 (
 ChannelID int,
 ChannelNo nvarchar(50),
 DeviceModel nvarchar(50),
 SerialNo nvarchar(50),
 InstallationDate date,
 LoadDate datetime default getdate(),
 constraint tescaDB_PosChannel_pk primary key(ChannelID)
 )

 select count(*) as StgDescCount from tescaDb.PosChannel

 --Load Pos Channel EDW--
 Truncate table tescaDb.PosChannel
 select p.ChannelID, p.ChannelNo, p.DeviceModel, p.InstallationDate, p.SerialNo from TescaDb.PosChannel p

 use[Tesca EDW Database]

 Create table tesca.DimMPosChannel
 (
 ChannelSK int identity(1,1),
 ChannelID int,
 ChannelNo nvarchar(50),
 DeviceModel nvarchar(50),
 SerialNo nvarchar(50),
 InstallationDate date,
 StartDate datetime,
 EndDate datetime,
 constraint tesca_DimPosChannel_sk primary key(ChannelSK)
 )
 select count(*) as PreCount from tesca.DimMPosChannel
select count(*) as PostCount from tesca.DimMPosChannel
----------------------------------------------------------VENDOR ---------------------------------------------------
 use [Tesca OLTPDatabase]

 select v.VendorID, v.VendorNo, CONCAT_WS(',',Upper(v.LastName), v.FirstNAme) VendorName, v.RegistrationNo, v.VendorAddress, 
 c.CityName as City, s.State, getdate() as LoadDate from Vendor v 
 inner join city c on v.cityID=C.CityID
 inner join state s on s. StateID=c.StateiD

  select count(*) as StgSourceCount from Vendor v 
 inner join city c on v.cityID=C.CityID
 inner join state s on s. StateID=c.StateiD


 ---Vendor Staging--
 use[Tesca Staging Database]

Drop table tescadb.Vendor

 Create table tescadb.Vendor
 (
 VendorID int,
 VendorNo nvarchar(50),
 Vendorname nvarchar(250),
 RegistrationNo nvarchar(50),
 VendorAddress nvarchar(50),
 City nvarchar(50),
 State nvarchar(50),
 LoadDate datetime default getdate(),
 constraint tescadb_vendor_pk primary key (VendorID)
 )
 select count(*) as stgDescCount from tescadb.Vendor

 Truncate table tescaDB.Vendor

 ---DIM Vendor--
 select  v.vendorID, v.VendorNo, v.VendorName, v.RegistrationNo, v.VendorAddress, v.City from TescaDb.Vendor v

 use [Tesca EDW Database]
 alter table Tesca.DimVendor alter column VendorName nvarchar(250); 
 Create table Tesca.DimVendor
 (
 VendorSK int identity(1,1),
 VendorID int,
 VendorNo nvarchar(50),
 VendorName nvarchar(250),
 RegistartionNo nvarchar(50),
 VendorAddress nvarchar(50),
 City nvarchar(50),
 State nvarchar(50),
 StartDate datetime, 
 EndDate datetime, 
 constraint tesca_dimvendor_sk primary key (VendorSk)
 )

select count(*) as PreCount from Tesca.DimVendor
select count(*) as PostCount from Tesca.DimVendor
 -----------------------------------------------------EMPLOYEE-----------------------------------------------
use [Tesca OLTPDatabase]
select e.EmployeeID, e.EmployeeNo, CONCAT_WS(',',Upper(e.LastName),e.FirstName) as EmployeeName, e.DoB as dateOfBirth,m.MaritalStatus, GetDate() as LoadDate
from Employee e inner join MaritalStatus m on e.MaritalStatus = m.MaritalStatusID


select count(*) as StgSourceCount from Employee e inner join MaritalStatus m on e.MaritalStatus = m.MaritalStatusID

---Employee Staging---

 use[Tesca Staging Database]
 
 Create table tescaDB.employee
 (
 EmployeeID int,
 EmployeeNo nvarchar(50),
 EmployeeName nvarchar(250),
 DateofBirth Date, 
 MaritalStatus nvarchar(50),
 LoadDate Datetime default getdate(),
 constraint tescadb_employee_pk primary key(EmployeeID)
 )

 Truncate table tescaDb.employee
 select count(*) as stgDescCount from tescaDb.employee

 ---Loading to EDW---
use [Tesca Staging Database]
select e.EmployeeID, e.EmployeeNo,e.EmployeeName, e.DateofBirth, e.MaritalStatus
from tescaDb.employee e

use [Tesca EDW Database]

create table tesca.dimEmployee
(
 EmployeeSK int identity(1,1),
 EmployeeID int,
 EmployeeNo nvarchar(50),
 EmployeeName nvarchar(250),
 DateofBirth Date, 
 MaritalStatus nvarchar(50),
 StartDate datetime,
 Enddate datetime,
 constraint tesca_dimemployee_sk primary key(EmployeeSk)
)
select count(*) as PreCount from tesca.dimEmployee
select count(*) as PostCount from tesca.dimEmployee
 ----------------------------------------------------Misconduct-----------------------------------------------
 --no query required, data is in excel file
 --since we dont have it on OLTP, do we need to truncate? YEs every staging need to be truncated and load. 

 use [Tesca Staging Database]
Drop table HRMisconduct.misconduct
 Create table HRMisconduct.misconduct   ---HRMisconduct schema
 (
 misconductid int,
 misconductDescription nvarchar(250),
 LoadDate datetime default getdate(),
 --constraint HRMisconduct_misconduct_pk primary key (misconductid)
 )

 Truncate table HRMisconduct.misconduct
 
 select count(*) as StgDescCount from HRMisconduct.misconduct
 
 --Load Misconduct EDW---

 use [Tesca Staging Database]
 select m.misconductid, m.misconductDescription from HRMisconduct.misconduct m
 group by m.misconductid, m.misconductDescription

 use [Tesca EDW Database]

 Create table Tesca.dimMisconduct
 (
 misconductsk int identity(1,1), 
 misconductid int,
 misconductDescription  nvarchar(250),
 StartDte datetime,
 constraint tesca_dimMisconduct_sk primary key (misconductsk)
 )
select count(*) as PreCount from Tesca.dimMisconduct
select count(*) as PostCount from Tesca.dimMisconduct

 ------------------------------------------------------Decision--------------------------------------------------------

 use [Tesca Staging Database]
 Create table HRMisconduct.Decision
 (
 decisionid int,
 decision nvarchar(250),
 LoadDate datetime default getdate(),
 )

Truncate table HRMisconduct.decision
 --Load Misconduct EDW---

 use [Tesca Staging Database]
 select d.decisionid, d.decision from HRMisconduct.Decision d
 group by d.decisionid, d.decision

 use [Tesca EDW Database]

 select count(*) as stgDescCount from HRMisconduct.decision


 Create table Tesca.dimDecision
 (
 decisionsk int identity(1,1), 
 decisiontid int,
 decision  nvarchar(250),
 StartDte datetime,
 constraint tesca_dimDecision_sk primary key (Decisionsk)
 )

 select * from Tesca.dimDecision

 select count(*) as PreCount from Tesca.dimDecision
select count(*) as PostCount from Tesca.dimDecision
 -------------------------------------------------------------ABSENT CATEGORY------------------------------------------------------------------
--Load into Staging--
 use [Tesca Staging Database]
 Create table HRAbsence.AbsentCategory
 (
   Categoryid int,
   Category nvarchar(250),
   LoadDate datetime default getdate(),
 )

Truncate table HRAbsence.AbsentCategory
 --Load absent Category EDW---

use [Tesca Staging Database]
 select d.Categoryid, d.Category from HRAbsence.AbsentCategory d
 group by d.Categoryid, d.Category

 use [Tesca EDW Database]

 select count (*) as stgDescCount from HRAbsence.AbsentCategory

 Create table Tesca.dimAbsentCategory
 (
 categorysk int identity(1,1), 
 Categoryid int,
 category nvarchar(250),
 StartDate datetime,
 constraint tesca_dimAbsentCategory_sk primary key (Categorysk)
)

 select count(*) as PreCount from Tesca.dimAbsentCategory
select count(*) as PostCount from Tesca.dimAbsentCategory

 ----------------------------------------------Create DimHOUR Dimension---------------------------------------------
 
/*select    datepart(HOUR, getdate())*60+ datepart(MINUTE, getdate()) totalminutes,  datepart(HOUR, getdate()) thour, datepart(MINUTE, getdate()) minu

if edmonton time  = 10 am  then class start
if  edmontontime >= 5 pm  then class stop

if   ( ( hour(edmontime)+1  )* 60 ) - 10                    --- 900          890 

  if   minute(edmontime) =  (( ( hour(edmontime)+1  )* 60 ) - 10 )    then shorttime 


  Pocket -> Paper money, coins (Data Types) 
    - > Mould block 
  Pocket <> Water

  declare @pocket nvarchar(10)='efddddddddddddddddddddddddddddddffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffvcdvdfdfwdfffffdscsdfsdsas'
  --- int, bigint, char, varchar, nvarchar, table, float, decimal, money

  declare @pocket Table
  (
    
  )

  select @pocket*/
 
 
 set nocount on
  ---Declarative block
  declare @max int =50
  declare @currentCount int= 1
     --- Logic Area-----
	While @currentCount<=@max     ----  2<=10 ->True
	BEGIN 
		  
		  ---select @currentCount 
		  IF @currentCount%2 =1
		    print('Male :'+ cast(@currentCount as nvarchar))
		  ELSE
			print('FeMale :'+ cast(@currentCount as nvarchar))

		  select @currentCount=@currentCount+1    ----  @currentCount=3+1 = 2

	END
	Print('End of execution')
--Hours we have is 0-23

------------------------ dimHour

use [Tesca EDW Database]

Create Table Tesca.DimHour 
(
  Hoursk int identity(1,1),
  Time_Hour int,   ---   0 - 23 
  PeriodOfDay   nvarchar(50),  ----   0 -> Midnight, 1 to 4 -> Early hours, 5  to 11 Morning  -> 12 Noon, 13 to 16 afternoon, 17 to 20 Evening, 21 to 23 Night
  BusinessHour    nvarchar(50), ---->  0 to 6 closed, 7 to 17 Open , 18 to 22 closed
  StartDate datetime default getdate(),
  constraint Tesca_dimHour_sk primary key(hoursk)
)


select * from tesca.DimHour

/*
declare @hourcount int = 0
declare @PeriodOfDay nvarchar(50)
declare @BusinessHour    nvarchar(50)

BEGIN
	WHILE @hourcount<=23
		BEGIN 
		 IF @hourcount = 0 
		   select @PeriodOfDay='Mid Night'

		 IF @hourcount >=1 AND  @hourcount <=4
			select @PeriodOfDay='Early Hour'

		IF @hourcount >=5 AND  @hourcount <=11
			select @PeriodOfDay='Morning'

		IF @hourcount = 12
		   select @PeriodOfDay='Noon'

		IF @hourcount >=13 AND  @hourcount <=16
			select @PeriodOfDay='Afternoon'

		IF @hourcount >=17 AND  @hourcount <=20
			select @PeriodOfDay='Evening'

		IF @hourcount >=21 AND  @hourcount <=23
			select @PeriodOfDay='Night'

		Select @hourcount, @PeriodOfDay
		select @hourcount = @hourcount+1
		END 
END
*/

select Object_ID(N'tesca.DimHour') 

CREATE Procedure tesca.spDimHour
AS
BEGIN	
   declare @hourcount int = 0
   declare @PeriodOfDay nvarchar(50)
   declare @BusinessHour nvarchar(50)

 ---IF (select Object_ID(N'tesca.DimHour')) is not  null
 ---Truncate table tesca.DimHour 

	WHILE @hourcount<=23
	  BEGIN 
		
		insert into tesca.DimHour(Time_Hour,PeriodOfDay,BusinessHour,StartDate)
		select @hourcount as Time_hour, 
		 case 
		   When  @hourcount = 0  then 'Mid Night'
		   When  @hourcount >=1 AND  @hourcount <=4 then 'Early Hour'
		   When  @hourcount >=5 AND  @hourcount <=11  then 'Morning'
		   When @hourcount = 12  Then 'Noon'
		   When @hourcount >=13 AND  @hourcount <=16 Then 'Afternoon'
		   When @hourcount >=17 AND  @hourcount <=20 Then 'Evening'
		   When @hourcount >=21 AND  @hourcount <=23 Then 'Night'
		   END  as PeriodOfDay,
	   	case		
		 ---0 to 6 closed, 7 to 17 Open , 18 to 23 closed		 
		 when  @hourcount between 0 and 6  OR  @hourcount between 18 and 23 Then 'Closed'
		 when  @hourcount between 7 AND 17 Then 'Open'
		 --when  @hourcount>0 AND @hourcount<=6 Then 'Closed'
		 --when  @hourcount>=18 AND @hourcount<=22 Then 'Closed'
		 --when  @hourcount>=7 AND @hourcount<=17 Then 'Open'		 
		 END as BusinessHour, GETDATE() as StartDate
		
	 select @hourcount = @hourcount+1
	 END 
END

 -----------------------------------------Date Dimension--------------------------------------------------------------------

 --------------------1. Create date dimension

 Use [Tesca EDW Database]

 drop table tesca.DimDate
 alter table tesca.DimDate alter column DateSK Date;
 Create table tesca.DimDate
 (
 DateSK int,
 ActualDate Date,
 ActualYear int, 
 ActualQuarter nvarchar(2),
 ActualMonth int,
 EnglishMonth nvarchar(50),
 SpanishMonth nvarchar(50),
 HinduMonth nvarchar(50), 
 EnglishDayofWeek nvarchar(50),
 SpanishDayofWeek nvarchar(50),
 HinduDayofWeek nvarchar(50),
 ActualWeekDay nvarchar(50), 
 ActualWeek int,
 ActualDayofYear int,
 ActualDayofMonth int,
 constraint tesca_dimDate_sk primary key(DateSK) 
 )

 ----lets get datekey out from GetDate()

 select convert(date, GETDATE())
 select convert(nvarchar(8), GETDATE(), 112)--Surrogate Key
 select DATEPART(Month, GETDATE())
 select 'Q' + cast(DATEPART(Quarter, getdate())as nvarchar)

 --Chaitra, Vaisakha, Jyaistha, Asadha, Shravana, Bhadra, Ashwin, Kartika, Mārgasirsa (Agrahayana), Pausha, Magha, and Phalguna
--"enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "Agosto", :septiembre", "octubre", "noviembre", and "diciembre"
--- "janvier" , "février" , "mars" , "avril" , "mai" , "juin" , "juillet", "août" , "septembre" , "octobre" , "novembre"  and "décembre"

--from and to  ----  1940 to 2050

select DATEFROMPARTS(2050,12,31), DATEFROMPARTS(1940,01,01), DATEDIFF(day, '2022-09-01','2022-09-25')
select DATEDIFF(day, DATEFROMPARTS(1940,01,01),DATEFROMPARTS(2050,12,31))
-- we are doing this to make loop...- Total days 50542

--Intention is to get SK
/*declare @noofdays int= DATEDIFF(day, DATEFROMPARTS(1940,01,01),DATEFROMPARTS(2050,12,31))
declare @currentday int=0
While @currentday<=@noofdays
BEGIN
print(DATEADD(day,@currentday, DATEFROMPARTS(1940,01,01)) 
Select @currentday= @currentday+1
END
*/
---make it dynamic using exce from Stored Procedure



CREATE procedure tesca.spdimGenerator(@EndDate Date)
AS
BEGIN
SET NOCOUNT ON
declare @StartDate Date= (
                           select convert(date, min(StartDate)) FROM
						     (   select Min(TransDate) startdate from [Tesca OLTPDatabase].dbo.PurchaseTransaction
						         union all
							     select Min(TransDate) startdate from [Tesca OLTPDatabase].dbo.SalesTransaction
							  )a
						   )

declare @noofdays int= DATEDIFF(day, @StartDate,@EndDate)
declare @currentday int=0
declare @currentdate date
----Have another Begin-End, second Begin-End belongs to While loop. Truncate is faster comapred to Delete
BEGIN
  IF (select Object_ID(N'tesca.DimDate')) is not null
    Truncate table tesca.DimDate

While @currentday<=@noofdays
BEGIN
  select @CurrentDate= (DATEADD(day,@currentday, @StartDate) )

  insert into tesca.dimDate(DateSk,ActualDate, ActualYear,ActualQuarter,ActualMonth, EnglishMonth, SpanishMonth,HinduMonth,EnglishDayofWeek,
  SpanishDayofWeek,HinduDayofWeek,ActualWeekDay, ActualWeek,ActualDayofYear,ActualDayofMonth)
  select convert(int,convert(nvarchar(8), @currentdate, 112)) as Datekey, @currentdate as ActualDate, YEAR(@currentdate) as ActualYear, 
  'Q'+cast(DATEPART(Q,@currentdate) as nvarchar) as ActualQuarter, DATEPART(Month, @CurrentDate) as ActualMonth, Datename(month, @currentDate) EnglishMonth, 
  case DATEPARt(Month, @currentdate)
    When 1 then 'enero'
	When 2 then 'febrero'
	When 3 then 'marzo'
	When 4 then 'abril'
	When 5 then 'mayo'
	When 6 then 'junio'
	When 7 then 'julio'
    When 8 then 'Agosto'
    When 9 then 'septiembre'
    When 10 then 'octubre'
    When 11 then 'noviembre'
    When 12 then 'diciembre'
  END SpanishMonth,
   case DATEPARt(Month, @currentdate)
    When 1 then 'Chaitra'
	When 2 then 'Vaisakhao'
	When 3 then 'Jyaistha'
	When 4 then 'Asadha'
	When 5 then 'Shravana'
	When 6 then 'Ashwin'
	When 7 then 'Kartika'
    When 8 then 'Agosto'
    When 9 then 'Mārgasirsa'
    When 10 then 'Pausha'
    When 11 then 'Magha'
    When 12 then 'Phalguna'
   END HinduMonth,
   DATENAME(Weekday, @currentdate) as EnglsihdayofWeek, 
   case DATEPART(Weekday,@CurrentDate)
     When 1 then 'Domingo'
	 When 2 then 'Lunes'
	 When 3 then 'Martes'
	 When 4 then 'Mierocoles'
	 When 5 then 'Jueves'
	 When 6 then 'Viernes'
	 When 7 then 'Sabado'
   End SpanishDayofWeek,
    case DATEPART(Weekday,@CurrentDate)
     When 1 then 'Ravivar'
	 When 2 then 'Saumvar'
	 When 3 then 'Mangalvar'
	 When 4 then 'Budhwar'
	 When 5 then 'Guruwar'
	 When 6 then 'Shukrawar'
	 When 7 then 'Shanivar'
   End HinduDayofWeek,

DatepArt (WEEkday, @currentDate) as ActualWeekday, Datepart(week, @CurrentDate) as ActualWeek, 
Datepart (Dayofyear, @currentdate) as ActualDayofYear, Day(@currentdate) as ActualDayofMonth
Select @currentday= @currentday+1
END
END
END

exec tesca.spdimGenerator '2110-12-31'
select * from tesca.DimDate
select * from tesca.DimHour

-----------------------------tescafactSaleAnalysis-------------------------------------------------

use [Tesca OLTPDatabase]

IF(select count(*) from [Tesca EDW Database].tesca.Fact_sales_analysis) >0 
 BEGIN
  select s.TransactionID, s.TransactionNo, convert(date,TransDate) as TransDate, datepart(hour, TransDate) TransHour, 
  convert(date,OrderDate) as OrderDate, datepart(hour,OrderDate) OrderHour, convert(date,deliveryDate) DeliveryDate, 
  ChannelID, CustomerID, EmployeeID, ProductID, SToreID,PromotionID, Quantity, TaxAmount, LineAmount, LineDiscountAmount, getdate() as LoadDate
  from SalesTransaction s
  Where  convert(date, TransDate) = dateadd(day, -1, convert(date,getdate()))  ----n-1
 END
ELSE
 BEGIN
   select s.TransactionID, s.TransactionNo, convert(date,TransDate) as TransDate, datepart(hour, TransDate) TransHour, 
   convert(date,OrderDate) as OrderDate, datepart(hour,OrderDate) OrderHour, convert(date,deliveryDate) DeliveryDate, 
   ChannelID, CustomerID, EmployeeID, ProductID, SToreID,PromotionID, Quantity, TaxAmount, LineAmount, LineDiscountAmount, getdate() as LoadDate
   from SalesTransaction s
   Where  convert(date, TransDate) <= dateadd(day, -1, convert(date,getdate()))   --- from inception to n-1
 END
----------------------------------------------------------------------------------------------------------------------------------------------------
 declare @stgSourceCount bigint=0
 IF(select count(*) from [Tesca EDW Database].tesca.Fact_sales_analysis) >0 
 BEGIN
  select @StgSourceCount= (
  select count(*) as StgSourceCount
  from SalesTransaction s
  Where  convert(date, TransDate) = dateadd(day, -1, convert(date,getdate()))
  )  ----n-1
 END
ELSE
 BEGIN
    select @StgSourceCount= (
	select count(*) as StgSourceCount
   from SalesTransaction s
   Where  convert(date, TransDate) <= dateadd(day, -1, convert(date,getdate()))
   )   --- from inception to n-1
 END
 select @stgSourceCount as StgSourceCount
 -----------------------------------------------------------------------------------------------------------------------------------------------------


 --------------------------------------SalesStaging--------------------------------------------

 use [Tesca Staging Database]

Truncate Table tescaDb.sales_trans
Drop Table tescaDb.sales_trans

select * from tescaDb.sales_trans

 Create Table tescaDb.sales_trans
 (
 TransactionID int,
 TransactionNo nvarchar(50),
 TransDate DATE,
 TransHour INT,
 OrderDate DATE,
 OrderHour INT,
 DeliveryDate DATE,
 ChannelID INT,
 CustomerID INT,
 EmployeeID INT,
 ProductID INT,
 StoreID INT,
 PromotionID INT,
 Quantity FLOAT, 
 TaxAmount FLOAT,
 LineAmount FLOAT,
 LineDiscountAmount FLOAT,
 LoadDate DATETIME DEFAULT GETDATE(),
 CONSTRAINT TescaDb_SALES_TRANS_PK PRIMARY KEY (TransactionID)
 )

 ---Tesca Sales transaction to EDW----
 use [Tesca Staging Database]
 select TransactionID, TransactionNo, TransDate, TransHour, OrderDate, OrderHour, DeliveryDate, ChannelID, CustomerID, EmployeeID, ProductID, StoreID,
 PromotionID, Quantity, TaxAmount, LineAmount, LineDiscountAmount,GetDate() as LoadDate from tescaDb.sales_Trans

 --select count(*) as stgDescCount from tescaDb.sales_trans 

 use [Tesca EDW Database]
 select DateSK,ActualDate from tesca.DimDate
 select Categorysk,categoryid from tesca.dimAbsentCategory
 select CustomerSK,CustomerID from tesca.dimCustomer where EndDate is null
 select EmployeeSK,EmployeeID from tesca.dimEmployee where EndDate is null
 select decisionsk,decisiontid from tesca.dimDecision
 select Hoursk,Time_Hour from tesca.DimHour
 select misconductsk,misconductid from tesca.dimMisconduct
 select ChannelSK,ChannelId from tesca.DimMPosChannel where EndDate is null
 select productSK,productID from tesca.dimProduct where EndDate is null
 select promotionSk, promotionID from tesca.dimPromotion
 select StoreSk, StoreID from tesca.DimStore
 select VendorSK,Vendorid from tesca.DimVendor where EndDate is null




drop table tesca.Fact_sales_analysis

 create table tesca.Fact_sales_analysis
 (
 sales_analysis_sk bigint identity(1,1),
 TransactionID int,
 TransactionNo nvarchar(50),
 TransDateSk int,
 TransHourSk int,
 OrderDateSk int,
 OrderHourSk int,
 DeliveryDateSk int,
 ChannelSk int,
 CustomerSk int,
 EmployeeSk int,
 ProductSk int,
 StoreSk int,
 PromotionSK int, 
 Quantity float, 
 TaxAmount Float,
 LineAmount float,
 LineDoscountAmount float,
 LoadDate datetime,
 constraint tesca_sales_analysis_sk primary key(sales_analysis_sk), 
 constraint tesca_sales_transDatesk foreign key(TransDateSk) references tesca.dimdate(datesk), 
 constraint tesca_sales_transHoursk foreign key(TransHourSk) references tesca.dimHour(Hoursk),
 constraint tesca_sales_OrderDatesk foreign key(OrderDateSk) references tesca.dimdate(Datesk),
 constraint tesca_sales_OrderHoursk foreign key(OrderHourSk) references tesca.dimHour(Hoursk), 
 constraint tesca_sales_DeliveryDatesk foreign key(DeliveryDateSk) references tesca.dimdate(datesk), 
 constraint tesca_sales_Channelsk foreign key(ChannelSk) references tesca.dimMPosChannel(ChannelSk),
 constraint tesca_sales_Customersk foreign key(CustomerSk) references tesca.dimCustomer(Customersk), 
 constraint tesca_sales_Employeesk foreign key(EmployeeSk) references tesca.dimEmployee(EmployeeSk), 
 constraint tesca_sales_Productsk foreign key(ProductSk) references tesca.dimProduct(productSk), 
 constraint tesca_sales_Storesk foreign key(StoreSk) references tesca.dimStore(StoreSk), 
 constraint tesca_sales_Promotionsk foreign key(PromotionSk) references tesca.dimPromotion(promotionsk),
 )

 select * from tesca.Fact_sales_analysis

 select count(*) as PreCount from tesca.Fact_sales_analysis
 select count(*) as PostCount from tesca.Fact_sales_analysis

 ------------------------------Purchase Analysis Fact Business Process---------------------------------------------
 use [Tesca OLTPDatabase]

 If( select count(*) from [Tesca EDW Database].tesca.Fact_sales_analysis) <0
 Begin
  Select p.TransactionID, p.TransactionNO, convert(date,TransDate) TransDate, Convert(date,OrderDate) OrderDate, Convert(date,p.DeliveryDate) DeliveryDate,
  convert(date, p.ShipDate) ShipDate, p.VendorID, p.EmployeeID, p.ProductID, p.StoreID, p.Quantity, p.LineAmount, p.TaxAmount, 
  Datediff(day, Convert(date, OrderDate), convert(date, DeliveryDate))+1 Delivery_Services
  from PurchaseTransaction p Where convert(date, TransDate)<= DATEADD(day, -1,convert(date,getdate())) --- from inception to n-1
 END
Else
 Begin
  Select p.TransactionID, p.TransactionNO, convert(date,TransDate) TransDate, Convert(date,OrderDate) OrderDate, Convert(date,p.DeliveryDate) DeliveryDate,
  convert(date, p.ShipDate) ShipDate, p.VendorID, p.EmployeeID, p.ProductID, p.StoreID, p.Quantity, p.LineAmount, p.TaxAmount, 
  Datediff(day, Convert(date, OrderDate), convert(date, DeliveryDate))+1 Delivery_Services
  from PurchaseTransaction p Where convert(date, TransDate)= DATEADD(day, -1,convert(date,getdate()))   ---n-1
 END

 ---------------------------------------------------------------------------------------------------------------------
 ----------------------------------------------------------------------------------------------------------------------
 declare @stgSourceCount bigint=0

 If( select count(*) from [Tesca EDW Database].tesca.Fact_Purchase_Analysis) <=0
 Begin
 select @StgSourceCount= (
 Select count(*)
  from PurchaseTransaction p Where convert(date, TransDate)<= DATEADD(day, -1,convert(date,getdate()))
  )--- from inception to n-1
 END
Else
 Begin
 select @StgSourceCount= (
 Select count(*)
 from PurchaseTransaction p Where convert(date, TransDate)= DATEADD(day, -1,convert(date,getdate()))
 )---n-1
 END
 select @StgSourceCount as StgSourceCount
 -------------------------------------------------------------------------------------------------------------------

--------Purchase Fact Analysis Staging--------------------------------------------
 use [Tesca Staging Database]

-- Drop table if exists tescaDB.Purchase_Analysis

select count(*) as StgDescCount from tescaDB.Purchase_Analysis

Truncate table tescaDB.Purchase_Analysis
Drop table tescaDb.Purchase_Analysis

 Create table tescaDb.Purchase_Analysis
 (
 TransactionID int,
 TransactionNO nvarchar(50),
 TransDate Date,
 OrderDate Date,
 DeliveryDate Date,
 ShipDate Date,
 VendorID int,
 EmployeeID int,
 ProductID int,
 StoreID int,
 Quantity float,
 LineAmount float,
 TaxAmount float,
 Delivery_Services int, --calculated column, this will slow performance bcoz eof dynamic calc if isnated of int you use query
 LoadDate datetime default getDate(),
 constraint tescaDb_purchase_Analysis_pk primary key(TransactionID)
 )
 Truncate Table tescaDB.Purchase_Analysis

 ----EDW Purchase Process Loading----
 Select  TransactionID, TransactionNO, TransDate, OrderDate, DeliveryDate, ShipDate, VendorID, EmployeeID, ProductID, StoreID, Quantity,
 LineAmount, TaxAmount, Delivery_Services, getdate() as LoadDate from tescaDb.Purchase_Analysis

 use [Tesca EDW Database]

 select count(*) as PreCount from tesca.Fact_Purchase_Analysis
 select count(*) as PostCount from tesca.Fact_Purchase_Analysis

 


 drop table tesca.Fact_Purchase_Analysis
 Create table tesca.Fact_Purchase_Analysis
 (
 Purchase_analysis_Sk bigint identity(1,1),
 TransactionID int, 
 TransactionNO nvarchar(50),
 TransDateSk int,
 OrderDateSK int,
 DeliveryDateSk int,
 ShipDateSk int,
 VendorSk int,
 EmployeeSk int,
 ProductSk int,
 StoreSk int,
 Quantity float,
 LineAmount float,
 TaxAmount float,
 Delivery_Services int,
 constraint tesca_Purchase_Analysis_sk primary key(purchase_analysis_sk),
 constraint tesca_purchase_transDateSk foreign key(TransDateSk) references tesca.dimdate(datesk),
 constraint tesca_purchase_OrderDateSk foreign key(OrderDateSK) references tesca.dimdate(datesk),
 constraint tesca_purchase_DeliveryDateSk foreign key(DeliveryDateSk) references tesca.dimdate(datesk),
 constraint tesca_purchase_ShipDateSk foreign key(ShipDateSk) references tesca.dimdate(datesk),
 constraint tesca_purchase_VendorSk foreign key(VendorSk) references tesca.dimVendor(Vendorsk),
 constraint tesca_purchase_EmployeeSk foreign key(EmployeeSk) references tesca.dimEmployee(Employeesk),
 constraint tesca_purchase_ProductSk foreign key(ProductSk) references tesca.dimProduct(Productsk),
 constraint tesca_purchase_StoreSk foreign key(StoreSk) references tesca.dimStore(Storesk),
 )

 ----------------------------HR fact Overtime Analysis -----------------------------------
 use [Tesca Staging Database]

 select count(*) as StgDescCount from tescaDb.Overtime_Trans
  select * from tescaDb.Overtime_Trans

Drop table tescaDb.Overtime_Trans

 Create table tescaDb.Overtime_Trans
 (
 OvertimeID bigint,
 EmployeeNo nvarchar(50),
 FirstName nvarchar(50),
 LastName nvarchar(50),
 STartOvertime datetime,
 EndOverTime datetime,
 LoadDate datetime
 )

 select * from tescaDb.Overtime_Trans
 Truncate table tescaDb.Overtime_Trans

 --EDW for overtime is what? in ssis we created new EDW connection manager

 select count(*) as edwcount from tesca.Fact_Hr_Overtime
 select count(employeeSK) from tesca.Fact_Hr_Overtime

-----Staging Query---


 select count(*) as PreCount from tesca.Fact_Hr_Overtime
 select count(*) as PostCount from tesca.Fact_Hr_Overtime

  Truncate table tescaDb.Overtime_Trans

 select OvertimeID, EmployeeNo, FirstName, LastName, convert(date,StartOvertime) StartOverTimeDate,
 datepart(hour, StartOvertime) StartOverTimeHour, convert(date,EndOvertime) EndOverTimeDate, datepart(hour,EndOverTime) EndOverTimeHour,
 Datediff (hour, StartOverTime, EndOverTime) Overtimehour
 from tescaDb.Overtime_Trans
 Where OvertimeID in
 (
 select min(OvertimeID) from tescaDb.Overtime_Trans group by EmployeeNo, FirstName, LastName, StartOvertime, EndOvertime)

 ---Fact Overtime-----

 use [tesca EDW Database]

 Drop table tesca.Fact_Hr_Overtime

 select * from tesca.Fact_Hr_Overtime
  Truncate table tesca.Fact_Hr_Overtime
 Create table tesca.Fact_Hr_Overtime
 (
 Hr_Overtime_SK bigint identity(1,1),
 EmployeeSK int,
 StartOverDateSk int,
 StartOverHourSk int,
 EndOverDateSk int,
 EndOverHourSk int,
 Overtimehour int,
 LoadDate datetime default getdate(),
 constraint tesca_hr_overtime_sk primary key (Hr_Overtime_SK),
 Constraint tesca_hr_overtime_employeesk foreign key (EmployeeSK) references tesca.dimEmployee(EmployeeSk),
 Constraint tesca_hr_overtime_StartOverDatesk foreign key (StartOverDateSk) references tesca.dimDate(dateSk),
 Constraint tesca_hr_overtime_StartOverHoursk foreign key (StartOverHourSk) references tesca.dimHour(HourSk),
 Constraint tesca_hr_overtime_EndOverDatesk foreign key (EndOverDateSk) references tesca.dimDate(dateSk),
 Constraint tesca_hr_overtime_EndOverHoursk foreign key (EndOverHourSk) references tesca.dimHour(HourSk)
 )

 ----------------Absent Data (Fact Absence analysis)--------------

 truncate table tescaDb.hr_absence_analysis
 select count(*) as stgDescCount from tescaDb.hr_absence_analysis
 select count(*) as edwCount from tesca.fact_hr_absence_analysis

 use[Tesca Staging Database]

 drop Table tescaDb.hr_absence_analysis

 Create Table tescaDb.hr_absence_analysis
 (
 empid int,
 store int,
 absent_date date,
 absent_hour int,
 absent_category int,
 Loaddate datetime default getdate()
 )


 With absent_data (RowID, AbsentKey, empid, store, absent_date, Absent_hour, absent_category)
 AS
 (
 select
 ROW_NUMBER() over (order by empid, store, absent_date, absent_hour, absent_category) as RowID,
 concat_WS ('~', empid, store,absent_date,absent_hour,absent_category) as absentKey,
 empid, store, absent_date, Absent_hour, absent_category
 from tescaDb.hr_absence_analysis
 )
 select empid, store, absent_date, Absent_hour, absent_category from Absent_Data
 Where rowID in (select min(RowID) from Absent_Data group by Absentkey) 

 ---Fact Absent Data----

 use [Tesca EDW Database]

 select count(*) as PreCount from tesca.fact_hr_absence_analysis
  select count(*) as PostCount from tesca.fact_hr_absence_analysis
   select count(*) as PreCount from tesca.fact_hr_absence_analysis
Truncate Table tesca.fact_hr_absence_analysis

 Create Table tesca.fact_hr_absence_analysis
 (
 hr_absence_analysis_Sk bigInt identity(1,1),
 EmployeeSk int,
 storeSk int,
 absentdateSK int,
 absent_hour int,
 absentcategorySK int,
 LoadDate datetime default getdate(),
 constraint tesca_hr_absence_analysis_Sk primary key(hr_absence_analysis_Sk),
 Constraint tesca_hr_absence_analysis_employeesk foreign key (EmployeeSk) references tesca.dimEmployee(EmployeeSk),
 Constraint tesca_hr_absence_analysis_Storesk foreign key (StoreSK) references tesca.dimStore(StoreSk),
 Constraint tesca_hr_absence_analysis_absentDatesk foreign key (absentdateSK) references tesca.dimdate(datesk),
 Constraint tesca_hr_absence_analysis_absentCategorysk foreign key (absentcategorySK) references tesca.dimAbsentCategory (CategorySk)
 )

 select * from  tesca.fact_hr_absence_analysis

 --------------------------------Misconduct----------

 use [Tesca Staging Database]
 -----------------------
 truncate table tescaDb.hr_misconduct_analysis

 select count(*) as edwcount from tesca.fact_hr_misconduct_analysis
 select count(*) as StgDescCount from tescaDb.hr_misconduct_analysis
 --------------------------------
Drop Table tescaDb.hr_misconduct_analysis
 Create Table tescaDb.hr_misconduct_analysis
 (
 empid int,
 store int,
 Misconduct_date date,
 Misconduct_id int,
 decisionId int,
 Loaddate datetime default getdate()
 )


 With misconduct_data (RowID, MisconductKey, empid, store, Misconduct_date, Misconduct_id, decisionId)
 AS
 (
 select
 ROW_NUMBER() over (order by empid, store, Misconduct_date, Misconduct_Id, decisionid) as RowID,
 concat_WS ('~', empid, store, Misconduct_date, Misconduct_id,decisionId) as MisconductKey,
 empid, store,  Misconduct_date, Misconduct_id, decisionId
 from tescaDb.hr_misconduct_analysis
 )
 select empid, store, Misconduct_date, Misconduct_Id, decisionid, getdate() as LoadDate from Misconduct_Data
 Where rowID in (select max(RowID) from Misconduct_Data group by MisconductKey) 

 ---Fact Misconduct table Data----

 use [Tesca EDW Database]

 select count(*) as PreCount from tesca.fact_hr_misconduct_analysis
 select count(*) as PostCount from tesca.fact_hr_misconduct_analysis

 
 Truncate Table tesca.fact_hr_misconduct_analysis

 Create Table tesca.fact_hr_misconduct_analysis
 (
 hr_misconduct_analysis_Sk bigInt identity(1,1),
 EmployeeSk int,
 storeSk int,
 MisconductdateSk int,
 MisconductSk int,
 decisionSk int,
 Loaddate datetime default getdate(),
 constraint tesca_hr_Misconduct_analysis_Sk primary key(hr_misconduct_analysis_Sk),
 Constraint tesca_hr_Misconduct_analysis_employeesk foreign key (EmployeeSk) references tesca.dimEmployee(EmployeeSk),
 Constraint tesca_hr_Misconduct_analysis_Storesk foreign key (StoreSK) references tesca.dimStore(StoreSk),
 Constraint tesca_hr_Misconduct_analysis_MisconductDatesk foreign key (misconductDateSK) references tesca.dimdate(datesk),
 Constraint tesca_hr_Misconduct_analysis_misconductSk foreign key (misconductSk) references tesca.dimMisconduct(misconductSk),
 Constraint tesca_hr_Misconduct_analysis_DecisionSk foreign key (DecisionSk) references tesca.dimDecision(DecisionSk)
 )


truncate table [tesca].[fact_hr_absence_analysis]
truncate table[tesca].[fact_hr_misconduct_analysis]
truncate table[tesca].[Fact_Hr_Overtime]
truncate table[tesca].[Fact_Purchase_Analysis]
truncate table[tesca].[Fact_sales_analysis]
truncate table[tesca].[dimAbsentCategory]
truncate table[tesca].[dimCustomer]
truncate table[tesca].[DimDate]
truncate table[tesca].[dimDecision]
truncate table[tesca].[dimEmployee]
truncate table[tesca].[DimHour]
truncate table[tesca].[dimMisconduct]
truncate table[tesca].[DimMPosChannel]
truncate table[tesca].[dimPromotion]
truncate table[tesca].[DimStore]
truncate table[tesca].[DimVendor]
truncate table [tesca].[dimProduct]