--CTE 递归使用DEMO

--解决问题 1：递归计算职级
create table testbzm (
id int, --本人ID
name varchar(10), --姓名
position varchar(10),--职务
upid int --上级ID
)

--插入简单测试数据
insert into testbzm values
(1,'Tom','Sales',4),
(2,'Jim','Sales',4),
(3,'Sam','Sales',5),
(4,'Jirry','Manager',6),
(5,'Lily','Manager',6),
(6,'Tomas','CEO',NULL)



with cte as (
--起始条件
select id,name,position,cast(0 as int) pLevel from testbzm a where upid is null
union all
--CTE每次递归条件
select a.id,a.name,a.position,cte.pLevel+1 pLevel from testbzm a,cte/*CTE需要明确写在from表中*/ where a.upid=cte.id
)

select * from cte
--递归次数限制：不做指定，最大递归100次
--指定OPTION(MAXRECURSION number)：number=0 不做任何限制，否则限制递归number次


--解决问题 2：循环问题（不用指针）
/*
A	B	    C
1	2.05	3.14
2	9.1	    =B2*C1=28.574
3	2.74	=B3*C2=78.29276
 ……
*/
create table testbzm(
a int,
b decimal(20,8)
)

insert into testbzm values(1,2.05),(2,9.1),(3,2.74)

with cte_test(a,b,c)/*去掉(a,b,c)直接写cte_test 也可以*/ as (
select a,b,cast(3.14 as decimal(20,8)) c from testbzm a where a=1
union all
select a.a,a.b,cast(a.b*ct.c as decimal(20,8)) c from testbzm a,cte_test ct where a.a=ct.a+1 and a.a<>1
)--注意C列的数据格式要做强转，否则会报错
select * from cte_test --OPTION(MAXRECURSION 0)
/*
1	2.05000000	3.14000000
2	9.10000000	28.57400000
3	2.74000000	78.29276000
*/

drop table testbzm