create table TEST1111
(
  a         VARCHAR2(30)
)

--增加列
alter table TEST1111 add test varchar2(10);

--修改列
alter table TEST1111 modify test varchar2(20);
alter table TEST1111 modify test null; --可以为空
alter table TEST1111 modify test not null; --非空

--删除列
alter table TEST1111 drop column test;


select * from TEST1111;
drop table TEST1111 purge;

--查询表的所有列
select OWNER, TABLE_NAME, COLUMN_NAME
from all_tab_columns 
where table_name = 'BD_CORP';

--同表交换列
update CRMKH set id=BIRTHDAY ,BIRTHDAY=id where 条件;
--oracle 有undo 支持两个杯子互换水的，不需要第三个杯子。
update  crmkh a set a.birthday =a.sex ,a.sex=a.name, a.name=a.createcorp where ~~   --多列交换

--增加主键
alter table tablename add constraint keyname primary key (columnName) enable validate; 
--删除主键
alter table tablename drop constraint keyname;