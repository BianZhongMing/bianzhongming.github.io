```sql
create table testbzm (
id int primary key,
uname varchar(10),
UPDATE_TIME TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP 
)

insert into testbzm(id,uname) values(1,'xm') 

select * from testbzm 
-- 1	xm	2017-02-21 11:26:59

update testbzm set uname='xm' where id=1
# 受影响的行: 0

select * from testbzm 
-- 1	xm	2017-02-21 11:26:59
```
