```sql
# text LENGTH
#TINYTEXT: 256 bytes
#TEXT: 65,535 bytes => ~64kb
#MEDIUMTEXT: 16,777,215 bytes => ~16MB
#LONGTEXT: 4,294,967,295 bytes => ~4GB



select version();
# 5.7.17

create table testTB (id int not null primary key,
val text not null);

select * from testTB;

#create readom string FUNCTION
CREATE FUNCTION `rand_string`(n INT) RETURNS varchar(4096) 
BEGIN
    DECLARE chars_str varchar(100) DEFAULT 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    DECLARE return_str varchar(4096) DEFAULT '';
    DECLARE i INT DEFAULT 0;
    WHILE i < n DO
        SET return_str = concat(return_str,substring(chars_str , FLOOR(1 + RAND()*62 ),1));
        SET i = i +1;
    END WHILE;
    RETURN return_str;
END;

#TEST
select rand_string(200);


insert into testTB(id,val) values(1,rand_string(4096));

select * from testTB;

#循环执行，直到插入不了
update testTB set val=concat(val,rand_string(4096));
/*
[SQL]update testTB set val=concat(val,rand_string(4096));
[Err] 1406 - Data too long for column 'val' at row 1
*/
select LENGTH(val) from testTB; -- 61440

alter table testTB modify column val MEDIUMTEXT not NULL;
/*
受影响的行: 1
时间: 0.082s
*/
update testTB set val=concat(val,val);

select LENGTH(val) from testTB; -- 2686976

drop FUNCTION rand_string；
drop table testTB;


-----------------------------------
select version();
# 5.5.54-0ubuntu0.12.04.1

create table testTB (id int not null primary key,
val text not null);

#create readom string FUNCTION
CREATE FUNCTION `rand_string`(n INT) RETURNS varchar(4096) 
BEGIN
    DECLARE chars_str varchar(100) DEFAULT 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    DECLARE return_str varchar(4096) DEFAULT '';
    DECLARE i INT DEFAULT 0;
    WHILE i < n DO
        SET return_str = concat(return_str,substring(chars_str , FLOOR(1 + RAND()*62 ),1));
        SET i = i +1;
    END WHILE;
    RETURN return_str;
END;

insert into testTB(id,val) values(1,rand_string(4096));

#循环执行，直到插入不了
update testTB set val=concat(val,rand_string(4096));
/* 受影响的行: 0
时间: 0.127s*/
#######超限制不报错
select * from testTB;
select LENGTH(val) from testTB; -- 65535

alter table testTB modify column val MEDIUMTEXT not NULL;
/*
受影响的行: 1
时间: 0.031s
*/
update testTB set val=concat(val,val);
/*受影响的行: 0
时间: 0.018s
*/
select LENGTH(val) from testTB;-- 0
-- 超限会置空

drop FUNCTION rand_string；
drop table testTB;

------------------------
results:mysql5.5和5.7都可以直接变更字段。需要留意的是，mysql5.5中，当更新字段长度超过MEDIUMTEXT字段允许最大长度时，字段将会被更新为NULL。
```