create table T
(
  unitname VARCHAR2(200) not null,
  unitcode VARCHAR2(40) 
)

--插入数据方式
--way 1
insert into t (select unitname,unitcode from bd_corp);
--way 2
insert into t (unitname,unitcode) values('J001','001');--只能单条插入数据，values后不能用select
--缺省字段
insert into t (unitname) (select unitname from bd_corp);  insert into t (unitname) values('J001');--可以操作，未插入字段默认NULL
insert into t (unitcode) (select unitcode from bd_corp); insert into t (unitcode) values('001');--不可操作，因为字段属性not null

drop table t purge;



