--output Demo

--Basic data
if(object_id('dbo.prd','U') is not null) drop table dbo.prd;
CREATE TABLE dbo.prd(
id bigint not null identity(1,1) constraint pk_prd primary key,
code varchar(20) not null,
pname varchar(50) not null,
val decimal(20,8) not null,
note varchar(20) not null default('Empty'),
changelog varchar(max) null
constraint BPK$PRD unique nonclustered (code,pname) 
)
insert into prd (code,pname,val) values
('10001','M-AS',10.235),('10002','M-AK',13.25),('10003','M-AL',16.82);

if(object_id('prdUp','U') is not null) drop table prdUp;
SELECT id, code, pname, val+100 as val into prdUp from prd;


------insert output
----直接output
insert into prd (code,pname,val) 
output inserted.id,inserted.code,inserted.pname,inserted.val,inserted.note,inserted.changelog
select * from 
(values('Test1','M-AS',11),('Test2','M-AK',12),('Test3','M-AL',13)) as D(code,pname,val);
--不在插入字段内的字段（自增的，默认的）也可以被output
----output结果插入中间表（必须为已经存在的表，不同于select into）
--表变量
DECLARE @prdInsert TABLE(
id BIGINT, code VARCHAR(20), pname VARCHAR(50), val DECIMAL(20, 8), note VARCHAR(20), changelog VARCHAR(MAX),
ADDCOLUMN datetime);
--output into 
insert into prd (code,pname,val) 
output inserted.id,inserted.code,inserted.pname,inserted.val,inserted.note,inserted.changelog,
       getdate() ADDCOLUMN --自定义字段
into @prdInsert
select * from 
(values('Test4','M-AS',11),('Test5','M-AK',12),('Test6','M-AL',13)) as D(code,pname,val);
--show data
select * from @prdInsert;
/*小结：
output的范围：插入列，被插入表的生成列，自定义列
output into:对象必须是已经存在的表*/

------delete output
--场景：归档删除数据
delete from prd 
output deleted.id,deleted.code,deleted.pname
where code like 'Test%';

------update output
--场景：记录数据变化
UPDATE O
   SET val = P.val
OUTPUT inserted.id AS id, deleted.val AS oldVal, inserted.val AS newVal
  FROM prd O JOIN prdUp P ON O.code = p.code AND o.pname = p.pname

------merge output
select * from prd

select * from 
(values('10001','M-AS',100),('10001','M-ZZ',10)) AS D(code,pname,val)




-------------------------简单 INSERT 语句
declare @code varchar(20)='10014'
declare @t table(id int)

if((select count(1) from testbzm where code=@code)=0) 
begin
 insert into testbzm(code) 
 output INSERTED.ID into @t
 values(@code) --(select '10017' id) 会报错, //select @code 不会报错（没有括号）
end

 select * from @t

 /*
 消息 208，级别 16，状态 0，第 25 行
Invalid object name '#t'.
*/
 --中间结果只能存在表变量中，不能用临时表


 ---------------------------------DEMO
 --将 OUTPUT INTO 用于简单 INSERT 语句
use AdventureWorks
go
--定义一个表格变量
declare @mytablevar table( ScrapReasonID smallint,
                           Name1 varchar(50),
                           ModifiedDate datetime)
insert into Production.ScrapReason
output inserted.ScrapReasonID,inserted.[Name],inserted.ModifiedDate into @mytablevar
values ('operator error',getdate());
--显示@mytablevar中的数据
select * from @mytablevar
--显示Production.ScrapReason表中的数据
select * from Production.ScrapReason
go


--将 OUTPUT 用于 INSERT…SELECT 语句
use AdventureWorks
go
if object_id('dbo.EmployeeSales','u') is not null
drop table dbo.EmployeeSales
go
create table dbo.EmployeeSales
(
    EmployeeID nvarchar(11) not null,
    LastName nvarchar(20) not null,
    FirstName nvarchar(20) not null,
    CurrentSales money not null,
    ProjectedSales money not null

)
go
insert into dbo.EmployeeSales
output inserted.EmployeeID,inserted.LastName,inserted.FirstName,inserted.CurrentSales,inserted.ProjectedSales
SELECT e.EmployeeID, c.LastName, c.FirstName, sp.SalesYTD, sp.SalesYTD * 1.10
FROM HumanResources.Employee AS e
        INNER JOIN Sales.SalesPerson AS sp
        ON e.EmployeeID = sp.SalesPersonID 
        INNER JOIN Person.Contact AS c
        ON e.ContactID = c.ContactID
    WHERE e.EmployeeID LIKE '2%'
    ORDER BY c.LastName, c.FirstName;
