set statistics time on
set statistics io on 
SET NOCOUNT ON; --Trans 优化

--创建测试表
create table testbzm (t decimal(20,8))

--set statistics io OFF 
--set statistics time OFF

-----------------------逐条提交
declare @i int
select @i=1
while(@i<=1000000)
begin 
insert into testbzm(t) (select rand()*10000 t)
select @i=@i+1
end

--time: >10min
select count(1) from testbzm
/* --1 times
SQL Server 执行时间:
   CPU 时间 = 0 毫秒，占用时间 = 91 毫秒。

 SQL Server 执行时间:
   CPU 时间 = 0 毫秒，占用时间 = 0 毫秒。

 SQL Server 执行时间:
   CPU 时间 = 0 毫秒，占用时间 = 0 毫秒。
表 'testbzm'。扫描计数 0，逻辑读取 1 次，物理读取 0 次，预读 0 次，lob 逻辑读取 0 次，lob 物理读取 0 次，lob 预读 0 次。
*/

truncate table testbzm

----------------------拼接实现分批提交
declare @i int
select @i=1
while(@i<=10000)
begin 
insert into testbzm(t)  --一次批量插入100行
(select rand()*10000 t union all
select rand()*10001 t union all
select rand()*10002 t union all
select rand()*10003 t union all
select rand()*10004 t union all
select rand()*10005 t union all
select rand()*10006 t union all
select rand()*10007 t union all
select rand()*10008 t union all
select rand()*10009 t union all
select rand()*10010 t union all
select rand()*10011 t union all
select rand()*10012 t union all
select rand()*10013 t union all
select rand()*10014 t union all
select rand()*10015 t union all
select rand()*10016 t union all
select rand()*10017 t union all
select rand()*10018 t union all
select rand()*10019 t union all
select rand()*10020 t union all
select rand()*10021 t union all
select rand()*10022 t union all
select rand()*10023 t union all
select rand()*10024 t union all
select rand()*10025 t union all
select rand()*10026 t union all
select rand()*10027 t union all
select rand()*10028 t union all
select rand()*10029 t union all
select rand()*10030 t union all
select rand()*10031 t union all
select rand()*10032 t union all
select rand()*10033 t union all
select rand()*10034 t union all
select rand()*10035 t union all
select rand()*10036 t union all
select rand()*10037 t union all
select rand()*10038 t union all
select rand()*10039 t union all
select rand()*10040 t union all
select rand()*10041 t union all
select rand()*10042 t union all
select rand()*10043 t union all
select rand()*10044 t union all
select rand()*10045 t union all
select rand()*10046 t union all
select rand()*10047 t union all
select rand()*10048 t union all
select rand()*10049 t union all
select rand()*10050 t union all
select rand()*10051 t union all
select rand()*10052 t union all
select rand()*10053 t union all
select rand()*10054 t union all
select rand()*10055 t union all
select rand()*10056 t union all
select rand()*10057 t union all
select rand()*10058 t union all
select rand()*10059 t union all
select rand()*10060 t union all
select rand()*10061 t union all
select rand()*10062 t union all
select rand()*10063 t union all
select rand()*10064 t union all
select rand()*10065 t union all
select rand()*10066 t union all
select rand()*10067 t union all
select rand()*10068 t union all
select rand()*10069 t union all
select rand()*10070 t union all
select rand()*10071 t union all
select rand()*10072 t union all
select rand()*10073 t union all
select rand()*10074 t union all
select rand()*10075 t union all
select rand()*10076 t union all
select rand()*10077 t union all
select rand()*10078 t union all
select rand()*10079 t union all
select rand()*10080 t union all
select rand()*10081 t union all
select rand()*10082 t union all
select rand()*10083 t union all
select rand()*10084 t union all
select rand()*10085 t union all
select rand()*10086 t union all
select rand()*10087 t union all
select rand()*10088 t union all
select rand()*10089 t union all
select rand()*10090 t union all
select rand()*10091 t union all
select rand()*10092 t union all
select rand()*10093 t union all
select rand()*10094 t union all
select rand()*10095 t union all
select rand()*10096 t union all
select rand()*10097 t union all
select rand()*10098 t union all
select rand()*10099 t)
select @i=@i+1
end

--time: 25s
select count(1) from testbzm --8s
/*SQL Server 执行时间:
   CPU 时间 = 0 毫秒，占用时间 = 3 毫秒。

 SQL Server 执行时间:
   CPU 时间 = 0 毫秒，占用时间 = 0 毫秒。

 SQL Server 执行时间:
   CPU 时间 = 0 毫秒，占用时间 = 0 毫秒。
表 'testbzm'。扫描计数 0，逻辑读取 100 次，物理读取 0 次，预读 0 次，lob 逻辑读取 0 次，lob 物理读取 0 次，lob 预读 0 次。
*/
truncate table testbzm

--------------------事务实现分批提交
declare @i int
select @i=1
begin tran
while(@i<=1000000)
begin 
insert into testbzm(t) (select rand()*10000 t)
select @i=@i+1
if(@i%10000=0)  --commit number
  begin 
     commit
	 begin tran
  end
end

while ((select @@TRANCOUNT )<>0 ) 
begin 
 commit 
end

select count(1) from testbzm with(nolock)
--100 commit:8min56s
--1000 commit:1min50s
--10000 commit:2min
/*SQL Server 执行时间:
   CPU 时间 = 0 毫秒，占用时间 = 0 毫秒。

 SQL Server 执行时间:
   CPU 时间 = 0 毫秒，占用时间 = 0 毫秒。

 SQL Server 执行时间:
   CPU 时间 = 0 毫秒，占用时间 = 0 毫秒。

 SQL Server 执行时间:
   CPU 时间 = 0 毫秒，占用时间 = 0 毫秒。
表 'testbzm'。扫描计数 0，逻辑读取 1 次，物理读取 0 次，预读 0 次，lob 逻辑读取 0 次，lob 物理读取 0 次，lob 预读 0 次。
*/
truncate table testbzm

drop table testbzm