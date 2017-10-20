## 一个简单的需求引发的问题

### 简单的需求
收到一个Mysql数据清理的需求，需要按照查询条件清理部分数据，按照操作规范：

+ 用Navicat（导出UTF8 CSV文件的方式）备份即将被清理的数据，记录数据量
+ 清理数据，核对数据量，没有问题

### 变更
后面需求变化，这部分数据不需要删除了，需要rollback，着手恢复数据

+ 用Navicat导入数据，报错：**违反唯一约束**
+ 核实库表变动，反馈表结构和数据都**没做过后续变更**
+ 利用 create table like 创建中间表导入数据，依然报**相同错误**

### 故障排查
+ 删除中间表唯一约束，数据可以正常导入，按照这个逻辑，当时导出数据的时候数据就违反唯一约束了，首先怀疑是否是Mysql唯一约束存在bug
+ 测试重复数据之后加唯一约束或者唯一约束之后插入重复数据都报错，说明问题可能出在**数据本身**
+ 核查重复数据，发现一个问题，现在已加唯一约束的表中也存在违反唯一约束的数据，但数据库没有报错

### 问题确定
+ 测试Mysql的唯一约束，发现其和sqlserver、ORACLE相比存在一个差异。当Mysql唯一约束的几个字段中存在空值的时候，唯一约束会失效。比如唯一约束为 ID+VALUES，对于values（1，NULL）这样的一条数据，在sqlserver中重复插入会报违反唯一约束，但Mysql不会报错（认为不违反唯一约束）。
+ Navicat查询结果导出为CSV后导入存在数据差异，因为选择了字符串分隔符，所以空值在CSV里面写入为""，当导入时这个数据就成了一个空字符串，导致数据差异。
+

### 解决方式
1. 将CSV导入中间表，然后将空字符串设为NULL
2. 将数据从中间表导入目标表

### 后续
切换导出查询结果工具，注意这个差异。

### test sql

```sql
---------------- mysql
create table testbzm (
id int,
val varchar(10)
);

ALTER TABLE `testbzm`
ADD UNIQUE INDEX `uq` (`id`, `val`) USING BTREE ;

insert into testbzm values(1,NULL);
insert into testbzm values(1,NULL);
insert into testbzm values(1,NULL);
insert into testbzm values(1,NULL);
-- 可以多次插入

select * from testbzm;
/*
1	
1	
1	
1	
*/

drop table testbzm;



----------------  sqlserver
create table testbzm (
id int,
val varchar(10)
);

ALTER TABLE testbzm ADD CONSTRAINT uq UNIQUE NONCLUSTERED(id, val) WITH(ONLINE=ON,FillFactor=90);

insert into testbzm values(1,NULL);
insert into testbzm values(1,NULL);
/* 第二次插入报错
Violation of UNIQUE KEY constraint 'uq'. Cannot insert duplicate key in object 'dbo.testbzm'. The duplicate key value is (1, <NULL>).
The statement has been terminated.
*/

drop table testbzm;

----------------  oracle
SQL> create table testbzm (
  2  id int,
  3  val varchar(10)
  4  );

表已创建。

SQL>
SQL> ALTER TABLE testbzm ADD CONSTRAINT uq UNIQUE (id, val) ;

表已更改。

SQL> insert into testbzm values(1,NULL);

已创建 1 行。

SQL> insert into testbzm values(1,NULL);
insert into testbzm values(1,NULL)
*
第 1 行出现错误:
ORA-00001: 违反唯一约束条件 (SYS.UQ)


SQL> drop table testbzm;

表已删除。
```





