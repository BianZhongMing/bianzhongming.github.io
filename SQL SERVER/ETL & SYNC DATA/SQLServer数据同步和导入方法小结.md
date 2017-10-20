### MS工具数据同步
1. 建立表结构
2. 数据同步（ID，时间戳不同步）

- NOTE：数据量大时，MS官方工具效率最高

### Excel文件等数据文件导入（利用Navicat）
1. 转换成Excel（csv/tsv，tsv选择分割符导入Excel）
2. 字段核查（错行，有效性）
3. 导入

- 导入截断问题处理：字符串长度 =LEN(A1) 降序排序 


### Excel拼接成sql
--N''
--为空处理('',,问题)：数字为0(=IF(LEN(I20),I20,0))，字符为空串('')
--时间类型处理：=TEXT(C2,"yyyy/mm/dd")
--原文本中 '处理：替换为原来文本没有的特殊字符后再数据库中replace    DESCRIPTION :'--@
--文本粘贴处理：替换"为空（换行cp文本自动加""）

### 链接服务器远程导入
```sql
--需导入自增ID场景：

SET IDENTITY_INSERT dbo.[your_table] ON

insert into your_table

( --列名

ID,

HOUSE_SRN,

HOUSE_NAME

--TMSTAMP

)

(

select 

ID,

HOUSE_SRN,

HOUSE_NAME

--TMSTAMP

from linkserver.yourtable

)

SET IDENTITY_INSERT dbo.[your_table] OFF

```

### BCP导入法

```sql
--开启功能
-- 允许配置高级选项  
EXEC master.sys.sp_configure 'show advanced options', 1  
-- 重新配置  
RECONFIGURE  
-- 启用xp_cmdshell  
EXEC master.sys.sp_configure 'xp_cmdshell', 1  
--重新配置  
RECONFIGURE  
--用完之后再把其关闭，关闭只需要把 1 变为 0 即可。


--简单导出表
EXEC master..xp_cmdshell 'BCP datayesdb.dbo.bond_id out d:\t_008.txt -c -t  -S"test_host_ip,1433" -U"user_name" -P"user_password"'
--SQL简单导出
EXEC master..xp_cmdshell 'BCP "select id,bond_id from datayesdb.dbo.bond_id" queryout d:\t_008.txt -c -t  -S"test_host_ip,1433" -U"user_name" -P"user_password"'

--格式化导出
/*
-t 分割符
-T 指定BCP使用信任连接登录SQL Server。如果未指定-T，必须指定-U和-P。
-r 行终止符
*/
EXEC master..xp_cmdshell 'BCP "select id,bond_id from datayesdb.dbo.bond_id where id='20932'" queryout d:\t_008.txt -c -t"|"  -S"test_host_ip,1433" -U"user_name" -P"user_password"'

--表头问题：单独导出，然后追加
type 2.txt>>1.txt

---example
--导出数据
EXEC master..xp_cmdshell 'bcp [Profile_Websites] out d:\0.txt -w -t "#BIColumn#" -r "#BIRow#" -S"test_host_ip,1433"  -U"DBA_DingQin" -P"password"'
--导入数据
EXEC master..xp_cmdshell 'bcp [Profile_Websites] in d:\data1410.txt -w -t "#BIColumn#" -r "#BIRow#" -S"192.168.1.104,1433"  -d"ppdai_snap_20141205180710" -U"DBA_DingQin" -P"password"'


```

### 利用SQL导入

```sql
--导出格式文件，这个是关键，数据库名称，表名称，用户名和密码，服务器ip和端口  
--先查看要导入的数据  
select *  
from  
openrowset(bulk 'd:\1.csv',             --要读取的文件路径和名称   
                formatfile='d:\wc.fmt',  --格式化文件的路径和名称  
                   
                firstrow = 2,            --要载入的第一行,由于第一行是标题,所以从2开始  
                --lastrow  = 1000,       --要载入的最后一行,此值必须大于firstrow  
                   
                maxerrors = 10,          --在加载失败之前加载操作中最大的错误数  
                --errorfile ='c:\wc_error1.txt', --存放错误的文件  
                   
                rows_per_batch = 10000                    --每个批处理导入的行数  
          ) as t   
   
/*  
aa  bb  cc  dd  ee  ff  
42222222223432432432    32432432432432432432    2332432432  32432432432 32432432    23432432 
42222222223432432432    32432432432432432432    2332432432  32432432432 32432432    23432432 
42222222223432432432    32432432432432432432    2332432432  32432432432 32432432    23432432 
42222222223432432432    32432432432432432432    2332432432  32432432432 32432432    23432432 
*/ 
   
--最后可以 insert into 表 (列)  select * from openrowset...插入数据即可  
insert into xxdd (aa,bb,cc,dd,ee,ff)  
select *  
from  
openrowset(bulk 'c:\wc.csv',             --要读取的文件路径和名称   
                formatfile='c:\wc.fmt',  --格式化文件的路径和名称  
                   
                firstrow = 2,            --要载入的第一行,由于第一行是标题,所以从2开始  
                --lastrow  = 1000,       --要载入的最后一行,此值必须大于firstrow  
                   
                maxerrors = 10,          --在加载失败之前加载操作中最大的错误数  
                --errorfile ='c:\wc_error1.txt', --存放错误的文件  
                   
                rows_per_batch = 10000                    --每个批处理导入的行数  
          ) as t   
   
   
select *  
from xxdd


--出现截断报错,利用MSDASQL
--打开文件
select *  from OpenRowset('MSDASQL', 'Driver={Microsoft Text Driver (*.txt; *.csv)}; 
DefaultDir=D:\;','select * from 1.csv')
--打开数据库
select *
FROM OPENROWSET('MSDASQL',
   'DRIVER={SQL Server};SERVER=HOST_IP;UID=dba_name;PWD=your_password',
   'select top 10 id,data_date from testdb.testbzm') AS a
           

--Excel读取
select * into testbzm from OpenRowSet('Microsoft.ACE.OLEDB.12.0', 'Excel 12.0;HDR=Yes;IMEX=1;
Database=D:\1.xlsx', 'select * from [Sheet1$]') 
--尚未注册 OLE DB 访问接口 "Microsoft.ACE.OLEDB.12.0"。

/*
注：
Excel 2007 工作簿文件的扩展名是：xlsx
HDR=Yes/No
可选参数，指定 Excel 表的第一行是否列名，缺省为 Yes，可以在注册表中修改缺省的行为。
IMEX=1
可选参数，将 Excel 表中混合 Intermixed 数据类型的列强制解析为文本。
*/
```



### 注：大批量导入时：

1. 建立参照ID
2. 建表字段先宽后严
3. 数据先导入，后清洗处理