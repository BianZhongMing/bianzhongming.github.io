--【sqlserver】 几种中间表实现方式比较（临时表、表变量、CTE）
 
/*
临时表
内涵：以#开头的局部临时表，以##开头的全局临时表。
存储：存放在tempdb数据库（包含 局部临时表，全局临时表）。
作用域：
    局部临时表：对当前连接有效，只在创建它的存储过度、批处理、动态语句中有效，类似于C语言中局部变量的作用域。
    全局临时表：在所有连接对它都结束引用时，会被删除，对创建者来说，断开连接就是结束引用；对非创建者，不再引用就是结束引用。
最好在用完后，就通过drop  table 语句删除，及时释放资源。
特性：能和普通表一样定义约束和创建索引，有数据分布的统计信息，开销和普通的表一样。
使用场景：数据量小直接当做中间表使用，数据量较大可以通过优化提高查询效率，对于复杂的查询可以将中间结果放在临时表中以固化执行计划（专治执行计划走错）
*/
--DEMO
 --存在判断
if ( object_id('tempdb..#t') is not null)
DROP TABLE #t
GO
--建表插数据
select top 100000 * into #t from testbzm
--建索引
select top 10 * from #t
create index IDX_T_ID on #t(update_time) WITH(ONLINE=OFF,FillFactor=90) --ONLINE=ON报错：不能创建、重建或删除网上本地临时表上的索引。离线执行索引操作。
--WITH(ONLINE=ON,FillFactor=90)
SET STATISTICS PROFILE ON --执行计划（文本）
select * from #t where update_time = '20160101' 
--explain plan
  --Nested Loops(Inner Join, OUTER REFERENCES:([Bmk1000]))
       --Index Seek(OBJECT:([tempdb].[dbo].[#t]), SEEK:([tempdb].[dbo].[#t].[UPDATE_TIME]='2016-01-01 00:00:00.000') ORDERED FORWARD)
       --RID Lookup(OBJECT:([tempdb].[dbo].[#t]), SEEK:([Bmk1000]=[Bmk1000]) LOOKUP ORDERED FORWARD)
--能走索引
drop table #t
SET STATISTICS PROFILE OFF


/*  
表变量
存储：表变量存放在tempdb数据库中。
作用域：和普通的变量一样，在定义表变量的存储过程、批处理、动态语句、函数结束时，会自动清除。
特性：可以有主键，但不能直接创建索引，也没有任何数据的统计信息。
使用场景：小数据量（百条以内）
注意：表变量不受事务的约束，下面的DEMO会演示。
*/
--DEMO 表变量
declare @tb table(id int primary key,val1 varchar(10))

begin tran  
    insert into @tb values (1,'aa'),(2,'bb'),(3,'cc') 
rollback tran  

select count(1) from @tb ; --3
--表变量没有rollback

begin tran  
    delete from @tb where id=1 
rollback tran 
 
select count(1) from @tb  --2
--表变量没有rollback
   
   
/*
CTE
内涵：通用表达式。
储存：不确定（有些部分，比如假脱机，会把数据存储在tempdb的worktable、workfile中，另外，一些大的hash join和排序操作，也会把中间数据存储在tempdb）
作用域：CTE下第一条SQL（后面调用不了）
使用场景：递归，SQL逻辑化（重复的部分写到CTE里面，能减少SQL量，增加SQL条理性和可读性）
注意：SQL逻辑化改写并不能固定执行计划（逻辑中间表，实际解析后还是一个SQL）
*/
--DEMO
--SQL逻辑化
--SQL A
select * from 
(select id,name from testbzm where UPDATE_TIME >'2015-01-01') a 
join (select id,name from testbzm where UPDATE_TIME >'2015-01-01' and dr=1) b on a.id=b.id
join (select id,name from testbzm where UPDATE_TIME >'2015-01-01' and dr=1 and name like 'H%') c on a.id=c.id
/*SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

(972 行受影响)
Table 'testbzm'. Scan count 15, logical reads 8850, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 79 ms,  elapsed time = 216 ms.
*/ 

--SQL逻辑等价转换==>SQL B
with cte_testtb as ( 
select id,name,dr from testbzm where UPDATE_TIME >'2015-01-01'
) --也可以同时定义多个表，用逗号隔开即可
select * from 
cte_testtb a 
join (select id,name from cte_testtb where dr=1) b on a.id=b.id
join (select id,name from cte_testtb where dr=1 and name like 'H%') c on a.id=c.id
/*SQL Server parse and compile time: 
   CPU time = 16 ms, elapsed time = 56 ms.

(972 行受影响)
Table 'testbzm'. Scan count 15, logical reads 8850, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 79 ms,  elapsed time = 369 ms.
*/
--执行计划差异不大

drop table testbzm

