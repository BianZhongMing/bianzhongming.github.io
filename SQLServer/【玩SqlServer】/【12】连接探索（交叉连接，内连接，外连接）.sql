select * into #t1 from (
select 0 num union all
select 1 num union all
select 2 num union all
select 3 num union all
select 4 num union all
select 5 num union all
select 6 num union all
select 7 num union all
select 8 num union all
select 9 num
) T;
select * into #t2 from (
select 0 num union all
select 1 num union all
select 2 num union all
select 3 num union all
select 4 num union all
select 5 num 
) T;

--CROSS JOIN
select * from #t1 a cross join #t2 b;--cartesian product

--JOIN
select a.num as anum ,b.num as bnum from #t1 a join #t2 b on a.num=b.num
--实现步骤拆解
select * from (
select  a.num as anum ,b.num as bnum from #t1 a cross join #t2 b --Step 1 :cartesian product
) T
where anum=bnum --Step2 :filter
;

--outer join
select a.num as anum ,b.num as bnum from #t1 a left outer join #t2 b on a.num=b.num
--实现步骤拆解
select * from (
select  a.num as anum ,b.num as bnum from #t1 a cross join #t2 b --Step 1 :cartesian product
) T
where anum=bnum --Step2 :filter
union all
-- Step3 : add outer column
select A.num anum, NULL bnum from #t1 A where a.num not in ( select anum from (
select  a.num as anum ,b.num as bnum from #t1 a cross join #t2 b --Step 1 :cartesian product
) T
where anum=bnum --Step2 :filter
);


--下面外连接的结果以及生产逻辑
select * from #t1 a left join #t2 b on (a.num=b.num and b.num=1);
select * from #t1 a left join #t2 b on (a.num=b.num and a.num=1);
select * from #t1 a left join #t2 b on (a.num=b.num and a.num=1 and b.num=2);
select * from #t1 a left join #t2 b on (a.num=b.num and a.num=1 and b.num=1);
--因为需要添加外部行，所以#t1的过滤条件无法真正对#t1进行过滤，若要过滤需要在where条件里面再增加一层过滤

select * from #t1 a left join #t2 b on (a.num=b.num and a.num=1 and b.num=1);
--实现步骤拆解
select * from (
select  a.num as anum ,b.num as bnum from #t1 a cross join #t2 b --Step 1 :cartesian product
) T
where anum=bnum and anum=1 and bnum=1--Step2 :filter
union all
-- Step3 : add outer column
select A.num anum, NULL bnum from #t1 A where a.num not in ( select anum from (
select  a.num as anum ,b.num as bnum from #t1 a cross join #t2 b --Step 1 :cartesian product
) T
where anum=bnum and anum=1 and bnum=1--Step2 :filter
);


---------------------外连接外部行被过滤问题
select * from #t1 a left join #t2 b on a.num=b.num join #t2 c on c.num=b.num
--原SQL，由于后一步join涉及到对b.num的过滤，而a添加的外部行的b表字段的占位符是NULL，会被过滤掉

select * from #t2 b join #t2 c on c.num=b.num right join #t1 a on a.num=b.num --way1
select * from #t1 a left join (#t2 b join #t2 c on c.num=b.num) on a.num=b.num --way2