/*
需求一：去除重复行（保留一行）
需求二：去除指定字段重复的行（保留随机的一行）
需求三：去除指定字段重复的行（保留指定规则的一行）

表的情况：
有主键（ID），有系统行ID（ROW_ID）

方法思路：
（1）按规则排序后定位处理，前提是必须有标注的标志能唯一定位到每一行；
（2）中间表/临时表 处理法
*/
--DEMO 无主键表保留时间（dt）次新的记录，删除val1,val2字段重复的记录

----------------------sqlserver
create table testbzm (
val1 varchar(10),
val2 varchar(10),
dt varchar(10)
);

insert into testbzm values('1','aa','2016-08-01');
insert into testbzm values('1','aa','2016-09-01');
insert into testbzm values('1','aa','2017-01-01');
insert into testbzm values('2','bb','2016-05-01');
insert into testbzm values('2','bb','2017-08-01');
insert into testbzm values('2','bb','2015-02-01');
insert into testbzm values('2','bb','2015-02-01');
--因为没有和主键类字段,所以只能使用临时表
select ROW_NUMBER() over(partition by val1,val2  order by dt desc) ID,* into #tp from testbzm 
truncate table testbzm
insert into testbzm(val1,val2,dt) (select val1,val2,dt from #tp where id=2)
select * from testbzm
/*
1	aa	2016-09-01
2	bb	2016-05-01
*/
drop table testbzm
drop table #tp
---------------------oracle
--oracle有row_id可以标注每一行，这样就很简单了，当然也可以使用中间表来操作
delete from testbzm where rowid not in (
select rid from (
select ROW_NUMBER() over(partition by val1, val2 order by dt desc) ID,
       rowid rid,
       val1,
       val2,
       dt
  from testbzm )
where ID=2
  );

select * from testbzm;
/*
1	aa	2016-09-01
2	bb	2016-05-01
*/
drop table testbzm purge;

-----------------Mysql
--mysql也是中间表/临时表的思路，不过mysql没有ROW_NUMBER() over(partition by val1, val2 order by dt desc)，只能通过变量手工实现
select val1,val2,dt
from (
select val1,val2,dt,
if(@val1=y.val1,@rank:=@rank+1,@rank:=1) as rank,  
  @val1:=y.val1  
from
(select val1,val2,dt from testbzm order by val1,val2,dt desc ) y,
(select @val1 := null ,@rank:=0) a
) results
where rank=2
/*
1	aa	2016-09-01
2	bb	2016-05-01
*/
drop table testbzm