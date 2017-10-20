--需求：求一串数据的中位数，若共有偶数个数据则取中间两个数的平均值

create table ta (sc int)

insert into ta values(80),(90),(81),(72),(55),(60);-- 偶数条

mysql> select * from ta order by sc;
+------+
| sc   |
+------+
|   55 |
|   60 |
|   72 |
|   80 |
|   81 |
|   90 |
+------+
6 rows in set (0.00 sec)

-- 基本实现
SELECT avg(t1.sc) as median_val FROM ( 
SELECT @rownum:=@rownum+1 as row_number, d.sc 
FROM ta d, (SELECT @rownum:=0) r 
WHERE 1 
ORDER BY d.sc
) as t1, 
( 
SELECT count(*) as total_rows 
FROM ta d 
WHERE 1  
) as t2 
WHERE 1 
AND t1.row_number in ( floor((total_rows+1)/2), floor((total_rows+2)/2) );
+------------+
| median_val |
+------------+
|    76.0000 |
+------------+
1 row in set (0.03 sec)

-- 增加筛选字段
alter table ta add na varchar(10);

update ta set na='Bai' where mod(sc,2)=0;
update ta set na='Hei' where mod(sc,2)=1;

mysql> select * from ta order by na,sc;
+------+------+
| sc   | na   |
+------+------+
|   60 | Bai  |
|   72 | Bai  |
|   80 | Bai  |
|   90 | Bai  |
|   55 | Hei  |
|   81 | Hei  |
+------+------+
6 rows in set (0.00 sec)

-- 最终实现
SELECT t1.na,
avg(t1.sc) as median_val FROM ( 
SELECT case when @na<>na then @rownum:=1 else @rownum:=@rownum+1 end as row_number, d.sc ,@na:=d.na na
FROM (SELECT @rownum:=0) r ,
(select @na:='' ) n,
ta d
WHERE 1 
ORDER BY d.na,d.sc
) as t1, 
( 
SELECT na,count(*) as total_rows 
FROM ta d 
WHERE 1 
group by na 
) as t2 
WHERE 1 
and t1.na=t2.na
AND t1.row_number in ( floor((total_rows+1)/2), floor((total_rows+2)/2) )
group by t1.na;
+------+------------+
| na   | median_val |
+------+------------+
| Bai  |    76.0000 |
| Hei  |    68.0000 |
+------+------------+
2 rows in set (0.02 sec)
