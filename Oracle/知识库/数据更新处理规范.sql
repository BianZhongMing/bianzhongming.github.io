---总则：
0.先备份，后处理（大表进行部分备份，注意备份pk，能一一对应进行还原）
1.涉及运算处理
    (1)注意对null进行单独处理后再进行(NULL进行计算/in 后结果都为NULL/FALSE)  处理方法：nvl(a.x,0)/no in改成not exists
    (2)除法注意0  decode(nvl(a.x,0),0,'',A/nvl(a.x,0))
    (3)注意负数，小数
2.不重复，不遗漏（整行的数据，select出来的字段都要进行筛查）
3.存在逻辑关系的数据一定要进校验，不能全部进行逻辑校验的数据至少要进行部分验证
4.not in的目标中若存在空格，则匹配不出结果
5.Excel数据迁移导入规范：分列-->txt粘贴处理-->设置单元格文本格式-->粘贴-->另存CSV
-----------------

drop table tmpbzm purge;
--导入临时表
create table tmpBZM
(
  vbatchcode          VARCHAR2(30),
    vdef25              VARCHAR2(100)
);

--行数验证
select count(*) from tmpBZM;

--建立索引
create index tmpBZM_i_10 on tmpBZM(vbatchcode) parallel nologging;
alter index tmpBZM_i_10  noparallel;

--查询重复记录
Select t.rowid, t.vbatchcode
  From tmpBZM t
 Where vbatchcode In
       (Select vbatchcode From tmpBZM Group By vbatchcode Having Count(*) > 1)
 order by t.vbatchcode;
/*--保留一条(去重复)
Delete tmpBZM t  --利用rowid，快
 Where t.rowid in ('AAYGORABiAABvfYACv');*/
 ----------------
 删除表中多余的重复记录，重复记录是根据单个字段（Id）来判断，只留有rowid最小的记录
DELETE from 表 WHERE (id) IN ( SELECT id FROM 表 GROUP BY id HAVING COUNT(id) > 1) AND ROWID NOT IN (SELECT MIN(ROWID) FROM 表 GROUP BY id HAVING COUNT(*) > 1);
 -----------------
 
--确定数据不遗漏
select a.allnum, b.innum
  from (select count(*) allnum from tmpBZM) a,
       (select count(*) innum
          from tmpBZM
         where vbatchcode in (select vbatchcode from ts_batchcode)) b;
--485	484  修改后485	485
/*--查看存在差异条码
select a.vbatchcode from tmpBZM a
where a.vbatchcode not in (select b.vbatchcode from ts_batchcode b where a.vbatchcode=b.vbatchcode) for update*/

--条件备份  20150107zppl.tsv
select vbatchcode,vdef25
  from ts_batchcode
 where vbatchcode in (select vbatchcode from tmpBZM);

--更新数据
UPDATE ts_batchcode a
 SET a.vdef25 = (select b.vdef25 from tmpBZM b where b.vbatchcode=a.vbatchcode)
where a.vbatchcode in (select vbatchcode
                from tmpBZM );
--验证
select b.docname,a.vdef25 from ts_batchcode a,bd_defdoc b where vbatchcode = '601130103090' and a.vdef25=b.PK_DEFDOC;
--提交
commit;
drop table tmpBZM purge;

