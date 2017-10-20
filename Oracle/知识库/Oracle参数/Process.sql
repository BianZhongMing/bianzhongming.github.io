--连接数使用情况查询
WITH Now AS
 (select count(*) connNum from v$process),
Allpro AS
 (select value connNum from v$parameter where name = 'processes')

select '当前连接数' conn,to_char(connNum) from Now
union all
select '最大连接数' conn,connNum from Allpro
union all
select '使用率' conn,a.connNum/b.connNum*100||'%' connNum from Now a,Allpro b;

--按用户分组的活动连接
select count(*),username from v$session where status='ACTIVE' group by username;


/*--最大连接数修改
show parameter processes 
alter system set processes = 300 scope = spfile; --重启数据库才能生效
shutdown immediate
*/





