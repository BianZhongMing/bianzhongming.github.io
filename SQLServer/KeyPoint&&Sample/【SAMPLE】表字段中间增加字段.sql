--在 Microsoft SQL Server Management Studio 中：
--1. 工具->选项->Designers->表设计器和数据库设计器->将“阻止保存要求重新创建表的更改”的选项的勾去掉
--2. 右键单击你要更改的数据表，点选“设计”，然后在表设计器中用鼠标拖动各列的位置，最后保存即可。

--SQL法
--Move
select * into test_bzm  from house_spider_new_sohu

--check
select count(1) from test_bzm --4614
select count(1) from house_spider_new_sohu --4614

--*****First Copy DDL SQL
--drop
drop table house_spider_new_sohu;

--create && Edit
CREATE TABLE dbo.house_spider_new_sohu();

--Insert
--columns
SELECT
	t.[name] 表名,
c.name+',' 列名
FROM
	sys.tables AS t,
sys.columns as c
WHERE
	t.object_id=c.object_id
and t.[name] ='test_bzm'
--do
SET IDENTITY_INSERT dbo.[house_spider_new_sohu] ON
insert into house_spider_new_sohu
( --列名
ID,
HOUSE_SRN,
HOUSE_NAME
--TMSTAMP
)
(
select 
ID,
HOUSE_SRN,
HOUSE_NAME
--TMSTAMP
from test_bzm
)
SET IDENTITY_INSERT dbo.[house_spider_new_sohu] OFF

--check
select count(1) from house_spider_new_sohu --4614
--clear
drop table test_bzm