GO
SELECT EmployeeID, LastName, FirstName, CurrentSales, ProjectedSales
FROM dbo.EmployeeSales;
GO

--将 OUTPUT 用于 DELETE 语句
USE AdventureWorks;
GO
DELETE Sales.ShoppingCartItem
    OUTPUT DELETED.* ;
--验证表中所有数据都被删除
SELECT COUNT(*) AS [Rows in Table] FROM Sales.ShoppingCartItem;
GO


--将 OUTPUT INTO 用于 UPDATE
USE AdventureWorks;
GO
DECLARE @MyTableVar table(
    EmpID int NOT NULL,
    OldVacationHours int,
    NewVacationHours int,
    ModifiedDate datetime);
UPDATE TOP (10) HumanResources.Employee
SET VacationHours = VacationHours * 1.25 
OUTPUT INSERTED.EmployeeID,
       DELETED.VacationHours,
       INSERTED.VacationHours,
       INSERTED.ModifiedDate
INTO @MyTableVar;
--显示@MyTableVar的值
SELECT EmpID, OldVacationHours, NewVacationHours, ModifiedDate
FROM @MyTableVar;
GO
--显示插入表的值
SELECT TOP (10) EmployeeID, VacationHours, ModifiedDate
FROM HumanResources.Employee;
GO


-- 使用 OUTPUT INTO 返回表达式
USE AdventureWorks;
GO
DECLARE @MyTableVar table(
    EmpID int NOT NULL,
    OldVacationHours int,
    NewVacationHours int,
    VacationHoursDifference int,
    ModifiedDate datetime);
UPDATE TOP (10) HumanResources.Employee
SET VacationHours = VacationHours * 1.25 
OUTPUT INSERTED.EmployeeID,
       DELETED.VacationHours,
       INSERTED.VacationHours,
       INSERTED.VacationHours - DELETED.VacationHours,
       INSERTED.ModifiedDate
INTO @MyTableVar;
--显示表变量中的数据
SELECT EmpID, OldVacationHours, NewVacationHours, 
    VacationHoursDifference, ModifiedDate
FROM @MyTableVar;
GO
SELECT TOP (10) EmployeeID, VacationHours, ModifiedDate
FROM HumanResources.Employee;
GO


--在 UPDATE 语句中使用包含 from_table_name 的 OUTPUT INTO
USE AdventureWorks;
GO
DECLARE @MyTestVar table (
    OldScrapReasonID int NOT NULL, 
    NewScrapReasonID int NOT NULL, 
    WorkOrderID int NOT NULL,
    ProductID int NOT NULL,
    ProductName nvarchar(50)NOT NULL);
UPDATE Production.WorkOrder
SET ScrapReasonID = 4
OUTPUT DELETED.ScrapReasonID,
       INSERTED.ScrapReasonID, 
       INSERTED.WorkOrderID,
       INSERTED.ProductID,
       p.Name
    INTO @MyTestVar
FROM Production.WorkOrder AS wo
    INNER JOIN Production.Product AS p 
    ON wo.ProductID = p.ProductID 
    AND wo.ScrapReasonID= 16
    AND p.ProductID = 733;

SELECT OldScrapReasonID, NewScrapReasonID, WorkOrderID, 
    ProductID, ProductName 
FROM @MyTestVar;
GO


--在 DELETE 语句中使用包含 from_table_name 的 OUTPUT INTO
USE AdventureWorks
GO
DECLARE @MyTableVar table (
    ProductID int NOT NULL, 
    ProductName nvarchar(50)NOT NULL,
    ProductModelID int NOT NULL, 
    PhotoID int NOT NULL);

