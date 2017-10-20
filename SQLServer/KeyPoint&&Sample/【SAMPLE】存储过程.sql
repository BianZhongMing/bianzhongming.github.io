--存储过程
--===创建&基本操作（无参存储过程）
--1创建存储过程
create procedure BZMtest
as
select * from sys_table where name_en='bond' or node_cd='N06'
--2执行存储过程
execute bzmtest --名称不区分大小写
--3移除存储过程
drop procedure bzmtest
go

--===带入参
select * from sys_table where name_en='bond' or node_cd='N06'
--创建
create proc bzmtest  -- create procedure=create proc
( @name_en varchar(10),
 @node_cd varchar(10)
)
as 
select * from sys_table where name_en=@name_en or node_cd= @node_cd
--调用
exec bzmtest 'bond','N06'--直接顺序传参
exec bzmtest @node_cd='N06' ,@name_en='bond'--指定传参

--===带出入参
select table_id from sys_table where name_en='bond' or node_cd='N06'
--创建
create proc bzmtest  
( @name_en varchar(10),
 @node_cd varchar(10),
 @table_id varchar(10) output   --出参【出参加标识（output）】
)
as 
select @table_id=table_id from sys_table 
where name_en=@name_en or node_cd= @node_cd
--调用
declare @table_id2 varchar(10)
exec bzmtest @name_en='bond',@node_cd='N06' ,@table_id=@table_id2 output
select @table_id2
--只能传一个数值


--====表数据传递（利用中间表）
create proc bzmtest  -- create procedure=create proc
( @name_en varchar(10),
 @node_cd varchar(10)
)
as 
select table_id,NAME_CN,name_en from sys_table where name_en=@name_en or node_cd= @node_cd
go
--结果插入临时表
create proc p_test @name_en1 varchar(10), @node_cd1 varchar(10)
as
set nocount on --优化存储过程

if exists(select * from sysobjects where xtype in ('S','U') and name='testbzm')
drop table testbzm
else
create table testbzm(table_id varchar(10),NAME_CN varchar(500),name_en varchar(500))
insert into testbzm
exec bzmtest @name_en=@name_en1,@node_cd=@node_cd1
go
--执行
exec p_test @node_cd1='N06' ,@name_en1='bond'
select * from testbzm
--清理
drop procedure bzmtest
drop procedure p_test
drop table testbzm

--=================
--循环
declare @i int
set @i = 0
while @i < 100
begin
  update table set column = @i where ID_column = @i
  set @i = @i + 1
end