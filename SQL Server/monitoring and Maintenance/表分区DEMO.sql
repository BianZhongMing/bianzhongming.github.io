--先创建文件夹和子文件夹

IF  EXISTS (SELECT name FROM sys.databases WHERE name = N'AirAvCache')  
DROP DATABASE [AirAvCache]  
GO  
CREATE DATABASE [AirAvCache]  
ON PRIMARY 
(NAME='Data Partition DB Primary FG',  
FILENAME=  
'C:\Data\Primary\AirAvCache Primary FG.mdf',  
SIZE=5,  
MAXSIZE=500,  
FILEGROWTH=1 ),  
FILEGROUP [AirAvCache FG1]  
(NAME = 'AirAvCache FG1',  
FILENAME =  
'C:\Data\FG1\AirAvCache FG1.ndf',  
SIZE = 5MB,  
MAXSIZE=500,  
FILEGROWTH=1 ),  
FILEGROUP [AirAvCache FG2]  
(NAME = 'AirAvCache FG2',  
FILENAME =  
'C:\Data\FG2\AirAvCache FG2.ndf',  
SIZE = 5MB,  
MAXSIZE=500,  
FILEGROWTH=1 ),  
FILEGROUP [AirAvCache FG3]  
(NAME = 'AirAvCache FG3',  
FILENAME =  
'C:\Data\FG3\AirAvCache FG3.ndf',  
SIZE = 5MB,  
MAXSIZE=500,  
FILEGROWTH=1 ),  
FILEGROUP [AirAvCache FG4]  
(NAME = 'AirAvCache FG4',  
FILENAME =  
'C:\Data\FG4\AirAvCache FG4.ndf',  
SIZE = 5MB,  
MAXSIZE=500,  
FILEGROWTH=1 ),  
FILEGROUP [AirAvCache FG5]  
(NAME = 'AirAvCache FG5',  
FILENAME =  
'C:\Data\FG5\AirAvCache FG5.ndf',  
SIZE = 5MB,  
MAXSIZE=500,  
FILEGROWTH=1 ),  
 
FILEGROUP [AirAvCache FG6]  
(NAME = 'AirAvCache FG6',  
FILENAME =  
'C:\Data\FG6\AirAvCache FG6.ndf',  
SIZE = 5MB,  
MAXSIZE=500,  
FILEGROWTH=1 ),  
 
 
FILEGROUP [AirAvCache FG7]  
(NAME = 'AirAvCache FG7',  
FILENAME =  
'C:\Data\FG7\AirAvCache FG7.ndf',  
SIZE = 5MB,  
MAXSIZE=500,  
FILEGROWTH=1 ),  
 
FILEGROUP [AirAvCache FG8]  
(NAME = 'AirAvCache FG8',  
FILENAME =  
'C:\Data\FG8\AirAvCache FG8.ndf',  
SIZE = 5MB,  
MAXSIZE=500,  
FILEGROWTH=1 ),  
 
FILEGROUP [AirAvCache FG9]  
(NAME = 'AirAvCache FG9',  
FILENAME =  
'C:\Data\FG9\AirAvCache FG9.ndf',  
SIZE = 5MB,  
MAXSIZE=500,  
FILEGROWTH=1 ),  
 
FILEGROUP [AirAvCache FG10]  
(NAME = 'AirAvCache FG10',  
FILENAME =  
'C:\Data\FG10\AirAvCache FG10.ndf',  
SIZE = 5MB,  
MAXSIZE=500,  
FILEGROWTH=1 ),  
 
FILEGROUP [AirAvCache FG11]  
(NAME = 'AirAvCache FG11',  
FILENAME =  
'C:\Data\FG11\AirAvCache FG11.ndf',  
SIZE = 5MB,  
MAXSIZE=500,  
FILEGROWTH=1 ),  
 
FILEGROUP [AirAvCache FG12]  
(NAME = 'AirAvCache FG12',  
FILENAME =  
'C:\Data\FG12\AirAvCache FG12.ndf',  
SIZE = 5MB,  
MAXSIZE=500,  
FILEGROWTH=1 ) 


-------创建分区函数

USE AirAvCache  
GO   
 
-- 创建函数  
 
CREATE PARTITION FUNCTION [AirAvCache Partition  Range](DATETIME)  
AS RANGE LEFT FOR VALUES ('2010-09-01','2010-10-01','2010-11-01',
'2010-12-01','2011-01-01','2011-02-01','2011-03-01','2011-04-01',
'2011-05-01','2011-06-01','2010-07-01'); 


------创建分区架构

CREATE PARTITION SCHEME [AirAvCache Partition Scheme]  
AS PARTITION [AirAvCache Partition  Range]  
TO ([AirAvCache FG1], [AirAvCache FG2], [AirAvCache FG3],[AirAvCache FG4],[AirAvCache FG5],[AirAvCache FG6],[AirAvCache FG7],[AirAvCache FG8],  
[AirAvCache FG9],[AirAvCache FG10],[AirAvCache FG11],[AirAvCache FG12]); 

---------创建一个使用AirAvCache Partitiion Scheme 架构的表
CREATE TABLE [dbo].[AvCache](  
    [CityPair] [varchar](6)  NOT NULL,  
    [FlightNo] [varchar](10)  NULL,  
    [FlightDate] [datetime] NOT NULL,  
    [CacheTime] [datetime] NOT NULL   DEFAULT (getdate()),  
    [AVNote] [varchar](300)  NULL 
)  ON [AirAvCache Partition Scheme] (FlightDate);   
--注意这里使用[AirAvCache Partition Scheme]架构，根据FlightDate 分区 

-------查询分区情况
insert into [AvCache]([CityPair],[FlightDate]) values
('NJ','2010-10-01'),
('NJ','2010-10-01'),
('NJ','2010-09-01'),
('NJ','2010-01-01'),
('NJ','2010-08-01'),
('NJ','2010-07-01');
-- 查看使用情况   
SELECT *, $PARTITION.[AirAvCache Partition  Range](FlightDate)  
FROM dbo.AVCache 