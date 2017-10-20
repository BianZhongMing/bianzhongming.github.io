with seed as (
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
)

select s1.num*10+s2.num as n
 from 
seed s1
cross join seed s2
order by n