---------- Mysql 变量SET值：
set @i =100;/set @i:=100;/select @i:=101
set @i =100,@j=100;  -- 可多变量赋值

---------- sqlserver 变量SET值：
declare @i int,@j int --必须declare
--set @i=100
--set @j=101
--不可多变量一起SET
select @i=100,@j=101
select @i,@j