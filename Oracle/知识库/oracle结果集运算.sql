--oracle结果集运算
--【+】 union(去重拼接，默认规则排序) ,union all（直接拼接，不排序）
select d.unitname,  d.unitcode from bd_corp d where d.unitcode in ('J001','J002','J003') 
union
select d.unitname,  d.unitcode from bd_corp d where d.unitcode in ('J001','J002','J003');

select d.unitname,  d.unitcode from bd_corp d where d.unitcode in ('J001','J002','J003') 
union all
select d.unitname,  d.unitcode from bd_corp d where d.unitcode in ('J001','J002','J003');

--【-】intersect<取交集>(去异存同，去重，默认规则排序)，minus<有顺序>(A-B,默认规则排序)
select d.unitname,  d.unitcode from bd_corp d where d.unitcode in ('J001','J002','J003') 
intersect
select d.unitname,  d.unitcode from bd_corp d where d.unitcode in ('J001','J002','J004');

select d.unitname,  d.unitcode from bd_corp d where d.unitcode in ('J001','J002','J003') 
minus
select d.unitname,  d.unitcode from bd_corp d where d.unitcode in ('J001','J002','J004');
