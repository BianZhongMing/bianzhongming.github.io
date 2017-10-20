--远程调取数据时远程端索引的影响
set statistics time on;
set statistics io on;

--REMOTE
sp_helpindex DataSync20170327
--The object 'DataSync20170327' does not have any indexes, or you do not have permissions.

select * FROM DEVDB.NJTESTDB.DBO.DataSync20170327 where INNERCODE between 1000298 and 1000300
/*
SQL Server 分析和编译时间: 
   CPU 时间 = 0 毫秒，占用时间 = 220 毫秒。

(16181 行受影响)

 SQL Server 执行时间:
   CPU 时间 = 78 毫秒，占用时间 = 3908 毫秒。
   */
------------REMOTE
/*
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

(16181 行受影响)
Table 'DataSync20170327'. Scan count 5, logical reads 231209, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 3282 ms,  elapsed time = 1454 ms.*/


--REMOTE
create index I_DataSync20170327 on DataSync20170327(INNERCODE)

select * FROM DEVDB.NJTESTDB.DBO.DataSync20170327 where INNERCODE between 1000298 and 1000300
/*
SQL Server 分析和编译时间: 
   CPU 时间 = 0 毫秒，占用时间 = 0 毫秒。
SQL Server 分析和编译时间: 
   CPU 时间 = 0 毫秒，占用时间 = 191 毫秒。

(16181 行受影响)

 SQL Server 执行时间:
   CPU 时间 = 32 毫秒，占用时间 = 1087 毫秒。
   */
------------REMOTE
/*
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

(16181 行受影响)
Table 'DataSync20170327'. Scan count 1, logical reads 16221, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 47 ms,  elapsed time = 284 ms.
*/
--statistics看不到远程调用的具体信息，但是多次测试远端建立索引后效率的确提高了。


----换个玩法
执行一个复杂查询，查看执行计划
Remote Query(SOURCE:(DEVDB), QUERY:(SELECT "Tbl1001"."TRADE_DATE" "Col1038","Tbl1001"."PRE_CLOSE_PRICE" "Col1039" FROM "NJTESTDB"."DBO"."DataSync20170327" "Tbl1001" WHERE "Tbl1001"."TRADE_DATE"<convert(date, '2014-11-18') AND "Tbl1001"."innercode"=?))	
--REMOTE  捕获SQL
select   request_session_id  spid,OBJECT_NAME(resource_associated_entity_id) tableName 
from   sys.dm_tran_locks with(nolock) where resource_type='OBJECT'
and OBJECT_NAME(resource_associated_entity_id)='DataSync20170327'
--65
select spid,text from sys.sysprocesses a with(nolock) 
cross apply sys.dm_exec_sql_text(sql_handle)
where spid in(65)
--TEXT
(@P1 int)SELECT "Tbl1004"."TRADE_DATE" "Col1026","Tbl1004"."PRE_CLOSE_PRICE" "Col1027" FROM "NJTESTDB"."DBO"."DataSync20170327" "Tbl1004" WHERE "Tbl1004"."TRADE_DATE"<convert(date, '2014-11-18') AND "Tbl1004"."innercode"=@P1

--结论：远程抓取SQL的语句是交给远程服务器来跑的（附加上参数），所以在远程建立索引会对LinkServer调取数据库数据的效率产生影响的。


