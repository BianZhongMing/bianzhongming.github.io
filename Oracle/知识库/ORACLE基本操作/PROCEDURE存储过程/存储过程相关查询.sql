--按照存储过程名称查询job
select * from dba_jobs where what like '%Tbzm20141212%';

--查询存储过程基本信息
select * from DBA_objects where object_type='PROCEDURE' and object_name='T3';

--由表名查询相关存储过程
SELECT * FROM ALL_SOURCE  where TEXT LIKE '%TS_CORP_SALE_KPI%';
XP_TMP_PKG
WJ_UTITOOL_PKG
--若上面查询结果中没有存储过程只有包，这再次查询该包相关的存储过程即可
SELECT * FROM ALL_SOURCE  where TYPE='PROCEDURE'  AND TEXT LIKE '%XP_TMP_PKG%';