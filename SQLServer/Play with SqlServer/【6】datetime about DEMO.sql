--语言设置对时间的影响

set language british;
select cast('02/12/2017' as datetime);
--2017-12-02 00:00:00.000
select cast('20170212' as datetime);
--2017-02-12 00:00:00.000
select cast('2017-02-12' as datetime)
--2017-12-02 00:00:00.000

set language us_english;
select cast('02/12/2017' as datetime);
--2017-12-02 00:00:00.000
select cast('20170212' as datetime);
--2017-02-12 00:00:00.000
select cast('2017-02-12' as datetime)
--2017-12-02 00:00:00.000

--优先使用'20170212'这种时间格式（能避免语言设置的影响问题）

select @@version
/*Microsoft SQL Server 2012 - 11.0.2100.60 (X64) 
	Feb 10 2012 19:39:15 
	Copyright (c) Microsoft Corporation
	Enterprise Edition (64-bit) on Windows NT 6.1 <X64> (Build 7601: Service Pack 1) (Hypervisor)
*/
select cast('20170212 12:15:45.115' as datetime); --2017-02-12 12:15:45.117 精度问题，会有误差
select cast('20170212 12:15:45.115' as datetime2);  --2017-02-12 12:15:45.1150000

-----------------时间获取
select 
getdate(), --2017-04-05 17:21:34.863
CURRENT_TIMESTAMP, --2017-04-05 17:21:34.863  --ANSI SQL标准，推荐使用
getutcdate(), --2017-04-05 09:21:34.863  --UTC时间
sysdatetime(),--2017-04-05 17:21:34.8640435  --datetime2格式时间
sysutcdatetime(),--2017-04-05 09:21:34.8640435  --datetime2格式UTC时间
sysdatetimeoffset() --2017-04-05 17:21:34.8640435 +08:00  --datetimeoffset格式时间
;

-----------------时区转换 SWITCHOFFSET(datatimeoffset_value,time_zone)
select 
sysdatetimeoffset(), --2017-04-05 17:21:05.0201555 +08:00
SWITCHOFFSET(sysdatetimeoffset() ,'+00:00')--2017-04-05 09:21:05.0201555 +00:00  --UTC时间

--datetime格式转换成datetimeoffset  TODATETIMEOFFSET(data_and_time_value,time_zone)
select 
sysdatetimeoffset(), --2017-04-05 17:25:21.4255765 +08:00
TODATETIMEOFFSET(sysdatetimeoffset(),'+09:00'), --2017-04-05 17:25:21.4255765 +09:00 --时间不做任何转换计算，只简单指定时区
TODATETIMEOFFSET(sysdatetime(),'+08:00') --2017-04-05 17:25:21.4255765 +08:00

-----------------时间计算
--DATEADD(part,n,dt_val)
select current_timestamp,
dateadd(year,+1,current_timestamp),
dateadd(quarter,+1,current_timestamp), --季度
dateadd(month,-10,current_timestamp),
dateadd(dayofyear,-10,current_timestamp),
dateadd(day,-10,current_timestamp),
dateadd(week,-10,current_timestamp),
dateadd(WEEKDAY,-10,current_timestamp)


-----------------时间差计算
--DATEDIFF(part,dt_val1,dt_val2)
select DATEDIFF(day,'2015-01-01','2016-10-23') --661

-----------------时间截取
--DATEPART(part,dt_val)
select DATEPART(yy,'2015-03-01'), --2015
year('2015-03-01'), --2015(等价)
DATEPART(mm,'2015-03-01'), --3
month('2015-03-01'), --3(等价)
DATEPART(dd,'2015-03-01'),--1
day('2015-03-01'), --1(等价)
------DATENAME(part,dt_val) -- 返回值和系统语言有关
DATENAME(month,'2015-03-01'),--March (和系统语言有关，返回月份/年/日的名称)
DATEPART(week, getdate())/*本年度周数*/,
DATEPART(weekday, getdate())/*时区相关，从周日开始*/,
DATENAME(weekday, getdate()) --时间是周几

--时间判断
select 
ISDATE('20150101'),--1
ISDATE('2015-01-01'),--1
ISDATE('20151845')--0



--综合计算
select   dateadd(dd,-day('20110210'),dateadd(m,1,'20110210'))
--当月月末
select   dateadd(dd,-day('20110210')+1,'20110210')  
--当月第一天
SELECT CONVERT(datetime,CONVERT(char(8),GETDATE(),120)+'1')
--这月的第一天
select dateadd(d,-day(getdate()),dateadd(m,1,getdate()))
--***这月的最后一天（日期本身不是最后一天的时候正确，否则可以先取第一天，在取最后一天） 
select dateadd(d,-day(getdate()),dateadd(m,2,getdate()))
--下月的最后一天 
SELECT DATEADD(mm,DATEDIFF(mm,0,dateadd(month,-1,getdate())),0)
--上月第一天
select dateadd(ms,-3,DATEADD(mm,DATEDIFF(mm,0,getdate()),0))
--上月最后一天
select DATEADD(SS,-1,dateadd(day,1,CONVERT(varchar(15) , getdate(), 102 )))
--获取当天的最后一刻