DELETE Production.ProductProductPhoto
OUTPUT DELETED.ProductID,
       p.Name,
       p.ProductModelID,
       DELETED.ProductPhotoID
    INTO @MyTableVar
FROM Production.ProductProductPhoto AS ph
JOIN Production.Product as p 
    ON ph.ProductID = p.ProductID 
    WHERE p.ProductModelID BETWEEN 120 and 130;

SELECT ProductID, ProductName, ProductModelID, PhotoID 
FROM @MyTableVar
ORDER BY ProductModelID;
GO


-- 将 OUTPUT INTO 用于大型对象数据类型
USE AdventureWorks;
GO
DECLARE @MyTableVar table (
    DocumentID int NOT NULL,
    SummaryBefore nvarchar(max),
    SummaryAfter nvarchar(max));
UPDATE Production.Document
SET DocumentSummary .WRITE (N'features',28,10)
OUTPUT INSERTED.DocumentID,
       DELETED.DocumentSummary, 
       INSERTED.DocumentSummary 
    INTO @MyTableVar
WHERE DocumentID = 3 ;
SELECT DocumentID, SummaryBefore, SummaryAfter 
FROM @MyTableVar;
GO


-- 在 INSTEAD OF 触发器中使用 OUTPUT
USE AdventureWorks;
GO
IF OBJECT_ID('dbo.vw_ScrapReason','V') IS NOT NULL
    DROP VIEW dbo.vw_ScrapReason;
GO
CREATE VIEW dbo.vw_ScrapReason
AS (SELECT ScrapReasonID, Name, ModifiedDate
    FROM Production.ScrapReason);
GO
CREATE TRIGGER dbo.io_ScrapReason 
    ON dbo.vw_ScrapReason
INSTEAD OF INSERT
AS
BEGIN
--ScrapReasonID is not specified in the list of columns to be inserted 
--because it is an IDENTITY column.
    INSERT INTO Production.ScrapReason (Name, ModifiedDate)
        OUTPUT INSERTED.ScrapReasonID, INSERTED.Name, 
               INSERTED.ModifiedDate
    SELECT Name, getdate()
    FROM inserted;
END
GO
INSERT vw_ScrapReason (ScrapReasonID, Name, ModifiedDate)
VALUES (99, N'My scrap reason','20030404');
GO


--将 OUTPUT INTO 用于标识列和计算列
USE AdventureWorks ;
GO
IF OBJECT_ID ('dbo.EmployeeSales', 'U') IS NOT NULL
    DROP TABLE dbo.EmployeeSales;
GO
CREATE TABLE dbo.EmployeeSales
( EmployeeID   int IDENTITY (1,5)NOT NULL,
  LastName     nvarchar(20) NOT NULL,
  FirstName    nvarchar(20) NOT NULL,
  CurrentSales money NOT NULL,
  ProjectedSales AS CurrentSales * 1.10 
);

insert into EmployeeSales(LastName,FirstName,CurrentSales)
values('Top','Sa',10)

select * from EmployeeSales

update EmployeeSales set ProjectedSales=1

GO
DECLARE @MyTableVar table(
  LastName     nvarchar(20) NOT NULL,
  FirstName    nvarchar(20) NOT NULL,
  CurrentSales money NOT NULL
  );

INSERT INTO dbo.EmployeeSales (LastName, FirstName, CurrentSales)
  OUTPUT INSERTED.LastName, 
         INSERTED.FirstName, 
         INSERTED.CurrentSales
  INTO @MyTableVar
    SELECT c.LastName, c.FirstName, sp.SalesYTD
    FROM HumanResources.Employee AS e
        INNER JOIN Sales.SalesPerson AS sp
        ON e.EmployeeID = sp.SalesPersonID 
        INNER JOIN Person.Contact AS c
        ON e.ContactID = c.ContactID
    WHERE e.EmployeeID LIKE '2%'
    ORDER BY c.LastName, c.FirstName;

SELECT LastName, FirstName, CurrentSales
FROM @MyTableVar;
GO
SELECT EmployeeID, LastName, FirstName, CurrentSales, ProjectedSales
FROM dbo.EmployeeSales;
GO


