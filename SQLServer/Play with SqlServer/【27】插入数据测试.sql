--Create table
if(object_id('testa','U') is not null) drop table testa;
create table testa (
id int not null identity(1,1) primary key,
val varchar(200) not null 
constraint testa$BPK_AK_Key unique nonclustered(val));

--Query
declare @v varchar(200)=newid();
if ((select count(1) from testa where val=@v)=0)
insert into testa(val) select @v;
else
return
---------------


select count(1) from testa;

select top 10 * from testa;
/*测试：
30000iterations * 1threads 07：16s second/iterations=0.0100
10000iterations * 3threads 03：21s second/iterations=0.0124
5000iterations * 6threads 02：35s second/iterations=0.0191
1000iterations * 30threads 01：41s second/iterations=0.0574
*/

truncate table testa;

----------------------------
--Query(merge)
declare @v varchar(200)=newid();
if ((select count(1) from testa where val=@v)=0)
insert into testa(val) select @v;
else
return
--10000iterations * 3threads 03：00s
--效率提升

--Query
declare @tb table (v varchar(200));
insert into @tb values
(newid()),(newid()),(newid()),(newid()),(newid()),(newid()),(newid()),(newid()),(newid()),(newid());
select * from @tb;

if ((select count(1) from testa where val=@v)=0)
insert into testa(val) select newid();
else
return
---------------

--增加线程数量，单节点速度减慢，总进度加速。