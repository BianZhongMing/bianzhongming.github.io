select name from v$tempfile;
--C:\ORACLE\PRODUCT\10.2.0\ORADATA\ORCL\TEMP01.DBF

--创建中转临时表空间
create TEMPORARY TABLESPACE TEMP2 TEMPFILE 'C:\ORACLE\PRODUCT\10.2.0\ORADATA\ORCL\TEMP02.DBF' SIZE 1024M REUSE AUTOEXTEND ON NEXT 1024K MAXSIZE 5120M; 
--改变缺省临时表空间 为刚刚创建的新临时表空间temp2
alter database default temporary tablespace temp2;
--删除原来临时表空间
drop tablespace temp including contents and datafiles;

--重新创建临时表空间
create TEMPORARY TABLESPACE TEMP TEMPFILE 'C:\ORACLE\PRODUCT\10.2.0\ORADATA\ORCL\TEMP01.DBF' SIZE 100M REUSE AUTOEXTEND ON NEXT 1024K MAXSIZE 5120M; 

--重置缺省临时表空间为新建的temp表空间
alter database default temporary tablespace temp; 

--删除中转用临时表空间
drop tablespace temp2 including contents and datafiles;

--重新指定用户表空间为重建的临时表空间
alter user zxd temporary tablespace temp;
  
--至此临时表空间增长过大可以更改完成。 
--下面是查询在sort排序区使用的执行耗时的SQL:
Select se.username,se.sid,su.extents,su.blocks*to_number(rtrim(p.value))as    Space,tablespace,segtype,sql_text
from v$sort_usage su,v$parameter p,v$session se,v$sql s
where p.name='db_block_size' and su.session_addr=se.saddr and s.hash_value=su.sqlhash and s.address=su.sqladdr
order by se.username,se.sid
--此语句可以做跟踪查看分析时用。