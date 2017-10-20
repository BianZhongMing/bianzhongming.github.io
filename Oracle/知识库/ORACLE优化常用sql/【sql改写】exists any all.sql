/*--创建测试表
create table TT
( ta VARCHAR2(10),
  tb VARCHAR2(10) );

create table TT1
( ta VARCHAR2(10),
  tb VARCHAR2(10) );

insert into TT (ta, tb)
values ('1', '11');
insert into TT (ta, tb)
values ('2', '22');
insert into TT (ta, tb)
values ('3', '33');
insert into TT (ta, tb)
values ('4', '44');
commit;
prompt 4 records loaded
prompt Loading TT1...
insert into TT1 (ta, tb)
values ('1', 'A');
insert into TT1 (ta, tb)
values ('2', 'B');
insert into TT1 (ta, tb)
values ('3', 'C');
insert into TT1 (ta, tb)
values (null, 'D');
commit;
*/
1.(NOT) EXISTS / (NOT) IN
语法： (NOT) EXISTS subquery
参数： subquery 是一个受限的 SELECT 语句 (不允许有 COMPUTE 子句和 INTO 关键字)。
结果类型： Boolean 如果子查询包含行，则返回 TRUE ，否则返回 FLASE 。（行的结果为NULL的也是属于包含行的）
区别：
(1)允许列数/字段数不同: in (select ta from tt)/ exist (select ta,tb from tt)
(2)驱动表不同(执行顺序不同，效率不同)：in内表驱动，exists外表驱动
(3)通常情况下采用exists要比in效率高，因为IN不走索引。
(4)如果在not in子查询中有null值的时候,则不会返回数据。not exists会返回正确的值
select * from tt where ta not in (select ta from tt1 ); --没结果
select * from tt a where not exists (select null from tt1 b where a.ta=b.ta);--4	44
(5)exists运行过程
》分析器找到关键字SELECT》跳到FROM关键字将外表导入内存，并通过指针找到第一条记录
》接着找到WHERE关键字计算它的条件表达式，如果为真那么把这条记录装到一个虚表当中，指针再指向下一条记录。
如果为假那么指针直接指向下一条记录，而不进行其它操作。一直检索完整个表，并把检索出来的虚拟表返回给用户。
EXISTS是条件表达式的一部分，它也有一个返回值(true或false)。

2.作用
(1)SQL改写调优
    ①in<=>exists IN适合于外表大而内表小或枚举常量的情况；EXISTS适合于外表小而内表大的情况。
    ②distinct<=>exists exists逐行判断优于distinct--【注意：不完全等价】
    select distinct tt.ta from tt,tt1 where tt.ta=tt1.ta;--等价前提为tt.ta因为和tt1.ta关联(一对多)导致重复，tt.ta本身不存在重复
    select ta from tt where exists(select 1 from tt1 where tt1.ta=tt.ta);--better
    ②用表连接替换exists：通常来说，采用表连接的方式比exists更有效率。 --【注意：不完全等价】
    select a.ta from tt a where exists (select 1 from tt1 b where a.ta=b.ta)--若a.ta关联存在重复会去重复，原理同2
    select a.ta from tt a,tt1 b where a.ta=b.ta--better
(2)避免not in陷阱(使用 not exists替代)

3.其他等价情况(比较列没有空值的情况下)
delete from tt1 where ta is null;
--ALL<>MAX()
SELECT * FROM TT WHERE TA > ALL(SELECT ta FROM tt1);
SELECT * FROM TT WHERE TA > (SELECT MAX(ta) FROM tt1);

--ANY<>MIN()
SELECT * FROM TT WHERE TA > ANY(SELECT ta FROM tt1);
SELECT * FROM TT WHERE TA > (SELECT MIN(ta) FROM tt1);

--=ANY<>IN
SELECT * FROM TT WHERE TA = ANY(SELECT ta FROM tt1);
SELECT * FROM TT WHERE TA IN (SELECT ta FROM tt1);

